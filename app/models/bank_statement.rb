class BankStatement < ActiveRecord::Base
  require 'csv'
  require 'strscan'
  require 'date'
  has_many :bank_statement_line_items,:dependent => :destroy
  belongs_to :account

 attr_accessible :account_id, :start_date, :end_date, :file, :company_id, :created_by, :bank_statement_line_items_attributes,:account_no
 accepts_nested_attributes_for :bank_statement_line_items, :allow_destroy => true

 validates_presence_of :start_date, :end_date, :account_id
 validate :start_date_and_end_date_validation
 # validates_presence_of :bank_statement_line_items
 # validates_associated :bank_statement_line_items
 has_attached_file :file,
                    :storage=>:s3,
                    :s3_credentials=>"#{Rails.root}/config/s3.yml",
                    :url => ":s3_domain_url",
                    :path => "/uploaded_data/:class/:id/:basename.:extension"

validates_attachment_content_type :file, :content_type => ['text/csv','application/vnd.ms-excel'],
                                  :message=>" must be of .csv type",
                                  :allow_nil => true
validates_attachment_presence :file

  def self.bank_name(bank_name)
      string = bank_name
       if /sbi|state bank of india|sbi bank|s.b.i/i.match(string)
        @BANKNAME = 1
      elsif /icici|icici bank|i.c.i.c.i|i.c.i.c.i bank/i.match(string)
        @BANKNAME = 2
        elsif /idbi|idbi bank|i.d.b.i|i.d.b.i bank/i.match(string)
        @BANKNAME = 3
      elsif /canara|canara bank/i.match(string)
        @BANKNAME = 4
      else
        @message = "Bank Not Found !!!"
       end
       @BANKNAME
  end

  def start_date_and_end_date_validation
      if !start_date.blank? && !end_date.blank?
         valid = start_date && end_date && start_date < end_date
         errors.add(:start_date, "must be before end date") unless valid
     end

  end

   def self.date_validation

   end

   def date

         valid = BankStatement must  && end_date && start_date < end_date
         errors.add(:start_date, "must be before end date") unless valid

   end

  def file_name
    file_file_name
  end

  def file_size
    file_file_size
  end

  def get_account_name(account_id)
    Account.find_by_id_and_accountable_type(account_id,'BankAccount')
  end

  def self.get_bank
    BANK
  end

  def self.convert_date(bank,date)
   if !date.blank?
    bank_name = bank.to_i
    if bank_name == 2 || bank_name == 4
      date1 = Date.strptime(date, "%d/%m/%Y")
    elsif bank_name == 1
      date1 = Date.strptime(date, "%d %b %Y")
    elsif bank_name == 3
      date1 = Date.strptime(date, "%d/%m/%y")
    end
  end
    date1
  end

  def self.create_deposit(params, company, user, fyr)
      deposit = Deposit.new
      deposit.company_id = company
      deposit.created_by = user.id
      deposit.from_account_id = Account.get_account_id(params[:from_account_name], company)
      deposit.to_account_id = Account.get_account_id(params[:to_account_name], company)
      deposit.branch_id = user.branch_id unless user.branch_id.blank?
      deposit.fin_year = fyr
      deposit
  end

  class << self
    def read_file(bank_id,bank_statement)
       result=0
      if bank_id != 7
       result= self.for_bank(bank_id,bank_statement)
      else
       result=2
      end
    end

    def for_bank(bank_id,bank_statement)
      start_date = bank_statement.start_date
      end_date = bank_statement.end_date
      account_id = bank_statement.account_id
      company_id = bank_statement.company_id
      escaped_transactions = []
      rows = CSV.parse(open(bank_statement.file.url))
      column_count=10
      row,column,date_format = match_string(rows,bank_id,column_count)
      puts row
      puts column
      records=[]
      if [row[1],row[2],row[3],row[4],row[5]].uniq.length==1
        first_row= row[column[0].join.to_i].join.to_i 
        #rows.each do |row|
        handler = open(bank_statement.file.url)
        csv_string = handler.read.encode('UTF-8', {:invalid => :replace,:undef   => :replace,:replace => ''})


        CSV.parse(csv_string).each_with_index do |csv,index|
        if index > first_row  && index < rows.count && !csv[column[0].join.to_i].nil?
               begin
                if bank_id == 1
                  date= !csv[column[0].join.to_i].nil? ? Date.strptime(csv[column[0].join.to_i].encode("UTF-8"), date_format.to_s) :0
                  value_date = !csv[column[1].join.to_i].nil? ? Date.strptime(csv[column[1].join.to_i].encode("UTF-8"),date_format.to_s) :0
                  description = !csv[column[2].join.to_i].nil? ? csv[column[2].join.to_i].encode("UTF-8") :0
                  cheque_reference = !csv[column[3].join.to_i].nil? ? csv[column[3].join.to_i].encode("UTF-8") : "-"
                  amount=  csv[column[4].join.to_i].strip !="" ? csv[column[4].join.to_i].encode("UTF-8").gsub(/,/, '').to_f : csv[column[5].join.to_i].gsub(/,/, '').to_f
                  credit_debit= csv[column[4].join.to_i].strip !="" ? 0 : 1
                  account_balance = !csv[column[6].join.to_i].nil? ? csv[column[6].join.to_i].gsub(/,/, '').to_f : 0
                  records << [date,description,cheque_reference,value_date,amount,credit_debit,account_balance]
                elsif bank_id == 2
                  date= !csv[column[0].join.to_i].nil? ? Date.strptime(csv[column[0].join.to_i].encode("UTF-8"),date_format.to_s) :0
                  value_date = !csv[column[0].join.to_i].nil? ? Date.strptime(csv[column[0].join.to_i].encode("UTF-8"),date_format.to_s) :0
                  cheque_reference = !csv[column[1].join.to_i].nil? ? csv[column[1].join.to_i].encode("UTF-8") : "-"
                  description = !csv[column[2].join.to_i].nil? ? csv[column[2].join.to_i].encode("UTF-8") :0
                  if  !csv[column[4].join.to_i].nil? || !csv[column[3].join.to_i].nil?
                  amount=  !csv[column[4].join.to_i].nil? ? csv[column[4].join.to_i].encode("UTF-8").gsub(/,/, '').to_f : csv[column[3].join.to_i].gsub(/,/, '').to_f
                  credit_debit=  csv[column[4].join.to_i].nil? ? 1 : 0
                 else
                  amount=  0
                 end
                  account_balance = !csv[column[5].join.to_i].nil? ? csv[column[5].join.to_i].gsub(/,/, '').to_f : 0
                  records << [date,description,cheque_reference,value_date,amount,credit_debit,account_balance]

                elsif bank_id == 3
                  date= !csv[column[0].join.to_i].nil? ? Date.strptime(csv[column[0].join.to_i].encode("UTF-8"),date_format.to_s) :0
                  description = !csv[column[1].join.to_i].nil? ? csv[column[1].join.to_i].encode("UTF-8") : "-"
                  cheque_reference = !csv[column[2].join.to_i].nil? ? csv[column[2].join.to_i].encode("UTF-8") : "-"
                  value_date = !csv[column[3].join.to_i].nil? ? Date.strptime(csv[column[3].join.to_i].encode("UTF-8"),date_format.to_s) :0
                  amount=  !csv[column[4].join.to_i].nil? ? csv[column[4].join.to_i].encode("UTF-8").gsub(/,/, '').to_f : csv[column[5].join.to_i].gsub(/,/, '').to_f
                  credit_debit=  !csv[column[4].join.to_i].nil? ? 0 : 1
                  account_balance = !csv[column[6].join.to_i].nil? ? csv[column[6].join.to_i].gsub(/,/, '').to_f : 0
                  records << [date,description,cheque_reference,value_date,amount,credit_debit,account_balance]
                elsif bank_id == 4
                  date= !csv[column[0].join.to_i].nil? ? Date.strptime(csv[column[0].join.to_i].encode("UTF-8"),date_format.to_s) :0
                  description = !csv[column[1].join.to_i].nil? ? csv[column[1].join.to_i].encode("UTF-8") :0
                  cheque_reference = !csv[column[2].join.to_i].nil? ? csv[column[2].join.to_i].encode("UTF-8") : "-"
                  value_date = !csv[column[0].join.to_i].nil? ? Date.strptime(csv[column[0].join.to_i].encode("UTF-8"),date_format.to_s) :0
                  amount=  !csv[column[4].join.to_i].nil? ? csv[column[4].join.to_i].encode("UTF-8").gsub(/,/, '').to_f : csv[column[5].join.to_i].gsub(/,/, '').to_f
                  credit_debit=  !csv[column[4].join.to_i].nil? ? 0 : 1
                  account_balance = !csv[column[6].join.to_i].nil? ? csv[column[6].join.to_i].gsub(/,/, '').to_f : 0
                  records << [date,description,cheque_reference,value_date,amount,credit_debit,account_balance]
                elsif bank_id == 8
                  date= !csv[column[0].join.to_i].nil? ? Date.strptime(csv[column[0].join.to_i].encode("UTF-8"),date_format.to_s) :0
                  value_date = !csv[column[0].join.to_i].nil? ? Date.strptime(csv[column[0].join.to_i].encode("UTF-8"),date_format.to_s) :0
                  cheque_reference = !csv[column[1].join.to_i].nil? ? csv[column[1].join.to_i].encode("UTF-8") : "-"
                  description = !csv[column[2].join.to_i].nil? ? csv[column[2].join.to_i].encode("UTF-8") : "-"
                  amount=  csv[column[3].join.to_i].strip !="" ? csv[column[3].join.to_i].encode("UTF-8").gsub(/,/, '').to_f : csv[column[4].join.to_i].gsub(/,/, '').to_f  
                  credit_debit=  csv[column[3].join.to_i].strip =="" ? 1 : 0
                  account_balance = !csv[column[5].join.to_i].nil? ? csv[column[5].join.to_i].gsub(/,/, '').to_f : 0
                  records << [date,description,cheque_reference,value_date,amount,credit_debit,account_balance]
                elsif bank_id == 9
                  date= !csv[column[0].join.to_i].nil? ? Date.strptime(csv[column[0].join.to_i].encode("UTF-8"),date_format.to_s) :0
                  value_date = !csv[column[1].join.to_i].nil? ? Date.strptime(csv[column[0].join.to_i].encode("UTF-8"),date_format.to_s) :0
                  cheque_reference = !csv[column[2].join.to_i].nil? ? csv[column[2].join.to_i].encode("UTF-8") : "-"
                  description = !csv[column[3].join.to_i].nil? ? csv[column[3].join.to_i].encode("UTF-8") : "-"
                  
                  if csv[column[4].join.to_i]=="DR"
                  amount=   csv[column[5].join.to_i].encode("UTF-8").gsub(/,/, '').to_f 
                  credit_debit= 0
                else
                  amount=   csv[column[5].join.to_i].encode("UTF-8").gsub(/,/, '').to_f 
                  credit_debit= 1
                end
                  account_balance = !csv[column[6].join.to_i].nil? ? csv[column[6].join.to_i].gsub(/,/, '').to_f : 0
                  records << [date,description,cheque_reference,value_date,amount,credit_debit,account_balance]

                elsif bank_id == 5
                  date= !csv[column[0].join.to_i].nil? ? Date.strptime(csv[column[0].join.to_i].encode("UTF-8"),date_format.to_s) :0
                  value_date = !csv[column[0].join.to_i].nil? ? Date.strptime(csv[column[0].join.to_i].encode("UTF-8"),date_format.to_s) :0
                  description = !csv[column[1].join.to_i].nil? ? csv[column[1].join.to_i].encode("UTF-8") :0
                  cheque_reference = !csv[column[2].join.to_i].nil? ? csv[column[2].join.to_i].encode("UTF-8") : "-"
                  if csv[column[3].join.to_i]=="DR"
                  amount=   csv[column[4].join.to_i].encode("UTF-8").gsub(/,/, '').to_f 
                  credit_debit= 0
                else
                  amount=   csv[column[4].join.to_i].encode("UTF-8").gsub(/,/, '').to_f 
                  credit_debit= 1
                end
                  account_balance = !csv[column[5].join.to_i].nil? ? csv[column[5].join.to_i].gsub(/,/, '').to_f : 0
                  records << [date,description,cheque_reference,value_date,amount,credit_debit,account_balance]
                else

              end
              rescue
                     next
              end
        end

        end

      end
      records.each do |record|
          if (record[0] > start_date.to_date && record[0] > end_date.to_date) || (record[0] < start_date.to_date && record[0] < end_date.to_date)
            escaped_transactions << "Date Outside limit"
          elsif BankStatementLineItem.exists?(:company_id => company_id,:date => record[0], :account_id=>account_id, :amount=>record[4].to_f, :credit_debit_indicator=>record[5].to_i,:account_balance => record[6])            
            @bank_statement_line_items = BankStatementLineItem.new(:date => record[0], :account_id => account_id,:cheque_reference =>record[2],:value_date => record[3], :status => 2, :amount => record[4].to_f,:credit_debit_indicator => record[5].to_i,:description => record[1],:account_balance => record[6],:bank_statement_id => bank_statement.id,:company_id => bank_statement.company_id)
            @bank_statement_line_items.save
          elsif record[0] >= start_date.to_date && record[0] <= end_date.to_date
            @bank_statement_line_items = BankStatementLineItem.new(:date => record[0], :account_id => account_id,:cheque_reference =>record[2],:value_date => record[3],:status => 0, :amount => record[4].to_f,:credit_debit_indicator => record[5].to_i,:description => record[1],:account_balance => record[6],:bank_statement_id => bank_statement.id,:company_id => bank_statement.company_id)
            @bank_statement_line_items.save
          end

    end
       
      if escaped_transactions.count == records.count
        result = 0
      else
        result = 1
      end
      result
    end

    def  match_string(rows,bank_id,column_count)
          row=[]
          headers=BankStatementHeaders.find_by_bank_id(bank_id)
          if headers.bank_id==2
            column_count=60
          end
          date_format= headers.date_format
          column=[]
          for i in 0..(rows.count-1)
            for j in 0..(column_count-1)
              if !rows[i][j].nil? 
                 string= rows[i][j].scan(/[[:alpha:]]+/).count > 1 ? rows[i][j].gsub(/[^0-9a-z\\s]/i, '').to_s : rows[i][j].to_s.strip
               else
                  string="Nil"
              end
              search = StringScanner.new(string)
              search.match?(/#{remove_whitespace(headers.header_1)}$/)
              if search.matched?
                row << [i]
                column << [j]
              end
              search.match?(/#{remove_whitespace(headers.header_2)}$/)
              if search.matched?
                row << [i]
                column << [j] 
              end
              search.match?(/#{remove_whitespace(headers.header_3)}$/)
              if search.matched?
                row << [i]
                column << [j] 
              end
              search.match?(/#{remove_whitespace(headers.header_4)}$/)
              if search.matched?
                row << [i]
                column << [j] 
              end
              search.match?(/#{remove_whitespace(headers.header_5)}$/)
              if search.matched?
                row << [i]
                column << [j]
              end
              search.match?(/#{remove_whitespace(headers.header_6)}$/)
              if search.matched?
                row << [i]
                column << [j]
              end
              search.match?(/#{remove_whitespace(headers.header_7)}$/)
              if search.matched?
                row << [i]
                column << [j]
              end

            end
          end
        return row,column,date_format       
end

def remove_whitespace(string)
  if string.scan(/[[:alpha:]]+/).count > 1
    search=string.gsub(/[^0-9a-z\\s]/i, '').to_s
    
  else
    search=string.to_s

  end
  search
end

    def other_bank(statement_id,date,amount,description,credit,debit,account_balance)
      statement_id = statement_id
      date = date
      amount = amount
      description = description
      credit = credit
      debit = debit
      account_balance = account_balance
      bank_statement = BankStatement.find(statement_id)
      start_date = bank_statement.start_date
      end_date = bank_statement.end_date
      account_id = bank_statement.account_id
      company_id = bank_statement.company_id
      bank_id=7
      result = 0
      total_rows = 0
      rows = CSV.parse(open(bank_statement.file.url))
      column_count=10
      row,column,date_format = match_string(rows,bank_id,column_count)
      puts row
      puts column
      records=[]
      escaped_transactions = []
      if [row[1],row[2],row[3],row[4]].uniq.length==1
        first_row= row[column[0].join.to_i].join.to_i 
        handler = open(bank_statement.file.url)
        csv_string = handler.read.encode('UTF-8', {:invalid => :replace,:undef   => :replace,:replace => ''})

      CSV.parse(csv_string).each_with_index do |csv,index|
        if index > first_row  && index < rows.count && !csv[column[0].join.to_i].nil?
             # begin
                  date= !csv[column[0].join.to_i].nil? ? Date.strptime(csv[column[0].join.to_i].encode("UTF-8").gsub(/\s|"|'/, ''), date_format.to_s) :0
                  value_date = !csv[column[0].join.to_i].nil? ? Date.strptime(csv[column[0].join.to_i].encode("UTF-8").gsub(/\s|"|'/, ''),date_format.to_s) :0
                  description = !csv[column[1].join.to_i].nil? ? csv[column[1].join.to_i].encode("UTF-8") : "-"
                  cheque_reference = "-"
                  begin
                  amount=  csv[column[2].join.to_i].strip !="" ? csv[column[2].join.to_i].encode("UTF-8").gsub(/,/, '').to_f : csv[column[3].join.to_i].gsub(/,/, '').to_f
                  credit_debit= csv[column[2].join.to_i].strip !="" ? 1: 0
                  rescue
                     amount=  !csv[column[2].join.to_i].nil? ? csv[column[2].join.to_i].encode("UTF-8").gsub(/,/, '').to_f : csv[column[3].join.to_i].gsub(/,/, '').to_f
                     credit_debit= !csv[column[2].join.to_i].nil? ? 1 : 0
                  end
                  account_balance = !csv[column[4].join.to_i].nil? ? csv[column[4].join.to_i].gsub(/,/, '').to_f : 0
                  records << [date,description,cheque_reference,value_date,amount,credit_debit,account_balance]     
              # rescue
              #        next
              # end
      
        end
      end
    end
      records.each do |record|
          if (record[0] > start_date.to_date && record[0] > end_date.to_date) || (record[0] < start_date.to_date && record[0] < end_date.to_date)
            escaped_transactions << "Date Outside limit"
          elsif BankStatementLineItem.exists?(:company_id => company_id,:date => record[0], :account_id=>account_id, :amount=>record[4].to_f, :credit_debit_indicator=>record[5].to_i,:account_balance => record[6])            
            @bank_statement_line_items = BankStatementLineItem.new(:date => record[0], :account_id => account_id,:cheque_reference =>record[2],:value_date => record[3], :status => 2, :amount => record[4].to_f,:credit_debit_indicator => record[5].to_i,:description => record[1],:account_balance => record[6],:bank_statement_id => bank_statement.id,:company_id => bank_statement.company_id)
            @bank_statement_line_items.save
          elsif record[0] >= start_date.to_date && record[0] <= end_date.to_date
            @bank_statement_line_items = BankStatementLineItem.new(:date => record[0], :account_id => account_id,:cheque_reference =>record[2],:value_date => record[3],:status => 0, :amount => record[4].to_f,:credit_debit_indicator => record[5].to_i,:description => record[1],:account_balance => record[6],:bank_statement_id => bank_statement.id,:company_id => bank_statement.company_id)
            @bank_statement_line_items.save
          end

      end
      if escaped_transactions.count == records.count
        result = 0
      else
        result = 1
      end

        result
    end

  end
end

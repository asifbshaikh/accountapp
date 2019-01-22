class JournalImport < ActiveRecord::Base
  include Sidekiq::Worker
  require 'date'
  require 'csv'
  require 'open-uri'
  belongs_to :import_file
  has_many :journal_import_line_items
  #STATUS = {0 => "Failed", 1 => "Success",2 => "Duplicate"}
  FAILED = 0
  SUCCESS = 1
  DUPLICATE = 2
  # @queue = :journal_imports_queue

  def perform(file_id,company_id,user_id,fyr)
    company = Company.find(company_id)
    user = User.find(user_id)
    imported_file = ImportFile.find(file_id)
    file = CSV.parse(open(imported_file.file.url).read)
    total_rows = file.size-1
    journal_import = nil
    journal = nil
    total = 0
    file.drop(1).each do |row|
      total += 1
      date = row[0]
      amount = row[2]
      credit_amount = row[3]

      # If all the rows are empty then one journal voucher is complete. Save it and overwrite any references
      if row[0].blank? && row[1].blank? && row[2].blank? && row[3].blank? && row[4].blank? && row[5].blank?
        if journal.valid?
          journal_import.status = SUCCESS
          journal.save_with_ledgers
        else
          journal_import.status = FAILED
        end
        journal_import.save!
        journal = nil
        journal_import = nil
      else
        begin
          date = fetch_date row[0]
          account_name = row[1].strip
          amount = convert_float(row[2])
          credit_amount = convert_float(row[3])
        rescue => e
        end
        account = Account.find_by_name_and_company_id(account_name,company.id)
        if !account.blank?
          account_id = account.id
        end
        # if there are no journal and journal import items then this is the start of a new journal voucher
        if journal == nil && journal_import == nil
          #create new journal import entry
          journal_import = JournalImport.new(:import_file_id => imported_file.id,
            :date => date, :created_by => user.id, :description => row[4],
            :tags => row[5])

          #create the new journal entry
          journal = Journal.new(:date => date,:description => row[4],:tags => row[5])
          journal.total_amount = 0
          #[FIXME] next_journal_number call should be encapsulated in journal voucher.
          journal.voucher_number = VoucherSetting.next_journal_number(company)
          journal.company_id = company.id
          journal.created_by = user.id
          journal.branch_id = user.branch_id unless user.branch_id.blank?
          journal.fin_year = fyr
        end

        #create the journal import line item
        journal_import_line_items = JournalImportLineItem.new(:journal_import_id => journal_import.id,
          :from_account_id => account_id, :amount => amount, :credit_amount => credit_amount)

        #create the journal line item
        journal_line_item = JournalLineItem.new(:journal_id => journal.id, :from_account_id => account_id,
          :amount => amount, :credit_amount => credit_amount)

        journal_import.journal_import_line_items << journal_import_line_items

        journal.total_amount += journal_line_item.amount unless journal_line_item.amount.blank?
        journal.journal_line_items << journal_line_item
        #the below code is for saving the last journal voucher in the CSV.
        if total == total_rows
          if journal.valid?
            journal_import.status = SUCCESS
            journal.save_with_ledgers
          else
            journal_import.status = FAILED
          end
          journal_import.save!
        end
      end
      imported_file.update_attributes(:status => SUCCESS)
    end
  end

    private

      def self.fetch_date(date_str)
        if date_str.index("-") >= 0
          Date.strptime(date_str, "%d-%m-%Y")
        elsif date_str.index("/") >= 0
          Date.strptime(date_str, "%d/%m/%Y")
        end
      end

      def self.convert_float(amt_str)
        amt_str.blank? ? 0 : amt_str.to_f
      end
end

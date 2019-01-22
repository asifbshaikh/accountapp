class Expense < ActiveRecord::Base
  include VoucherBase
  scope :by_branch_id, lambda {|id| where(:branch_id => id) unless id.blank? }
  scope :by_deleted, lambda {|del| where(:deleted => del)}
  scope :by_date, lambda{|fin_year| where(:expense_date => fin_year.start_date..fin_year.end_date) unless fin_year.blank?}
  scope :by_month, lambda{|month| where(:expense_date => month.beginning_of_month..month.end_of_month) unless month.blank?}
  scope :by_quarter, lambda{|quarter| where(:expense_date => quarter.beginning_of_month-3.month..quarter.end_of_month) unless quarter.blank?}
  scope :by_week, lambda{|week| where(:expense_date => week.beginning_of_week..week.end_of_week) unless week.blank?}
  scope :by_day,lambda{|day| where(:expense_date => day) unless day.blank?}
  scope :by_10day,lambda{|day| where(:expense_date => day) unless day.blank?}
  scope :by_monthwise,lambda{|day| where(:expense_date => day) unless day.blank?}
  scope :by_voucher, lambda{|voucher| where("voucher_number like ?", "%#{voucher}%") unless voucher.blank?}
  scope :by_project, lambda{|project| where(:project_id=>project) unless project.blank? }
  scope :by_date_range, lambda{|start_date, end_date| where(:expense_date=> start_date..end_date) unless start_date.blank? || end_date.blank? }
  scope :by_amount_range, lambda{|min_amt, max_amt| where(:total_amount=> min_amt..max_amt)}
  scope :by_account, lambda{|account| where(:account_id=>account) unless account.blank?}
  scope :by_created_by, lambda{|created_by| where(:created_by=>created_by) unless created_by.blank?}
  scope :by_status, lambda { |status| where(:status_id=>status)  }
  scope :by_credit_expenses, lambda { where(:credit_expense=>true)}
  scope :due_till_today, lambda { where("due_date <= ?", Time.zone.now.to_date ) }
  scope :records_by_filter, lambda { |params, user|  by_status(0).by_credit_expenses.by_account(params[:account_id]).due_till_today.by_branch_id(params[:branch_id])}
  scope :by_currency, lambda {|currency| where(:currency_id => currency) unless currency.blank?}
  scope :not_in, lambda { |expenses| where("id not in(?)", expenses.map { |e| e.id }) unless expenses.blank?}
  before_save :destroy_uploaded_file?
  attr_accessor :old_file_size
  has_many :expenses_payments, :conditions=>{:deleted=>[false, nil]}, :dependent=>:destroy
  has_many :payment_vouchers, :through=>:expenses_payments
  belongs_to :company
  belongs_to :account
  belongs_to :project
  has_many :ledgers, :as => :voucher, :dependent => :destroy
  has_many :expense_line_items, :conditions => {:type => "ExpenseLineItem"}, :dependent => :destroy
  has_many :tax_line_items, :class_name => "ExpenseLineItem", :conditions => {:type => nil} ,:dependent => :destroy
  accepts_nested_attributes_for :expense_line_items, :reject_if => lambda {|a| a[:account_id].blank? && a[:amount].blank? }, :allow_destroy => true
  accepts_nested_attributes_for :tax_line_items, :reject_if => lambda {|a| a[:account_id].blank? && a[:amount].blank? }, :allow_destroy => true

  attr_accessible :exchange_rate, :currency_id, :status_id, :credit_expense, :due_date, :total_amount,:expense_date, :customer_notes, :tags, :uploaded_file,
    :expense_line_items_attributes, :tax_line_items_attributes, :voucher_number, :deleted, :deleted_by, :deleted_datetime,:restored_by, :restored_datetime,
    :delete_uploaded_file, :account_id, :reverse_charge #, :project_id

 #validations
  validates_presence_of :expense_date, :account_id, :voucher_number
  validates_presence_of :due_date, :if=>lambda { |o| o[:credit_expense]==true }
  validates_uniqueness_of :voucher_number, :scope=>:company_id
  validates_presence_of :expense_line_items
  validates_associated :expense_line_items
  # validates_associated :tax_line_items,
  #                      :message => "fields with * are mandatory. You can remove the Tax line item if you don't want to enter the Tax amount."
  validate :storage_limit

  validates :exchange_rate, :numericality => {:greater_than=>0}, :presence=>true, :if => lambda{|e| !e.account.blank? && !e.account.get_currency_id.blank? && e.company.currency_code!=e.currency && e.credit_expense? }
  attr_accessor :skip_account_validation
  validate :validate_account_type, :if => :account_id, unless: :skip_account_validation
  validate :save_in_frozen_fy
  validate :account_effective_date
  attr_accessor :fin_year
  STATUS={1=>"Paid", 0=>"Unpaid"}
  STATE={true=>"new", false=>"edit"}

def itc_item
  item = Hash.new
  item[:igst] = 0
  item[:cgst] = 0
  item[:sgst] = 0
  self.expense_line_items.each do |itc|
  item[:eligibility] = itc.eligibility
  item[:igst] = itc.igst
  item[:cgst] = itc.cgst
  item[:sgst] = itc.sgst
    end
    item
 end

  def gst_line_items
    #create a hash with key as tax rate 
    #get the line item rate, check if the rate is present in hash
    #if not add a new gst_line_item_object to it
    #if present get the gst_line_item and add required fields to them
    items = Hash.new
    self.expense_line_items.each do |line_item|
      rate = line_item.gst_tax_rate
      if items.has_key? rate
        gst_tax_item = items[rate]
        gst_tax_item.add_txn_value(line_item.amount)
        gst_tax_item.add_igst_amt(line_item.igst_amt)
        gst_tax_item.add_cgst_amt(line_item.cgst_amt)
        gst_tax_item.add_sgst_amt(line_item.sgst_amt)
      else
        items[rate] = GstExpenseLineItem.new(rate, line_item.amount, line_item.igst_amt, line_item.cgst_amt, line_item.sgst_amt)
      end
    end
    items.values
  end

def  nil_rated_account(expense)
    
        nil_account= false
        
        if expense.tax_line_items.blank?
               nil_account = true
        else
          expense.tax_line_items.each do |line_item|
             nil_account = true if line_item.account.name.include?("@Nil") || line_item.account.name.include?("@Zero") 
           end
         end
          
          nil_account
   end
 
 def customer_state
    if vendor.present?
      state = vendor.get_state
    else
      state = customer.get_state
    end
  end

  def customer_name
     account.name
  end

  def cash_in_hand?
     account.accountable_type.include?("CashAccount")
  end


  def voucher_date
    expense_date
  end

  def sub_total
    expense_line_items.sum(:amount)
  end

  def igst_tax_amt
    @igst_tax_amt ||= calc_igst_tax_amt
  end

  def cgst_tax_amt
    @cgst_tax_amt ||= calc_cgst_tax_amt
  end

  def sgst_tax_amt
    @sgst_tax_amt ||= calc_sgst_tax_amt
  end


  def calc_igst_tax_amt
    igst_tax_amt = 0
    tax_line_items.each do |line_item|
      #Rails.logger.debug "Expense==========#{line_item.account.name} #{line_item.amount}======"
      act_name = line_item.account.name
      if act_name.include? "IGST"
        igst_tax_amt += line_item.amount
      end
    end
    igst_tax_amt
  end

  def calc_cgst_tax_amt
    cgst_tax_amt = 0
    tax_line_items.each do |line_item|
      #Rails.logger.debug "Expense==========#{line_item.account.name} #{line_item.amount}======"
      act_name = line_item.account.name
      if act_name.include? "CGST"
        cgst_tax_amt += line_item.amount
      end  
    end
    cgst_tax_amt
  end

  def calc_sgst_tax_amt
    sgst_tax_amt = 0
    tax_line_items.each do |line_item|
      #Rails.logger.debug "Expense==========#{line_item.account.name} #{line_item.amount}======"
      act_name = line_item.account.name
      if act_name.include? "SGST"
        sgst_tax_amt += line_item.amount
      end  
    end
    sgst_tax_amt
  end

   def cgst
     amt=0
    self.tax_line_items.each do |line_item|
       tax_account = line_item.account
       next if (tax_account.accountable_type=='DutiesAndTaxesAccounts' && tax_account.accountable.calculation_method==4 && tax_account.accountable.split_tax == 0 && !tax_account.name.include?("CGST"))
       if tax_account.name.include?("CGST")
            amt+= line_item.amount
       end
    end   
    amt
  end


  def sgst
     amt=0
    self.tax_line_items.each do |line_item|
       tax_account = line_item.account
       next if (tax_account.accountable_type=='DutiesAndTaxesAccounts' && tax_account.accountable.calculation_method==4 && tax_account.accountable.split_tax == 0)
       if tax_account.name.include?("SGST")
          amt+= line_item.amount
        end
    end   
    amt
  end

  def igst
     amt=0
    self.tax_line_items.each do |line_item|
       tax_account = line_item.account
       next if (tax_account.accountable_type=='DutiesAndTaxesAccounts' && tax_account.accountable.calculation_method==4 && tax_account.accountable.split_tax == 0)
       if tax_account.name.include?("IGST")
        amt+= line_item.amount
        end
    end   
    amt
  end


  def account_effective_date
    if !account.blank? && !expense_date.blank? && expense_date < account.start_date
      errors.add(:expense_date, "must be after account activation, #{account.name} is activated since #{account.start_date}")
    end
    expense_line_items.each do |line_item|
      if !line_item.account.blank? && !expense_date.blank? && expense_date < line_item.account.start_date
        errors.add(:expense_date, "must be after account activation, #{line_item.account.name} is activated since #{line_item.account.start_date}")
      end
    end
  end

  def deducted_tds
    expenses_payments.sum(:tds_amount)
  end
  def applied_tds?
    deducted_tds > 0
  end
  def paid?
    status_id==1
  end
  def update_payment_status
    if outstanding>0
      mark_unpaid
    else
      mark_paid
    end
  end



  def customer_GSTIN
    gstin = nil
    if account.customer.present?   
      gstin = customer.GSTIN
    elsif account.vendor.present?
      gstin = vendor.GSTIN
    end
    gstin
  end

  def mark_paid
    update_attribute("status_id", 1)
  end

  def mark_unpaid
    update_attribute('status_id', 0)
  end
  def status
    STATUS[status_id]
  end

  def currency
    if currency_id.blank?
      self.company.currency_code
    else
      Currency.find(currency_id).currency_code
    end
  end

  def foreign_currency?
    !currency_id.blank? && !exchange_rate.blank? && exchange_rate!=0
  end

  def paid_amount
    expenses_payments.sum(:amount) if credit_expense?
  end

  def outstanding
    total_amount - (paid_amount + deducted_tds) if credit_expense?
  end

  def get_product(tax_id)
    caccount = Account.find_by_id(tax_id)
    paccount = Account.find_by_id(caccount.parent_id)
    line = expense_line_items.includes(:expense_taxes).where(:expense_taxes=>{:account_id => paccount.blank? ? caccount.id : paccount.id}).first
    line.account
  end

  def save_in_frozen_fy
    if !expense_date.blank? && in_frozen_year?
      errors.add(:expense_date, "can't be in frozen financial year")
    end
  end
  def in_frozen_year?
    FinancialYear.check_if_frozen(company_id, expense_date)
  end
  def validate_account_type
    if !credit_expense? && !(["BankAccount", "CashAccount","SecuredLoanAccount", "UnsecuredLoanAccount"]).include?(Account.find(account_id).accountable_type)
      errors.add(:account_id,"you entered to paid from is wrong, please select right account")
    elsif credit_expense? && !(["SundryCreditor","SundryDebtor"]).include?(account.accountable_type)
      errors.add(:account_id,"you entered to paid from is wrong, please select right account")
    end
  end

  # def save_only_in_current_year
  #   year = Year.find_by_name(fin_year)
  #   f_year = FinancialYear.find_by_company_id_and_year_id(company_id, year.id)
  #   if !expense_date.blank? && (expense_date < f_year.start_date || expense_date > f_year.end_date)
  #     errors.add(:expense_date, " must be in current financial year")
  #   end
  # end


  has_attached_file :uploaded_file,
                    :storage=>:s3,
                    :s3_credentials=>"#{Rails.root}/config/s3.yml",
                    :url => ":s3_domain_url",
                    :path => "/uploaded_data/:class/:id/:basename.:extension"
   validates_attachment_size :uploaded_file, :less_than => 5.megabytes
   validates_attachment_content_type :uploaded_file, :content_type => ['image/jpeg','image/png','image /jpg','image/gif', 'application/pdf'],
                                    :message=>" must be of .jpeg,'.jpg', '.gif', .png or .pdf type",
                                    :allow_nil => true

    def validate_amount_total
    total_expenses = self.expense_line_items.map(&:amount).sum + self.tax_line_items.map(&:amount).sum
    total_payments = self.paid_line_items.map(&:amount).sum

    if total_expenses != total_payments
      errors.add(:base, "The total amount of expenses should match with total amounts of payments made.")
    end
  end

  def tax
   amt=0
    self.tax_line_items.each do |line_item|
       tax_account = line_item.account
       next if (tax_account.accountable_type=='DutiesAndTaxesAccounts' && tax_account.accountable.calculation_method==4 && tax_account.accountable.split_tax == 0)
       amt+= line_item.amount
    end
    
    amt
  end

  def created_by_user
    User.find(created_by).full_name
  end

  # def build_tax
  #  expense_line_items.each do |line|
  #    unless line.marked_for_destruction? || line.amount.blank?
  #      line.expense_taxes.each do |tax|
  #        account = tax.account
  #        unless account.blank?
  #          parent_tax_amount=0
  #          account.parent_child_accounts.reverse.each do |acc|
  #            if acc.parent_id.blank?
  #              tax_amount = acc.get_tax_amount(line.amount)
  #              parent_tax_amount = tax_amount
  #            else
  #              tax_amount = acc.get_tax_amount(parent_tax_amount)
  #            end
  #            tax_line_items << ExpenseLineItem.new(:account_id => acc.id, :tax => 1, :amount => tax_amount)
  #          end
  #        end
  #      end
  #    end
  #  end
  # end

  def group_tax_amt(account_id)
    self.tax_line_items.where(:account_id => account_id).sum(:amount)
  end

  def calculate_total_amount
    amount=0
    expense_line_items.each do |line_item|
    amount+=line_item.amount unless line_item.marked_for_destruction? || line_item.amount.blank?
    end
    if reverse_charge == false

      tax_line_items.each do |line_item|
        tax_account = line_item.account
        next if (tax_account.accountable_type=='DutiesAndTaxesAccounts' && tax_account.accountable.calculation_method==4 && tax_account.accountable.split_tax == 0)      
        amount+=line_item.amount unless line_item.marked_for_destruction?
      end
    end
    amount
  end

  def tax_total_amount
    tax_total=0  
    if reverse_charge?
        tax_total= 0 
    else
        tax_line_items.each do |line_item|
           tax_account = line_item.account
           next if (tax_account.accountable_type=='DutiesAndTaxesAccounts' && tax_account.accountable.calculation_method==4 && tax_account.accountable.split_tax == 0)      
          tax_total += line_item.amount unless line_item.amount.blank?
        end
    end
    tax_total
  end

  def paid?
    status_id==1
  end

  def unpaid?
    !paid?
  end

  def delete_and_manage_payment_if_credit_expense
    result=false
    transaction do
      payment_vouchers.update_all(:voucher_type=>1, :allocated=>false, :advanced=>true)
      destroy
      result=true
    end
    result
  end
  class << self
    def get_expense_type(company_id)
      accounts  = Account.find_all_by_company_id_and_accountable_type_and_deleted(company_id,["DirectExpenseAccount",  "IndirectExpenseAccount","ProvisionAccount",
      "PurchaseAccount","SuspenseAccount"], false)
      arr=[]
      accounts.each do |account|
        hash={}
        hash["id"]= account.id
        hash["name"]= account.name
        arr<<hash
      end
      arr.to_json
    end

    def new_expense(company)
      expense = Expense.new
      #expense.expense_date = Time.zone.now.to_date
      expense.voucher_number = VoucherSetting.next_expense_number(company)
      expense.expense_line_items.build
      expense.company_id=company.id
      expense.expense_line_items.each do |line_item|
        2.times{line_item.expense_taxes.build}
      end
      expense.old_file_size = 0
      expense
    end

    def create_expense(params, company, user, fyr)
      expense = Expense.new(params[:expense])
      if company.currency_code == 'INR'
        expense.gst_expense = true
      end
      expense.created_by = user.id
      expense.company_id = company.id
      expense.status_id=0 if expense.credit_expense?
      expense.project_id = Project.get_project_id(params[:project_id], company.id)
      expense.account_id=nil if expense.account_id==0
      expense.currency_id = expense.account.get_currency_id unless expense.account_id.blank?
      if expense.currency_id.blank? || expense.account.get_currency == expense.company.currency_code
        expense.exchange_rate = 0
      end
      expense.old_file_size = 0
      expense.branch_id = user.branch_id unless user.branch_id.blank?
      expense.build_tax
      expense.total_amount=expense.calculate_total_amount
      expense
    end

    def update_expense(params, company, user, fyr)
      expense = Expense.find(params[:id])
      if company.currency_code == 'INR'
        expense.gst_expense = true
      end
      expense.tax_line_items.each do |line_item|
        line_item.mark_for_destruction
      end
      expense.assign_attributes(params[:expense])
      expense.expense_line_items.each do |line_item|
        line_item.account_id=nil if line_item.account.blank?
      end
      expense.project_id = Project.get_project_id(params[:project_id], company.id)
      expense.old_file_size = params[:old_file_size]
      expense.branch_id = user.branch_id unless user.branch_id.blank?
      expense.build_tax
      expense.total_amount=expense.calculate_total_amount
      if expense.credit_expense? && expense.outstanding > 0
        expense.status_id=0
      else
        expense.status_id=1
      end
      expense
    end
  end

  def register_user_action(remote_ip, action)
    Workstream.register_user_action(company_id, created_by, remote_ip,
    " #{voucher_number} #{action} for amount #{expense_line_items.sum(:amount)}.", action, branch_id)
  end

  def register_delete_action(remote_ip, user, action)
    Workstream.register_user_action(company_id, user.id, remote_ip,
    " #{voucher_number} #{action} for amount #{expense_line_items.sum(:amount)}.", action, branch_id)
  end


 def save_with_ledgers
    save_result = false
    transaction do
      if save
        expense_line_items.each do |line_item|
          random_str=Ledger.generate_secure_random
          debit_ledger_entry = Ledger.new_debit_ledger(line_item.account_id, company_id, expense_date, line_item.converted_amount, voucher_number, created_by, line_item.description, branch_id, random_str, account_id)
          credit_ledger_entry = Ledger.new_credit_ledger(account_id, company_id, expense_date, line_item.converted_amount, voucher_number, created_by, line_item.description, branch_id, random_str, line_item.account_id)
          #build relationship between invoice and ledgers
          ledgers << debit_ledger_entry
    			ledgers << credit_ledger_entry
        end

        tax_line_items.each do |line_item|
           #write code to allow entry if gst invoice and parent id present
        tax_account = line_item.account
        next if (tax_account.accountable_type=='DutiesAndTaxesAccounts' && tax_account.accountable.calculation_method==4 && tax_account.accountable.split_tax == 0)
        if self.gst_expense? && self.reverse_charge?
          #Retrieve account of this company with sales for e.g if CSGT@9 for purchase then retrieve CGST@9 for sales
          expense_account_name = line_item.account.name.chomp('on purchases')
          account_name = "#{expense_account_name}".concat("on sales")
          random_str=Ledger.generate_secure_random
          reverse_account = company.accounts.find_by_name(account_name)
          debit_ledger_entry = Ledger.new_debit_ledger(line_item.account_id, company_id, expense_date, line_item.converted_amount, voucher_number, created_by, line_item.description, branch_id, random_str, reverse_account.id )
          credit_ledger_entry = Ledger.new_credit_ledger(reverse_account.id, company_id, expense_date, line_item.converted_amount, voucher_number, created_by, line_item.description, branch_id, random_str, line_item.account_id )
          logger.debug  debit_ledger_entry.inspect
          ledgers << debit_ledger_entry
          ledgers << credit_ledger_entry
        else
        random_str=Ledger.generate_secure_random
        debit_ledger_entry = Ledger.new_debit_ledger(line_item.account_id, company_id, expense_date, line_item.converted_amount, voucher_number, created_by, line_item.description, branch_id, random_str, account_id )
        credit_ledger_entry = Ledger.new_credit_ledger(account_id, company_id, expense_date, line_item.converted_amount, voucher_number, created_by, line_item.description, branch_id, random_str, line_item.account_id )
        #build relationship between expense and ledgers
        ledgers << debit_ledger_entry
        ledgers << credit_ledger_entry
          end
          ExpenseFilerWorker.perform_async(company_id, id)
        end      
        

        save_result = true
          Subscription.increase_storage(company_id, uploaded_file_file_size, old_file_size)
      end
    end
    save_result
  end

   def save_expense_with_ledgers(to_account_id,tax_account_id,gateway)

    description= "Fees deducted for #{gateway} online payment"
    save_result = false
    transaction do
      if save

        expense_line_items.each do |line_item|
          random_str=Ledger.generate_secure_random
          debit_ledger_entry = Ledger.new_debit_ledger(line_item.account_id, company_id, expense_date,line_item.amount, voucher_number, created_by, description, branch_id, random_str, account_id )
          credit_ledger_entry = Ledger.new_credit_ledger(account_id, company_id, expense_date, line_item.amount, voucher_number, created_by,description, branch_id, random_str,line_item.account_id )
          #build relationship between invoice and ledgers
          ledgers << debit_ledger_entry
          ledgers << credit_ledger_entry
        end
      tax_line_items.each do |line_item|
          random_str_1=Ledger.generate_secure_random
          debit_ledger_entry = Ledger.new_debit_ledger(line_item.account_id, company_id, expense_date,line_item.amount, voucher_number, created_by,description, branch_id, random_str_1,account_id )
          credit_ledger_entry = Ledger.new_credit_ledger(account_id, company_id, expense_date,line_item.amount, voucher_number, created_by,description, branch_id, random_str_1,line_item.account_id )
          #build relationship between expense and ledgers
          ledgers << debit_ledger_entry
          ledgers << credit_ledger_entry
        end
        save_result = true
      end
    end
    save_result
  end


  def update_and_post_ledgers
	  update_result = false
	  transaction do
      ledgers.each do |ledger|
        bank_statement_line_item = ledger.bank_statement_line_item
        unless bank_statement_line_item.blank?
          bank_statement_line_item.update_attributes(:status => 0, :ledger_id => nil)
        end
      end
  		Ledger.delete(ledgers)
      expense_line_items.reload

  		expense_line_items.each do |line_item|
        random_str=Ledger.generate_secure_random
        debit_ledger_entry = Ledger.new_debit_ledger(line_item.account_id, company_id, expense_date, line_item.converted_amount, voucher_number, created_by, line_item.description, branch_id, random_str, account_id )
  			credit_ledger_entry = Ledger.new_credit_ledger(account_id, company_id, expense_date, line_item.converted_amount, voucher_number, created_by, line_item.description, branch_id, random_str, line_item.account_id )
        #build relationship between invoice and ledgers
        ledgers << debit_ledger_entry
  			ledgers << credit_ledger_entry
      end

      tax_line_items.reload
      tax_line_items.each do |line_item|
  
         #write code to allow entry if gst invoice and parent id present
        tax_account = line_item.account
        next if (tax_account.accountable_type=='DutiesAndTaxesAccounts' && tax_account.accountable.calculation_method==4 && tax_account.accountable.split_tax == 0)
        if self.gst_expense? && self.reverse_charge?
          #Retrieve account of this company with sales for e.g if CSGT@9 for purchase then retrieve CGST@9 for sales
          expense_account_name = line_item.account.name.chomp('on purchases')
          account_name = "#{expense_account_name}".concat("on sales")
          random_str=Ledger.generate_secure_random
          reverse_account = company.accounts.find_by_name(account_name)
          debit_ledger_entry = Ledger.new_debit_ledger(line_item.account_id, company_id, expense_date, line_item.converted_amount, voucher_number, created_by, line_item.description, branch_id, random_str, reverse_account.id )
          credit_ledger_entry = Ledger.new_credit_ledger(reverse_account.id, company_id, expense_date, line_item.converted_amount, voucher_number, created_by, line_item.description, branch_id, random_str, line_item.account_id )
          logger.debug  debit_ledger_entry.inspect
          ledgers << debit_ledger_entry
          ledgers << credit_ledger_entry
        else
        random_str=Ledger.generate_secure_random
        debit_ledger_entry = Ledger.new_debit_ledger(line_item.account_id, company_id, expense_date, line_item.converted_amount, voucher_number, created_by, line_item.description, branch_id, random_str, account_id )
        credit_ledger_entry = Ledger.new_credit_ledger(account_id, company_id, expense_date, line_item.converted_amount, voucher_number, created_by, line_item.description, branch_id, random_str, line_item.account_id )
        #build relationship between expense and ledgers
        ledgers << debit_ledger_entry
        ledgers << credit_ledger_entry
          end
      end
      update_result = true
      # self.update_attribute(:total_amount, amount)
       Subscription.increase_storage(company_id, uploaded_file_file_size, old_file_size)
    end
	  update_result
  end

  def vendor_name
    account.name
  end

   def vendor
    account.vendor.blank? ? account.customer : account.vendor
  end

  def file_name
    uploaded_file_file_name
  end

  def file_size
    uploaded_file_file_size
  end

  #soft delete method
  def delete(deleted_by_user)
    result = false
    transaction do
      if update_attributes(:deleted_by => deleted_by_user, :deleted => true, :deleted_datetime => Time.zone.now)
        ledgers.update_all(:deleted_by => deleted_by_user, :deleted => true, :deleted_datetime => Time.zone.now)
        result = true
	  end
    end
    result
  end
 #restore method
  def restore(restored_by_user)
    result = false
    transaction do
      if update_attributes(:restored_by => restored_by_user, :deleted => false, :restored_datetime => Time.zone.now)
		ledgers.update_all(:restored_by => restored_by_user, :deleted => false, :restored_datetime => Time.zone.now)
		result = true
	  end
    end
    result
  end

  def delete_uploaded_file
    @file_delete ||= "0"
  end

  def delete_uploaded_file=(value)
    @file_delete = value
  end

  def project_name
     (project_id.blank? || project_id==0) ? "Not available" : Project.find(project_id).name
  end

  def from_account_name
   Account.find(account_id).name
  end

  private
    def storage_limit
      errors[:base] << "Storage limit reached, your plan does not allow storing any more files." if Subscription.storage_limit?(company_id, uploaded_file_file_size, old_file_size)
    end
    def destroy_uploaded_file?
      self.uploaded_file.clear if @file_delete == "1" and !uploaded_file.dirty?
    end
end

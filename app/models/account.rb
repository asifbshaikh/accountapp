class Account < ActiveRecord::Base
  paginates_per 20
  scope :by_name, lambda{|name| where("name like ?", "%#{name}%") unless name.blank?}
  scope :by_group, lambda{|group| where(:account_head_id=>group) unless group.blank? }
  scope :by_accountable_type, lambda{|accountable_type| where(:accountable_type=>accountable_type) unless accountable_type.blank? }
  scope :by_creater, lambda{|creater| where(:created_by =>creater) unless creater.blank? }
  scope :by_parent, lambda { |parent_id| where(:account_head_id=>parent_id) }
  scope :by_end_date, lambda { |end_date| where("end_date is null or end_date > ?", end_date)}
  scope :valid_accounts, where(:deleted => false).order(:name)
  has_many :payroll_execution_jobs
  # has_one :customer_account
  belongs_to :customer
  # has_one :vendor_account
  has_many :expense_taxes, :dependent=>:destroy
  has_many :expense_line_items, :through=>:expense_taxes
  has_many :purchase_return_taxes, :dependent=>:destroy
  has_many :purchase_return_line_items, :through=>:purchase_return_taxes
  has_many :purchase_order_taxes, :dependent=>:destroy
  has_many :purchase_order_line_items, :through=>:purchase_order_taxes
  has_many :purchase_taxes, :dependent=>:destroy
  has_many :purchase_line_items, :through=>:purchase_taxes
  has_many :estimate_taxes, :dependent=>:destroy
  has_many :estimate_line_items, :through=>:estimate_taxes
  has_many :sales_order_taxes, :dependent=>:destroy
  has_many :sales_order_line_items, :through=>:sales_order_taxes
  has_many :invoice_return_taxes, :dependent=>:destroy
  has_many :invoice_return_line_items, :through=>:invoice_return_taxes
  has_many :gst_credit_note_taxes, :dependent=>:destroy
  has_many :gst_credit_note_line_items, :through=>:gst_credit_note_taxes
  has_many :invoice_taxes, :dependent=>:destroy
  has_many :invoice_line_items, :through=>:invoice_taxes
  has_many :time_line_items, :through=>:invoice_taxes
  has_many :gstr_advance_receipt_taxes, :dependent => :destroy
  has_many :gstr_advance_receipt_line_items, :through=> :gstr_advance_receipt_taxes
  has_many :gstr_advance_receipts,:foreign_key => :from_account_id, :dependent => :destroy, :conditions => {:deleted => false}

  belongs_to :vendor
  belongs_to :company
  belongs_to :account_head
  has_many :invoices, :conditions => {:deleted => false, :invoice_status_id=>[0,2,3]}
  has_many :receipt_vouchers, :foreign_key => :from_account_id, :conditions => {:deleted => false}
  has_many :payment_vouchers, :foreign_key => :to_account_id, :conditions => {:deleted => false}
  has_many :account_histories, :dependent => :destroy
  has_many :ledgers, :dependent => :destroy, :conditions => {:deleted => false}
  has_many :corresponding_ledgers, :class_name => 'Ledger', :foreign_key => 'corresponding_account_id'
  has_many :purchases, :dependent => :destroy, :conditions => {:deleted => false}
  belongs_to :accountable, :polymorphic => true
  has_one :product, :dependent=> :destroy
  # has_many :invoice_line_items, :dependent => :destroy
  has_many :estimate_taxes, :dependent => :destroy
  has_many :gstr_advance_payment_taxes, :dependent => :destroy
  has_many :gstr_advance_payments,:foreign_key=>:to_account_id, :dependent => :destroy, :conditions => {:deleted => false}
  has_many :estimate_line_items, :through=> :estimate_taxes
  has_many :gstr_advance_payment_line_items, :through=> :gstr_advance_payment_taxes
  # has_many :purchase_line_items, :dependent => :destroy
  # has_many :purchase_order_line_items, :dependent => :destroy
  has_many :estimates, :dependent => :destroy, :conditions => {:deleted => false}
  has_many :purchase_orders, :dependent => :destroy, :conditions => {:deleted => false}
  has_many :sales_orders, :dependent => :destroy
  has_many :delivery_challans, :dependent => :destroy

  #validations
  validates :name, :presence => true, :uniqueness => {:scope => :company_id}
  validates_format_of :name, :with =>/^([a-z]|[A-Z]|[0-9]|[.]|[ ]|[-]|[_]|[@]|[%]|[(]|[)]|[\/]|[&])*$/i, :message => "should start with alphabet and should not contain special characters"
  validates_presence_of :account_head_id
  validates_presence_of :start_date
  validate :ledger_minimum_date
  validate :archive_date, :on=>:update
  validates :opening_balance, :numericality => true, :allow_blank => true
  validate :if_reseller_product_name_present, :on => :create

  validates_associated :accountable, :message => "fields with star(*) are mandatory"

  accepts_nested_attributes_for :accountable
  attr_accessible :erasable, :start_date, :end_date, :parent_id, :account_head_id, :name, :opening_balance, :deleted, :deleted_by, :deleted_datetime, :accountable_attributes, :company_id, :created_by
  accepts_nested_attributes_for :gstr_advance_receipt_taxes
  after_create :create_corresponding_sales


  # def get_current_opening_balance(start_date, end_date)
  #   op_balance = 0
  #   financial_year = FinancialYear.find_by_company_id_and_start_date_and_end_date(company.id, start_date, end_date )
  #   account_history = AccountHistory.find_by_account_id_and_financial_year_id_and_company_id(id, financial_year.id, company_id) unless financial_year.blank?
  #   if !financial_year.freeze?
  #     op_balance = opening_balance
  #   elsif financial_year.freeze? && !account_history.blank?
  #     op_balance = account_history.opening_balance
  #   end
  #   op_balance
  # end

  #Naveen Sep 3 2017 GST changes
  #This method returns true for accounts that are GST accounts and not for IGST and CGST
  def gst_tax_account?
    (name.include? "GST @") && (accountable.calculation_method==4 && accountable.split_tax == 0)
  end

  #Naveen Sep 3 2017 GST changes
  #This method returns true for accounts that are GST accounts and not for IGST and CGST
  def igst_tax_account?
    (name.include? "IGST @")
  end

  #Naveen 9 May 2016
  # This method returns the sum of transactions done on this account between a given time period
  # sum(debits) - sum(credits) in a given time period
  def transactions_in_period(start_date, end_date)
    result= self.ledgers.select("sum(ledgers.debit) - sum(ledgers.credit) as balance").where(:company_id => self.company_id).where("ledgers.transaction_date between ? and ?", start_date, end_date)
    transaction_balance = result[0].balance.nil? ? 0 : result[0].balance
  end

  # Naveen  This method returns the balance of this account on the given date.
  # In effect this also means the closing balance of the account as on the given day
  def balance_on_date(balance_on_date)
    result =  ledgers.select("sum(ledgers.debit) - sum(ledgers.credit) as balance").where("company_id =? and ledgers.transaction_date  <= ?", company_id, balance_on_date)
    transaction_balance = result[0].balance.nil? ? 0 : result[0].balance

    transaction_balance += opening_balance unless opening_balance.blank?
    transaction_balance
  end

  def opening_balance_on_date(date)
    balance_on_date(date-1)
  end

  def closing_balance_on_date(date)
    balance_on_date(date)
  end


  def tax_rate
    ind_tax_rate=0
    parent_tax_rate=0
    parent_child_accounts.reverse.each do |tax_account|
      if tax_account.parent_id.blank?
        parent_tax_rate=tax_account.accountable.tax_rate*(tax_account.accountable.calculate_on_percent/100.0)
        ind_tax_rate=parent_tax_rate
      else
        if tax_account.accountable.calculation_method==2
          ind_tax_rate+=tax_account.accountable.tax_rate*((accountable.calculate_on_percent+parent_tax_rate)/100.0)
         elsif tax_account.accountable.calculation_method.to_i==3
          ind_tax_rate += tax_account.accountable.tax_rate
        else
        if !(accountable.calculation_method==4 && accountable.split_tax == 0)
           ind_tax_rate+=(parent_tax_rate*(tax_account.accountable.tax_rate/100.0))
        end  
        end
      end
    end
    ind_tax_rate
  end

  def add_tax_lines(object, line)
    tax_line_items=[]
    primary_tax_amount=0
    base_amount=0
    amount=0 #this will hold the actual line amount
    parent_child_accounts.reverse.each do |acc|
      if acc.parent_id.blank?
        amount=(object.has_attribute?(:tax_inclusive) && object.tax_inclusive?) ? (line.quantity*line.item_cost) : line.amount
        base_amount=amount*(acc.accountable.calculate_on_percent/100.00)
        tax_amt = (object.has_attribute?(:tax_inclusive) && object.tax_inclusive?) ? acc.tax_inclusive_amt(base_amount) : acc.get_tax_amount(base_amount)
        primary_tax_amount = tax_amt
      else
        calculate_on_amount=primary_tax_amount
        if acc.accountable.calculation_method.to_i==2
          calculate_on_amount+= base_amount
        elsif acc.accountable.calculation_method.to_i==3
          #Fixed the issue where child taxes were not being calculated on n% of sub total
          #Author : Ashish Wadekar & Rohit Chandran
          #Date : 5th December 2016

          # calculate_on_amount = amount
          calculate_on_amount = base_amount
        end
        tax_amt = (object.has_attribute?(:tax_inclusive) && object.tax_inclusive?) ? acc.tax_inclusive_amt(calculate_on_amount) : acc.get_tax_amount(calculate_on_amount)
      end
      tax_line_items << line.class.to_s.constantize.new(:account_id => acc.id, :tax => 1, :amount => tax_amt)
    end
    tax_line_items
  end

  # Naveen 29 Apr 2016
  # This method is temporary hack for estimate and needs to be removed
  def add_estimate_tax_lines(object, line)
    tax_line_items=[]
    primary_tax_amount=0
    base_amount=0
    amount=0 #this will hold the actual line amount
    parent_child_accounts.reverse.each do |acc|
      if acc.parent_id.blank?
        tax_inclusive = (object.has_attribute?(:tax_inclusive) && object.tax_inclusive?)
        amount=tax_inclusive ? (line.quantity*line.tax_inclusive_unit_cost) : line.amount
        base_amount=amount*(acc.accountable.calculate_on_percent/100.00)
        tax_amt = tax_inclusive ? acc.tax_inclusive_amt(base_amount) : acc.get_tax_amount(base_amount)
        primary_tax_amount = tax_amt
      else
        calculate_on_amount=primary_tax_amount
        if acc.accountable.calculation_method.to_i==2
          calculate_on_amount+= base_amount
        elsif acc.accountable.calculation_method.to_i==3
          calculate_on_amount=amount
        end
        tax_amt = (object.has_attribute?(:tax_inclusive) && object.tax_inclusive?) ? acc.tax_inclusive_amt(calculate_on_amount) : acc.get_tax_amount(calculate_on_amount)
      end
      tax_line_items << line.class.to_s.constantize.new(:account_id => acc.id, :tax => 1, :amount => tax_amt)
    end
    tax_line_items
  end

def add_gstr_advance_receipt_tax_lines(object, line)
    tax_line_items=[]
    primary_tax_amount=0
    base_amount=0
    amount=0 #this will hold the actual line amount
    parent_child_accounts.reverse.each do |acc|
      if acc.parent_id.blank?
        # tax_inclusive = (object.has_attribute?(:tax_inclusive) && object.tax_inclusive?)
        amount = line.amount
        logger.debug amount.inspect
        base_amount=amount*(acc.accountable.calculate_on_percent/100.00)
        logger.debug base_amount.inspect
        tax_amt = acc.get_tax_amount(base_amount)
        logger.debug tax_amt.inspect
        primary_tax_amount = tax_amt
        logger.debug primary_tax_amount.inspect
      else
        calculate_on_amount=primary_tax_amount
        if acc.accountable.calculation_method.to_i==2
          calculate_on_amount+= base_amount
        elsif acc.accountable.calculation_method.to_i==3
          calculate_on_amount=amount
        end
        tax_amt = acc.get_tax_amount(calculate_on_amount)
        logger.debug "tax_amount"
        logger.debug tax_amt.inspect
      end
      tax_line_items << line.class.to_s.constantize.new(:account_id => acc.id, :amount => tax_amt)

    end
    tax_line_items
  end

def add_gstr_advance_payment_tax_lines(object, line)
    tax_line_items=[]
    primary_tax_amount=0
    base_amount=0
    amount=0 #this will hold the actual line amount
    parent_child_accounts.reverse.each do |acc|
      if acc.parent_id.blank?
        # tax_inclusive = (object.has_attribute?(:tax_inclusive) && object.tax_inclusive?)
        amount = line.amount
        logger.debug amount.inspect
        base_amount=amount*(acc.accountable.calculate_on_percent/100.00)
        logger.debug base_amount.inspect
        tax_amt = acc.get_tax_amount(base_amount)
        logger.debug tax_amt.inspect
        primary_tax_amount = tax_amt
        logger.debug primary_tax_amount.inspect
      else
        calculate_on_amount=primary_tax_amount
        if acc.accountable.calculation_method.to_i==2
          calculate_on_amount+= base_amount
        elsif acc.accountable.calculation_method.to_i==3
          calculate_on_amount=amount
        end
        tax_amt = acc.get_tax_amount(calculate_on_amount)
        logger.debug tax_amt.inspect
      end
      tax_line_items << line.class.to_s.constantize.new(:account_id => acc.id, :amount => tax_amt)

    end
    tax_line_items
  end


  def add_purchase_tax_lines(object, line)
    tax_line_items=[]
    primary_tax_amount=0
    base_amount=0
    amount=0 #this will hold the actual line amount
    parent_child_accounts.reverse.each do |acc|
      if acc.parent_id.blank?
        tax_inclusive = (object.has_attribute?(:tax_inclusive) && object.tax_inclusive?)
        amount=tax_inclusive ? (line.quantity*line.tax_inclusive_unit_cost) : line.amount
        base_amount=amount*(acc.accountable.calculate_on_percent/100.00)
        tax_amt = tax_inclusive ? acc.tax_inclusive_amt(base_amount) : acc.get_tax_amount(base_amount)
        primary_tax_amount = tax_amt
      else
        calculate_on_amount=primary_tax_amount
        if acc.accountable.calculation_method.to_i==2
          calculate_on_amount+= base_amount
        elsif acc.accountable.calculation_method.to_i==3
          calculate_on_amount= amount
        end
        tax_amt = (object.has_attribute?(:tax_inclusive) && object.tax_inclusive?) ? acc.tax_inclusive_amt(calculate_on_amount) : acc.get_tax_amount(calculate_on_amount)
      end
      tax_line_items << line.class.to_s.constantize.new(:account_id => acc.id, :tax => 1, :amount => tax_amt)
    end
    tax_line_items
  end

  def tax_amount(object, line)
    primary_tax_amount=0
    base_amount=0
    tax_amt=0
    amount=0 #this will hold the actual line amount
    parent_child_accounts.reverse.each do |acc|
      if acc.parent_id.blank?
        amount=(object.has_attribute?(:tax_inclusive) && object.tax_inclusive?) ? (line.quantity*line.item_cost) : line.amount
        base_amount=amount*(acc.accountable.calculate_on_percent/100.00)
        tax_amt = (object.has_attribute?(:tax_inclusive) && object.tax_inclusive?) ? acc.tax_inclusive_amt(base_amount) : acc.get_tax_amount(base_amount)
        primary_tax_amount = tax_amt
      else
        calculate_on_amount=primary_tax_amount
        if acc.accountable.calculation_method==2
          calculate_on_amount+= base_amount
        elsif acc.accountable.calculation_method==3
          calculate_on_amount= amount
        end
            ###Added for GST 
         if !(accountable.calculation_method==4 && accountable.split_tax == 0)
           tax_amt += (object.has_attribute?(:tax_inclusive) && object.tax_inclusive?) ? acc.tax_inclusive_amt(calculate_on_amount) : acc.get_tax_amount(calculate_on_amount)
        end
        ########
      end
    end
    tax_amt
  end

  def has_childs?
    !Account.where(:parent_id=>id).blank?
  end

  def calculate_tax(amount)
    tax_amt=0
    parent_child_accounts.reverse.each do |acc|
      if acc.parent_id.blank?
        tax_amt+=amount
      else
        tax_amt += acc.get_tax_amount(amount)
      end
    end
    tax_amt
  end

  def get_party
    customer.blank? ? vendor : customer
  end

  def archive_date
    unless end_date.blank?
      ledgers = company.ledgers.by_account(id).by_transaction_date_greater_than_or_equal_to(end_date)
      errors.add(:base, "There are some vouchers created for #{name} after #{end_date}") unless ledgers.blank?
    end
  end

  def archive?
    !end_date.blank? && end_date <= Time.zone.now.to_date
  end

  def history_any?
    !AccountHistory.where(:account_id=>id, :company_id=>company_id).blank?
  end

  def collected_tax(fyr)
    tax_amt = Ledger.get_tax_amount(company_id, id, fyr)
    linked_accounts = get_linked_taxes
    unless linked_accounts.blank?
      linked_accounts.each do |linked_account|
        tax_amt += Ledger.get_tax_amount(company_id, linked_account.id, fyr)
      end
    end
    tax_amt
  end

  def get_linked_taxes
    Account.where(:company_id => company_id, :parent_id => id, :deleted => false)
  end

  def tax_on_purchase?
    accountable.apply_to == 2
  end

  def tax_on_sales?
    accountable.apply_to == 1
  end

  def linked_sales
    arr = []
    parent_child_accounts.reverse.each do |acc|
      name_rate = {}
      name_rate["name"] = acc.name.sub(" on sales", "")
      name_rate["rate"] = acc.accountable.tax_rate
      name_rate["calculate_on_percent"] = acc.accountable.calculate_on_percent
      name_rate["calculation_method"] = acc.accountable.calculation_method
      name_rate["class_name"] = acc.get_class
      name_rate["parent"]=acc.parent_id.blank?
      arr<<name_rate
    end
    arr.to_json
  end
  def linked_purchase
    arr = []
    parent_child_accounts.reverse.each do |acc|
      name_rate = {}
      name_rate["name"] = acc.name.sub(" on purchases", "")
      name_rate["calculate_on_percent"] = acc.accountable.calculate_on_percent
      name_rate["calculation_method"] = acc.accountable.calculation_method
      name_rate["rate"] = acc.accountable.tax_rate
      name_rate["class_name"] = acc.get_class
      name_rate["parent"]=acc.parent_id.blank?
      arr<<name_rate
    end
    arr.to_json
  end

  def get_class
    "tax#{id}"
  end

  def get_tax_amount(amount)
    tax_amount=0
    rate = accountable.tax_rate
    tax_amount=amount*(rate/100.00) unless rate.blank?
    tax_amount
  end

  def tax_inclusive_amt(amount)
    amount*(accountable.tax_rate/100.0)
    # rate = accountable.tax_rate
    # tax_amt = (amount/(100.0+rate))*100.0 unless rate.blank?
    # amount - tax_amt
  end

  def parent_child_accounts
    accounts = Account.where(:company_id => company_id, :parent_id => id, :deleted => false).reverse
    accounts.push(self)
    accounts
  end

  FREQUENCY = {"1" => "Monthly", "3" => "Quarterly", "6" => "Half-Yearly", "12" => "Yearly"}

  def get_filling_frequency
    FREQUENCY[accountable.filling_frequency.to_s]
  end

  def self.filling_frequency
    FREQUENCY
  end


  class << self

    #this method will create all the GST taxes at the time of company registration
    def create_gst_accounts(company, user)
      gst_rates = ['Nil', 'Zero','3%', '5%','12%', '18%', '28%']
      gst_rate_percentages = [0, 0, 3, 5, 12, 18, 28]
      gst_tax_types = ['GST', 'IGST']
      gst_taxes_on = ['sales', 'purchases']
      gst_child_taxes = ['CGST', 'SGST']
      account_head = AccountHead.find_by_company_id_and_name(company, "Duties and Taxes")
      start_date = '2017-07-01'
      gst_rates.each_with_index do |gst_rate, gst_rate_index|
        gst_tax_types.each_with_index do |gst_tax_type, gst_tax_type_index|
          gst_taxes_on.each do |tax_on|
            if tax_on == 'sales'
              apply_to=1
            else
              apply_to=2
            end
            if (gst_tax_type == "GST") && (gst_rate_percentages[gst_rate_index] != 0)
              #create parent GST @tax rate
              gst_account = Account.new(:name=> "#{gst_tax_type} @#{gst_rate} on #{tax_on}",
                :company_id => company.id, :account_head_id => account_head.id, :opening_balance => 0,
                :created_by => user.id, :start_date => start_date )
              gst_account.accountable = DutiesAndTaxesAccounts.new(:apply_to => apply_to,
                :description => 'The Goods and Service Tax', :tax_rate => gst_rate_percentages[gst_rate_index], 
                :filling_frequency => filling_frequency, :calculate_on_percent=> 100,
                :calculation_method=> 4, :split_tax => 0) # calculation method 4 - means split tax, tax is split in child taxes
              #puts "The GST account to be saved is #{gst_account.inspect}"
              gst_account.save!  
              #create child CGST@tax_rate/2
              gst_child_taxes.each do |gst_child_tax|
                linked_child_account = Account.new(:name=> "#{gst_child_tax} @#{gst_rate_percentages[gst_rate_index].to_d/2} on #{tax_on}",
                  :company_id => company.id,
                  :account_head_id => account_head.id, :opening_balance => 0,
                  :created_by => user.id, :start_date => start_date,
                  :parent_id => gst_account.id)
                linked_child_account.accountable = DutiesAndTaxesAccounts.new(:apply_to => apply_to,
                  :description => 'The Goods and Service Tax', :tax_rate => 50, 
                  :filling_frequency => filling_frequency, :calculate_on_percent=> 100,
                  :calculation_method=> 1, :split_tax=>1)
                #puts "The GST linked child account to be saved is #{linked_child_account.inspect}"
                linked_child_account.save!
              end #loop for child taxes
            else
              #create single IGST @tax rate
              gst_account = Account.new(:name=> "#{gst_tax_type} @#{gst_rate} on #{tax_on}",
                :company_id => company.id,
                :account_head_id => account_head.id, :opening_balance => 0,
                :created_by => user.id, :start_date => start_date )
              gst_account.accountable = DutiesAndTaxesAccounts.new(:apply_to => apply_to,
                :description => 'The Goods and Service Tax', :tax_rate => gst_rate_percentages[gst_rate_index], 
                :filling_frequency => filling_frequency, :calculate_on_percent=> 100,
                :calculation_method=> 3) # calculation method 4 - means split tax, tax is split in child taxes
              #puts "The IGST account to be saved is #{gst_account.inspect}"
              gst_account.save!  
            end
          end #loop end for gst_purchase_sales  
        end #loop end for  gst_tax_type
      end #loop end for gst_rate
    end

    #This method returns the total opening balance of all accounts that are create on or before the as_on_date
    def total_opening_balance(company, as_on_date)
      # result= Account.select("sum(opening_balance) as opening_balance").where(:company_id => company).where("start_date <= ?", as_on_date)
      # result[0].opening_balance.nil? ? 0 : result[0].opening_balance
      company.accounts.where("start_date <= ?", as_on_date).sum(:opening_balance)
    end


    #This method returns the balance of an account withing the given date ranges.
    #It includes the opening balance if account created date is after the start date.
    #This method is only used in profit and loss report. The opening balance and previous years transactions
    # are ignored as they will be part of the reserves and surplus calculations.
    # The opening balance is only considered incase the account is created after or on the given start date
    def balance_by_account_type_in_date_range(company, start_date, end_date, account_transaction_type)
      opening_bal_result = Account.select(" sum(opening_balance) as opening_balance").where(:company_id => company, :accountable_type => account_transaction_type, :deleted => false).where("start_date >= ?", start_date)
      opening_balance = opening_bal_result[0].opening_balance.nil? ? 0 : opening_bal_result[0].opening_balance
      result = Account.select(" sum(ledgers.debit) - sum(ledgers.credit) as balance").where(:company_id => company, :accountable_type => account_transaction_type, :deleted => false).joins(:ledgers).
        where(:ledgers => { :company_id => company}).where(" ledgers.transaction_date between ? and ?", start_date, end_date)
      transaction_balance = result[0].balance.nil? ? 0 : result[0].balance
      # if account_transaction_type="DirectExpenseAccount"
      #   nil.split
      # end
      opening_balance + transaction_balance
    end


    #This method returns the balance of an account as on the given date. Used in Balance sheet
    def balance_by_account_type(company, balance_as_on_date, account_transaction_type)
      opening_bal_result = Account.select(" sum(opening_balance) as opening_balance").where(:company_id => company, :accountable_type => account_transaction_type, :deleted => false).
        where("start_date <= ?", balance_as_on_date)
      #puts ">>>>Account Opening: #{opening_bal_result[0].opening_balance.to_i} <<<<"
      opening_balance = opening_bal_result[0].opening_balance.nil? ? 0 : opening_bal_result[0].opening_balance

      result = Account.select(" sum(ledgers.debit) - sum(ledgers.credit) as balance").where(:company_id => company, :accountable_type => account_transaction_type, :deleted => false).joins(:ledgers).
        where(:ledgers => { :company_id => company}).where(" ledgers.transaction_date  <= ?", balance_as_on_date)
      transaction_balance = result[0].balance.nil? ? 0 : result[0].balance

      opening_balance + transaction_balance
    end

    def get_default_income_account(company)
      where(:company_id=> company, :name=> "Sales Account - default income").first
    end

    def get_default_expense_account(company)
      where(:company_id=> company, :name=> "Purchase Account - default expense").first
    end

    def company_contacts(company)
      contacts = Account.find_all_by_company_id_and_accountable_type_and_deleted(company,["SundryDebtor", "SundryCreditor"], false)
      arr=[]
      contacts.each do |contact|
        hash={}
        hash["id"]=contact.id
        hash["name"]=contact.name
        arr<<hash
      end
      arr.to_json
    end

    def get_account_ids(company,account)
      accounts = Account.where(" company_id = ? and name like (?)",company, account)
        @account_ids = []
        if !accounts.blank?
          accounts.each do |a|
            @account_ids << a.id
          end
        end
      @account_ids
    end
    def account_type
      ["DirectExpenseAccount", "IndirectExpenseAccount", "DirectIncomeAccount", "IndirectIncomeAccount"]
    end

    def create_default_tax(company, user, financial_year)
      tax_on = ["sales", "purchase"]
      tax_on.each do |tax|
        service_tax = fetch_tax_account("Service Tax @12% on #{tax}", 12, nil, tax=="sales" ? 1 : 2 ,company, user, nil, 12, nil, 100, nil)
        service_tax.start_date=financial_year.start_date
        if service_tax.save!
          edu_secc = fetch_tax_account("Education Cess @2% on #{tax}", 2, nil, tax=="sales" ? 1 : 2 ,company, user, service_tax.id, 12, nil, 100, nil)
          has_secc = fetch_tax_account("Secondary Higher Education Cess @1% on #{tax}", 1, nil, tax=="sales" ? 1 : 2 ,company, user, service_tax.id, 12, nil, 100,nil)
          edu_secc.start_date=financial_year.start_date
          has_secc.start_date=financial_year.start_date
          edu_secc.save!
          has_secc.save!
        end
        vat = fetch_tax_account("VAT @5% on #{tax}", 5, nil, tax=="sales" ? 1 : 2 ,company, user, nil, 12, nil, 100,nil)
        vat.start_date=financial_year.start_date
        vat.save!
      end
    end

    def create_tax(params, company, user)
      result = false
      unless params[:apply_to].blank?
        transaction do
          account_name = params[:account_name]
          if params[:apply_to].include?("1")
            account = fetch_tax_account(account_name.blank? ? nil : "#{account_name} @#{params[:sales_tax_rate]}% on sales", params[:sales_tax_rate], params[:description], 1, company, user, nil, params[:filling_frequency], params[:registration_number], params[:calculate_on_percent], 0)
            account.start_date=params[:start_date]
            if account.save
              unless params[:linked_tax].blank?
                params[:linked_tax].each_with_index do |tax, index|
                  linked_tax = fetch_tax_account("#{params[:linked_tax][index.to_s][:account_name]} @#{params[:linked_tax][index.to_s][:sales_tax_rate]}% on sales", params[:linked_tax][index.to_s][:sales_tax_rate], params[:linked_tax][index.to_s][:description], 1, company, user, account.id, account.accountable.filling_frequency, params[:linked_tax][index.to_s][:registration_number], 100, params[:linked_tax][index.to_s][:calculation_method])
                  linked_tax.start_date=params[:start_date]
                  raise ActiveRecord::Rollback unless linked_tax.save
                end
              end
            else
              raise ActiveRecord::Rollback
            end
          end
          if params[:apply_to].include?("2")
            account = fetch_tax_account(account_name.blank? ? nil : "#{account_name} @#{params[:purchase_tax_rate]}% on purchase", params[:purchase_tax_rate], params[:description], 2, company, user, nil, params[:filling_frequency], params[:registration_number], params[:calculate_on_percent], 0)
            account.start_date=params[:start_date]
            if account.save
              unless params[:linked_tax].blank?
                params[:linked_tax].each_with_index do |tax, index|
                  linked_tax = fetch_tax_account("#{params[:linked_tax][index.to_s][:account_name]} @#{params[:linked_tax][index.to_s][:purchase_tax_rate]}% on purchase", params[:linked_tax][index.to_s][:purchase_tax_rate], params[:linked_tax][index.to_s][:description], 2, company, user, account.id, account.accountable.filling_frequency, params[:linked_tax][index.to_s][:registration_number], 100, params[:linked_tax][index.to_s][:calculation_method])
                  linked_tax.start_date=params[:start_date]
                  raise ActiveRecord::Rollback unless linked_tax.save
                end
              end
            else
              raise ActiveRecord::Rollback
            end
          end
          result = true
        end
      end
      result
    end

    def fetch_tax_account(name, rate, description, apply_to,company, user, parent, filling_frequency, registration_number, calculate_on_percent, calculation_method)
      tax_head = AccountHead.find_by_company_id_and_name(company, "Duties and Taxes")
      account = Account.new(:name => name, :company_id => company,
        :created_by => user.id, :account_head_id => tax_head.id, :parent_id => parent)
      sub_account = DutiesAndTaxesAccounts.new(:apply_to => apply_to,
        :description => description, :tax_rate => rate, :filling_frequency => filling_frequency,
        :registration_number => registration_number, :calculate_on_percent=> calculate_on_percent,
        :calculation_method=> calculation_method )
      account.accountable = sub_account
      account
    end

    def get_sales_taxes(company)
      accounts = Account.get_tax_accounts(company).by_end_date(Time.zone.now.to_date)
      result_set = []
      accounts.each do |account|
        result_set << account if account.accountable.apply_to == 1
      end
      result_set
    end

    def get_purchase_taxes(company)
      accounts = Account.get_tax_accounts(company).by_end_date(Time.zone.now.to_date)
      result_set = []
      accounts.each do |account|
        result_set << account if account.accountable.apply_to == 2
      end
      result_set
    end


def get_invoice_taxes(company)
      accounts = Account.get_tax_accounts(company).by_end_date(Time.zone.now.to_date)
      result_set = []
      accounts.each do |account|
        result_set << account if account.accountable.apply_to == 2
      end
      result_set
    end
    def withdraw_from_accounts(company)
      accounts= TransactionType.fetch_from_accounts(company,'bankacc')
      arr=[]
      accounts.each do |account|
        hash={}
        hash["id"]= account.id
        hash["name"]= account.name
        arr<<hash
      end
      arr.to_json
    end

    def withdraw_to_accounts(company)
      accounts= TransactionType.fetch_to_accounts(company,'cashacc')
      arr=[]
      accounts.each do |account|
        hash={}
        hash["id"]= account.id
        hash["name"]= account.name
        arr<<hash
      end
      arr.to_json
    end

    def deposit_from_accounts(company)
      accounts= TransactionType.fetch_from_accounts(company,'cashacc')
      arr=[]
      accounts.each do |account|
        hash={}
        hash["id"]= account.id
        hash["name"]= account.name
        arr<<hash
      end
      arr.to_json
    end

    def deposit_to_accounts(company)
      accounts= TransactionType.fetch_to_accounts(company,'bankacc')
      arr=[]
      accounts.each do |account|
        hash={}
        hash["id"]= account.id
        hash["name"]= account.name
        arr<<hash
      end
      arr.to_json
    end
    def transfer_cash_from_accounts(company)
      accounts= TransactionType.fetch_from_accounts(company, 'transferacc')
      arr=[]
      accounts.each do |account|
        hash={}
        hash["id"]= account.id
        hash["name"]= account.name
        arr<<hash
      end
      arr.to_json
    end

    def transfer_cash_to_accounts(company)
      accounts= TransactionType.fetch_to_accounts(company, 'transferacc')
      arr=[]
      accounts.each do |account|
        hash={}
        hash["id"]= account.id
        hash["name"]= account.name
        arr<<hash
      end
      arr.to_json
    end

  def journal_to_accounts(company)
      accounts= TransactionType.fetch_to_accounts(company, 'journal')
      arr=[]
      accounts.each do |account|
        hash={}
        hash["id"]= account.id
        hash["name"]= account.name
        arr<<hash
      end
      arr.to_json
    end

 def saccounting_to_accounts(company)
      accounts= TransactionType.fetch_to_accounts(company, 'saccounting')
      arr=[]
      accounts.each do |account|
        hash={}
        hash["id"]= account.id
        hash["name"]= account.name
        arr<<hash
      end
      arr.to_json
    end
 
 def gstr_advance_receipt_from_accounts(company)
  accounts= TransactionType.fetch_from_accounts(company, 'sales')
      arr=[]
      accounts.each do |account|
        hash={}
        hash["id"]= account.id
        hash["name"]= account.name
        arr<<hash
      end
      arr.to_json
 end





 def credit_note_from_accounts(company)
      accounts= TransactionType.fetch_from_accounts(company, 'journal')
      arr=[]
      accounts.each do |account|
        hash={}
        hash["id"]= account.id
        hash["name"]= account.name
        arr<<hash
      end
      arr.to_json
    end

    def credit_note_to_accounts(company)
      accounts= TransactionType.fetch_to_accounts(company, 'sales')
      arr=[]
      accounts.each do |account|
        hash={}
        hash["id"]= account.id
        hash["name"]= account.name
        arr<<hash
      end
      arr.to_json
    end

    def debit_note_from_accounts(company)
      accounts= TransactionType.fetch_from_accounts(company, 'journal')
      arr=[]
      accounts.each do |account|
        hash={}
        hash["id"]= account.id
        hash["name"]= account.name
        arr<<hash
      end
      arr.to_json
    end

    def debit_note_to_accounts(company)
      accounts= TransactionType.fetch_to_accounts(company, 'sales')
      arr=[]
      accounts.each do |account|
        hash={}
        hash["id"]= account.id
        hash["name"]= account.name
        arr<<hash
      end
      arr.to_json
    end
    def reimbursement_note_from_accounts(company)
      accounts= TransactionType.fetch_from_accounts(company, 'purchases')
      arr=[]
      accounts.each do |account|
        hash={}
        hash["id"]= account.id
        hash["name"]= account.name
        arr<<hash
      end
      arr.to_json
    end

    def reimbursement_note_to_accounts(company)
      accounts= TransactionType.fetch_to_accounts(company, 'sales')
      arr=[]
      accounts.each do |account|
        hash={}
        hash["id"]= account.id
        hash["name"]= account.name
        arr<<hash
      end
      arr.to_json
    end
    
    def receipt_from_accounts(company)
      accounts= TransactionType.fetch_from_accounts(company,'receipts')
      arr=[]
      accounts.each do |account|
        hash={}
        hash["id"]= account.id
        hash["name"]= account.name
        arr<<hash
      end
      arr.to_json
    end

    def advance_receipt_from_accounts(company)
      accounts= TransactionType.fetch_from_accounts(company,'receipts')
      arr=[]
      accounts.each do |account|
        hash={}
        hash["id"]= account.id
        hash["name"]= account.name
        arr<<hash
      end
      arr.to_json
    end



    def payment_to_accounts(company)
      accounts= TransactionType.fetch_to_accounts(company, 'payments')
      arr=[]
      accounts.each do |account|
        hash={}
        hash["id"]= account.id
        hash["name"]= account.name
        arr<<hash
      end
      arr.to_json
    end
    def income_from_accounts(company)
      accounts= TransactionType.fetch_from_accounts(company,'receipts')
      arr=[]
      accounts.each do |account|
        hash={}
        hash["id"]= account.id
        hash["name"]= account.name
        arr<<hash
      end
      arr.to_json
    end

   def expense_from_accounts(company)
      accounts= TransactionType.fetch_from_accounts(company,'expenseacc')
      arr=[]
      accounts.each do |account|
        hash={}
        hash["id"]= account.id
        hash["name"]= account.name
        arr<<hash
      end
      arr.to_json
    end

    # def company_account_groups(company)
    #   groups = AccountHead.where("name not in ('Current Assets', 'Vendors (Creditors)', 'Customers (Debtors)','DutiesAndTaxesAccounts')", :deleted =>false, :company_id => company)
    #   arr=[]
    #   groups.each do |group|
    #     hash={}
    #     hash["id"]= group.id
    #     hash["name"]= group.name
    #     arr<<hash
    #   end
    #   arr.to_json
    # end

    # def company_users(company)
    #   users = User.where(:company_id=> company, :deleted=> false)
    #   arr=[]
    #   users.each do |user|
    #     hash={}
    #     hash["id"]= user.id
    #     hash["name"]= user.first_name
    #     arr<<hash
    #   end
    #   arr.to_json
    # end
  end

  def update_tax(params)
    result = false
    transaction do
      account = Account.find id
      account.attributes = params
      account.name = "#{params[:name]} #{accountable.apply_to == 1 ? 'on sales' : 'on purchase'}"
      account.save
      result = true
    end
    result
  end

 #method to create default account at ne signup for payheads
  def self.create_default_accounts(company_id, user_id, financial_year)
    account_names = ["Basic","House Rent Allowance", "Dearness Allowance", "Travelling Allowance", "Bonus","Gain or loss on fluctuation in foreign currency","Payment Gateway Charge"]
    account_head = AccountHead.get_root_head(company_id, "Indirect Expenses")
    account_names.each do |name|
      account = Account.new
      account.name = name
      account.company_id = company_id
      account.created_by = user_id
      account.start_date = financial_year.start_date
      account.erasable= false if name=="Gain or loss on fluctuation in foreign currency"
      account.erasable= false if name=="Payment Gateway Charges"
      account.account_head_id = account_head.id
      if !account.account_head_id.blank?
        sub_account = IndirectExpenseAccount.new
        account.accountable = sub_account
      end
      account.save!
    end
    default_accounts = {"Cash Accounts" => ["Cash in hand"],
      "Bank Accounts" => ["Citi bank", "Standard chartered bank", "SBI bank"],
      "Deferred Tax Asset Or Liability" => ["Deferred Tax Asset Or Liability"] }
    default_accounts.each do |key, values|
      head = AccountHead.find_by_company_id_and_name(company_id, key.to_s)
      values.each do |value|
        account = Account.new(:name => value, :company_id => company_id,
          :created_by => user_id, :account_head_id => head.id, start_date: financial_year.start_date)
        sub_account = nil
        case key
        when "Cash Accounts"
          sub_account = CashAccount.new()
        when "Bank Accounts"
          sub_account = BankAccount.new(:bank_name => value, :account_number => "")
        when "Customers (Debtors)"
          sub_account = SundryDebtor.new()
        when "Vendors (Creditors)"
          sub_account = SundryCreditor.new()
        when "Deferred Tax Asset Or Liability"
          sub_account = DeferredTaxAssetOrLiability.new()
        end
        account.accountable = sub_account
        account.save
      end
    end
  end

  def self.create_account(company, user, account_head, financial_year, name, sub_account_name)
    account = Account.new(:company_id=>company, :account_head_id=>account_head.id, :name=>name,
      :created_by=>user, :start_date=> financial_year.start_date, :erasable=>false)
    sub_account=sub_account_name.constantize.new
    account.accountable=sub_account
    account.save!
    account
  end

  def self.create_direct_income(company, user, head, financial_year)
    new_income_account = Account.new(:company_id => company, :account_head_id => head,
      :name => "Sales Account - default income", :created_by => user, start_date: financial_year.start_date, :erasable=>false)
    sub_account = DirectIncomeAccount.new()
    new_income_account.accountable = sub_account
    new_income_account.save!
    new_income_account
  end

  def self.create_direct_expense(company, user, head, financial_year)
    new_expense_account = Account.new(:company_id => company, :account_head_id => head,
     :name => "Purchase Account - default expense", :created_by => user, start_date: financial_year.start_date, :erasable=>false)
    sub_account = DirectExpenseAccount.new(:inventoriable => false)
    new_expense_account.accountable = sub_account
    new_expense_account.save!
    new_expense_account
  end

  def self.create_other_expense_on_sales(company, user, head, financial_year)
   sales_acc_names = ["shipping charge", "adjustment on sales"]
   sales_acc_names.each do |name|
    new_other_expense_account = Account.new(:company_id => company, :account_head_id => head,
     :name => name, :created_by => user, start_date: financial_year.start_date, :erasable=>false)
    sub_account = IndirectExpenseAccount.new(:inventoriable => false)
    new_other_expense_account.accountable = sub_account
    new_other_expense_account.save
   end
  end
  def self.create_other_expense_on_purchase(company, user, head, financial_year)
    purchase_acc_names = ["other charge on purchase","adjustment on purchase"]
    purchase_acc_names.each do |name|
      new_other_expense_account = Account.new(:company_id => company, :account_head_id => head,
       :name => name, :created_by => user, start_date: financial_year.start_date, :erasable=>false)
      sub_account = DirectExpenseAccount.new(:inventoriable => false)
      new_other_expense_account.accountable = sub_account
      new_other_expense_account.save
    end
  end

  def self.create_tds_receivable_acc(company, user, head, financial_year)
    tds_receivable_acc = Account.new(:company_id => company, :account_head_id => head, :name => "tds receivable", :created_by => user, start_date: financial_year.start_date, :erasable=>false)
    sub_account = OtherCurrentAsset.new()
    tds_receivable_acc.accountable = sub_account
    tds_receivable_acc.save
  end
  def self.create_tds_payable_acc(company, user, head, financial_year)
    names = ["Sec.193 - Interest on Debentures", "Sec.194 - Deemed Dividend", "Sec. 194A - Interest on Securities","Sec. 194B - Winnings from Lotteries or Puzzle or Game",
              "Sec. 194 BB - Winnings from Horse Race","Sec. 194 C 1- Payment to Contractors","Sec. 194 C 2- Payment to Sub-Contractors or for Advertisements","Sec. 194 D- Payment of Insurance Commission",
              "Sec. 194 EE -Payment of NSS Deposits","Sec. 194 F -Repurchase of units by Mutual Funds or UTI","Sec. 194 G - Commission on Sale of Lottery tickets","Sec. 194 H - Commission or Brokerage",
              "Sec. 194 I - Rent of Land or Building or Furniture or Plant and Machinery", "Sec. 194 IA - Transfer of Immovable Property","Sec. 194 J - Professional or technical services or royalty " ,
              "Sec. 194 J 1 - Remuneration or commission to director of the company","Sec. 194 J ba - Any remuneration or fees or commission paid to a director of a company other than Salary ",
              "Sec. 194 L - Compensation on acquisition of Capital Asset","Sec. 194 LA - Compensation on acquisition of certain immovable property" ]
    names.each do |name|
      tds_payable_acc = Account.new(:company_id => company, :account_head_id => head, :name => name,:created_by => user, start_date: financial_year.start_date)
      sub_account = DutiesAndTaxesAccounts.new(:tax_rate=>0)
      tds_payable_acc.accountable = sub_account
      tds_payable_acc.save
    end
  end
#-------------------------------------
  def if_reseller_product_name_present
    if accountable_type == 'PurchaseAccount'
      account_heads = AccountHead.get_sales_account(company_id)
      account_heads.each do |account_head|
       if !account_head.blank?
        sales_account = get_account_obj(account_head.id, name)
        unless sales_account.blank?
          errors.add(:base, "An Account with same name is already present in products/services accounts. Please enter a different name.")
        end
       end
      end
    end

    if accountable_type == 'SalesAccount'
      account_heads = AccountHead.get_purchase_head(company_id)
      account_heads.each do |account_head|
       if !account_head.blank?
        purchase_account = get_account_obj(account_head.id, name)
        unless purchase_account.blank?
          errors.add(:base, "An account with same name already exists within purchase accounts. Please enter a different name.")
        end
      end
     end
    end

  end



  def self.accounts_by_company(company_id)
    Account.where(:company_id => company_id, :deleted => false).order("created_at DESC").page
  end

  def created_by_user
    User.find(self.created_by).first_name
  end

  def bank_accounts(company_id)
  end

  # Commented by Naveen on 07-Jun-2017 as it is no longer needed
  # Will delete after impact analysis
  # def closing_balance
  #   ledgers.blank? ? 0 : (ledgers.sum(:debit) - ledgers.sum(:credit))
  # end

  def current_balance
    opening_bal = 0
    opening_bal = opening_balance unless opening_balance.blank?
    closing_balance +  opening_bal
  end

  def delete(deleted_by_user)
    result = false
    if self.ledgers.empty? && corresponding_ledgers.empty?
      result = update_attributes(:deleted_by => deleted_by_user, :deleted => true, :deleted_datetime => Time.zone.now)
    else
      errors.add(:base,"This account has ledgers associated with it. You need to delete the ledgers before deleting this account.")
    end
    result
  end

  def self.get_account_id(name, company)
    acc = Account.find_by_name_and_company_id(name, company)
    if acc.blank?
      nil
    else
      acc.id
    end
  end

  def self.get_cash_accounts(company)
    get_accounts(company, "CashAccount")
  end

  def self.get_product_or_service_accounts(company)
    get_accounts(company, "SalesAccount")
  end
  def self.get_purchase_accounts(company)
    get_accounts(company, 'PurchaseAccount')
  end
  def self.get_bank_accounts(company)
    get_accounts(company, "BankAccount")
  end
  def self.get_customer_vendor_accounts(company)
    get_accounts(company, ["SundryDebtor", "SundryCreditor"])
  end

  def self.get_customer_accounts(company)
    get_accounts(company, "SundryDebtor")
  end

  def self.get_vendor_accounts(company)
    get_accounts(company, "SundryCreditor")
  end

  def self.get_tax_accounts(company)
    # get_accounts(company, "DutiesAndTaxesAccounts")
    where(:company_id => company, :accountable_type => "DutiesAndTaxesAccounts", :deleted => false, :parent_id => nil)
    #where(:company_id => company, :accountable_type => "DutiesAndTaxesAccounts", :deleted => false)
  end

  #naveen 21 Aug 2017 added duplicte method to accomodate GST taxes in the tax summary report
  def self.get_tax_report_tax_accounts(company)
    # get_accounts(company, "DutiesAndTaxesAccounts")
    where(:company_id => company, :accountable_type => "DutiesAndTaxesAccounts", :deleted => false)
  end

  def self.get_vat_accounts(company)
    vat_accounts = where("company_id = ? and accountable_type = 'DutiesAndTaxesAccounts' and deleted = ? and name like ?", company,false,"%vat%")
  end

  def self.get_payable_accounts(company)
    get_accounts(company, ["PurchaseAccount","DutiesandTax"])
  end

  def self.get_receivable_accounts(company)
    get_accounts(company, ["SalesAccount","DutiesandTax"])
  end

  def self.get_ind_exp_accounts(company)
    get_accounts(company, "IndirectExpenseAccount")
  end

  def self.get_expense_accounts(company)

    where(:company_id => company, :accountable_type => ["IndirectExpenseAccount", "DirectExpenseAccount"], :deleted => false )
  end

  def self.get_indirect_income_accounts(company)
     get_accounts(company, "IndirectIncomeAccount")
  end

  def self.get_income_accounts(company)
    where(:company_id => company, :accountable_type => ["IndirectIncomeAccount", "DirectIncomeAccount"], :deleted => false )
  end

  def self.get_accounts(company, account_type)
    where(:company_id => company, :accountable_type => account_type, :deleted => false)
  end

  # accounts for shiping accounts
  def self.get_other_expense_accounts(company)
    account_head = AccountHead.get_other_expense_head(company)
    where(:company_id => company.id, :account_head_id => account_head.id)
  end

  def self.get_other_expense_on_purchase_accounts(company)
    account_head = AccountHead.get_other_expense_head_on_purchase(company)
    where(:company_id => company.id, :account_head_id => account_head.id)
  end

  def self.get_tds_receivable_accounts(company)
    account_head = AccountHead.get_tds_receivable_head(company)
    where(:company_id => company.id, :account_head_id => account_head.id)
  end

  def self.get_tds_payable_accounts(company)
    account_head = AccountHead.get_tds_payable_head(company)
    where(:company_id => company.id, :account_head_id => account_head.id)
  end

  #[FIXME] This method is no longer called from balance sheet.
  def self.get_non_tds_tax_accounts(company, page, sort)
    account_head = company.account_heads.find_by_name('Duties and Taxes')
    where(:company_id => company.id, :accountable_type => "DutiesAndTaxesAccounts", :deleted => false, :parent_id => nil,
      :account_head_id => account_head.id).includes(:accountable).page(page).order(sort)
  end

  def is_customer?
    accountable_type == "SundryDebtor"
  end
  def is_vendor?
    accountable_type == "SundryCreditor"
  end

  # def self.get_top_customers(company)
  #   where(:company_id => company, :accountable_type => "SundryDebtor", :deleted => false).includes(:ledgers).order(:closing_balance).limit(5)
  # end

def create_corresponding_sales
    if accountable_type == "PurchaseAccount" && accountable.reseller_product? && !company.plan.free_plan?
      sales_account_heads = AccountHead.get_sales_account(company.id)
      sales_account_heads.each do |sales_account_head|
       @sales_account_head = AccountHead.find(sales_account_head.id)
      end
          #creating sales account
          account = Account.new(attributes)
          account.opening_balance = 0
          account.company = company
          account.account_head_id = @sales_account_head.id

        sales = SalesAccount.new
        sales.inventoriable = accountable.inventoriable
        sales.unit_cost = accountable.unit_cost
        sales.description = accountable.description

        account.accountable = sales
        account.created_by = created_by
        if account.save!(:validate => false)
        end
    end
  end

  def update_reseller_flow(account_name)

    if accountable_type == 'SalesAccount'
      account_heads = AccountHead.get_purchase_head(company_id)
      account_heads.each do |account_head|
       @purchase_account = get_account_obj(account_head.id, account_name)
      end
      unless @purchase_account.blank?
        @purchase_account.update_attributes(:name => name, :opening_balance => opening_balance)
        @purchase_account.accountable.update_attributes(:inventoriable => accountable.inventoriable, :unit_cost => accountable.unit_cost, :description => accountable.description)
        if @purchase_account.accountable.inventoriable?
          @purchase_account.manage_inventory
        end
      end
    end

    if accountable_type == 'PurchaseAccount'
      account_heads = AccountHead.get_sales_account(company_id)
      account_heads.each do |account_head|
       @sales_account = get_account_obj(account_head.id, account_name)
      end
      unless @sales_account.blank?
        @sales_account.update_attributes(:name => name, :opening_balance => opening_balance)
        @sales_account.accountable.update_attributes(:inventoriable => accountable.inventoriable, :unit_cost => accountable.unit_cost, :description => accountable.description)
      end

      if accountable.inventoriable?
        self.manage_inventory
      end

      self.manage_reseller_product(@sales_account)
    end
  end

  def get_account_obj(account_head, account_name)
    Account.find_by_name_and_company_id_and_account_head_id(account_name, company_id, account_head)
  end

  def manage_inventory
    if product.blank?
      Product.create(:company_id => company_id, :created_by => created_by, :account_id => id, :name => name)
    else
      product.update_corresponding_product(name)
    end
  end

  def manage_reseller_product(sales_account)
    if sales_account.blank?
      if accountable.reseller_product?
        self.create_corresponding_sales
      end
    else
      if accountable.reseller_product?
        sales_account.update_attributes(:deleted => false, :deleted_by => created_by, :deleted_datetime => Time.zone.now)
      else
        sales_account.update_attributes(:deleted => true, :deleted_by => created_by, :deleted_datetime => Time.zone.now)
      end
    end
  end

  def reseller?
    result = false
    if accountable_type == "SalesAccount"
      account_heads = AccountHead.get_purchase_head(company_id)
      account_heads.each do |account_head|
       @purchase_account = get_account_obj(account_head.id, name)
      end
      result = true unless @purchase_account.blank?
    end
    result
  end

  def products
    Product.where("income_account_id=:id or expense_account_id=:id", :id=>id)
  end

  def has_ledgers?
    !Ledger.joins("account").where("account_id = ?", id).blank?
  end

  def has_product?
    !products.blank? #|| ( !product.blank? && product.has_stock_vouchers? )
  end

  def has_vouchers?
   !payroll_execution_jobs.blank? || !all_purchases.blank? || !all_invoices.blank? || !estimates.blank? || !purchase_orders.blank? || !sales_orders.blank? || !delivery_challans.blank? || !invoice_line_items.blank? || !purchase_line_items.blank? || !estimate_line_items.blank? || !purchase_order_line_items.blank?
  end
  def all_purchases
    Purchase.where(:company_id=>company_id, :account_id=>id)
  end
  def all_invoices
    Invoice.where(:company_id=>company_id, :account_id=>id)
  end

  def has_payheads?
    !Payhead.where(:company_id=> company.id, :account_id=> id).blank?
  end

  def is_used?
    has_ledgers? || has_vouchers? || has_payheads?
  end

  def sales_tax_name
    tax_name = "#{name.sub(' on sales', '')}"
    additional_tax = 0
    accounts = Account.where(:company_id => company_id, :parent_id => id, :deleted => false)
    unless accounts.blank?
      accounts.each do |account|
        additional_tax += account.accountable.tax_rate unless account.accountable.blank?
      end
    end
    if additional_tax > 0 && self.accountable.calculation_method!=4
      tax_name = "#{name.sub(' on sales', '')}+#{additional_tax}%(linked tax)"
    elsif self.accountable.calculation_method==4
      tax_name = "#{name.sub(' on sales', '')}(split tax)"  
    end
    tax_name
  end

  def purchase_tax_name
    tax_name = "#{name.sub(' on purchases', '')}"
    additional_tax = 0
    accounts = Account.where(:company_id => company_id, :parent_id => id, :deleted => false)
    unless accounts.blank?
      accounts.each do |account|
        additional_tax += account.accountable.tax_rate unless account.accountable.blank?
      end
    end
    if additional_tax > 0 && self.accountable.calculation_method!=4
      tax_name = "#{name.sub(' on purchases', '')}+#{additional_tax}%(linked tax)"
    elsif self.accountable.calculation_method==4
      tax_name = "#{name.sub(' on purchases', '')} (split tax)"
    end
    tax_name
  end

  #[FIXME] This method is redundant with current design. Opening balance can be retrieved from the attribute opening_balance.
  def get_opening_balance(current_user, company_id, financial_year, start_date, branch_id)
    # branch_id=current_user.branch_id
    opening_bal = 0
    if financial_year.blank? && !start_date.blank?
      financial_year = FinancialYear.where("company_id=? and start_date<=? and end_date>?", company_id, start_date.to_date, start_date.to_date).first
    end
    unless financial_year.blank?
      previous_financial_year = financial_year.get_previous_year
      if Account.account_type.include?(accountable_type)
        opening_bal=self.opening_balance unless self.opening_balance.blank? || history_any? || !(branch_id.blank? || current_user.owner?)
      elsif
        if !start_date.blank? && start_date.to_date < financial_year.start_date && !previous_financial_year.blank?
          opening_bal = get_opening_balance(current_user, company_id, previous_financial_year, start_date, branch_id)
        else
          if !financial_year.freeze?
            if previous_financial_year.blank? || previous_financial_year.freeze?
              opening_bal = self.opening_balance unless self.opening_balance.blank? || !(branch_id.blank? || current_user.owner?)
            else
              opening_bal = get_closing_balance(current_user, company_id, previous_financial_year, previous_financial_year.end_date, branch_id)
            end
          else
            account_history = AccountHistory.find_by_company_id_and_account_id_and_financial_year_id(company_id, id, financial_year.id)
            if !account_history.blank? && !account_history.opening_balance.blank?
              opening_bal = account_history.opening_balance
            end
          end

          if !start_date.blank? && start_date.to_date > financial_year.start_date
            opening_bal += Ledger.get_current_year_transactions(company_id, current_user, id, financial_year.start_date, (start_date.to_date - 1.days), branch_id)
          end
        end
      end
    end
    opening_bal
  end

  #[FIXME] This method is redundant with current design. The closing balance should be opening_balance + sum of all ledger entries
  def get_closing_balance(current_user, company_id, financial_year, end_date, branch_id)
    close_balance = 0
    if !end_date.blank? && end_date.to_date < financial_year.end_date
      end_date = end_date.to_date
    else
      end_date = financial_year.end_date
    end
    currenct_financial_year=FinancialYear.where("company_id=? and start_date<? and end_date>=?", company_id, end_date, end_date).first
    close_balance=Ledger.current_year_balance(company_id, current_user, self.id, currenct_financial_year.start_date, end_date, branch_id) unless currenct_financial_year.blank?
    close_balance
  end

  def get_currency
    if accountable_type == "SundryDebtor" || accountable_type =="SundryCreditor"
      currency = customer.blank? ? vendor.currency_code : customer.currency
    end
  end
 def get_gstn
    gstn_value = customer.gstn_id unless customer.blank?
  end

  def get_currency_id
    if accountable_type == "SundryDebtor" || accountable_type =="SundryCreditor"
    currency = customer.blank? ? vendor.currency_id : customer.currency_id
    end
  end

  def ledger_minimum_date
    if !ledgers.minimum(:transaction_date).blank?
      if start_date > ledgers.minimum(:transaction_date)
        errors.add(:base, "The start date for this account cannot be after #{ledgers.minimum(:transaction_date)}. Please set it on or before #{ledgers.minimum(:transaction_date)}.")
      end
    end
  end
end

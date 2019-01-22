class ReceiptVoucher < ActiveRecord::Base
  scope :by_branch_id, lambda {|id| where(:branch_id => id) unless id.blank? }
  scope :by_deleted, lambda {|del| where(:deleted => del)}
  scope :by_date, lambda{|fin_year| where(:received_date => fin_year.start_date..fin_year.end_date) unless fin_year.blank?}
  scope :by_customer, lambda{|customer| where(:from_account_id=> customer) unless customer.blank? }
  scope :by_voucher, lambda{|voucher_no| where("voucher_number like ?", "%#{voucher_no}%")}
  scope :by_date_range, lambda{|start_date, end_date| where(:received_date=> start_date..end_date) unless start_date.blank? || end_date.blank? }
  scope :by_amount_range, lambda{|min_amt, max_amt| where(:amount=> min_amt..max_amt)}
  scope :by_project, lambda{|project| where(:project_id=>project) unless project.blank? }
  scope :by_advance, lambda { |is_advance| is_advance.blank? ? where(:advanced=>false) : where(:advanced=>true) }

  belongs_to :company
  has_many :invoices_receipts, :conditions => {:deleted => false}
  has_many :invoices, :through => :invoices_receipts, :dependent=> :destroy
  belongs_to :project
  belongs_to :account
  belongs_to :customer
  belongs_to :to_account, :class_name=>"Account", :foreign_key=>:to_account_id
  belongs_to :from_account, :class_name=>"Account", :foreign_key=>:from_account_id
  belongs_to :user, :foreign_key=> :created_by
  belongs_to :currency
  #has_one :payment_mode, :foreign_key => :voucher_id, :dependent => :destroy
  has_many :ledgers, :as => :voucher, :dependent => :destroy
  has_one :payment_detail, :as => :voucher, :dependent => :destroy
  has_one :billing_address, :class_name=>'Address', :as=>:addressable, :conditions=>{:address_type=>1}

  accepts_nested_attributes_for :payment_detail
  accepts_nested_attributes_for :invoices_receipts, :reject_if => lambda {|a| a[:amount].blank? }
  attr_accessible :advanced, :allocated, :deleted_by, :deleted, :deleted_datetime, :voucher_number, :received_date, :voucher_date, :tds_amount,:tds_account_id,
                  :description, :amount, :from_account_id, :to_account_id ,:payment_detail_attributes, :restored_by, :restored_datetime,:currency_id, :exchange_rate,
                  :project_id, :invoice_id, :invoices_receipts_attributes
  
  #validations
  validates_associated :payment_detail
  validates_presence_of  :voucher_number, :voucher_date, :received_date, :amount, :to_account_id, :from_account_id
  # validate :invoice_id, :presence => true
  validates_uniqueness_of :voucher_number, :scope => :company_id
  validates :amount, :numericality => {:greater_than_or_equal_to => 0.01,
                                        :message => " should not be zero or negative ." }

  # validate :voucher_date_and_received_date
  validate :validate_from_account_and_to_account
  validate :check_amount_on_create, :on => :create
  validate :check_amount_on_update, :on => :update
  # validate :save_only_in_current_year
  validate :save_in_frozen_fy
  validate :validate_from_account_type, :if => :from_account_id
  validate :validate_to_account_type, :if => :to_account_id
  validate :validate_tds_amount, :if =>  :tds_amount
  validate :available_amount, :if => :advanced, :on=>:update
  validate :amount_underflow, :if=>:advanced
  validates_presence_of :exchange_rate, :if => lambda{|e| !e.from_account.blank? && !e.from_account.get_currency_id.blank?}
  validate :validate_exchange_rate, :if => :exchange_rate
  # after_destroy :update_included_invoice_status
  validate :account_effective_date
  attr_accessor :fin_year

  def get_party
    from_account.customer.blank? ? from_account.vendor : from_account.customer
  end

  def voucher_setting
    VoucherSetting.by_voucher_type(2, company_id).first
  end

  def account_effective_date
    if !from_account.blank? && !received_date.blank? && received_date < from_account.start_date
      errors.add(:received_date, "must be after account activation, #{from_account.name} is activated since #{from_account.start_date}")
    end
    if !to_account.blank? && !received_date.blank? && received_date < to_account.start_date
      errors.add(:received_date, "must be after account activation, #{to_account.name} is activated since #{to_account.start_date}")
    end
  end

  def validate_exchange_rate
    account = Account.find_by_id(from_account_id)
    unless account.blank?
    customer_currency = account.get_currency
     if !customer_currency.blank? && company.currency_code != customer_currency
      if exchange_rate <= 0
        errors.add(:exchange_rate, "should not be zero or negative")
      end
     end
    end
  end

  def allocated_status
    if allocated?
      "Allocated"
    else
      "Unallocated"
    end
  end

  def currency_code
    if currency.blank?
      company.currency_code
    else
      currency.currency_code
    end
  end

  def from_account
   Account.find_by_id(from_account_id) unless from_account_id.blank?
  end

  def create_invoice_histories
    invoices.each do |invoice|
      invoice.create_invoice_history(invoice.id,company_id,created_by,"payment added with voucher no. '#{voucher_number}' ")
    end
  end

   def create_online_payment_histories
    invoices.each do |invoice|
      invoice.create_invoice_history(invoice.id,company_id,created_by,"Online payment received and an entry has been made with voucher no. '#{voucher_number}' for this invoice generated ")
    end
  end

  def save_in_frozen_fy
    if !received_date.blank? && in_frozen_year?
      errors.add(:received_date, "can't be in frozen financial year")
    end
  end

  def in_frozen_year?
    FinancialYear.check_if_frozen(company_id, received_date)
  end

  def amount_underflow
    if (!amount.blank? && amount < invoices_receipts.sum(:amount)) || ( !tds_amount.blank? && tds_amount < invoices_receipts.sum(:tds_amount))
      errors.add(:base, "Can't change allocated amount" )
    end
  end

  def set_amount_allocation
    allocated_amount = invoices_receipts.sum(:amount)
    allocated_tds = invoices_receipts.sum(:tds_amount)
    tds_deducted=0
    tds_deducted=tds_amount unless tds_amount.blank?
    if allocated_tds==tds_deducted && allocated_amount==amount
      update_attribute("allocated", true)
    elsif allocated_tds<tds_deducted || allocated_amount<amount
      update_attribute("allocated", false)
    end
  end

  def available_amount
    unless invoices_receipts.blank?
      allocated_amount = 0
      allocated_tds = 0
      invoices_receipts.each do |invoice_receipt|
        allocated_amount+=invoice_receipt.amount unless invoice_receipt.amount.blank?
        allocated_tds+=invoice_receipt.tds_amount unless invoice_receipt.tds_amount.blank?
      end
      if allocated_amount<=0
        errors.add(:amount, "can't negative or zero.")
      end
      if allocated_amount>amount
        errors.add(:base, "Received amount should not be greater than unallocated amount")
      end
      if !tds_amount.blank? && allocated_tds>tds_amount
        errors.add(:base, "TDS deducted should not be greater than unallocated tds amount")
      end
    end
  end

  def unallocated_amount
    amt=0
    if advanced?
      amt=amount-invoices_receipts.sum(:amount) unless amount.blank?
    end
    amt
  end

  def unallocated_tds_amount
    amt=0
    if advanced?
      amt=tds_amount-invoices_receipts.sum(:tds_amount) unless tds_amount.blank?
    end
    amt
  end

  def update_included_invoice_status
    invoices.each do |invoice|
      invoice.update_invoice_status
    end
  end

  def update_included_invoice_online_status
    invoices.each do |invoice|
      invoice.update_invoice_online_status
    end
  end

  def invoice_by_id(invoice_id)
    invoices_receipts.where(:invoice_id=>invoice_id).first
  end

  def validate_from_account_type
    if !(["CapitalAccount","DepositAccount","DirectIncomeAccount","IndirectIncomeAccount","LoansAdvancesAccount",
            "LoanAccount","SecuredLoanAccount","SundryDebtor", "SundryCreditor","SuspenseAccount","UnsecuredLoanAccount"]).include?(Account.find(from_account_id).accountable_type)
      errors.add(:from_account_id,"you entered is wrong, please select right account")
    end
  end
  def validate_to_account_type
     if !(["BankAccount","CashAccount","SecuredLoanAccount","DirectIncomeAccount","IndirectIncomeAccount","OtherCurrentAsset","CurrentLiability"]).include?(Account.find(to_account_id).accountable_type)
      errors.add(:to_account_id,"you entered is wrong, please select right account")
     end
  end

  def validate_tds_amount
    if advanced?
      unless tds_amount.blank? || amount.blank?
        errors.add(:tds_amount, "can't be greater than amount") unless amount >= tds_amount
      end
      invoices_receipts.each do |invoice_receipt|
        unless invoice_receipt.tds_amount.blank?
          errors.add(:tds_amount, "can't be greater than received amount for invoice#{invoice_receipt.invoice.invoice_number}") if invoice_receipt.amount.blank? || invoice_receipt.tds_amount>invoice_receipt.amount
        end
      end
    else
      invoices_receipts.each do |invoice_receipt|
        unless invoice_receipt.tds_amount.blank? || invoice_receipt.amount.blank?
          errors.add(:tds_amount, "should not greater than received amount for invoice #{invoice_receipt.invoice.invoice_number}") unless invoice_receipt.amount >= invoice_receipt.tds_amount
        end
      end
    end
  end

  # def currency
  #   if currency_id.blank?
  #    self.company.currency_code
  #   else
  #    Currency.find(currency_id).currency_code
  #   end
  # end

  def foreign_currency?
    !currency_id.blank? && !exchange_rate.blank? && exchange_rate!=0
  end

  def check_amount_on_create
    invoices_receipts.each do |invoice_receipt|
      invoice = invoice_receipt.invoice
      if !invoice_receipt.amount.blank? && invoice_receipt.amount<0
        errors.add(:amount, "can't not be negative for invoice(#{invoice.invoice_number})")
      else
        if !invoice.blank?
          inv_rct_amount = invoice_receipt.amount
          inv_rct_amount += invoice_receipt.tds_amount unless invoice_receipt.tds_amount.blank?
          if inv_rct_amount > invoice.outstanding
            errors.add(:base, "Amount must not be greater than invoice(#{invoice.invoice_number}) amount(you have to pay #{invoice.currency}#{invoice.outstanding} only)")
          end
        end
      end
    end
  end

  def check_amount_on_update
    invoices_receipts.each do |invoice_receipt|
      invoice = invoice_receipt.invoice
      if !invoice_receipt.amount.blank? && invoice_receipt.amount<0
        errors.add(:amount, "can't not be negative for invoice(#{invoice_receipt.invoice.invoice_number})")
      elsif !invoice_receipt.amount.blank?
        if !invoice.blank?
          total_received_amt = invoice.total_received_amt
          self_receipt = invoices_receipts.where(:invoice_id=>invoice.id).first
          amt_before_update=0
          unless self_receipt.blank?
            amt_before_update = self_receipt.amount
            amt_before_update += self_receipt.tds_amount unless self_receipt.tds_amount.blank?
            total_received_amt-=amt_before_update unless amt_before_update.blank?
          end
          total_received_amt += invoice_receipt.amount
          total_received_amt += invoice_receipt.tds_amount unless invoice_receipt.tds_amount.blank?
          if total_received_amt > invoice.total_amount
            errors.add(:base, "Amount must not be greater than invoice(#{invoice.invoice_number}) outstanding(you have to pay #{invoice.currency}#{invoice.outstanding+amt_before_update} only)")
          end
        end
      end
    end
  end

  def validate_from_account_and_to_account
    if self.from_account_id == self.to_account_id
        errors.add(:base, "Both accounts should not be same")
    end
  end

  def from_account_name
      from_account.name
  end

  def to_account_name
      to_account.name
  end

  def currency_multiplied_amount
    if foreign_currency?
      amount * exchange_rate unless exchange_rate.blank? || amount.blank?
    else
      amount
    end
  end

  class << self

    def receipts_for_customer_as_on_date(company, customer, start_date, end_date)
      start_date = start_date.to_date
      end_date = end_date.blank? ? Time.zone.now.end_of_month.to_date : end_date.to_date
      company.receipt_vouchers.by_customer(customer).by_date_range(start_date, end_date)
    end

    def customer_receipt_totals(financial_year)
      where(:received_date=>financial_year.start_date..financial_year.end_date).sum(:amount)
    end

    def customer_receipt_base_cur_totals(financial_year)
      where(:received_date=>financial_year.start_date..financial_year.end_date).sum("amount * exchange_rate")
    end

    def new_receipt(params, company, user, account)
      receipt_voucher = ReceiptVoucher.new
      receipt_voucher.voucher_number = VoucherSetting.next_receipt_voucher_number(company)
      receipt_voucher.company_id = company.id
      receipt_voucher.project_id=params[:project_id] if params[:project_id].present?
      receipt_voucher.received_date = Time.zone.now.to_date
      from_account_id=params[:account_id].blank? ? account.id : params[:account_id].to_i
      receipt_voucher.from_account_id = from_account_id
      receipt_voucher.build_payment_detail
      invoices=company.invoices.by_branch_id(user.branch_id).by_deleted(false).by_status(0).by_customer(receipt_voucher.from_account_id).by_currency(receipt_voucher.from_account.get_currency_id)
      invoices.each do |invoice|
        invoice_receipt=InvoicesReceipt.new(:invoice_id=>invoice.id, :tds_amount=>nil, :amount=>nil)
        receipt_voucher.invoices_receipts<<invoice_receipt
      end
      receipt_voucher
    end

    def create_receipt(params, company, user, fyr)
      receipt_voucher = ReceiptVoucher.new(params[:receipt_voucher])
      receipt_voucher.company_id = company.id
      receipt_voucher.created_by = user.id
      receipt_voucher.project_id = Project.get_project_id(params[:project_id], company.id)
      receipt_voucher.tds_account_id=Account.find_by_name_and_company_id("tds receivable", company.id).id
      receipt_voucher.branch_id = user.branch_id unless user.branch_id.blank?
      if params[:currency_id].blank?
        receipt_voucher.currency_id = receipt_voucher.from_account.get_currency_id unless receipt_voucher.from_account.blank?
      else
        receipt_voucher.currency_id = params[:currency_id]
      end
      if receipt_voucher.currency_id.blank? || receipt_voucher.from_account.get_currency == receipt_voucher.company.currency_code
        receipt_voucher.exchange_rate = 0
      end
      receipt_voucher.allocated=false if receipt_voucher.advanced?
      receipt_voucher.fin_year = fyr

      unless receipt_voucher.advanced?
        receipt_voucher.amount=0
        receipt_voucher.tds_amount=0
        receipt_voucher.invoices_receipts.each do |ir|
          receipt_voucher.amount += ir.amount
          receipt_voucher.tds_amount += ir.tds_amount unless ir.tds_amount.blank?
        end
      end

      receipt_voucher.payment_detail = fetch_payment_details(params)
      receipt_voucher.payment_detail.amount = receipt_voucher.amount
      if !receipt_voucher.valid? && receipt_voucher.errors[:voucher_number]
        if !receipt_voucher.voucher_setting.custom_sequence?
           receipt_voucher.voucher_number= VoucherSetting.next_receipt_voucher_number(company)
        end
      end
      receipt_voucher
    end

    def update_receipt(params, company, user, fyr)
      receipt_voucher = ReceiptVoucher.find(params[:id])
      receipt_voucher.assign_attributes(params[:receipt_voucher])
      receipt_voucher.tds_account_id=Account.find_by_name_and_company_id("tds receivable", company).id
      receipt_voucher.project_id=Project.get_project_id(params[:project_id], company)
      receipt_voucher.branch_id = user.branch_id unless user.branch_id.blank?
      receipt_voucher.currency_id = receipt_voucher.from_account.get_currency_id unless receipt_voucher.from_account.blank?
      unless receipt_voucher.advanced?
        receipt_voucher.amount=0
        receipt_voucher.tds_amount=0
        receipt_voucher.invoices_receipts.each do |ir|
          receipt_voucher.amount += ir.amount
          receipt_voucher.tds_amount += ir.tds_amount unless ir.tds_amount.blank?
        end
      end
      receipt_voucher.payment_detail.amount = receipt_voucher.amount
      receipt_voucher.fin_year = fyr
      receipt_voucher
    end

    def fetch_payment_details(params)
      if params[:transaction_type] == 'cheque'
        payment = ChequePayment.new(params[:cheque_payment])
      elsif params[:transaction_type] == 'card'
        payment = CardPayment.new(params[:card_payment])
      elsif params[:transaction_type] == 'ibank'
        payment = InternetBankingPayment.new(params[:internet_banking_payment])
      else
        payment = CashPayment.new(params[:cash_payment])
        payment.payment_date = Time.zone.now.to_date
        payment
      end
    end
  end
  def register_user_action(remote_ip, action)
    Workstream.register_user_action(company_id, created_by, remote_ip,
        " #{voucher_number} for customer #{from_account_name} for amount #{amount}", action, branch_id)
  end

  def register_delete_action(remote_ip, user, action)
    Workstream.register_user_action(company_id, user.id, remote_ip,
        " #{voucher_number} for customer #{from_account_name} for amount #{amount}", action, branch_id)
  end


# method to calculate amount after deducting tds
  def amount_after_tds
    tds_amount.blank? ? 0 : tds_amount
  end

# method for gain and loss ledger entry on foreign currency fluction
def gain_and_loss_ledger_entry
  gain_or_loss_acc = Account.find_by_name_and_company_id_and_accountable_type("Gain or loss on fluctuation in foreign currency", company_id, "IndirectExpenseAccount")

  invoices_receipts.each do |invoice_receipt|
    invoice = invoice_receipt.invoice
    if invoice.foreign_currency? && invoice.currency!=company.currency_code
      expected_amount=0
      expected_amount=invoice_receipt.amount*invoice.exchange_rate
      received_amount=0
      received_amount=invoice_receipt.amount*exchange_rate if foreign_currency?
      gnl_amount=(received_amount-expected_amount)
      random_str=Ledger.generate_secure_random
      if gnl_amount > 0
        gl_debit_ledger_entry = Ledger.new_debit_ledger(from_account_id, company_id, received_date,
            gnl_amount.abs, voucher_number, created_by, description, branch_id, random_str, gain_or_loss_acc.id)

        gl_credit_ledger_entry = Ledger.new_credit_ledger(gain_or_loss_acc.id, company_id, received_date,
            gnl_amount.abs, voucher_number, created_by, description, branch_id, random_str, from_account_id)

        ledgers << gl_debit_ledger_entry
        ledgers << gl_credit_ledger_entry
      elsif gnl_amount < 0
        gl_debit_ledger_entry = Ledger.new_debit_ledger(gain_or_loss_acc.id, company_id, received_date,
            gnl_amount.abs, voucher_number, created_by, description, branch_id, random_str, from_account_id)

        gl_credit_ledger_entry = Ledger.new_credit_ledger(from_account_id, company_id, received_date,
            gnl_amount.abs, voucher_number, created_by, description, branch_id, random_str, gain_or_loss_acc.id)

        ledgers << gl_debit_ledger_entry
        ledgers << gl_credit_ledger_entry
      end
    end
  end
end

#method for saving receipt voucher with ledger
def save_with_ledgers
    save_result = false
    transaction do
      if save!
        random_str=Ledger.generate_secure_random
        debit_ledger_entry = Ledger.new_debit_ledger(to_account_id, company_id, received_date,
          currency_multiplied_amount, voucher_number, created_by, description, branch_id, random_str,from_account_id)

        credit_ledger_entry = Ledger.new_credit_ledger(from_account_id, company_id, received_date,
          currency_multiplied_amount, voucher_number, created_by, description, branch_id, random_str,to_account_id)

        #build and save relationship between receipt_voucher and ledgers
        ledgers << debit_ledger_entry
        ledgers << credit_ledger_entry

        unless tds_amount.blank? || tds_amount <=0
          random_str1=Ledger.generate_secure_random
          debit_ledger_entry = Ledger.new_debit_ledger(tds_account_id, company_id, received_date,
          tds_amount, voucher_number, created_by, description, branch_id, random_str1,from_account_id)

          credit_ledger_entry = Ledger.new_credit_ledger(from_account_id, company_id, received_date,
          tds_amount, voucher_number, created_by, description, branch_id, random_str1, tds_account_id)

          ledgers << debit_ledger_entry
          ledgers << credit_ledger_entry
        end
        self.gain_and_loss_ledger_entry
        save_result = true
      end
    end
    save_result
  end

#method for updating receipt voucher with ledger
  def update_and_post_ledgers
    update_result = false
    transaction do
     if update
     Ledger.delete(ledgers)
      random_str=Ledger.generate_secure_random
      debit_ledger_entry = Ledger.new_debit_ledger(to_account_id, company_id, received_date,
        currency_multiplied_amount, voucher_number, created_by, description, branch_id, random_str, from_account_id)

      credit_ledger_entry = Ledger.new_credit_ledger(from_account_id, company_id, received_date,
        currency_multiplied_amount, voucher_number, created_by, description, branch_id, random_str, to_account_id)

      #build and save relationship between receipt_voucher and ledgers
      ledgers << debit_ledger_entry
      ledgers << credit_ledger_entry
      unless tds_amount.blank? || tds_amount <=0
        random_str1=Ledger.generate_secure_random
        debit_ledger_entry = Ledger.new_debit_ledger(tds_account_id, company_id, received_date,
          tds_amount, voucher_number, created_by, description, branch_id, random_str1, from_account_id)

        credit_ledger_entry = Ledger.new_credit_ledger(from_account_id, company_id, received_date,
          tds_amount, voucher_number, created_by, description, branch_id, random_str1, tds_account_id)
        ledgers << debit_ledger_entry
        ledgers << credit_ledger_entry
      end
      self.gain_and_loss_ledger_entry
      update_result = true
    end
   end
      update_result
  end

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
def get_product(tax_id)

  end

  def self.get_customer_receipt_vouchers(company, account)
    where(:company_id => company, :from_account_id => account, :deleted => false)
  end

  def project_name
    project.name
  end
end

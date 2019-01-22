class PaymentVoucher < ActiveRecord::Base
  #SCOPES
  scope :by_branch_id, lambda {|id| where(:branch_id => id) unless id.blank? }
  scope :by_deleted, lambda {|del| where(:deleted => del)}
  scope :by_date, lambda{|fin_year| where(:payment_date => fin_year.start_date..fin_year.end_date) unless fin_year.blank?}
  scope :by_account, lambda{|account| where(:to_account_id=> account) unless account.blank? }
  scope :by_voucher, lambda{|voucher_no| where("voucher_number like ?", "%#{voucher_no}%")}
  scope :by_date_range, lambda{|start_date, end_date| where(:payment_date=> start_date..end_date) unless start_date.blank? || end_date.blank? }
  scope :by_amount_range, lambda{|min_amt, max_amt| where(:amount=> min_amt..max_amt)}
  scope :by_voucher_type, lambda { |voucher_type| where(:voucher_type=>voucher_type) unless voucher_type.blank? }
  #ASSOCIATIONS
  #has_one :payment_mode, :foreign_key => :voucher_id, :dependent => :destroy
  # belongs_to :expense
  has_many :ledgers, :as => :voucher, :dependent => :destroy
  belongs_to :company
  has_many :purchases_payments#, :conditions=>{:deleted=>[false, nil]}
  has_many :purchases, :through=>:purchases_payments, :dependent=>:destroy
  has_many :expenses_payments#, :conditions=>{:deleted=>[false, nil]}
  has_many :expenses, :through=>:expenses_payments, :dependent=>:destroy
  # belongs_to :purchase
  # belongs_to :account
  belongs_to :to_account, :class_name=>"Account", :foreign_key=>:to_account_id
  belongs_to :from_account, :class_name=>"Account", :foreign_key=>:from_account_id
  belongs_to :tds_account, :class_name=>"Account", :foreign_key=>:tds_account_id
  has_one :payment_detail, :as => :voucher, :dependent => :destroy
  belongs_to :user, foreign_key: :created_by 
  belongs_to :currency
  has_attached_file :uploaded_file,
    :url => "/uploaded_data/:class/:id/:basename.:extension",
    :path => ":rails_root/public/uploaded_data/:class/:id/:basename.:extension"



  accepts_nested_attributes_for :payment_detail
  accepts_nested_attributes_for :purchases_payments, :reject_if=>lambda { |o| o[:amount].blank? }
  accepts_nested_attributes_for :expenses_payments, :reject_if=>lambda { |o| o[:amount].blank? }
  attr_accessible :voucher_type, :advanced, :allocated, :description, :voucher_number, :voucher_date, :payment_date, :amount, :payment_detail_attributes, :deleted, :deleted_datetime,
    :deleted_by, :restored_datetime, :restored_by, :uploaded_file, :delete_uploaded_file, :tds_account_id, :tds_amount, :currency_id, :exchange_rate,
    :to_account_id, :from_account_id, :expense_id, :purchases_payments_attributes, :expenses_payments_attributes

  attr_accessor :old_file_size
  attr_accessor :fin_year
  attr_accessor :tds_applicable
  # attr_writer :voucher_type

  #VALIDATIONS
  validates_presence_of  :voucher_number, :voucher_date, :payment_date, :amount, :to_account_id, :from_account_id
  # validate :purchase_id, :allow_blank => true
  validates_uniqueness_of :voucher_number, :scope=>:company_id
  validates :amount, :numericality => {:greater_than_or_equal_to => 0.01,
    :message => " should not be zero or negative ." }

  #validate :voucher_date_and_payment_date
  validate :validate_from_account_and_to_account
  #validate :amount_less_or_equal, :if => :purchase_id

  validates_attachment_size :uploaded_file, :less_than => 5.megabytes
  validates_attachment_content_type :uploaded_file, :content_type => ['image/jpeg','image/png','image/jpg','image/gif', 'application/pdf'],
    :message=>" must be of .jpeg,'.jpg', '.gif', .png or .pdf type",
    :allow_nil => true
  validate :storage_limit
  # validate :save_only_in_current_year

  validate :check_balance_on_create, :on => :create
  validate :check_balance_on_update, :on => :update

  # validate :check_expense_balance_on_create, :if => :expense_id, :on => :create
  # validate :check_expense_balance_on_update, :if => :expense_id, :on => :update

  validate :validate_from_account_type, :if => :from_account_id
  validate :validate_to_account_type, :if => :to_account_id
  validate :validate_tds_amount, :if => :tds_amount
  validates_presence_of :exchange_rate, :if => lambda{|e| !e.to_account.blank? && !e.to_account.get_currency_id.blank?}
  validate :validate_exchange_rate, :if => :exchange_rate
  validates_presence_of :tds_amount, :if =>  lambda{|e| !e.tds_account_id.blank? }
  validate :save_in_frozen_fy
  validates_presence_of :tds_account_id, :if=>lambda { |e| e.tds_applicable=='yes' }
  validate :available_amount, :if => :advanced, :on=>:update
  validate :amount_underflow, :if=>:advanced
  validate :account_effective_date

  #CALLBACKS
  before_save :destroy_uploaded_file?
  # after_save :utilized_storage

  STATUS={"1" => "Paid", "0" => "Unpaid"}
  PAYMENT_OPTION={0=>"against_vouchers", 1=>"advance_payment", 2=>"other_payment"}

  def voucher_setting
    VoucherSetting.by_voucher_type(7, company_id).first
  end
  
  def account_effective_date
    if !from_account.blank? && !payment_date.blank? && from_account.start_date > payment_date
      errors.add(:payment_date, "must be after account activation, #{from_account.name} is activated since #{from_account.start_date}")
    end
    if !to_account.blank? && !payment_date.blank? && to_account.start_date > payment_date
      errors.add(:payment_date, "must be after account activation, #{to_account.name} is activated since #{to_account.start_date}")
    end
  end
  
  def vendor
    to_account.vendor.blank? ? to_account.customer : to_account.vendor
  end

  def amount_underflow
    if ( !amount.blank? && amount < (purchases_payments.sum(:amount) + expenses_payments.sum(:amount))) || ( !tds_amount.blank? && tds_amount < (purchases_payments.sum(:tds_amount)+ expenses_payments.sum(:tds_amount)))
      errors.add(:base, "Can't change allocated amount" )
    end
  end

  def available_amount
    unless purchases_payments.blank?
      allocated_amount = 0
      allocated_tds = 0
      purchases_payments.each do |purchase_payment|
        allocated_amount+=purchase_payment.amount unless purchase_payment.amount.blank?
        allocated_tds+=purchase_payment.tds_amount unless purchase_payment.tds_amount.blank?
      end
      expenses_payments.each do |expenses_payment|
        allocated_amount+=expenses_payment.amount unless expenses_payment.amount.blank?
        allocated_tds+=expenses_payment.tds_amount unless expenses_payment.tds_amount.blank?
      end
      if allocated_amount<=0
        errors.add(:amount, "can't negative or zero.")
      end
      if allocated_amount>amount
        errors.add(:base, "Paid amount should not be greater than unallocated amount")
      end
      if !tds_amount.blank? && allocated_tds>tds_amount
        errors.add(:base, "TDS deducted should not be greater than unallocated tds amount")
      end
    end
  end

  def unallocated_amount
    amt=0
    if advanced?
      amt=amount-(purchases_payments.sum(:amount) + expenses_payments.sum(:amount)) unless amount.blank?
    end
    amt
  end

  def unallocated_tds_amount
    amt=0
    if advanced?
      amt=tds_amount-(purchases_payments.sum(:tds_amount) + expenses_payments.sum(:tds_amount)) unless tds_amount.blank?
    end
    amt
  end

  # def voucher_type
  #   @voucher_type || "against_vouchers"
  # end

  def against_vouchers?
    voucher_type==0
  end

  def advance_payment?
    voucher_type==1
  end

  def other_payment?
    voucher_type==2
  end

  def against_expense?
    !expense_id.blank?
  end

  def against_purchase?
    !purchase_id.blank?
  end

  def validate_exchange_rate
    account = Account.find_by_id(to_account_id)
    unless account.blank?
    customer_currency = account.get_currency
     if !customer_currency.blank? && company.currency_code != customer_currency
      if exchange_rate <= 0
        errors.add(:exchange_rate, "should not be zero or negative")
      end
     end
    end
  end

 # def to_account
 #  Account.find_by_id(to_account_id) unless  to_account_id.blank?
 # end

  def save_in_frozen_fy
    if !payment_date.blank? && in_frozen_year?
      errors.add(:payment_date, "can't be in frozen financial year")
    end
  end
  def in_frozen_year?
    FinancialYear.check_if_frozen(company_id, payment_date)
  end
  def created_by_user
    user.full_name
  end

  def validate_from_account_type
    if !from_account.blank? && !(["BankAccount", "CashAccount","SecuredLoanAccount","UnsecuredLoanAccount","OtherCurrentAsset","CurrentLiability"]).include?(from_account.accountable_type)
      errors.add(:from_account_id,"you entered is wrong, please select right account")
    end
  end

  def validate_to_account_type
    if !(["DirectExpenseAccount","IndirectExpenseAccount","LoansAdvancesAccount","LoanAccount","ProvisionAccount","SecuredLoanAccount",
      "SundryCreditor", "SundryDebtor","UnsecuredLoanAccount","DepositAccount","SuspenseAccount", "CapitalAccount","DutiesAndTaxesAccounts"]).include?(Account.find(to_account_id).accountable_type)
      errors.add(:to_account_id,"you entered is wrong, please select right account")
    end
  end

  def validate_tds_amount
    unless tds_amount.blank? || amount.blank?
      if tds_amount >= amount
        errors.add(:tds_amount, "should not greater than total amount")
      end
    end
  end

  def currency_code
    if currency_id.blank?
      self.company.currency_code
    else
      self.currency.currency_code
    end
  end

  def foreign_currency?
    !currency_id.blank? && !exchange_rate.blank? && exchange_rate!=0
  end

# this method is used to calculate gain and loss in purchase model
  def total_amount
   foreign_currency? ? (amount*exchange_rate).round(2) : amount
  end

  def check_balance_on_create
    purchases_payments.each do |purchase_payment|
      purchase=purchase_payment.purchase
      unless purchase.blank?
        purchase_paid_amount=purchase_payment.amount
        if purchase_paid_amount>purchase.outstanding
          errors.add(:base, "Amount must not be greater than purchase(#{purchase.purchase_number}) amount(you have to pay #{purchase.currency}#{purchase.outstanding} only)")
        end
      end
    end
    expenses_payments.each do |expense_payment|
      expense=expense_payment.expense
      unless expense.blank?
        expense_paid_amount=expense_payment.amount
        if expense_paid_amount>expense.outstanding
          errors.add(:base, "Amount must not be greater than expense(#{expense.voucher_number}) amount(you have to pay #{expense.currency}#{expense.outstanding} only)")
        end
      end
    end
    # purchase = Purchase.find_by_id(purchase_id)
    # unless purchase.blank?
    #   if amount > purchase.outstanding
    #     errors.add(:base, "Amount must not be greater than purchase amount (you have to pay #{purchase.currency} #{purchase.outstanding} only)")
    #   end
    # end
  end

  def check_balance_on_update
    purchases_payments.each do |purchase_payment|
      purchase=purchase_payment.purchase
      if !purchase_payment.amount.blank? && purchase_payment.amount < 0
        errors.add(:amount, "can't not be negative for purchase(#{purchase_payment.purchase.purchase_number})")
      elsif !purchase_payment.amount.blank? && !purchase.blank?
        purchase_paid_amount=purchase.total_paid
        amount_before_update=0
        self_purchase_payment = purchases_payments.where(:purchase_id=>purchase.id).first
        unless self_purchase_payment.blank?
          amount_before_update=self_purchase_payment.amount
          purchase_paid_amount-=amount_before_update
        end
        purchase_paid_amount+=purchase_payment.amount
        if purchase_paid_amount > purchase.total_amount
          errors.add(:base, "Amount must not be greater than purchase(#{purchase.purchase_number}) outstanding(you have to pay #{purchase.currency}#{purchase.outstanding+amount_before_update} only)")
        end
      end
    end
    expenses_payments.each do |expense_payment|
      expense=expense_payment.expense
      if !expense_payment.amount.blank? && expense_payment.amount < 0
        errors.add(:amount, "can't not be negative for expense(#{expense_payment.expense.voucher_number})")
      elsif !expense_payment.amount.blank? && !expense.blank?
        expense_paid_amount=expense.paid_amount
        amount_before_update=0
        self_expense_payment = expenses_payments.where(:expense_id=>expense.id).first
        unless self_expense_payment.blank?
          amount_before_update=self_expense_payment.amount
          expense_paid_amount-=amount_before_update
        end
        expense_paid_amount+=expense_payment.amount
        if expense_paid_amount > expense.total_amount
          errors.add(:base, "Amount must not be greater than expense(#{expense.voucher_number}) outstanding(you have to pay #{expense.currency}#{expense.outstanding+amount_before_update} only)")
        end
      end
    end
  end

  # def check_expense_balance_on_create
  #   expense = Expense.find_by_id(expense_id)
  #   unless expense.blank?
  #     if amount > expense.outstanding
  #       errors.add(:base, "Amount must not be greater than expense amount (you have to pay #{company.currency_code} #{expense.outstanding} only)")
  #     end
  #   end
  # end

  # def check_expense_balance_on_update
  #   expense = Expense.find_by_id(expense_id)
  #   unless expense.blank?
  #     payment_before_update = PaymentVoucher.find(id).amount
  #     total = (expense.paid_amount - payment_before_update) + amount
  #     if total > expense.total_amount
  #       errors.add(:base, "Amount must not be greater than expense amount (you have to pay #{company.currency_code} #{expense.outstanding+payment_before_update} only)")
  #     end
  #   end
  # end

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

def set_amount_allocation
  allocated_amount = purchases_payments.sum(:amount) + expenses_payments.sum(:amount)
  allocated_tds = purchases_payments.sum(:tds_amount) + expenses_payments.sum(:tds_amount)
  tds_deducted=0
  tds_deducted=tds_amount unless tds_amount.blank?
  if allocated_tds==tds_deducted && allocated_amount==amount
    update_attribute("allocated", true)
  elsif allocated_tds<tds_deducted || allocated_amount<amount
    update_attribute("allocated", false)
  end
end

def destroy_and_manage_voucher_status
  result=false
  transaction do
    mark_vouchers_deleted
    update_voucher_status
    destroy
    result=true
  end
  result
end
def update_voucher_status
  purchases.each do |purchase|
   purchase.update_purchase_status
  end
  expenses.each do |expense|
   expense.update_payment_status
  end
end
def mark_vouchers_deleted
  purchases_payments.update_all(:deleted=>true)
  expenses_payments.update_all(:deleted=>true)
end

def update_and_manage_status(remote_ip)
  transaction do
    save!
    update_and_post_ledgers
    purchases.each do |purchase|
      purchase.update_purchase_status
    end
    expenses.each do |expense|
      expense.update_payment_status
    end
    set_amount_allocation if advanced?
    register_user_action(remote_ip, 'updated')
  end
end

def save_and_manage_status(remote_ip)
  transaction do
    save_with_ledgers
    purchases.each do |purchase|
      purchase.update_purchase_status
    end
    expenses.each do |expense|
      expense.update_payment_status
    end
    register_user_action(remote_ip, 'created')
  end
end

class << self

  def create_payment_vouchers(params, company, user, fyr)
    payment_voucher = PaymentVoucher.create_payment(params, company, user, fyr)
    purchase = payment_voucher.purchase
    if payment_voucher.valid?
      payment_voucher.save_with_ledgers
      purchase.update_purchase_status unless @purchase.blank?
    end
  end

  def new_payment(params, company)
    payment_voucher = PaymentVoucher.new
    payment_voucher.company_id = company.id
    payment_voucher.to_account_id = params[:account_id] unless params[:account_id].blank?
    payment_voucher.voucher_date = Time.zone.now.to_date
    payment_voucher.payment_date = Time.zone.now.to_date
    if params[:purchase_id].present?
      purchase = Purchase.find(params[:purchase_id])
      payment_voucher.purchase_id = purchase.id
      payment_voucher.to_account_id = purchase.account_id
      payment_voucher.amount = purchase.outstanding
    elsif params[:expense_id].present?
      expense=Expense.find_by_id(params[:expense_id])
      payment_voucher.expense_id=expense.id
      payment_voucher.to_account_id=expense.account_id
      payment_voucher.amount=expense.outstanding
      payment_voucher.currency_id=expense.currency_id
      payment_voucher.exchange_rate=expense.exchange_rate
    end
    payment_voucher.build_payment_detail
    payment_voucher.voucher_number = VoucherSetting.next_payment_voucher_number(company)
    payment_voucher.old_file_size = 0
    payment_voucher
  end

  def create_payment(params, company, user, fyr)
    payment_voucher = PaymentVoucher.new(params[:payment_voucher])
    payment_voucher.company_id = company
    payment_voucher.created_by = user.id
    payment_voucher.old_file_size = 0
    payment_voucher.tds_applicable=params[:tds]
    payment_voucher.from_account_id=nil if payment_voucher.from_account_id=="create_new"
    payment_voucher.to_account_id=nil if payment_voucher.to_account_id=="create_new"
    # payment_voucher.voucher_type=PAYMENT_OPTION[params[:payment_option]]
    payment_voucher.branch_id = user.branch_id unless user.branch_id.blank?
    payment_voucher.currency_id = payment_voucher.to_account.get_currency_id unless payment_voucher.to_account.blank?
    if payment_voucher.currency_id.blank? || payment_voucher.to_account.get_currency == payment_voucher.company.currency_code
      payment_voucher.exchange_rate = 0
    end
    if payment_voucher.against_vouchers?
      payment_voucher.amount=0
      payment_voucher.tds_amount=0
      payment_voucher.purchases_payments.each do |purchase_payment|
        payment_voucher.amount +=purchase_payment.amount
        payment_voucher.tds_amount += purchase_payment.tds_amount unless purchase_payment.tds_amount.blank?
      end
      payment_voucher.expenses_payments.each do |expense_payment|
        payment_voucher.amount +=expense_payment.amount
        payment_voucher.tds_amount += expense_payment.tds_amount unless expense_payment.tds_amount.blank?
      end
    end
    if payment_voucher.against_vouchers?
      payment_voucher.tds_applicable="yes" if payment_voucher.tds_amount > 0
    end
    if payment_voucher.tds_applicable=="no" || payment_voucher.tds_applicable.blank?
      payment_voucher.tds_amount=nil
      payment_voucher.tds_account_id=nil
    end
    payment_voucher.payment_detail = fetch_payment_details(params)
    payment_voucher.payment_detail.amount = payment_voucher.amount
    payment_voucher
  end

  def update_payment(params, company, user, fyr)
    payment_voucher = PaymentVoucher.find(params[:id])
    payment_voucher.assign_attributes(params[:payment_voucher])
    payment_voucher.from_account_id=nil if payment_voucher.from_account.blank?
    payment_voucher.branch_id = user.branch_id unless user.branch_id.blank?
    payment_voucher.currency_id = payment_voucher.to_account.get_currency_id unless payment_voucher.to_account.blank?
    # if payment_voucher.currency_id.blank? || payment_voucher.to_account.get_currency == payment_voucher.company.currency_code
    #   payment_voucher.exchange_rate = 0
    # end
    if payment_voucher.against_vouchers?
      payment_voucher.amount=0
      payment_voucher.tds_amount=0
      payment_voucher.purchases_payments.each do |purchase_payment|
        payment_voucher.amount +=purchase_payment.amount
        payment_voucher.tds_amount += purchase_payment.tds_amount unless purchase_payment.tds_amount.blank?
      end
      payment_voucher.expenses_payments.each do |expense_payment|
        payment_voucher.amount +=expense_payment.amount
        payment_voucher.tds_amount += expense_payment.tds_amount unless expense_payment.tds_amount.blank?
      end
    end
    if payment_voucher.against_vouchers?
      payment_voucher.tds_applicable="yes" if payment_voucher.tds_amount > 0
    end
    if payment_voucher.tds_applicable=="no"
      payment_voucher.tds_amount=nil
      payment_voucher.tds_account_id=nil
    end
    payment_voucher.old_file_size = params[:old_file_size]
    payment_voucher.payment_detail.amount = payment_voucher.amount
    payment_voucher
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

  def current_year_total(financial_year)
    where(:payment_date=> financial_year.start_date..financial_year.end_date).sum(:amount)
  end

  def current_year_base_cur_total(financial_year)
    where(:payment_date=> financial_year.start_date..financial_year.end_date).sum("amount * exchange_rate")
  end

end

def register_user_action(remote_ip, action)
  Workstream.register_user_action(company_id, created_by, remote_ip,
    " #{voucher_number} #{action} for #{to_account_name} for amount #{amount} paid from #{from_account_name}", action, branch_id)
end

def register_delete_action(remote_ip, user, action)
  Workstream.register_user_action(company_id, user.id, remote_ip,
    " #{voucher_number} #{action} for #{to_account_name} for amount #{amount} paid from #{from_account_name}", action, branch_id)
end

def payment_method_amt
  self.payment_detail.amount
end


# method for gain and loss ledger entry on foreign currency fluction
def gain_and_loss_ledger_entry
  gain_or_loss_acc = Account.find_by_name_and_company_id_and_accountable_type("Gain or loss on fluctuation in foreign currency", company_id, "IndirectExpenseAccount")
  purchases_payments.each do |purchase_payment|
    purchase=purchase_payment.purchase
    if !purchase.blank? && purchase.foreign_currency? &&(purchase.currency != company.currency_code)
      pur_amt = purchase_payment.amount*purchase.exchange_rate
      pmt_amt = purchase_payment.amount*exchange_rate if foreign_currency?
      gain_or_loss_amt = (pmt_amt - pur_amt)
      random_str = Ledger.generate_secure_random
      if gain_or_loss_amt < 0
        gl_debit_ledger_entry = Ledger.new_debit_ledger(to_account_id, company_id, payment_date,
            gain_or_loss_amt.abs, voucher_number, created_by, description, branch_id, random_str, gain_or_loss_acc.id)

        gl_credit_ledger_entry = Ledger.new_credit_ledger(gain_or_loss_acc.id, company_id, payment_date,
            gain_or_loss_amt.abs, voucher_number, created_by, description, branch_id, random_str, to_account_id)

        ledgers << gl_debit_ledger_entry
        ledgers << gl_credit_ledger_entry
      elsif gain_or_loss_amt > 0
        gl_debit_ledger_entry = Ledger.new_debit_ledger(gain_or_loss_acc.id, company_id, payment_date,
            gain_or_loss_amt.abs, voucher_number, created_by, description, branch_id, random_str, to_account_id)

        gl_credit_ledger_entry = Ledger.new_credit_ledger(to_account_id, company_id, payment_date,
            gain_or_loss_amt.abs, voucher_number, created_by, description, branch_id, random_str, gain_or_loss_acc.id)

        ledgers << gl_debit_ledger_entry
        ledgers << gl_credit_ledger_entry
      end
    end
  end
end

# method to calculate amount after deducting tds
def amount_after_tds
  amt = 0
  tds_amt = (tds_amount.blank? ? 0 : tds_amount)
  amt = amount-tds_amt
  foreign_currency? ? (amt*exchange_rate).round(2) : amt
end

def ledger_amt
  foreign_currency? ? (amount*exchange_rate).round(2) : amount
end
def ledger_tds_amt
  foreign_currency? ? (tds_amount*exchange_rate).round(2) : tds_amount
end

#method for saving payment voucher with ledger
def save_with_ledgers
  save_result = false
  transaction do
    if save!
      if tds_account_id.blank?

        random_str=Ledger.generate_secure_random
        debit_ledger_entry = Ledger.new_debit_ledger(to_account_id, company_id, payment_date,
          ledger_amt, voucher_number, created_by, description, branch_id, random_str, from_account_id)

        credit_ledger_entry = Ledger.new_credit_ledger(from_account_id, company_id, payment_date,
          ledger_amt, voucher_number, created_by, description, branch_id, random_str, to_account_id)

          #build and save relationship between receipt_voucher and ledgers
          ledgers << debit_ledger_entry
          ledgers << credit_ledger_entry
      else
        random_str1=Ledger.generate_secure_random
        random_str2=Ledger.generate_secure_random
        debit_ledger_entry1 = Ledger.new_debit_ledger(to_account_id, company_id, payment_date,
          amount_after_tds, voucher_number, created_by, description, branch_id, random_str1, from_account_id)

        credit_ledger_entry1 = Ledger.new_credit_ledger(from_account_id, company_id, payment_date,
          amount_after_tds, voucher_number, created_by, description, branch_id, random_str1, to_account_id)

        debit_ledger_entry2 = Ledger.new_debit_ledger(to_account_id, company_id, payment_date,
          ledger_tds_amt, voucher_number, created_by, description, branch_id, random_str2, tds_account_id)

        credit_ledger_entry2 = Ledger.new_credit_ledger(tds_account_id, company_id, payment_date,
          ledger_tds_amt, voucher_number, created_by, description, branch_id, random_str2, to_account_id)

        #build and save relationship between receipt_voucher and ledgers
        ledgers << debit_ledger_entry1
        ledgers << credit_ledger_entry1

        ledgers << debit_ledger_entry2
        ledgers << credit_ledger_entry2
      end
      self.gain_and_loss_ledger_entry
      save_result = true
      Subscription.increase_storage(company_id, uploaded_file_file_size, old_file_size)
    end
  end
  save_result
end

#method for updating payment voucher with ledger
def update_and_post_ledgers
  update_result = false
  transaction do
    if update
      Ledger.delete(ledgers)

      if tds_account_id.blank?
        random_str=Ledger.generate_secure_random
        debit_ledger_entry = Ledger.new_debit_ledger(to_account_id, company_id, payment_date,
          ledger_amt, voucher_number, created_by, description, branch_id, random_str, from_account_id)

        credit_ledger_entry = Ledger.new_credit_ledger(from_account_id, company_id, payment_date,
          ledger_amt, voucher_number, created_by, description, branch_id, random_str, to_account_id)

        #build and save relationship between receipt_voucher and ledgers
        ledgers << debit_ledger_entry
        ledgers << credit_ledger_entry
      else
        random_str1=Ledger.generate_secure_random
        random_str2=Ledger.generate_secure_random
        debit_ledger_entry1 = Ledger.new_debit_ledger(to_account_id, company_id, payment_date,
          amount_after_tds, voucher_number, created_by, description, branch_id, random_str1, from_account_id)

        credit_ledger_entry1 = Ledger.new_credit_ledger(from_account_id, company_id, payment_date,
          amount_after_tds, voucher_number, created_by, description, branch_id, random_str1, to_account_id)


        debit_ledger_entry2 = Ledger.new_debit_ledger(to_account_id, company_id, payment_date,
          ledger_tds_amt, voucher_number, created_by, description, branch_id, random_str2, tds_account_id)

        credit_ledger_entry2 = Ledger.new_credit_ledger(tds_account_id, company_id, payment_date,
          ledger_tds_amt, voucher_number, created_by, description, branch_id, random_str2, to_account_id)

        #build and save relationship between receipt_voucher and ledgers
        ledgers << debit_ledger_entry1
        ledgers << credit_ledger_entry1

        ledgers << debit_ledger_entry2
        ledgers << credit_ledger_entry2
      end
      self.gain_and_loss_ledger_entry
      update_result = true
      Subscription.increase_storage(company_id, uploaded_file_file_size, old_file_size)
    end
  end
  update_result
end

#methods for uploaded files
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

def self.get_vendor_payment_vouchers(company, account)
  where(:company_id => company, :to_account_id => account, :deleted => false)
end
def get_product(tax_id)

end

private

def storage_limit
  errors[:base] << "Storage limit reached, your plan does not allow storing any more files." if Subscription.storage_limit?(company_id, uploaded_file_file_size, old_file_size)
end

def destroy_uploaded_file?
  self.uploaded_file.clear if @file_delete == "1" and !uploaded_file.dirty?
end

end

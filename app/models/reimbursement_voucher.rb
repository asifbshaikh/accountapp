class ReimbursementVoucher < ActiveRecord::Base
  scope :by_branch_id, lambda {|id| where(:branch_id => id) unless id.blank? }
  scope :by_deleted, lambda {|del| where(:deleted => del)}
  scope :by_date, lambda{|fin_year| where(:received_date => fin_year.start_date..fin_year.end_date) unless fin_year.blank?}
  scope :by_customer, lambda{|customer| where(:from_account_id => customer, :deleted => false) unless customer.blank? }
  scope :by_voucher, lambda{|voucher_no| where("voucher_number like ?", "%#{voucher_no}%")}
  scope :by_date_range, lambda{|start_date, end_date| where(:received_date=> start_date..end_date) unless start_date.blank? || end_date.blank? }
  scope :by_amount_range, lambda{|min_amt, max_amt| where(:amount=> min_amt..max_amt)}
  scope :by_project, lambda{|project| where(:project_id=>project) unless project.blank? }
  scope :by_advance, lambda { |is_advance| is_advance.blank? ? where(:advanced=>false) : where(:advanced=>true) }
  belongs_to :company
  belongs_to :project
  belongs_to :account
  belongs_to :to_account, :class_name=>"Account", :foreign_key=>:to_account_id
  belongs_to :from_account, :class_name=>"Account", :foreign_key=>:from_account_id
  belongs_to :user, :foreign_key=> :created_by
  has_many :reimbursement_notes
  has_many :reimbursement_voucher_line_items
  has_many :ledgers, :as => :voucher, :dependent => :destroy
  has_one :payment_detail, :as => :voucher, :dependent => :destroy

  accepts_nested_attributes_for :payment_detail
  accepts_nested_attributes_for :reimbursement_voucher_line_items, :reject_if => lambda {|a| a[:payment_amount].blank?}, :allow_destroy => true

  attr_accessible :advanced, :allocated, :deleted_by, :deleted, :deleted_datetime, :voucher_number, :received_date, :voucher_date, :tds_amount,:tds_account_id, :description, :amount, :from_account_id, :to_account_id ,:payment_detail_attributes, :restored_by, :restored_datetime,:currency_id, :exchange_rate, :project_id, :invoice_id, :reimbursement_voucher_line_items_attributes, :reimbursement_note_id, :payment_amount

  #validations
  validates_associated :payment_detail
  validates_presence_of  :voucher_number, :voucher_date, :received_date, :amount, :to_account_id, :from_account_id
  validates_uniqueness_of :voucher_number, :scope => :company_id
  validates :amount, :numericality => {:greater_than_or_equal_to => 0.01,
                                       :message => " should not be zero or negative ." }
  validate :validate_from_account_and_to_account
  validate :save_in_frozen_fy
  validate :validate_from_account_type, :if => :from_account_id
  validate :validate_to_account_type, :if => :to_account_id
  validate :account_effective_date
  attr_accessor :fin_year

  #callbacks
  before_update :manage_reimbursement_voucher_line_items

  def get_party
    from_account.customer.blank? ? from_account.vendor : from_account.customer
  end

  def voucher_setting
    VoucherSetting.by_voucher_type(24, company_id).first
  end

  def account_effective_date
    if !from_account.blank? && !received_date.blank? && received_date < from_account.start_date
      errors.add(:received_date, "must be after account activation, #{from_account.name} is activated since #{from_account.start_date}")
    end
    if !to_account.blank? && !received_date.blank? && received_date < to_account.start_date
      errors.add(:received_date, "must be after account activation, #{to_account.name} is activated since #{to_account.start_date}")
    end
  end

  def from_account
    Account.find_by_id(from_account_id) unless from_account_id.blank?
  end

  def save_in_frozen_fy
    if !received_date.blank? && in_frozen_year?
      errors.add(:received_date, "can't be in frozen financial year")
    end
  end

  def in_frozen_year?
    FinancialYear.check_if_frozen(company_id, received_date)
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

  def validate_from_account_and_to_account
    if self.from_account_id == self.to_account_id
      errors.add(:base, "Both accounts should not be same")
    end
  end

  def from_account_name
    Account.find(from_account_id).name
  end

  def to_account_name
    Account.find(to_account_id).name
  end

  def reimbursed
    Company.reimbursement_notes.paid?
  end

  #method to look changes in line items & update them according to user input
  def manage_reimbursement_voucher_line_items
    logger.debug ">>>>> Deleting line items before update Count:#{reimbursement_voucher_line_items.count} <<<<<"
    reimbursement_voucher_line_items.each do |line_item|
      logger.debug ">>>>> Line Item #{line_item.id} is persisted? #{line_item.persisted?}  changed? #{line_item.changed?}<<<<<"
      if line_item.persisted?
        line_item.delete
      end
    end

    logger.debug ">>>>> Removing submitted status of Rimb Notes before update <<<<<"
    reimbursement_notes.update_all(:submitted => false, :reimbursement_voucher_id => nil)
  end

  #method for saving receipt voucher with ledger
  def save_and_make_relation_with_reimbursement_notes
    logger.debug ">>>>> Inside save_with_ledgers <<<<<<"
    save_result = false
    transaction do
      if save!
        reimbursement_voucher_line_items.each do | line_item |
          rimb_note = ReimbursementNote.find(line_item.reimbursement_note_id)
          logger.debug ">>> Updating status for Rimb Note #{rimb_note.reimbursement_note_number} <<<"
          rimb_note.update_attributes(:reimbursement_voucher_id => self.id, :submitted => true)
          logger.debug ">>> Updated status for Rimb Note #{rimb_note.reimbursement_note_number} <<<"
          random_str = Ledger.generate_secure_random
          debit_ledger_entry = Ledger.new_debit_ledger(to_account_id, company_id, voucher_date, rimb_note.amount, voucher_number, created_by, description, branch_id, random_str, from_account_id)
          credit_ledger_entry = Ledger.new_credit_ledger(from_account_id, company_id, voucher_date, rimb_note.amount, voucher_number, created_by, description, branch_id, random_str, to_account_id)
          ledgers << debit_ledger_entry
          ledgers << credit_ledger_entry
        end
        VoucherSetting.next_reimbursement_voucher_write(company_id)
        save_result = true
      end
    end
    save_result
  end

  #method for updating receipt voucher with ledger
  def update_and_remake_relation_with_reimbursement_notes
    update_result = false
    transaction do
      if update
        Ledger.delete(ledgers)

        reimbursement_voucher_line_items.each do | line_item |
          if line_item.persisted?
            rimb_note = ReimbursementNote.find(line_item.reimbursement_note_id)
            rimb_note.update_attributes(:reimbursement_voucher_id => self.id, :submitted => true)
            random_str = Ledger.generate_secure_random
            debit_ledger_entry = Ledger.new_debit_ledger(to_account_id, company_id, voucher_date, rimb_note.amount, voucher_number, created_by, description, branch_id, random_str, from_account_id)
            credit_ledger_entry = Ledger.new_credit_ledger(from_account_id, company_id, voucher_date, rimb_note.amount, voucher_number, created_by, description, branch_id, random_str, to_account_id)
            ledgers << debit_ledger_entry
            ledgers << credit_ledger_entry
          end
        end
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
        reimbursement_notes.update_all(:submitted => false, :reimbursement_voucher_id => nil)
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
        reimbursement_notes.update_all(:submitted => true, :reimbursement_voucher_id => self.id)
        result = true
      end
    end
    result
  end

  def register_user_action(remote_ip, action)
    Workstream.register_user_action(company_id, created_by, remote_ip," #{voucher_number} for customer #{from_account_name} for amount #{amount}", action, branch_id)
  end

  def register_delete_action(remote_ip, user, action)
    Workstream.register_user_action(company_id, user.id, remote_ip,
                                    " #{voucher_number} for customer #{from_account_name} for amount #{amount}", action, branch_id)
  end

  class << self
    def new_voucher(params, company, user, account)
      reimbursement_voucher = ReimbursementVoucher.new
      reimbursement_voucher.voucher_number = VoucherSetting.next_reimbursement_voucher_number(company)
      reimbursement_voucher.company_id = company.id
      reimbursement_voucher.project_id=params[:project_id] if params[:project_id].present?
      reimbursement_voucher.received_date = Time.zone.now.to_date
      from_account_id = params[:account_id].blank? ? account.id : params[:account_id].to_i
      reimbursement_voucher.from_account_id = from_account_id
      reimbursement_voucher.build_payment_detail
      reimbursement_notes = company.reimbursement_notes.by_branch_id(user.branch_id).by_deleted(false).by_submitted(0)
      reimbursement_voucher
    end

    def create_voucher(params, company, user, fyr)
      reimbursement_voucher = ReimbursementVoucher.new(params[:reimbursement_voucher])
      reimbursement_voucher.company_id = company
      reimbursement_voucher.created_by = user.id
      reimbursement_voucher.branch_id = user.branch_id unless user.branch_id.blank?
      reimbursement_voucher.received_date = Date.today
      reimbursement_voucher.fin_year = fyr
      reimbursement_voucher.reimbursement_voucher_line_items.each do | line_item |
        reimbursement_voucher.amount += line_item.payment_amount
      end
      reimbursement_voucher.payment_detail = fetch_payment_details(params)
      reimbursement_voucher.payment_detail.amount = reimbursement_voucher.amount
      reimbursement_voucher
    end

    def update_voucher(params, company, user, fyr)
      reimbursement_voucher = ReimbursementVoucher.find(params[:id])
      reimbursement_voucher.assign_attributes(params[:reimbursement_voucher])
      reimbursement_voucher.branch_id = user.branch_id unless user.branch_id.blank?
      reimbursement_voucher.amount = 0
      reimbursement_voucher.reimbursement_voucher_line_items.each do | line_item |
        reimbursement_voucher.amount += line_item.payment_amount unless line_item.persisted?
      end
      reimbursement_voucher.payment_detail = fetch_payment_details(params)
      reimbursement_voucher.payment_detail.amount = reimbursement_voucher.amount
      reimbursement_voucher.fin_year = fyr
      reimbursement_voucher
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

    def for_customer_as_on_date(company, customer, start_date, end_date)
      start_date = start_date.to_date
      end_date = end_date.blank? ? Time.zone.now.end_of_month.to_date : end_date.to_date
      company.reimbursement_vouchers.by_customer(customer).by_date_range(start_date, end_date)
    end
  end
end

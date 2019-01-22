class ReimbursementNote < ActiveRecord::Base
  #Lookup scoping for easier search helper
  scope :by_party, lambda {|id| where(:from_account_id => id, :deleted => false) unless id.blank?}
  scope :by_branch_id, lambda {|id| where(:branch_id => id) unless id.blank? }
  scope :by_deleted, lambda {|del| where(:deleted => del)}
  scope :by_submitted, lambda {|submit| where(:submitted => submit)}
  scope :by_date, lambda{|fin_year| where(:transaction_date => fin_year.start_date..fin_year.end_date) unless fin_year.blank?}
  scope :by_voucher, lambda{|voucher| where("reimbursement_note_number like ?", "%#{voucher}%") unless voucher.blank?}
  scope :by_from_account, lambda{|from_account| where(:from_account_id=>from_account) unless from_account.blank? }
  scope :by_date_range, lambda{|start_date, end_date| where(:transaction_date=> start_date..end_date) unless start_date.blank? || end_date.blank? }
  scope :by_amount_range, lambda{|min_amt, max_amt| where(:amount=> min_amt..max_amt)}

  #relationships
  belongs_to :account
  belongs_to :from_account, :class_name=>"Account", :foreign_key=>:from_account_id
  belongs_to :company
  has_many :ledgers, :as => :voucher, :dependent => :destroy
  has_many :reimbursement_note_line_items, :dependent => :destroy
  has_one :reimbursement_voucher, :dependent => :destroy
  has_many :reimbursement_note_attachments

  #validations
  validates :reimbursement_note_number ,:transaction_date,:amount, :presence=> true
  validates :from_account_id, :numericality => {:greater_than => 0, :message => " sholud be valid."}
  validates_uniqueness_of :reimbursement_note_number, :scope=>:company_id
  validates_length_of :description , :maximum => 300
  validates :amount, :numericality => {:greater_than_or_equal_to => 0.01,
       :message => " sholud not be zero or negative."}

  validate :validate_from_account

  # accepts_nested_attributes_for :reimbursement_note_line_items, :reject_if => lambda {|a| a[:description].blank? && a[:amount].blank? }, :allow_destroy => true
  accepts_nested_attributes_for :reimbursement_note_line_items, :allow_destroy => true


  def get_status
    submitted == false ? "Unpaid" : "Reimbursed"
  end

  def get_badge(status)
    status == "Unpaid" ? "label  bg-warning" : "label  bg-primary"
  end


  def voucher_setting
    VoucherSetting.by_voucher_type(23, company_id).first
  end

  def total_amount
    amount
  end
  def currency
    code=company.currency_code
    code
  end

  # validate :save_only_in_current_year
  validate :save_in_frozen_fy
  attr_accessor :fin_year

  def save_in_frozen_fy
    if !transaction_date.blank? && in_frozen_year?
      errors.add(:transaction_date, "can't be in frozen financial year")
    end
  end

  def in_frozen_year?
    FinancialYear.check_if_frozen(company_id, transaction_date)
  end

  def validate_from_account
    if !from_account.blank? && !transaction_date.blank? && from_account.start_date > transaction_date
      errors.add(:transaction_date, "must be after account activation, #{from_account.name} is activated since #{from_account.start_date}")
    end
  end

  def from_account_name
    Account.find(from_account_id).name
  end

  def to_account_name
    Account.find(to_account_id).name
  end

  def paid?
    submitted
  end

  class << self
    def new_note(company)
      reimbursement_note = ReimbursementNote.new
      reimbursement_note.company_id=company.id
      reimbursement_note.reimbursement_note_number = VoucherSetting.next_reimbursement_note_number(company)
      reimbursement_note.reimbursement_note_line_items.build
      reimbursement_note
    end

    def update_note(params, company, user, fyr)
      reimbursement_note = ReimbursementNote.find(params[:id])
      reimbursement_note.branch_id = user.branch_id unless user.branch_id.blank?
      reimbursement_note.fin_year = fyr
      reimbursement_note
    end

    def for_customer_as_on_date(company, customer, start_date, end_date)
      start_date = start_date.to_date
      end_date = end_date.blank? ? Time.zone.now.end_of_month.to_date : end_date.to_date
      company.reimbursement_notes.by_party(customer).by_date_range(start_date, end_date)
    end
  end

  def register_user_action(remote_ip, action)
    Workstream.register_user_action(company_id, created_by, remote_ip,"#{reimbursement_note_number} for amount #{amount}", action, branch_id)
  end

  #creating new ledger entry for ne record
  def save_with_ledgers
    save_result = false
    transaction do
      if save
        puts " Reimbursement Note Number >>>>>>>>>>>>>>>>> #{self.reimbursement_note_number} <<<<<<<<<<<<<<<<<<"
        reimbursement_note_line_items.each do |line_item|
          random_str = Ledger.generate_secure_random
          debit_ledger_entry = Ledger.new_debit_ledger(from_account_id, company_id, transaction_date, line_item.amount, reimbursement_note_number, created_by, line_item.description, branch_id,random_str, line_item.expense_account_id)
          credit_ledger_entry = Ledger.new_credit_ledger(line_item.expense_account_id, company_id, transaction_date, line_item.amount, reimbursement_note_number, created_by, line_item.description, branch_id,random_str, from_account_id)

          #build relationship between reimbursement note and ledgers
          ledgers << debit_ledger_entry
          ledgers << credit_ledger_entry
        end
        VoucherSetting.next_reimbursement_note_write(company_id)
        save_result = true
      end
    end
    save_result
  end

  #updating ledger entries in  case of edit actions
  def update_and_post_ledgers
    update_result = false;
    transaction do
      if update
        Ledger.delete(ledgers)
        random_str = Ledger.generate_secure_random

        reimbursement_note_line_items.each do |line_item|
          debit_ledger_entry = Ledger.new_debit_ledger(line_item.expense_account_id, company_id, transaction_date, line_item.amount, reimbursement_note_number, created_by, description, branch_id,random_str, from_account_id)
          credit_ledger_entry = Ledger.new_credit_ledger(from_account_id, company_id, transaction_date, line_item.amount, reimbursement_note_number, created_by, description, branch_id,random_str, line_item.expense_account_id)
          #build relationship between reimbursement note and ledgers
          ledgers << debit_ledger_entry
          ledgers << credit_ledger_entry
        end
        update_result = true
      end
    end
  end

  #update payment status on Reimbursement Voucher Entry
  def update_payment_status
    self.update_attribute(:submitted, 1)
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
  end
end

class DebitNote < ActiveRecord::Base
  scope :by_branch_id, lambda {|id| where(:branch_id => id) unless id.blank? }
  scope :by_deleted, lambda {|del| where(:deleted => del)}
  scope :by_date, lambda{|fin_year| where(:transaction_date => fin_year.start_date..fin_year.end_date) unless fin_year.blank?}
  scope :by_voucher, lambda{|voucher| where("debit_note_number like ?", "%#{voucher}%") unless voucher.blank?}
  scope :by_from_account, lambda{|from_account| where(:from_account_id=>from_account) unless from_account.blank? }
  scope :by_to_account, lambda{|to_account| where(:to_account_id=>to_account) unless to_account.blank? }
  scope :by_date_range, lambda{|start_date, end_date| where(:transaction_date=> start_date..end_date) unless start_date.blank? || end_date.blank? }
  scope :by_amount_range, lambda{|min_amt, max_amt| where(:amount=> min_amt..max_amt)}

  #relationships
  belongs_to :account
  belongs_to :from_account, :class_name=>"Account", :foreign_key=>:from_account_id
  belongs_to :to_account, :class_name=>"Account", :foreign_key=>:to_account_id
  belongs_to :company
  has_many :ledgers, :as => :voucher, :dependent => :destroy
  belongs_to :purchase_return
  has_many :purchase_debit_allocations

  accepts_nested_attributes_for :purchase_debit_allocations
  #validations
  validates :debit_note_number ,:transaction_date,:amount,:to_account_id , :presence=> true
  validates_presence_of :from_account_id, :if=>lambda { |a| !a.read_only? }
  validates_uniqueness_of :debit_note_number, :scope=>:company_id
  validates_length_of :description , :maximum => 300
  validates :amount, :numericality => {:greater_than_or_equal_to => 0.01,
       :message => " sholud not be zero or negative."}

  validate :validate_from_account_and_to_account
  validate :amount_allocation
  # after_update :manage_purchase_and_debit_note_status
  def voucher_setting
    VoucherSetting.by_voucher_type(13, company_id).first
  end

  def total_amount
    amount
  end
  def currency
    code=company.currency_code
    code=purchase_return.currency unless purchase_return.blank?
    code
  end

  def manage_purchase_and_debit_note_status
    if amount<=allocated_amount
      self.update_attribute("opened", false)
    end
    purchase_debit_allocations.each do |allocation|
      allocation.purchase.update_purchase_status
    end
  end

  def amount_allocation
    if amount<allocated_amount
      errors.add(:amount, "can't be greater than unallocated amount")
    end
  end

  def allocated_amount
    amount=0
    purchase_debit_allocations.each do |allocation|
      amount+=allocation.amount unless allocation.amount.blank?
    end
    amount
  end
  # validate :save_only_in_current_year
  validate :save_in_frozen_fy
  attr_accessor :fin_year

  WRITE_STATUS={true=>"ro", false=>"rw"}

  def unallocated_amount
    amount-purchase_debit_allocations.sum(:amount)
  end

  def allocation_enable?
    !in_frozen_year? && opened?
  end

  def save_in_frozen_fy
    if !transaction_date.blank? && in_frozen_year?
      errors.add(:transaction_date, "can't be in frozen financial year")
    end
  end

  def in_frozen_year?
    FinancialYear.check_if_frozen(company_id, transaction_date)
  end

  def get_product(tax_id)
  end

  def validate_from_account_and_to_account
    if self.from_account_id == self.to_account_id
      errors.add(:base, "Both accounts should not be same")
    end
    if !from_account.blank? && !transaction_date.blank? && from_account.start_date > transaction_date
      errors.add(:transaction_date, "must be after account activation, #{from_account.name} is activated since #{from_account.start_date}")
    end
    if !to_account.blank? && !transaction_date.blank? && to_account.start_date > transaction_date
      errors.add(:transaction_date, "must be after account activation, #{to_account.name} is activated since #{to_account.start_date}")
    end
  end

  def from_account_name
    Account.find(from_account_id).name
  end

  def to_account_name
    Account.find(to_account_id).name
  end

  class << self
    def create_allocation(params, company)
      debit_note=company.debit_notes.find(params[:id])
      debit_note.assign_attributes(params[:debit_note])
      debit_note
    end

    def allocate_debit(params, company)
      debit_note=company.debit_notes.find(params[:id])
      allocated_purchases=debit_note.purchase_debit_allocations
      unallocated_purchases = company.purchases.not_in(allocated_purchases).by_vendor(debit_note.to_account_id).by_status(0).by_currency(debit_note.to_account.get_currency_id)
      unallocated_purchases.each do |purchase|
        purchase_debit_allocation=PurchaseDebitAllocation.new(:purchase_id=>purchase.id)
        debit_note.purchase_debit_allocations<<purchase_debit_allocation
      end
      debit_note
    end

    def add_purchase_return_note(purchase_return, remote_ip)
      # debit note will be recorded against purchase return
      debit_note=new_note(purchase_return.company)
      debit_note.company_id=purchase_return.company.id
      debit_note.created_by=purchase_return.created_by
      debit_note.transaction_date=purchase_return.record_date
      debit_note.to_account_id=purchase_return.account_id
      debit_note.description=purchase_return.customer_notes
      debit_note.branch_id=purchase_return.purchase.branch_id
      debit_note.read_only=true
      debit_note.amount=purchase_return.total_amount
      debit_note.purchase_return_id=purchase_return.id
      debit_note.description="This voucher generated with reference of purchase return ##{purchase_return.purchase_return_number}"
      debit_note.save(:validate=>false)
      debit_note.register_user_action(remote_ip, 'created')
      debit_note
    end

    def new_note(company)
      debit_note = DebitNote.new
      debit_note.company_id=company.id
      debit_note.debit_note_number = VoucherSetting.next_debit_note_number(company)
      debit_note
    end

    def create_note(params, company, user, fyr)
      debit_note = DebitNote.new(params[:debit_note])
      debit_note.company_id = company
      debit_note.created_by = user.id
      debit_note.branch_id = user.branch_id unless user.branch_id.blank?
      debit_note.fin_year = fyr
      debit_note
    end

    def update_note(params, company, user, fyr)
      debit_note = DebitNote.find(params[:id])
      debit_note.branch_id = user.branch_id unless user.branch_id.blank?
      debit_note.fin_year = fyr
      debit_note
    end
  end

  def register_user_action(remote_ip, action)
    Workstream.register_user_action(company_id, created_by, remote_ip," #{debit_note_number} for amount #{amount}", action, branch_id)
  end

  #creating new ledger entry for ne record
  def save_with_ledgers
    save_result = false
    transaction do
      if save
        random_str = Ledger.generate_secure_random
        debit_ledger_entry = Ledger.new_debit_ledger(to_account_id, company_id, transaction_date, amount, debit_note_number, created_by, description, branch_id,random_str, to_account_id)
        credit_ledger_entry = Ledger.new_credit_ledger(from_account_id, company_id, transaction_date, amount, debit_note_number, created_by, description, branch_id,random_str, from_account_id)
        #build relationship between invoice and ledgers
        ledgers << debit_ledger_entry
        ledgers << credit_ledger_entry
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
        debit_ledger_entry = Ledger.new_debit_ledger(to_account_id, company_id, transaction_date, amount, debit_note_number, created_by, description, branch_id, random_str, to_account_id)
        credit_ledger_entry = Ledger.new_credit_ledger(from_account_id, company_id, transaction_date, amount, debit_note_number, created_by, description, branch_id, random_str, from_account_id)
        #build relationship between invoice and ledgers
        ledgers << debit_ledger_entry
        ledgers << credit_ledger_entry
        update_result = true
      end
    end
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

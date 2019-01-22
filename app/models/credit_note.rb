class CreditNote < ActiveRecord::Base
  scope :by_branch_id, lambda {|id| where(:branch_id => id) unless id.blank? }
  scope :by_deleted, lambda {|del| where(:deleted => del)}
  scope :by_date, lambda{|fin_year| where(:transaction_date => fin_year.start_date..fin_year.end_date) unless fin_year.blank?}
  scope :by_voucher, lambda{|voucher| where("credit_note_number like ?", "%#{voucher}%") unless voucher.blank?}
  scope :by_from_account, lambda{|from_account| where(:from_account_id=>from_account) unless from_account.blank? }
  scope :by_to_account, lambda{|to_account| where(:to_account_id=>to_account) unless to_account.blank? }
  scope :by_date_range, lambda{|start_date, end_date| where(:transaction_date=> start_date..end_date) unless start_date.blank? || end_date.blank? }
  scope :by_amount_range, lambda{|min_amt, max_amt| where(:amount=> min_amt..max_amt)}


  belongs_to :account
  belongs_to :company
  has_many :ledgers, :as=>:voucher, :dependent=>:destroy
  has_many :invoice_credit_allocations, :dependent=>:destroy
  belongs_to :from_account, :class_name=>"Account", :foreign_key=>:from_account_id
  belongs_to :to_account, :class_name=>"Account", :foreign_key=>:to_account_id
  belongs_to :invoice_return

  accepts_nested_attributes_for :invoice_credit_allocations, :reject_if=> lambda{|a| a[:amount].blank? || a[:amount].to_f<=0}, :allow_destroy => true
  #validations
   validates :credit_note_number ,:transaction_date,:amount,:to_account_id, :presence=> true
   validates_uniqueness_of :credit_note_number, :scope=>:company_id
   validates_length_of :description , :maximum => 300
   validates :amount, :numericality => {:greater_than_or_equal_to => 0.01,
                                         :message => " should not be zero or negative ." }

   validate :validate_from_account_and_to_account

   # validate :save_only_in_current_year
   validate :save_in_frozen_fy
  attr_accessor :fin_year
  validate :amount_allocation
  READ_ONLY={true=>"read_only", false=>"read_write"}
  def voucher_setting
    VoucherSetting.by_voucher_type(14, company_id).first
  end

  def total_amount
      amount
    end
  def amount_allocation
    if amount<allocated_amount
      errors.add(:amount, "can't be greater than unallocated amount")
    end
  end

  def manage_invoice_and_credit_note_status
    if amount<=allocated_amount
      self.update_attribute("opened", false)
    end
    invoice_credit_allocations.each do |allocation|
      allocation.invoice.update_invoice_status
    end
  end

  def allocated_amount
    amount=0
    invoice_credit_allocations.each do |allocation|
      amount+=allocation.amount unless allocation.amount.blank?
    end
    amount
  end

  def unallocated_amount
    amount-invoice_credit_allocations.sum(:amount)
  end

  def currency
    code=company.currency_code
    code=invoice_return.currency unless invoice_return.blank?
    code
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
     from_account.name unless from_account.blank?
   end

  def to_account_name
    to_account.name unless to_account.blank?
  end

  class << self
    def create_allocation(params, company)
      credit_note=company.credit_notes.find(params[:id])
      credit_note.assign_attributes(params[:credit_note])
      credit_note
    end

    def allocate_credit(params, company)
      credit_note=company.credit_notes.find(params[:id])
      allocated_invoices=credit_note.invoice_credit_allocations
      unallocated_invoices = company.invoices.not_in(allocated_invoices).by_customer(credit_note.to_account_id).by_status(0).by_currency(credit_note.to_account.get_currency_id)
      unallocated_invoices.each do |invoice|
        invoice_credit_allocation=InvoiceCreditAllocation.new(:invoice_id=>invoice.id)
        credit_note.invoice_credit_allocations<<invoice_credit_allocation
      end
      credit_note
    end

    def add_invoice_return_note(invoice_return, remote_ip, credit_note_amount)
      voucher_setting = VoucherSetting.where(:company_id=>invoice_return.company.id, :voucher_type=> 14).first
      if  voucher_setting.voucher_number_strategy ==2
        credit_note=return_invoice_new_note(invoice_return)
      else
        credit_note=new_note(invoice_return.company)
      end

      credit_note.company_id=invoice_return.company.id
      credit_note.created_by=invoice_return.created_by
      credit_note.transaction_date=invoice_return.record_date
      credit_note.to_account_id=invoice_return.account_id
      credit_note.description=invoice_return.description
      credit_note.branch_id=invoice_return.invoice.branch_id
      credit_note.read_only=true
      credit_note.amount=credit_note_amount
      credit_note.invoice_return_id=invoice_return.id
      credit_note.description="This voucher generated with reference of invoice return ##{invoice_return.invoice_return_number}"
      credit_note.save(:validate=>false)
      credit_note.register_user_action(remote_ip, 'created')
      credit_note
    end
    def return_invoice_new_note(invoice_return)
      credit_note = CreditNote.new
      credit_note.company_id=invoice_return.company.id
      credit_note.credit_note_number =VoucherSetting.return_invoice_next_credit_note_number(invoice_return)
      credit_note
    end

    def new_note(company)
      credit_note = CreditNote.new
      credit_note.company_id=company.id
      credit_note.credit_note_number = VoucherSetting.next_credit_note_number(company)
      credit_note
    end

    def create_note(params, company, user, fyr)
      credit_note = CreditNote.new(params[:credit_note])
      credit_note.company_id = company
      credit_note.created_by = user.id
      credit_note.branch_id = user.branch_id unless user.branch_id.blank?
      credit_note.fin_year = fyr
      credit_note
    end
    def update_note(params, company, user, fyr)
      credit_note = CreditNote.find(params[:id])
      credit_note.branch_id = user.branch_id unless user.branch_id.blank?
      credit_note.fin_year = fyr
      credit_note
    end
  end
  def register_user_action(remote_ip, action)
     Workstream.register_user_action(company_id, created_by, remote_ip," #{credit_note_number} for amount #{amount}", action, branch_id)
  end
 #creating new ledger entry for new record
  def save_with_ledgers
    save_result = false
    transaction do
      if save
        random_str = Ledger.generate_secure_random
        debit_ledger_entry = Ledger.new_debit_ledger(from_account_id, company_id, transaction_date, amount, credit_note_number, created_by, description, branch_id, random_str, to_account_id)
        credit_ledger_entry = Ledger.new_credit_ledger(to_account_id, company_id, transaction_date, amount, credit_note_number, created_by, description, branch_id, random_str, from_account_id)
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
        debit_ledger_entry = Ledger.new_debit_ledger(from_account_id, company_id, transaction_date, amount, credit_note_number, created_by, description, branch_id, random_str, to_account_id)
        credit_ledger_entry = Ledger.new_credit_ledger(to_account_id, company_id, transaction_date, amount, credit_note_number, created_by, description, branch_id, random_str, from_account_id)
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
 def credit_notes(company)
    acc = self.accounts.find_all_by_company_id(company)
     if acc.blank?
      nil
    else
      acc
    end
 end

end

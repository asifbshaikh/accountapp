class Deposit < ActiveRecord::Base
  scope :by_branch_id, lambda {|id| where(:branch_id => id) unless id.blank? }
  scope :by_deleted, lambda {|del| where(:deleted => del)}
  scope :by_date, lambda{|fin_year| where(:transaction_date => fin_year.start_date..fin_year.end_date) unless fin_year.blank?}
  scope :by_voucher, lambda{|voucher| where("voucher_number like ?", "%#{voucher}%") unless voucher.blank?}
  scope :by_from_account, lambda{|from_account| where(:from_account_id=>from_account) unless from_account.blank? }
  scope :by_to_account, lambda{|to_account| where(:to_account_id=>to_account) unless to_account.blank? }
  scope :by_date_range, lambda{|start_date, end_date| where(:transaction_date=> start_date..end_date) unless start_date.blank? || end_date.blank? }
  scope :by_amount_range, lambda{|min_amt, max_amt| where(:amount=> min_amt..max_amt)}


  belongs_to :from_account, :class_name=>"Account", :foreign_key=>:from_account_id
  belongs_to :to_account, :class_name=>"Account", :foreign_key=>:to_account_id
  belongs_to :company
  has_many :ledgers, :as => :voucher, :dependent => :destroy

  #validations
  validates :transaction_date, :amount, :from_account_id, :to_account_id, :voucher_number , :presence=> true
  validates_uniqueness_of :voucher_number, :scope=>:company_id
  validates_length_of :description , :maximum => 300
  validates :amount, :numericality => {:greater_than_or_equal_to => 0.01,
                                          :message => " should not be zero or negative ." }
  validate :validate_from_account_and_to_account
  # validate :save_only_in_current_year
  validate :validate_from_account_type, :if => :from_account_id
  validate :validate_to_account_type, :if => :to_account_id
  validate :save_in_frozen_fy
  attr_accessor :fin_year
  def voucher_setting
    VoucherSetting.by_voucher_type(9, company_id).first
  end
  def save_in_frozen_fy
    if !transaction_date.blank? && in_frozen_year?
      errors.add(:transaction_date, "can't be in frozen financial year")
    end
  end

  def in_frozen_year?
    FinancialYear.check_if_frozen(company_id, transaction_date)
  end

  def validate_from_account_type
     if !("CashAccount").include?(Account.find(from_account_id).accountable_type)
      errors.add(:from_account_id,"you entered is not a cash account, please select right account")
     end
  end
  def validate_to_account_type
     if !(["BankAccount", "SecuredLoanAccount"]).include?(Account.find(to_account_id).accountable_type)
      errors.add(:to_account_id,"you entered is not a bank account, please select right account")
     end
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
    def new_deposit(company)
      deposit = Deposit.new
      deposit.company_id=company.id
      deposit.voucher_number = VoucherSetting.next_deposit_number(company)
      deposit
    end
    def create_deposit(params, company, user, fyr)
      deposit = Deposit.new(params[:deposit])
      deposit.from_account_id=nil if deposit.from_account.blank?
      deposit.to_account_id=nil if deposit.to_account.blank?
      deposit.company_id = company
      deposit.created_by = user.id
      deposit.branch_id = user.branch_id unless user.branch_id.blank?
      deposit.fin_year = fyr
      deposit
    end
    def update_deposit(params, company, user, fyr)
      deposit = Deposit.find(params[:id])
      deposit.assign_attributes(params[:deposit])
      deposit.from_account_id=nil if deposit.from_account.blank?
      deposit.to_account_id=nil if deposit.to_account.blank?
      deposit.branch_id = user.branch_id unless user.branch_id.blank?
      deposit.fin_year = fyr
      deposit
    end
  end

def register_user_action(remote_ip, action)
  Workstream.register_user_action(company_id, created_by, remote_ip,
  " #{voucher_number} for #{amount} into #{to_account_name}", action, branch_id)
end

def register_delete_action(remote_ip, user, action)
  Workstream.register_user_action(company_id, user.id, remote_ip,
  " #{voucher_number} for #{amount} into #{to_account_name}", action, branch_id)
end

  #method for saving deposit with ledger
def save_with_ledgers
    save_result = false
    transaction do
      if save
          random_str = Ledger.generate_secure_random
          debit_ledger_entry = Ledger.new_debit_ledger(to_account_id, company_id, transaction_date,
            amount, voucher_number, created_by, description, branch_id, random_str, from_account_id)

          credit_ledger_entry = Ledger.new_credit_ledger(from_account_id, company_id, transaction_date,
            amount, voucher_number, created_by, description, branch_id, random_str, to_account_id)

          #build and save relationship between invoice and ledgers
          ledgers << debit_ledger_entry
          ledgers << credit_ledger_entry

      save_result = true
      end
    end
    save_result
  end

#method for updating deposit with ledger
  def update_and_post_ledgers
    update_result = false
    transaction do
     if update
      ledgers.each do |ledger|
        bank_statement_line_item = ledger.bank_statement_line_item
        unless bank_statement_line_item.blank?
          bank_statement_line_item.update_attributes(:status => 0, :ledger_id => nil)
        end
      end
     Ledger.delete(ledgers)
        random_str = Ledger.generate_secure_random
        debit_ledger_entry = Ledger.new_debit_ledger(to_account_id, company_id, transaction_date,
          amount, voucher_number, created_by, description, branch_id, random_str, from_account_id)

        credit_ledger_entry = Ledger.new_credit_ledger(from_account_id, company_id, transaction_date,
          amount, voucher_number, created_by, description, branch_id, random_str, to_account_id)

        ledgers << debit_ledger_entry
        ledgers << credit_ledger_entry

      update_result = true
    end
   end
      update_result
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

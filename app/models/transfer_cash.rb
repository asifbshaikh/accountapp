class TransferCash < ActiveRecord::Base
  scope :by_branch_id, lambda {|id| where(:branch_id => id) unless id.blank? }
  scope :by_deleted, lambda {|del| where(:deleted => del)}
  scope :by_date, lambda{|fin_year| where(:transaction_date => fin_year.start_date..fin_year.end_date) unless fin_year.blank?}
  scope :by_voucher, lambda{|voucher| where("voucher_number like ?", "%#{voucher}%") unless voucher.blank?}
  scope :by_from_account, lambda{|from_account| where(:transferred_from_id=>from_account) unless from_account.blank? }
  scope :by_to_account, lambda{|to_account| where(:transferred_to_id=>to_account) unless to_account.blank? }
  scope :by_date_range, lambda{|start_date, end_date| where(:transaction_date=> start_date..end_date) unless start_date.blank? || end_date.blank? }
  scope :by_amount_range, lambda{|min_amt, max_amt| where(:amount=> min_amt..max_amt)}


  belongs_to :from_account, :class_name=>"Account", :foreign_key=>:transferred_from_id
  belongs_to :to_account, :class_name=>"Account", :foreign_key=>:transferred_to_id
  belongs_to :company
  has_many :ledgers, :as => :voucher, :dependent => :destroy

  #validations
  validates :transaction_date,:amount,:transferred_from_id, :transferred_to_id, :voucher_number, :presence=> true
  validates_uniqueness_of :voucher_number, :scope=>:company_id
  validates_length_of :description , :maximum => 300
  validates :amount, :numericality => {:greater_than_or_equal_to => 0.01,
                                        :message => " should not be zero or negative ." }
  validate :validate_from_account_and_to_account
   # validate :save_only_in_current_year
  validate :validate_from_account_type, :if => :transferred_from_id
  validate :validate_to_account_type, :if => :transferred_to_id
  validate :save_in_frozen_fy
  attr_accessor :fin_year
  def voucher_setting
    VoucherSetting.by_voucher_type(10, company_id).first
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
     if !(["BankAccount", "CashAccount", "SecuredLoanAccount"]).include?(Account.find(transferred_from_id).accountable_type)
      errors.add(:transferred_from_id,"account you entered is wrong, please select right account")
     end
  end
  def validate_to_account_type
     if !(["BankAccount", "CashAccount", "SecuredLoanAccount"]).include?(Account.find(transferred_to_id).accountable_type)
      errors.add(:transferred_to_id,"account you entered is wrong, please select right account")
     end
  end

  def validate_from_account_and_to_account
    unless from_account.blank? || to_account.blank?
      from_account_type = Account.find(transferred_from_id).accountable_type
      to_account_type = Account.find(transferred_to_id).accountable_type
      if self.transferred_from_id == self.transferred_to_id
        errors.add(:base, "Both accounts should not be same")
      # elsif from_account_type != to_account_type
      #   errors.add(:base, "Both account types should be same (either bank or cash accounts)")
      end
    end
    if !from_account.blank? && !transaction_date.blank? && from_account.start_date > transaction_date
      errors.add(:transaction_date, "must be after account activation, #{from_account.name} is activated since #{from_account.start_date}")
    end
    if !to_account.blank? && !transaction_date.blank? && to_account.start_date > transaction_date
      errors.add(:transaction_date, "must be after account activation, #{to_account.name} is activated since #{to_account.start_date}")
    end
  end

  def availble_balance
     account = Account.find(transferred_from_id)
	puts "@@@@@ respective account balance is #{account.closing_balance }"
	if self.amount > account.current_balance
	 errors.add(:base, "No enough balance in #{account.name}")
	else
		true
       end
  end

  def from_account_name
    Account.find(transferred_from_id).name
  end

  def to_account_name
    Account.find(transferred_to_id).name
  end

  class << self
    def new_transfer(company)
      transfer_cash = TransferCash.new
      transfer_cash.company_id=company.id
      transfer_cash.voucher_number = VoucherSetting.next_transfer_cash_number(company)
      transfer_cash
    end
    def create_transfer(params, company, user, fyr)
      transfer_cash = TransferCash.new(params[:transfer_cash])
      transfer_cash.transferred_from_id=nil if transfer_cash.from_account.blank?
      transfer_cash.transferred_to_id=nil if transfer_cash.to_account.blank?
      transfer_cash.company_id = company
      transfer_cash.created_by = user.id
      transfer_cash.branch_id = user.branch_id unless user.branch_id.blank?
      transfer_cash.fin_year = fyr
      transfer_cash
    end
    def update_transfer(params, company, user, fyr)
      transfer_cash = TransferCash.find(params[:id])
      transfer_cash.assign_attributes(params[:transfer_cash])
      transfer_cash.transferred_from_id=nil if transfer_cash.from_account.blank?
      transfer_cash.transferred_to_id=nil if transfer_cash.to_account.blank?
      transfer_cash.branch_id = user.branch_id unless user.branch_id.blank?
      transfer_cash.fin_year = fyr
      transfer_cash
    end
  end
  def register_user_action(remote_ip, action)
     Workstream.register_user_action(company_id, created_by, remote_ip,
    " #{voucher_number} for #{amount} from #{from_account_name} to #{to_account_name}", action, branch_id)
  end

  def register_delete_action(remote_ip, user, action)
     Workstream.register_user_action(company_id, user.id, remote_ip,
    " #{voucher_number} for #{amount} from #{from_account_name} to #{to_account_name}", action, branch_id)
  end

#method for saving transfer_cash with ledger
def save_with_ledgers
    save_result = false
    transaction do
      if save
          random_str = Ledger.generate_secure_random
          debit_ledger_entry = Ledger.new_debit_ledger(transferred_to_id, company_id, transaction_date,
            amount, voucher_number, created_by, description, branch_id, random_str, transferred_from_id)

          credit_ledger_entry = Ledger.new_credit_ledger(transferred_from_id, company_id, transaction_date,
            amount, voucher_number, created_by, description, branch_id, random_str, transferred_to_id)

          #build and save relationship between invoice and ledgers
          ledgers << debit_ledger_entry
          ledgers << credit_ledger_entry

      save_result = true
      end
    end
    save_result
  end

#method for updating transfer_cash with ledger
  def update_and_post_ledgers
    update_result = false
    transaction do
     if update
     Ledger.delete(ledgers)
        random_str = Ledger.generate_secure_random
        debit_ledger_entry = Ledger.new_debit_ledger(transferred_to_id, company_id, transaction_date,
          amount, voucher_number, created_by, description, branch_id, random_str, transferred_from_id)

        credit_ledger_entry = Ledger.new_credit_ledger(transferred_from_id, company_id, transaction_date,
          amount, voucher_number, created_by, description, branch_id, random_str, transferred_to_id)

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

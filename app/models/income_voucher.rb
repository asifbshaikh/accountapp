class IncomeVoucher < ActiveRecord::Base
  scope :by_branch_id, lambda {|id| where(:branch_id => id) unless id.blank? }
  scope :by_deleted, lambda {|del| where(:deleted => del)}
  scope :by_date, lambda{|fin_year| where(:income_date => fin_year.start_date..fin_year.end_date) unless fin_year.blank?}
  scope :by_customer, lambda{|customer| where(:from_account_id=> customer) unless customer.blank? }
  scope :by_voucher, lambda{|voucher_no| where("voucher_number like ?", "%#{voucher_no}%")}
  scope :by_date_range, lambda{|start_date, end_date| where(:income_date=> start_date..end_date) unless start_date.blank? || end_date.blank? }
  scope :by_amount_range, lambda{|min_amt, max_amt| where(:amount=> min_amt..max_amt)}


  belongs_to :company
  belongs_to :from_account, :class_name=>"Account", :foreign_key=>:from_account_id
  belongs_to :to_account, :class_name=>"Account", :foreign_key=>:to_account_id

  has_many :ledgers, :as => :voucher, :dependent => :destroy
  has_one :payment_detail, :as => :voucher, :dependent => :destroy

  accepts_nested_attributes_for :payment_detail, :allow_destroy => true
  attr_accessible  :deleted_by, :deleted, :deleted_datetime, :voucher_number, :description, :amount, :income_date,:from_account_id,
                   :to_account_id, :payment_detail_attributes

  #validations
  validates_associated :payment_detail
  validates_presence_of :voucher_number,  :income_date, :amount, :to_account_id, :from_account_id
  validates_uniqueness_of :voucher_number, :scope=> :company_id
  validates :amount, :numericality => {:greater_than_or_equal_to => 0.01,
                                        :message => " should not be zero or negative ." }

 validate :validate_from_account_and_to_account
 validate :account_effective_date
 # validate :save_only_in_current_year
 validate :validate_from_account_type, :if => :from_account_id
 validate :validate_to_account_type, :if => :to_account_id
 validate :save_in_frozen_fy
  attr_accessor :fin_year




  def account_effective_date
    if !from_account.blank? && !income_date.blank? && income_date < from_account.start_date
      errors.add(:income_date, "must be after received from account activation, #{from_account.name} is activated since #{from_account.start_date}")
    end

    if !to_account.blank? && !income_date.blank? && income_date < to_account.start_date
      errors.add(:income_date, "must be after deposit account activation, #{to_account.name} is activated since #{to_account.start_date}")
    end

  end

  def voucher_setting
    VoucherSetting.by_voucher_type(3, company_id).first
  end
  def save_in_frozen_fy
    if !income_date.blank? && in_frozen_year?
      errors.add(:income_date, "can't be in frozen financial year")
    end
  end
  def in_frozen_year?
    FinancialYear.check_if_frozen(company_id, income_date)
  end
  def validate_from_account_type
     if !(["CapitalAccount","DepositAccount","DirectIncomeAccount","IndirectIncomeAccount","LoansAdvancesAccount",
            "LoanAccount","SecuredLoanAccount","SundryDebtor", "SundryCreditor","SuspenseAccount","UnsecuredLoanAccount"]).include?(Account.find(from_account_id).accountable_type)
         errors.add(:from_account_id,"you entered is wrong, please select right account")
     end
  end
  def validate_to_account_type
     if !(["BankAccount","CashAccount","DirectIncomeAccount","IndirectIncomeAccount"]).include?(Account.find(to_account_id).accountable_type)
      errors.add(:to_account_id,"you entered is wrong, please select right account")
     end
  end


  # def save_only_in_current_year
  #   year = Year.find_by_name(fin_year)
  #   f_year = FinancialYear.find_by_company_id_and_year_id(company_id, year.id)
  #   if !income_date.blank? && (income_date < f_year.start_date || income_date > f_year.end_date)
  #     errors.add(:income_date, " must be in current financial year")
  #   end
  # end
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

  class << self
    def new_income(company)
      income_voucher = IncomeVoucher.new
      income_voucher.company_id=company.id
      income_voucher.voucher_number = VoucherSetting.next_income_voucher_number(company)
      income_voucher.build_payment_detail
      income_voucher
    end

    def create_income(params, company, user, fyr)
        income_voucher = IncomeVoucher.new(params[:income_voucher])
        income_voucher.from_account_id=nil if income_voucher.from_account.blank?
        income_voucher.to_account_id=nil if income_voucher.to_account.blank?
        income_voucher.company_id = company
        income_voucher.created_by = user.id
        income_voucher.branch_id = user.branch_id unless user.branch_id.blank?
        income_voucher.payment_detail = fetch_payment_details(params)
        income_voucher.payment_detail.amount = income_voucher.amount
        income_voucher.fin_year = fyr
        income_voucher
    end

    def update_income(params, company, user, fyr)
      income_voucher = IncomeVoucher.find(params[:id])
      income_voucher.from_account_id = Account.get_account_id(params[:from_account_id], company)
      income_voucher.to_account_id = Account.get_account_id(params[:to_account_id], company)
      income_voucher.branch_id = user.branch_id unless user.branch_id.blank?
      income_voucher.fin_year = fyr
      income_voucher
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
    " #{voucher_number} #{action} from #{from_account_name} for amount #{amount}.", action, branch_id)
  end
  #method for saving income voucher with ledger
  def save_with_ledgers
    save_result = false
    transaction do
      if save
        random_str=Ledger.generate_secure_random
        debit_ledger_entry = Ledger.new_debit_ledger(to_account_id, company_id, income_date,
          amount, voucher_number, created_by, description, branch_id, random_str, from_account_id)

        credit_ledger_entry = Ledger.new_credit_ledger(from_account_id, company_id, income_date,
          amount, voucher_number, created_by, description, branch_id, random_str, to_account_id)

        #build and save relationship between invoice and ledgers
        ledgers << debit_ledger_entry
        ledgers << credit_ledger_entry

        save_result = true
      end
    end
    save_result
  end

#method for updating income voucher with ledger
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
        random_str=Ledger.generate_secure_random
        debit_ledger_entry = Ledger.new_debit_ledger(to_account_id, company_id, income_date,
          amount, voucher_number, created_by, description, branch_id, random_str, from_account_id)

        credit_ledger_entry = Ledger.new_credit_ledger(from_account_id, company_id, income_date,
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
			ledgers.update_all(:deleted_by => restored_by_user, :deleted => false, :deleted_datetime => Time.zone.now)
			result = true
		end
    end
    result
  end

end

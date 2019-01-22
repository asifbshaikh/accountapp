class Saccounting < ActiveRecord::Base
  scope :by_branch_id, lambda {|id| where(:branch_id => id) unless id.blank? }
  scope :by_deleted, lambda {|del| where(:deleted => del)}
  scope :by_date, lambda{|fin_year| where(:voucher_date => fin_year.start_date..fin_year.end_date) unless fin_year.blank?}
  scope :by_voucher, lambda{|voucher| where("voucher_number like ?", "%#{voucher}%") unless voucher.blank?}
  scope :by_to_account, lambda{|to_account| where(:account_id=>to_account) unless to_account.blank? }
  scope :by_date_range, lambda{|start_date, end_date| where(:voucher_date=> start_date..end_date) unless start_date.blank? || end_date.blank? }
  scope :by_amount_range, lambda{|min_amt, max_amt| where(:total_amount=> min_amt..max_amt)}



  belongs_to :account
  belongs_to :company
  has_many :saccounting_line_items, :dependent => :destroy
  has_many :ledgers, :as => :voucher, :dependent => :destroy

  accepts_nested_attributes_for :saccounting_line_items, :reject_if => lambda {|a| a[:from_account_id].blank? && a[:amount].blank? },
                                :allow_destroy => true

  #validations
  validates_presence_of :voucher_date,:voucher_number, :account_id
  validates_uniqueness_of :voucher_number, :scope => :company_id
  validates_presence_of :saccounting_line_items
  validates_associated :saccounting_line_items#, :message => "fields with * are mandatory"

  # validate :save_only_in_current_year
  validate :save_in_frozen_fy
  attr_accessor :fin_year
  def save_in_frozen_fy
    if !voucher_date.blank? && in_frozen_year?
      errors.add(:voucher_date, "can't be in frozen financial year" )
    end
  end
  def in_frozen_year?
    FinancialYear.check_if_frozen(company_id, voucher_date)
  end
  def get_product(tax_id)
  end
  # def save_only_in_current_year
  #   year = Year.find_by_name(fin_year)
  #   f_year = FinancialYear.find_by_company_id_and_year_id(company_id, year.id)
  #   if !voucher_date.blank? && (voucher_date < f_year.start_date || voucher_date > f_year.end_date)
  #     errors.add(:voucher_date, " must be in current financial year")
  #   end
  # end
  def amount
    saccounting_total = self.saccounting_line_items.sum(:amount)
    total = saccounting_total
    total
  end
  def created_by_user
    User.find(created_by).first_name.capitalize
  end

  def to_account_name
    Account.find(account_id).name
  end

class << self
  def new_saccounting(company)
    saccounting = Saccounting.new
    saccounting.voucher_number = VoucherSetting.next_saccounting_number(company)
    saccounting.saccounting_line_items.build
    saccounting
  end
  def create_saccounting(params, company, user, fyr)
    saccounting = Saccounting.new(params[:saccounting])
    saccounting.company_id = company
    saccounting.created_by = user.id
    saccounting.account_id = Account.get_account_id(params[:account_name], company)
    saccounting.branch_id = user.branch_id unless user.branch_id.blank?
    saccounting.fin_year = fyr
    saccounting_total = 0
    saccounting.saccounting_line_items.each do |line_item|
      saccounting_total+=line_item.amount.blank? ? 0 : line_item.amount
    end
    saccounting.total_amount = saccounting_total
    saccounting
  end
  def update_saccounting(params, company, user, fyr)
    saccounting = Saccounting.find(params[:id])
    saccounting.account_id = Account.get_account_id(params[:account_name], company)
    saccounting.branch_id = user.branch_id unless user.branch_id.blank?
    saccounting.fin_year = fyr
    saccounting
  end
end

def register_user_action(remote_ip, action)
  Workstream.register_user_action(company_id, created_by, remote_ip," #{voucher_number} for amount #{amount}", action, branch_id)
end

def register_delete_action(remote_ip, user, action)
  Workstream.register_user_action(company_id, user.id, remote_ip," #{voucher_number} for amount #{amount}", action, branch_id)
end

#method for saving saccounting with ledger
def save_with_ledgers
    save_result = false
    transaction do
      if save
        saccounting_line_items.each do |line_item|
          random_str = Ledger.generate_secure_random
          debit_ledger_entry = Ledger.new_debit_ledger(line_item.from_account_id, company_id, voucher_date,
            line_item.amount, voucher_number, created_by, description, branch_id, random_str, account_id)

          credit_ledger_entry = Ledger.new_credit_ledger(account_id, company_id, voucher_date,
            line_item.amount, voucher_number, created_by, description, branch_id, random_str, line_item.from_account_id)

          #build and save relationship between invoice and ledgers
          ledgers << debit_ledger_entry
          ledgers << credit_ledger_entry
        end
      save_result = true
      end
    end
    save_result
  end

  #method for updating saccounting with ledger
  def update_and_post_ledgers
    update_result = false
    transaction do
     if update
      Ledger.delete(ledgers)
      saccounting_line_items.reload
      saccounting_line_items.each do |line_item|
        random_str = Ledger.generate_secure_random
        debit_ledger_entry = Ledger.new_debit_ledger(line_item.from_account_id, company_id, voucher_date,
          line_item.amount, voucher_number, created_by, description, branch_id, random_str, account_id)

        credit_ledger_entry = Ledger.new_credit_ledger(account_id, company_id, voucher_date,
          line_item.amount, voucher_number, created_by, description, branch_id, random_str, line_item.from_account_id)

        ledgers << debit_ledger_entry
        ledgers << credit_ledger_entry

      end

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

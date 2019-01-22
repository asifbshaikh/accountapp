class Journal < ActiveRecord::Base
  scope :by_branch_id, lambda {|id| where(:branch_id => id) unless id.blank? }
  scope :by_deleted, lambda {|del| where(:deleted => del)}
  scope :by_date, lambda{|fin_year| where(:date => fin_year.start_date..fin_year.end_date) unless fin_year.blank?}
  scope :by_voucher, lambda{|voucher| where("voucher_number like ?", "%#{voucher}%") unless voucher.blank?}
  scope :by_to_account, lambda{|to_account| where(:account_id=>to_account) unless to_account.blank? }
  scope :by_from_account, lambda{|from_account| joins(:journal_line_items).where(:journal_line_items=> {:from_account_id=>from_account}) unless from_account.blank? }
  scope :by_date_range, lambda{|start_date, end_date| where(:date=> start_date..end_date) unless start_date.blank? || end_date.blank? }
  scope :by_amount_range, lambda{|min_amt, max_amt| where(:total_amount=> min_amt..max_amt)}
  scope :by_project, lambda { |project_id| where(project_id: project_id) unless project_id.blank? }
  belongs_to :account
  belongs_to :company
  belongs_to :project
  has_many :ledgers, :as => :voucher, :dependent => :destroy
  has_many :journal_line_items, :dependent => :destroy
  accepts_nested_attributes_for :journal_line_items, :reject_if => lambda {|a| a[:from_account_id].blank? && a[:amount].blank? },
                                :allow_destroy => true
  #validations
  validates_presence_of :date,:voucher_number #, :account_id
  validates_uniqueness_of :voucher_number, :scope => :company_id,:message => "already Consumed !! Next voucher number is allocated for you."
  validates_presence_of :journal_line_items
  validates_associated :journal_line_items#, :message => "fields with * are mandatory"

  # validate :save_only_in_current_year
  validate :debit_and_credit_amount, :if => lambda{|e| !e.old_voucher?}
  validate :save_in_frozen_fy
  attr_accessor :fin_year
  validate :account_effective_date

  def project_name
    if project.blank?
      "Not available"
    else
      project.name
    end
  end
  def voucher_setting
    VoucherSetting.by_voucher_type(11, company_id).first
  end
  def voucher_against
    credit_amount > 0 || account.blank? ? "Multiple accounts" : account.name
  end

  def account_effective_date
    journal_line_items.each do |line_item|
      if !date.blank? && !line_item.account.blank? && date < line_item.account.start_date
        errors.add(:date, "must be after account activation, #{line_item.account.name} is activated since #{line_item.account.start_date}")
      end
    end
  end

  def debit_and_credit_amount
    debit_amount = 0
    credit_amount = 0
    journal_line_items.each do |line_item|
      if !line_item.blank? && !line_item.amount.blank? && !line_item.credit_amount.blank?
        debit_amount += line_item.amount
        credit_amount += line_item.credit_amount
      end
    end
    if debit_amount != credit_amount
      errors.add(:base, "Debit and credit amount total should be same")
    end
  end

  def save_in_frozen_fy
    if !date.blank? && in_frozen_year?
    errors.add(:date, "can't be in frozen financial year")
    end
  end

  def in_frozen_year?
    FinancialYear.check_if_frozen(company_id, date)
  end

  def get_product(tax_id)
  end

  # def save_only_in_current_year
  #   year = Year.find_by_name(fin_year)
  #   f_year = FinancialYear.find_by_company_id_and_year_id(company_id, year.id)
  #   if !date.blank? && (date < f_year.start_date || date > f_year.end_date)
  #     errors.add(:date, " must be in current financial year")
  #   end
  # end

  def to_account_name
    Account.find(account_id).name
  end

  def amount
    journal_total = self.journal_line_items.sum(:amount)
    total = journal_total
    total
  end

  def credit_amount
    self.journal_line_items.sum(:credit_amount)
  end

  def created_by_user
    User.find(created_by).first_name.capitalize
  end

  class << self

    def correct_journal(journal_id,company,user)
      imported_journal = JournalImport.find(journal_id)
      journal = Journal.new
      journal.voucher_number = VoucherSetting.next_journal_number(company)
      journal.company_id = company.id
      journal.created_by = user.id
      journal.date = imported_journal.date
      journal.description = imported_journal.description
      journal.tags = imported_journal.tags
      imported_journal.journal_import_line_items.each do |line_item|
        journal_line_items = JournalLineItem.new
        journal_line_items.journal_id = journal.id
        journal_line_items.from_account_id = line_item.from_account_id
        journal_line_items.amount = line_item.amount
        journal_line_items.credit_amount = line_item.credit_amount
        journal.journal_line_items << journal_line_items
      end
      journal
    end

    def new_journal(params, company)
      journal = Journal.new
      journal.company_id=company.id
      journal.project_id=params[:project_id]
      journal.voucher_number = VoucherSetting.next_journal_number(company)
      journal.journal_line_items.build
      journal
    end

    def create_journal(params, company, user, fyr)
      journal = Journal.new(params[:journal])
      journal.company_id = company
      journal.created_by = user.id
      journal.account_id = Account.get_account_id(params[:account_name], company)
      journal.branch_id = user.branch_id unless user.branch_id.blank?
      journal.fin_year = fyr
      journal_total = 0
      journal.journal_line_items.each do |line_item|
        journal_total+= line_item.amount.blank? ? 0 : line_item.amount
      end
      journal.total_amount=journal_total
      journal
    end

    def update_journal(params, company, user, fyr)
      journal = Journal.find(params[:id])
      journal.branch_id = user.branch_id unless user.branch_id.blank?
      journal.fin_year = fyr
      journal
    end
  end

  def register_user_action(remote_ip, action)
    Workstream.register_user_action(company_id, created_by, remote_ip," #{voucher_number} for amount #{amount}", action, branch_id)
  end

  def register_delete_action(remote_ip, user, action)
    Workstream.register_user_action(company_id, user.id, remote_ip," #{voucher_number} for amount #{amount}", action, branch_id)
  end

  def old_voucher?
    !account_id.blank? && credit_amount == 0
  end


 #creating new ledger entry incase of new record
  def save_with_ledgers
    save_result = false
    transaction do
      if save

        debit_line_items = journal_line_items.where(:credit_amount => 0)
        credit_line_items = journal_line_items.where(:amount => 0)
        random_str = Ledger.generate_secure_random

         debit_line_items.each do |line_item|
          debit_ledger_entry = Ledger.new_debit_ledger(line_item.from_account_id, company_id, date, line_item.amount, voucher_number, created_by, description, branch_id, random_str, nil)
          ledgers << debit_ledger_entry
         end

        credit_line_items.each do |line_item|
          credit_ledger_entry = Ledger.new_credit_ledger(line_item.from_account_id, company_id, date, line_item.credit_amount, voucher_number, created_by, description, branch_id, random_str, nil)
          ledgers << credit_ledger_entry
        end

        save_result = true
      end
    end
    save_result
  end

#updating ledger entries in  case of edit actions
  def update_and_post_ledgers
    update_result = false
    transaction do
      Ledger.delete(ledgers)
      journal_line_items.reload

      if old_voucher?
        journal_line_items.each do |line_item|
          random_str = Ledger.generate_secure_random
          debit_ledger_entry = Ledger.new_debit_ledger(line_item.from_account_id, company_id, date, line_item.amount, voucher_number, created_by, description, branch_id, random_str, account_id)
          credit_ledger_entry = Ledger.new_credit_ledger(account_id, company_id, date, line_item.amount, voucher_number, created_by, description, branch_id, random_str, line_item.from_account_id)
          #build relationship between invoice and ledgers
          ledgers << debit_ledger_entry
          ledgers << credit_ledger_entry
        end
      else
        debit_line_items = journal_line_items.where(:credit_amount => 0)
        credit_line_items = journal_line_items.where(:amount => 0)
        random_str = Ledger.generate_secure_random

         debit_line_items.each do |line_item|
          debit_ledger_entry = Ledger.new_debit_ledger(line_item.from_account_id, company_id, date, line_item.amount, voucher_number, created_by, description, branch_id, random_str, nil)
          ledgers << debit_ledger_entry
         end

        credit_line_items.each do |line_item|
          credit_ledger_entry = Ledger.new_credit_ledger(line_item.from_account_id, company_id, date, line_item.credit_amount, voucher_number, created_by, description, branch_id, random_str, nil)
          ledgers << credit_ledger_entry
        end
      end
      update_result = true
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

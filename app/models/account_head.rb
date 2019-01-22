class AccountHead < ActiveRecord::Base
  scope :by_name, lambda{|name| where("name like ?", "%#{name}%") unless name.blank?}
  scope :by_parent, lambda{|parent| where(:parent_id=>parent) unless parent.blank? }
  scope :by_creater, lambda{|creater| where(:created_by =>creater) unless creater.blank? }
  scope :by_deleted, lambda {|del| where(:deleted => del)}
  scope :exclude_parties, lambda { where("name not in('Customers (Debtors)', 'Vendors (Creditors)')")  }

  acts_as_tree
  belongs_to :company
  has_many :accounts, :conditions => {:deleted => false}, :dependent => :destroy

  has_many :children, :class_name => "AccountHead", :foreign_key => "parent_id"
  belongs_to :parent, :class_name => "AccountHead"
  validates_presence_of :name
  validates_presence_of :company_id

  #This looks up for children accounts related to a parent account. Used in Trial balance calculations
  #Author: Ashish Wadekar
  #Date: 17th March 2017
  def get_children
    AccountHead.where(:parent_id => self)
  end

  def current_period_accounts(end_date)
    accounts.where("company_id = ? and start_date <= ?", company_id, end_date)
  end

  # Naveen 30 Apr 2016. This method is only called from horizontal profit and loss account
  def get_linked_account_balance(current_user, start_date, end_date, branch_id)
    amount=0
    allowed_accounts=current_period_accounts(end_date)
    allowed_accounts.each do |account|
      amount += account.transactions_in_period(start_date, end_date)
    end
    amount
  end

  class << self
  def method_missing(method_name, *args, &block)
    if method_name.to_s =~ /^fetch_all_(.*)_sub_heads$/
      fetch_all_sub_account_heads(args[0].to_i, $1.titleize.to_s)
    elsif method_name.to_s=~/^fetch_(.*)_with_children$/
      fetch_with_children_account_heads(args[0].to_i, $1.titleize.to_s)
    else
      super
    end
  end
  def fetch_with_children_account_heads(company, head_name)
    account_head=where(:name=>head_name,:company_id=>company)
    get_parent_and_child_heads(company, account_head) unless account_head.blank?
  end
  def fetch_all_sub_account_heads(company, head_name)
    account_head=find_by_name_and_company_id(head_name, company)
    account_head.children unless account_head.blank?
  end
  #This method is used to create root accounts for a company at the time of registration.
  #Company the user registering are entered here.
  def create_root_account_heads(company_id, user_id)
    root_account_head_names=["Bank Accounts","Cash Accounts","Fixed Assets","Loan Accounts","Secured Loan Accounts",
 		  "Unsecured Loan Accounts","Customers (Debtors)","Vendors (Creditors)", "Direct Expenses","Duties and Taxes",
      "Indirect Expenses", "Investments","Loans and advances","Provisions", "Deposits","Suspense Accounts",
      "Capital Accounts","Direct Income","Indirect Income", "Current Liabilities", "Reserves and Surplus",
      "Deferred Tax Asset Or Liability", "Other Current Assets"]
    root_account_head_names.each do |name|
      root_act = AccountHead.new
      root_act.name = name
      root_act.company_id = company_id
      root_act.created_by = user_id
      root_act.erasable = false
      root_act.save!
    end
  end

  def add_discount_subaccount_heads(company, user)
    indirect_income = self.find_by_name_and_company_id("Indirect Income",company)
    direct_income = self.find_by_name_and_company_id("Direct Income",company)
    self.create(:company_id => company, :parent_id => indirect_income.id, :name => "Discount Received-Indirect Income", :created_by => user, :erasable=>false )
    self.create(:company_id => company, :parent_id => direct_income.id, :name => "Discount Received-Direct Income", :created_by => user, :erasable=>false )
  end

  def add_default_income_and_expense(company, user, financial_year)
    direct_income = self.find_by_name_and_company_id("Direct Income",company)
    unless direct_income.blank?
      income_account = Account.create_direct_income(company, user, direct_income.id, financial_year)
    end
    direct_expense = self.find_by_name_and_company_id("Direct Expenses",company)
    unless direct_expense.blank?
      expense_account = Account.create_direct_expense(company, user, direct_expense.id, financial_year)
    end
    indirect_expense = self.find_by_name_and_company_id("Indirect Expenses",company)
    unless indirect_expense.blank?
      indirect_expense_account=Account.create_account(company, user, indirect_expense, financial_year, "Discount on Sales Account", "IndirectExpenseAccount")
    end
    indirect_income = self.find_by_name_and_company_id("Indirect Income",company)
    unless indirect_income.blank?
      indirect_income_account=Account.create_account(company, user, indirect_income, financial_year, "Discount on Purchase Account", "IndirectIncomeAccount")
    end
    # Product.create_default_products(company, user, income_account.id, expense_account.id)
  end
  # create default sub head under indirect expense head and create a default account
  def add_default_other_expense(company, user, financial_year)
    indirect_expense = self.find_by_name_and_company_id("Indirect Expenses",company)
    direct_expense = self.find_by_name_and_company_id("Direct Expenses", company)

    other_expense_on_sales = self.create(:name=>"Other Charges on Sales", :company_id => company, :created_by=> user, :parent_id=> indirect_expense.id, :erasable=>false)
    other_expense_on_purchase = self.create(:name=>"Other Charges on Purchase", :company_id => company, :created_by=> user, :parent_id=> direct_expense.id, :erasable=>false)

    unless other_expense_on_sales.blank?
      Account.create_other_expense_on_sales(company, user, other_expense_on_sales.id, financial_year)
    end
    unless other_expense_on_purchase.blank?
      Account.create_other_expense_on_purchase(company, user, other_expense_on_purchase.id, financial_year)
    end
  end

  # default TDS sub heads under Duties and Taxes head and also creating default accounts
  def add_default_tds_subheads(company, user, financial_year)
    tax_head = self.find_by_name_and_company_id("Duties and Taxes", company)
    other_current_asset_head = self.find_by_name_and_company_id("Other Current Assets", company)
    tds_receivable_head = self.create(:company_id => company, :parent_id => other_current_asset_head.id, :name => "TDS Receivable", :created_by => user, :erasable=>false )
    tds_payable_head = self.create(:company_id => company, :parent_id => tax_head.id, :name => "TDS Payable", :created_by => user, :erasable=>false )
    unless tds_receivable_head.blank?
      tds_receivable_acc = Account.create_tds_receivable_acc(company, user, tds_receivable_head.id, financial_year)
    end
    unless tds_payable_head.blank?
      tds_payable_acc = Account.create_tds_payable_acc(company, user, tds_payable_head.id, financial_year)
    end
  end

  def get_expense_acc_to_heads(company)
    account_heads = AccountHead.find_all_by_company_id_and_name(company, ["Purchase Accounts", "Indirect Expenses", "Direct Expenses", "Provisions","Suspense Accounts" ])
    get_parent_and_child_heads(company, account_heads)
  end

  def get_expense_acc_from_heads(company)
   account_heads = AccountHead.find_all_by_company_id_and_name(company, ["Bank Accounts","Cash Accounts","Secured Loan Accounts","Unsecured Loan Accounts"])
   get_parent_and_child_heads(company, account_heads)
  end

  def get_indirect_expense_acc_head(company)
   account_heads = AccountHead.find_all_by_company_id_and_name(company, "Indirect Expenses")
   get_parent_and_child_heads(company, account_heads)
  end

  def get_root_head(company_id, account_head_name)
    AccountHead.find_by_company_id_and_name(company_id,account_head_name)
  end

  def get_indirect_income_acc_head(company)
    account_heads = AccountHead.find_all_by_company_id_and_name(company, "Indirect Income")
    get_parent_and_child_heads(company, account_heads)
  end

  def get_customer(company)
    account_heads = AccountHead.find_all_by_company_id_and_name(company, "Customers (Debtors)")
    get_parent_and_child_heads(company, account_heads)
  end

  def get_vendor_head(company)
    account_heads = AccountHead.find_all_by_company_id_and_name(company, "Vendors (Creditors)")
    get_parent_and_child_heads(company, account_heads)
  end

  def get_purchase_head(company)
    account_heads = AccountHead.find_all_by_company_id_and_name(company, "Purchase Accounts")
    get_parent_and_child_heads(company, account_heads)
  end

  def get_sales_account(company)
    account_heads = AccountHead.find_all_by_company_id_and_name(company, "Products/Services")
    get_parent_and_child_heads(company, account_heads)
  end

  def get_duties_and_taxes_account(company)
    account_heads = AccountHead.find_all_by_company_id_and_name(company, "Duties and Taxes")
    get_parent_and_child_heads(company, account_heads)
  end

  def get_customer_and_vendor_account_heads(company)
    account_heads = AccountHead.find_all_by_company_id_and_name(company, ["Customers (Debtors)","Vendors (Creditors)"])
    get_parent_and_child_heads(company, account_heads)
  end

  def get_receipt_to_heads(company)
    account_heads= AccountHead.find_all_by_company_id_and_name(company, ["Bank Accounts","Cash Accounts","Secured Loan Accounts","Direct Income","Indirect Income", "Current Liabilities","Other Current Assets"])
    get_parent_and_child_heads(company, account_heads)
  end

  def get_receipt_from_heads(company)
    account_heads = AccountHead.find_all_by_company_id_and_name(company, ["Capital Accounts","Deposits","Direct Income","Indirect Income",
                                        "Loans and advances","Loan Accounts","Products/Services","Secured Loan Accounts",
                                        "Suspense Accounts","Unsecured Loan Accounts"])
    get_parent_and_child_heads(company, account_heads)
  end

  def get_contra_to_heads(company)
    account_heads = AccountHead.find_all_by_company_id_and_name(company, ["Bank Accounts","Cash Accounts","Direct Income","Indirect Income"])
    get_parent_and_child_heads(company, account_heads)
  end

  def get_bankacc_from_heads(company)
      account_heads = AccountHead.find_all_by_company_id_and_name(company, ["Bank Accounts"])
      get_parent_and_child_heads(company, account_heads)
  end

  def get_bankacc_to_heads(company)
    account_heads = AccountHead.find_all_by_company_id_and_name(company, "Bank Accounts")
    get_parent_and_child_heads(company, account_heads)
  end

  def get_bank_and_loan_from_heads(company)
      account_heads = AccountHead.find_all_by_company_id_and_name(company, ["Bank Accounts", "Secured Loan Accounts"])
      get_parent_and_child_heads(company, account_heads)
  end

  def get_bank_and_loan_to_heads(company)
    account_heads = AccountHead.find_all_by_company_id_and_name(company, ["Bank Accounts", "Secured Loan Accounts"])
    get_parent_and_child_heads(company, account_heads)
  end

  def get_cashacc_to_heads(company)
    account_heads = AccountHead.find_all_by_company_id_and_name(company, "Cash Accounts")
    get_parent_and_child_heads(company, account_heads)
  end

  def get_cashacc_from_heads(company)
    account_heads = AccountHead.find_all_by_company_id_and_name(company, "Cash Accounts")
    get_parent_and_child_heads(company, account_heads)
  end

  def get_discount_accounts(company)
    indirect_income = self.find_by_name_and_company_id("Indirect Income",company)
    direct_income = self.find_by_name_and_company_id("Direct Income",company)
    indirect_income_sub_account_head = self.find_by_parent_id_and_name(indirect_income.id, "Discount Received-Indirect Income")
    direct_income_sub_account_head = self.find_by_parent_id_and_name(direct_income.id, "Discount Received-Direct Income")
   unless indirect_income_sub_account_head.blank? && direct_income_sub_account_head.blank?
    Account.where("account_head_id = ? or account_head_id = ?", indirect_income_sub_account_head.id, direct_income_sub_account_head.id)
   end
  end

  def get_transferacc_from_heads(company)
    account_heads = AccountHead.find_all_by_company_id_and_name(company, ["Bank Accounts","Cash Accounts","Secured Loan Accounts"])
    get_parent_and_child_heads(company, account_heads)
  end

  def get_payment_from_heads(company)
    account_heads = AccountHead.find_all_by_company_id_and_name(company, ["Bank Accounts","Cash Accounts","Unsecured Loan Accounts","Secured Loan Accounts","Current Liabilities","Other Current Assets"])
    get_parent_and_child_heads(company, account_heads)
  end

  def get_payment_to_heads(company)
    account_heads = AccountHead.find_all_by_company_id_and_name(company, ["Direct Expenses","Indirect Expenses","Loans and advances",
                 "Loan Accounts","Provisions","Secured Loan Accounts",
               "Unsecured Loan Accounts","Deposits","Purchase Accounts","Suspense Accounts","Capital Accounts","Duties And Taxes"])
    get_parent_and_child_heads(company, account_heads)
  end

  def get_journal_to_heads(company)
    account_heads = AccountHead.find_all_by_company_id_and_name(company,["Fixed Assets","Direct Expenses","Duties And Taxes","Indirect Expenses ",
                             "Loans and Advances","Loan Accounts","Provisions","Secured Loan Accounts",
                            "Unsecured Loan Accounts","Deposits", "Purchase Accounts","Suspense Accounts","Investments",
                             "Products/Services","Direct Income","Indirect Income", "Capital Accounts", "Discount Received-Indirect Income","Discount Received-Direct Income",
      "Current Liabilities", "Reserves and Surplus", "Deferred Tax Asset Or Liability", "Other Current Assets"])
    get_parent_and_child_heads(company, account_heads)
  end

  def get_journal_from_heads(company)
    account_heads = AccountHead.find_all_by_company_id_and_name(company,["Fixed Assets","Direct Expenses","Duties And Taxes","Indirect Expenses ",
                             "Loans and Advances","Loan Accounts","Provisions","Secured Loan Accounts",
                            "Unsecured Loan Accounts","Deposits", "Purchase Accounts","Suspense Accounts","Investments",
                             "Products/Services","Direct Income","Indirect Income ", "Capital Accounts", "Discount Received-Indirect Income","Discount Received-Direct Income",
      "Current Liabilities", "Reserves and Surplus", "Deferred Tax Asset Or Liability", "Other Current Assets"])
   get_parent_and_child_heads(company, account_heads)
  end

  def get_saccounting_to_heads(company)
    account_heads = AccountHead.find_all_by_company_id_and_name(company,["Bank Accounts","Cash Accounts","Fixed Assets","Direct Expenses","Duties And Taxes","Indirect Expenses ",
                             "Loans and Advances","Loan Accounts","Provisions","Secured Loan Accounts",
                            "Unsecured Loan Accounts","Deposits", "Purchase Accounts","Suspense Accounts","Investments",
                             "Products/Services","Direct Income","Indirect Income ", "Capital Accounts","Discount Received-Indirect Income","Discount Received-Direct Income",  "Current Liabilities", "Other Current Assets"])
    get_parent_and_child_heads(company, account_heads)
  end

  def get_saccounting_from_heads(company)
    account_heads = AccountHead.find_all_by_company_id_and_name(company,["Bank Accounts","Cash Accounts","Fixed Assets","Direct Expenses","Duties And Taxes","Indirect Expenses ",
                             "Loans and Advances","Loan Accounts","Provisions","Secured Loan Accounts",
                            "Unsecured Loan Accounts","Deposits", "Purchase Accounts","Suspense Accounts","Investments",
                             "Products/Services","Direct Income","Indirect Income ", "Capital Accounts","Discount Received-Indirect Income","Discount Received-Direct Income", "Current Liabilities", "Other Current Assets"])
    get_parent_and_child_heads(company, account_heads)
  end

  #[OPTIMIZE] The entire logic and also retrieval is wrong,
  def setup_progress(company)
    progress = 0

    # progress += 20 unless get_customer(company).accounts.blank?
    # is_customer = false
    # get_customer(company).each do |customer|
    #   if !customer.accounts.blank?
    #     is_customer = true
    #   end
    # end
    progress += 20 if company.customers.size > 0

    # progress += 20 unless get_sales_account(company).accounts.blank?
    #this step is now skipped as we add a default sales account during signup
    # is_sales = false
    # get_sales_account(company).each do |sales|
    #   if !sales.accounts.blank?
    #     is_sales = true
    #   end
    # end
    progress += 20

    # progress += 10 unless get_duties_and_taxes_account(company).accounts.blank?
    is_duties_and_taxes = false
    get_duties_and_taxes_account(company).each do |duties_and_taxes|
      if !duties_and_taxes.accounts.blank?
        is_duties_and_taxes = true
      end
    end
    progress += 10 if is_duties_and_taxes

    # progress += 10 unless get_bankacc_to_heads(company).accounts.blank?
    is_bank_acc = false
    get_bankacc_to_heads(company).each do |bank_acc|
      if !bank_acc.accounts.blank?
        is_bank_acc = true
      end
    end
    progress += 10 if is_bank_acc

    # progress += 10 unless get_cashacc_to_heads(company).accounts.blank?
    is_cash_acc = false
    get_cashacc_to_heads(company).each do |cash_acc|
      if !cash_acc.accounts.blank?
        is_cash_acc = true
      end
    end
    progress += 10 if is_cash_acc

    # progress += 10 unless get_vendor_head(company).accounts.blank?
    is_vendor = false
    get_vendor_head(company).each do |vendor|
      if !vendor.accounts.blank?
        is_vendor = true
      end
    end
    progress += 10 if is_vendor

    is_pay = false
    get_payment_to_heads(company).each do |pay|
      if !pay.accounts.blank?
        is_pay = true
        break
      end
    end
    progress += 10 if is_pay

    # progress += 10 unless get_purchase_head(company).accounts.blank?

    is_purchase = false
    get_purchase_head(company).each do |purchase|
      if !purchase.accounts.blank?
        is_purchase = true
        break
      end
    end
    progress += 10 if is_purchase


    progress
  end

   def get_subaccount_heads(company, parent_id)
     AccountHead.where(:company_id => company, :parent_id => parent_id)
   end

   def company_account_groups(company)
      groups = AccountHead.where("name not in ('Current Assets', 'Vendors (Creditors)', 'Customers (Debtors)','DutiesAndTaxesAccounts') and deleted = ? and company_id=?", false,company)
      arr=[]
      groups.each do |group|
        hash={}
        hash["id"]= group.id
        hash["name"]= group.name
        arr<<hash
      end
      arr.to_json
    end

#method to get sub account heads (parent and childs)
  def get_parent_and_child_heads(company, account_heads)
    parent_heads = account_heads
    parent_heads.each do |ph|
      child_heads = AccountHead.where(:parent_id => ph.id, :company_id => company)
     if !child_heads.blank?
        child_heads.each do |ch|
          parent_heads << ch
        end
      end
    end
    parent_heads
  end

  def get_other_expense_head(company)
    parent_head = AccountHead.find_by_name_and_company_id("Indirect Expenses",company.id)
    other_expense_head = AccountHead.find_by_name_and_parent_id("Other Charges on Sales", parent_head.id)
  end

  def get_other_expense_head_on_purchase(company)
    parent_head = AccountHead.find_by_name_and_company_id("Direct Expenses",company.id)
    other_expense_head = AccountHead.find_by_name_and_parent_id("Other Charges on Purchase", parent_head.id)
  end

  def get_tds_receivable_head(company)
    parent_head = AccountHead.find_by_name_and_company_id("Other Current Assets", company.id)
    tds_receivable_head = AccountHead.find_by_name_and_parent_id_and_company_id("TDS Receivable",parent_head.id, company.id)
  end

  def get_tds_payable_head(company)
    parent_head = AccountHead.find_by_name_and_company_id("Duties and Taxes", company.id)
    tds_payable_head = AccountHead.find_by_name_and_parent_id_and_company_id("TDS Payable",parent_head.id, company.id)
  end
 end

  def created_by_user
    User.find(self.created_by).first_name
  end

  def parent_name
    parent_id.nil? ? 'Primary Group' : AccountHead.find(parent_id).name
  end

  def delete(deleted_by_user)
    result = false
    if self.accounts.empty?
      result = update_attributes(:deleted_by => deleted_by_user, :deleted => true, :deleted_datetime => Time.zone.now)
    else
      errors.add(:base,"This account group has accounts associated with it. You need to delete the accounts before deleting this group.")
    end
    result
  end

   def has_account?
    !Account.where(:company_id => company, :account_head_id => id).blank?
   end
end

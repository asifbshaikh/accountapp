class Company < ActiveRecord::Base
  #after_save :utilized_storage
  scope :by_name, lambda{|name| where(:name => name) unless name.blank?}
  scope :by_contact, lambda{|mobile| where(:phone => mobile) unless mobile.blank?}
  scope :by_email, lambda{|email| where(:email => email) unless email.blank?}
  scope :by_date, lambda{|start_date, end_date| where(:activation_date => start_date..end_date)}
  # scope :by_plan, lambda{|plan| where(:plan => plan) unless plan.blank?}
  # scope :by_owner, lambda{|owner| where(:owner => owner) unless owner.blank?}

  attr_accessor :old_file_size

  before_save :destroy_logo?
  
  belongs_to :gst_category
  has_many :gstr_twos
  has_one :invoice_return_sequence
  has_many :gstr1_summaries
  has_many :active_sessions
  has_many :request_logs
  has_many :gst_returns
  has_many :gstr_ones
  has_many :gstr_one_items
  has_many :gstr_two_items
  has_many :gstr2as
  has_many :invoice_returns
  has_many :payroll_settings
  has_many :client_invitations
  has_many :stock_histories
  has_many :purchase_warehouse_details
  has_many :product_batches
  has_many :voucher_settings
  has_many :purchase_returns
  has_many :instamojo_payment_links
  has_one :purchase_return_sequence
  has_one :stock_wastage_voucher_sequence
  has_one :stock_transfer_voucher_sequence
  has_one :stock_receipt_voucher_sequence
  has_one :stock_issue_voucher_sequence
  has_one :saccounting_sequence
  has_one :credit_note_sequence
  has_one :gst_credit_note_sequence
  has_one :debit_note_sequence
  has_one :gst_debit_note_sequence
  has_one :reimbursement_note_sequence
  has_one :reimbursement_voucher_sequence
  has_one :journal_sequence
  has_one :transfer_cash_sequence
  has_one :deposit_sequence
  has_one :withdrawal_sequence
  has_one :payment_voucher_sequence
  has_one :gstr_advance_payment_voucher_sequence
  has_one :purchase_order_sequence
  has_one :purchase_sequence
  has_one :expense_sequence
  has_one :income_voucher_sequence
  has_one :receipt_voucher_sequence
  has_one :gstr_advance_receipt_voucher_sequence
  has_one :estimate_sequence
  has_one :sales_order_sequence
  has_one :delivery_challan_sequence
  has_many :customers
  has_many :gstr_advance_payments
  has_many :vendors
  has_many :gstr_advance_receipts
  has_many :receipt_advances
  has_many :product_pricing_levels
  has_one :product_setting
  has_one :inventory_setting
  has_many :company_templates, :dependent => :destroy
  has_many :custom_fields, :dependent => :destroy
  has_one :label
  has_many :branches, :dependent => :destroy
  has_one :address, :as => :addressable, :dependent => :destroy
  has_many :customer_relationships, :dependent => :destroy
  has_many :sales_orders, :dependent => :destroy
  has_many :delivery_challans, :dependent => :destroy
  accepts_nested_attributes_for :customer_relationships
  has_one  :plan, :through => :subscription
  has_one :subscription
  accepts_nested_attributes_for :subscription
  has_many :stocks, :dependent => :destroy
  accepts_nested_attributes_for :address, :allow_destroy => true
  attr_accessible :address_attributes, :VAT_no, :service_tax_reg_no, :excise_reg_no,:tin,:phone,:fax,:facebook_url,
  :twitter_url,:linked_in_url, :google_plus_url,:you_sell,:source, :total_employees, :annual_turnover,
  :current_system, :business_type, :industry,:CST_no, :email, :sales_tax_no,:company_status, :status,
  :customer_relationships_attributes, :subscription_attributes, :pan, :terms_and_conditions,:customer_note,
  :watermark,:tan_no, :estimate_terms_and_conditions, :gst_category_id
  has_many :workstreams
  has_many :projects
  has_many :leave_cards
  has_many :salaries
  has_many :leave_requests
  has_many :variable_payhead_details
  has_many :invitation_details, :dependent => :destroy
  has_many :auditors, :through => :company_auditors
  has_many :company_auditors , :dependent => :destroy
  has_many :payroll_details, :dependent => :destroy
  has_many :payroll_execution_jobs, :dependent => :destroy
  has_many :attendances, :dependent => :destroy
  has_many :years, :through => :financial_years
  has_many :financial_years
  has_many :supports, :dependent => :destroy
  has_many :users, :dependent => :destroy, :conditions => {:deleted => false}
  has_many :inactive_users, :dependent => :destroy, :class_name=> "User", :conditions => {:deleted=> true}
  has_many :messages, :dependent => :destroy
  has_many :inventories, :dependent => :destroy
  has_many :ledgers, :dependent => :destroy
  has_many :accounts, :dependent => :destroy, :conditions => {:deleted => false}
  has_many :account_heads, :dependent => :destroy
  has_many :invoices, :dependent => :destroy, :conditions => {:invoice_status_id => [0,2,3,4]}   #"invoice_status_id !=1" #{}> [0,2,3]} Not in condition has poor performance
  has_many :receipt_vouchers, :dependent => :destroy
  has_many :income_vouchers, :dependent => :destroy
  has_many :withdrawals, :dependent => :destroy
  has_many :deposits, :dependent => :destroy
  has_many :transfer_cashes, :dependent => :destroy
  has_many :tds_payment_vouchers, :dependent => :destroy
  has_many :journals, :dependent => :destroy
  has_many :debit_notes, :dependent => :destroy
  has_many :gst_debit_notes, :dependent => :destroy
  has_many :credit_notes, :dependent => :destroy
  has_many :gst_credit_notes, :dependent => :destroy
  has_many :reimbursement_notes, :dependent => :destroy
  has_many :reimbursement_vouchers
  has_many :saccountings, :dependent => :destroy
  has_many :departments, :dependent => :destroy
  has_many :estimates, :dependent => :destroy
  has_many :payment_vouchers, :dependent => :destroy
  has_many :purchase_orders, :dependent => :destroy
  has_many :purchases, :dependent => :destroy, :conditions=>{:status_id=>[0, 1, 3]}
  has_many :expenses, :dependent => :destroy
  has_many :assets, :dependent => :destroy
  has_many :company_assets, :dependent => :destroy
  has_many :holidays, :dependent => :destroy
  has_many :designations, :dependent => :destroy
  has_many :leave_types, :dependent => :destroy
  has_many :organisation_announcements, :dependent => :destroy
  has_many :master_objectives, :dependent => :destroy
  has_many :employee_goals, :dependent => :destroy
  has_many :payheads, :dependent => :destroy
  has_many :salary_structures, :dependent => :destroy
  has_many :salary_structure_histories, :dependent => :destroy
  has_many :tasks, :dependent => :destroy
  has_many :policy_documents, :dependent => :destroy
  has_many :timesheets, :dependent => :destroy
  has_many :warehouses, :dependent => :destroy
  has_many :products, :dependent => :destroy
  has_many :subscription_histories
  #has_many :country, :through => :country_companies
  #has_many :country_companies
  belongs_to :country
  has_many :stock_receipt_vouchers, :dependent => :destroy
  has_many :stock_issue_vouchers, :dependent => :destroy
  has_many :stock_transfer_vouchers, :dependent => :destroy
  has_many :currencies, :through => :company_currencies
  has_many :company_currencies

  has_many :billing_invoices, :conditions => {:status_id => 1}, :dependent => :destroy
  has_one :invoice_setting
  has_many :stock_wastage_vouchers
  has_many :pbreferrals
  has_many :email_templates
  has_many :company_notes
  has_one :lead_company
  has_one :lead, :through => :lead_company
  has_many :gstr3b_reports


  accepts_nested_attributes_for :users, :allow_destroy => true
  #accepts_nested_attributes_for :country_companies, :allow_destroy => true
  accepts_nested_attributes_for :company_currencies, :allow_destroy => true
  accepts_nested_attributes_for :accounts, :allow_destroy => true
  accepts_nested_attributes_for :company_notes
  validates :phone, :numericality => {:only_integer => true}, :length => {:in => 10..15}, :allow_blank => true
  validates_presence_of :name, :message => "of company can not be blank"
  # validates_presence_of :phone, :message => "number can not be blank"
  # validates :name, :uniqueness => { :case_sensitive => false , :message=>"is already taken, it is case insencitive, subdomain with this name will not be created"}
  validates_format_of :email,
  :with =>  /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i,
  :message => ":Its not a valid format", :allow_blank => true
  validates_uniqueness_of :email, :message => " is already taken.", :on => :create

  attr_accessible :lbt_registration_number, :name, :country_id, :timezone, :users_attributes,
  :logo, :delete_logo, :payroll_date, :company_currencies_attributes, :accounts_attributes,
  :company_notes_attributes, :ca_status, :GSTIN, :gstn_username
  #attr_accessible :country_attributes
  #Code for company logo validations and size limit
  has_attached_file :logo,:use_timestamp => false,
  :storage=>:s3,
  :s3_credentials=>"#{Rails.root}/config/s3.yml",
  :url => ":s3_domain_url",
  :path => "/uploaded_data/:class/:id/:style/:basename.:extension"
  # validates_attachment_presence :logo
  validates_attachment_size :logo, :less_than => 500.kilobytes, :message => "should less than or equal to 500 KB."
  validates_attachment_content_type :logo, :content_type => ['image/jpeg','image/png','image/jpg'],
  :message=>" must be of .jpeg,'.jpg' or .png type",
  :allow_nil => true
 # validate :storage_limit
 # validate :validate_state_and_city, :if => lambda{|e| e.basic_details_required? }
  # def validate_state_and_city
  #    if !address.blank?
  #      if address.city.blank? || address.state.blank?
  #        errors.add(:base,"State and city are mandatory")
  #      end
  #    end
  # end

  #Added this to fix issue where it was observed that some users were signing up with company names like na, abc, 123 etc.
  #Author: Ashish Wadekar
  #Date: 1st September 2016
  validates :name, :length => { :minimum => 4}, :on => :create


  CA_STATUS ={1 => 'Nobody', 2 => 'I am a CA', 3 =>  'We have a CA', 4 => 'I need to find a CA'}


  def oldest_ledger_date
    ledgers.minimum(:transaction_date)
  end
  def has_more_than_one_warehouses?
    warehouses.count>1
  end

  def default_warehouse
    Warehouse.default_warehouse(id)
  end

  def add_default_voucher_number_strategy
    #created shorcut method here as we have fixed number of vouchers
    vouchers=get_allowed_vouchers
    vouchers.sort.each do |key, value|
      VoucherSetting.create!(:company_id=> id, :voucher_number_strategy=>1, :voucher_type=>key.to_i )
    end
  end

  def gst_enabled?
    (GSTIN.present? && gst_category_id.present?)
  end

  def gstn_state_code
    self.GSTIN[0,2]
  end
  
  def get_allowed_vouchers
    vouchers = {1=>'Estimate', 2=>'Receipt', 3=>'Income', 4=>'Expense', 5=>'Purchase',
      6=>'Purchase order', 7=>'Payment', 8=>'Bank Withdrawal', 9=>'Bank Deposit', 10=>'Bank Transfer',
      11=>'Journal', 12=>'Saccounting', 13=>'Debit note', 14=>'Credit note', 21=>"Purchase return", 22=>"Invoice return", 23 => 'Reimbursement note', 24 => 'Reimbursement voucher', 
      25 =>'GstrAdvanceReceiptVoucher', 26 => 'GstrAdvancePaymentVoucher', 27 => 'GstCreditNote', 28 => 'GstDebitNote'}
      if plan.is_inventoriable?
        vouchers[15]='Stock issue'
        vouchers[16]='Stock receipt'
        vouchers[17]='Stock transfer'
        vouchers[18]='Stock wastage'
        vouchers[19]='Sales order'
        vouchers[20]='Delivery challan'
      end
      vouchers
    end

    def managers
      managers_arr=[]
      users.each do |user|
        manager=[]
        manager<<user.id
        manager<<user.full_name
        managers_arr<<manager
      end
      managers_arr
    end

    def get_customer_with_pricing_level
      pricing_levels = []
      if multilevel_pricing_enabled?
        accounts = Account.where(:deleted => false, :company_id => id, :accountable_type => "SundryDebtor")
        customer_pricing_level = {}
        accounts.each do |account|
          unless account.accountable.product_pricing_level.blank? || account.accountable.product_pricing_level.discount_percent.blank?
            customer_pricing_level[account.name] = account.accountable.product_pricing_level.discount_percent
          end
        end
        pricing_levels<<customer_pricing_level
      end
      pricing_levels.to_json
    end

    def multilevel_pricing_enabled?
      product_setting.multilevel_pricing?
    end

    def get_current_financial_year
      Time.zone = timezone unless timezone.blank?
      temp_year = Time.zone.now.to_date.strftime("%y")
      year_name = ''
      if country.blank? || country.name == "India"
        if Time.zone.now.to_date.month > 3
          temp_year = temp_year.to_i + 1
        else
          temp_year = temp_year.to_i
        end
        year_name = "FY"+ temp_year.to_s
      else
        year_name = "FY"+ Time.zone.now.to_date.strftime("%y").to_s
      end
      Year.find_by_name(year_name)
    end

    #This method has been deprecated in favour of the update_as_welcome_setup.
    #New attribute ca_status is handled in the new method to get status about companies chartered accountant.
    #Author: Ashish Wadekar
    #Date: 27th October 2016
    #
    #def update_as_setup(params)
    # transaction do
    #   result = false
    #   update_attributes!(params)
    #   address.update_attributes!(:city=> params[:city], :state=>params[:state]) unless address.blank?
    #   financial_years.last.update_period(params[:fiscal_year])
    # end
    #end
    #This method was modified to suit the new revised signup flow
    #The phone number updation is now removed as it is captured in the sign up page
    #Author: Ashish Wadekar
    #Date: 16th March 2017
    def update_as_welcome_setup(params)
      update_error = []
      begin
        transaction do
	      #users.first.update_attributes!(:first_name => params[:first_name], :last_name => params[:last_name])
        update_user = users.first
        update_user.first_name = params[:first_name]
        update_user.last_name = params[:last_name]
        update_error << update_user.errors.full_messages unless update_user.save
        #self.phone = params[:phone]
        if self.save
          #lead_company.lead.update_attributes(:mobile => params[:phone], :name => "#{params[:first_name]} #{params[:last_name]}")
          lead_company.lead.update_attributes(:name => "#{params[:first_name]} #{params[:last_name]}")
        else
          update_error << self.errors.full_messages
        end
        financial_years.last.update_period(params[:fiscal_year])
        update_attributes!(:country_id => params[:country_id], :ca_status => params[:company_ca_status])
      end
    rescue ActiveRecord::RecordInvalid
        #update_error << invalid.record.errors
      end
      update_error
    end

    #This method is used to capture the company information form the pais user during the 10th logout
    #It is based on the old update_as_setup method and is used to store the user feedback into the Company table
    #Author: Ashish Wadekar
    #Date: 7th November 2016
    def update_as_final_setup(params)
     transaction do
       update_attributes!(params)
     end
   end

    ##This method is used to capture the CA status for the old users
    ##Author: Ashish Wadekar
    ##Date: 10th November 2016
    #def update_ca_status(params)
    # transaction do
    #  update_attribute(:ca_status, params[:company_ca_status])
    # end
    #end

    def self.get_default_country
      country = Country.find_by_name("India")
      country.id unless country.blank?
    end

    def indian_company?
      self.country.name == "India" unless self.country.blank?
    end

    def middle_east_company?
      Country::MIDDLE_EAST_COUNTRIES.include? self.country_id
    end

    def logo_name
      logo_file_name
    end

    def logo_size
      logo_file_size
    end


    def delete_logo
      @logo_delete ||= "0"
    end

    def delete_logo=(value)
      @logo_delete = value
    end

    def get_accounts_of(name_str)
      case name_str
      when 'Loans Accounts'
        acc_heads = self.account_heads.find_all_by_name(['Loan Accounts', 'Secured Loan Accounts', 'Unsecured Loan Accounts'])
        acc = AccountHead.get_parent_and_child_heads(id, acc_heads)
      when 'Current Liabilities'
        acc_heads = self.account_heads.find_all_by_name(['Sundry Creditors', 'Duties and Taxes', 'Provisions'])
        acc = AccountHead.get_parent_and_child_heads(id, acc_heads)
      when 'Current Assets'
        acc_heads = self.account_heads.find_all_by_name(['Bank Accounts', 'Cash Accounts', 'Sundry Debtors','Loans and advances','Deposits'])
        acc = AccountHead.get_parent_and_child_heads(id, acc_heads)
      else
        acc_heads = self.account_heads.find_all_by_name(name_str)
        acc = AccountHead.get_parent_and_child_heads(id, acc_heads)
      end

      unless acc.blank?
        account_name(acc)
      end
    end

    def account_name(fetched_acc)
      if fetched_acc.kind_of?(Array)
        acc = []
        for i in fetched_acc
          all_fetched_acc = i.accounts
          for j in all_fetched_acc
            acc << j
          end
        end
        acc
      else
        fetched_acc.accounts
      end
    end

    def get_net_profit
      total_inventories = 0

      sale_accounts = self.get_accounts_of('Sales Accounts')
      total_sales_amount = FinalAccount.total_balance(sale_accounts)

      purchase_accounts = self.get_accounts_of('Purchase Accounts')
      total_purchase_amount = -1*FinalAccount.total_balance(purchase_accounts)

      direct_expenses = self.get_accounts_of('Direct Expenses')
      total_direct_expence = -1*FinalAccount.total_balance(direct_expenses)

      indirect_expenses = self.get_accounts_of('Indirect Expenses')
      total_indirect_expence = -1*FinalAccount.total_balance(indirect_expenses)

      direct_income_accounts = self.get_accounts_of('Direct Incomes')
      total_direct_income_amount = FinalAccount.total_balance(direct_income_accounts)

      indirect_income_accounts = self.get_accounts_of('Indirect Incomes')
      total_indirect_income_amount = FinalAccount.total_balance(indirect_income_accounts)

      net_profit = total_sales_amount + total_inventories - (total_purchase_amount + total_direct_expence  + total_indirect_expence)
    end

    def get_accounts_by_voucher_type(voucher_name)
      Ledger.find_all_by_voucher_type_and_company_id(voucher_name, id)
    end

    class << self
      def this_year
        Company.where("created_at between ? and ?", Time.zone.now.to_date.beginning_of_year, Time.zone.now.to_date.end_of_year).where(:status => "0" )
      end

      def this_week
        Company.where("created_at between ? and ?",  Time.zone.now.to_date.beginning_of_week, Time.zone.now.to_date.end_of_week).where(:status => "0" )
      end

      def this_month
        Company.where("created_at between ? and ?", Time.zone.now.to_date.beginning_of_month, Time.zone.now.to_date.end_of_month).where(:status => "0" )
      end

      def expiring_this_month
        start_date = Time.zone.now.to_date.beginning_of_month
        end_date = start_date.advance(:months => 3)
        Company.joins(:subscription).where("subscriptions.renewal_date between ? and ? and subscriptions.plan_id !=8 ", start_date, end_date).order("renewal_date ASC")
      end

      def expired_companies
        Company.joins(:subscription).where("subscriptions.renewal_date < ? and subscriptions.plan_id not in(8)", Time.zone.now.to_date)
      end

      def closed
        Company.where(:status => "2" ).order("deleted ASC")
      end

      def green
        Company.where(:status => "0")
      end

      def amber
        Company.where(:status => "1")
      end

      def red
        Company.where(:status => "2")
      end

      def financial_start_date(params)

        str = "#{Time.zone.now.year}-"+"04"+"-01"
        date = Date.parse(str)
        if Time.zone.now.to_date < date
          year = Time.zone.now - 1.years
          str1 = "#{year.year}-"+"04"+"-01"
          financial_year_start_date = Date.parse(str1)
          # financial_year_end_date = date - 1.days
        else
          financial_year_start_date = date
          # year = Time.zone.now + 1.years
          # str2 = "#{year.year}-"+"03"+"31"
          # financial_year_end_date = Date.parse(str2)
        end
        if params[:year] == "2013-14"
          financial_year = financial_year_start_date - 1.years
        else
          financial_year = financial_year_start_date
        end
        financial_year
      end

      def financial_end_date(params)
        str = "#{Time.zone.now.year}-"+"04"+"-01"
        date = Date.parse(str)
        if Time.zone.now.to_date < date
        # year = Time.zone.now - 1.years
        # str1 = "#{year.year}-"+"04"+"-01"
        # financial_year_start_date = Date.parse(str1)
        financial_year_end_date = date - 1.days
      else
        # financial_year_start_date = date
        year = Time.zone.now + 1.years
        str2 = "#{year.year}-"+"03"+"-31"
        financial_year_end_date = Date.parse(str2)
      end
      if params[:year] == "2013-14"
        financial_year = financial_year_end_date - 1.years - 1.days
      else
        financial_year = financial_year_end_date
      end
      financial_year
    end

    def monthly_registrations(params)
      month_begin = self.financial_start_date(params)
      end_date = self.financial_end_date(params)
      reg_arr=[]
      while month_begin <= end_date.beginning_of_month.to_date
        registrations = Company.where(:created_at => month_begin..month_begin.end_of_month)
        reg_arr<<registrations.count
        month_begin = month_begin + 1.month
      end
      reg_arr
    end

    def paid_users(params)
      paid_users_arr=[]
      month_begin = self.financial_start_date(params)
      end_date = self.financial_end_date(params)
      while month_begin <= end_date.beginning_of_month.to_date
        paid_users = Company.joins(:subscription).where("subscriptions.status = ? and companies.created_at between ? and ? ","Paid", month_begin.to_date, month_begin.to_date.end_of_month)
        paid_users_arr<<paid_users.count
        month_begin = month_begin + 1.month
      end
      paid_users_arr
    end

    def get_company(company)
      company = Company.find(company)
    end

    def get_customer_relationships(params)
      start_date = params[:start_date].blank? ? Time.zone.now.to_date : params[:start_date]
      end_date = params[:end_date].blank? ? Time.zone.now.to_date : params[:end_date]
      activity_status = params[:activity_status].blank? ? false : params[:activity_status]
      if !params[:super_user].blank?
        @customer_relationships = CustomerRelationship.where("activity_status = ? and next_contact_date BETWEEN ? AND ? and created_by = ?",activity_status, start_date.to_date, end_date.to_date,params[:super_user])
      else
        @customer_relationships = CustomerRelationship.where("activity_status = ? and next_contact_date BETWEEN ? AND ?",activity_status, start_date.to_date, end_date.to_date)
      end
    end

    def find_customer_relationship(comapny,start_date,end_date)
      customer_relationships = CustomerRelationship.where(:company_id => comapny)
      @activity = []
      customer_relationships.each do |customer|
        unless customer.next_contact_date.blank?
          if customer.next_contact_date >= start_date.to_date && customer.next_contact_date <= end_date.to_date
            @activity << customer
          end
        end
      end
      @activity
    end

    def find_last_contact_date(company)
      last_contact_date = CustomerRelationship.where(:company_id => company,:activity_status => true).maximum(:completed_date)
      unless last_contact_date.blank?
        last_contact_date.strftime("%d-%m-%Y")
      end
    end

    def find_next_contact_date(company)
      next_contact_date = CustomerRelationship.where("company_id = ? and next_contact_date >= ? and activity_status = ?",company,Time.zone.now.to_date,false).minimum(:next_contact_date)
      unless next_contact_date.blank?
        next_contact_date.strftime("%d-%m-%Y")
      end

    end

    def free_plan
      plan = Plan.free
      companies = plan.companies
    end

    def essential_plan
     plan = Plan.essential
     companies = plan.companies
   end

   def basic_plan
     plan = Plan.basic
     companies = plan.companies
   end

   def trial_plan
     plan = Plan.trial
     companies = plan.companies
   end

   def smb_plan
     plan = Plan.smb
     companies = plan.companies
   end

   def professional_plan
     plan = Plan.professional
     companies = plan.companies unless plan.blank?
   end

   def premium_plan
     plan = Plan.premium
     companies = plan.companies
   end

   def enterprise_plan
     plan = Plan.enterprise
     companies = plan.companies
   end
 end

 def utilized_storage
   subscription = Subscription.find_by_status_id_and_company_id(1, id)
   subscription.increase_storage(logo_file_size, old_file_size)
 end

  #####Method to get avaialabel subdomain ###
  def get_subdomain_from_count(subdomain)
    if Company.where(:subdomain => subdomain).count == 0
      new_subdomain = subdomain
    else
      # new_subdomain = subdomain + (Company.where(:subdomain => subdomain).count + SecureRandom.random_number(9)).to_s
      #Added this to fix issue where there was a possibilty to generate a duplicate subdomain if company name is already present for the registered user
      #Author: Ashish Wadekar
      #Date: 1st September 2016
      new_subdomain = subdomain + SecureRandom.hex(2)
    end
    new_subdomain
  end

  def get_available_subdomain
    generated_subdomain = name.downcase.gsub(/\s+|\&|\@|\#|\(|\)|\/|\.|\/|\?|\!|\"|\$|\%|\'|\*|\+|\,|\:|\;|\<|\>|\[|\]|\^|\`|\{|\}|\||\-|\~/, "") unless name.blank?
    new_subdomain = get_subdomain_from_count(generated_subdomain)
    if Company.subdomain_exist?(new_subdomain)
      new_subdomain = new_subdomain + new_subdomain.last.to_s
    else
      new_subdomain = new_subdomain
    end
    new_subdomain
  end
# ##############################################

def save_with_details(plan, ip, email, random_string)
  result = false
  transaction do
        #Saving company
        save
        #create subscription
        subscription = Subscription.new(
         :plan_id => plan.id,
         :start_date => Time.zone.now.to_date,
       	  :end_date => 14.days.from_now, #Recently changed trial plan limit to 14 days only
       	  :status_id => '0',
       	  :renewal_date => 14.days.from_now, #Recently changed trial plan limit to 14 days only
       	  :first_subscription_date => Time.zone.now.to_date,
       	  :ip_address => ip,
       	  :utilized_storage_mb => 0,
       	  :utilized_user_count => 1,
	        :status_id => 1 #Added this to remove the verify email for newly registered users
          )
        self.subscription = subscription
        #Creating & Saving user
        user = User.new
        user.company_id = self.id
        user.first_name = email
        user.last_name = email
        user.password = random_string
        user.password_confirmation = random_string
        user.username = email.to_s
        user.email = email
        user.reset_password = true
        user.roles << plan.roles.find_by_name('Owner')
        if user.valid?
         user.save
       else
        raise Exception.new("Email is already registered")
      end
      user = self.users.first

        # Saving default warehouse
        if plan.is_inventoriable?
          Warehouse.create_default_warehouse(id, user.id)
        end
     	# assigning current financial year to newly created company

       fin_year = FinancialYear.new
       temp_year = Time.zone.now.to_date.strftime("%y")
       this_year = Time.zone.now.to_date.year
       start_date = ''
       end_date = ''
       if Time.zone.now.to_date.month > 3
        temp_year = temp_year.to_i + 1
        start_date = Date.new(this_year.to_i, 04, 01)
        end_date = Date.new((this_year.to_i + 1), 03, 31)
      else
        temp_year = temp_year.to_i
        start_date = Date.new((this_year.to_i - 1), 04, 01)
        end_date = Date.new(this_year.to_i, 03, 31)
      end
      year = Year.find_by_name("FY"+ temp_year.to_s)
      fin_year.company_id = id

      if plan.foreign_plan?
        start_date = Date.new(this_year.to_i, 01, 01)
        end_date = Date.new(this_year.to_i, 12, 31)
      end

      fin_year.year_id = year.id
      fin_year.start_date = start_date
      fin_year.end_date = end_date
      fin_year.save

        #create root accounts for this company
        AccountHead.create_root_account_heads(id, user.id)
        # AccountHead.add_discount_subaccount_heads(id, user.id)
        AccountHead.add_default_income_and_expense(id, user.id, fin_year)
        # creating default other expense sub head and a default account
        AccountHead.add_default_other_expense(id, user.id, fin_year)
        # creating default TDS sub heads and default accounts
        AccountHead.add_default_tds_subheads(id, user.id, fin_year)
        # Discount sub heads
        AccountHead.add_discount_subaccount_heads(id, user.id)
        InvoiceSetting.create(:company_id => id, :invoice_sequence => 0, :invoice_no_strategy => InvoiceSetting::INVOICE_NUMBERING_STRATEGY[:prefix_with_sequence],
          :invoice_prefix => 'INV')
        CompanyTemplate.create_default_template(id)
        Label.create_default_record(id, user.id)
        TemplateMargin.create_default_record(id)
        #Creating default leave type ,holiday and payhead_type for company having payroll plan
        if plan.payroll_enabled?
          PayrollSetting.create_default_payslip_record(id)
          #saving default holiday
          year = (Time.zone.now.to_date.month.to_i < fin_year.start_date.month ?  fin_year.end_date.year : fin_year.start_date.year )
          holiday_date1 = Date.new(year.to_i, 1, 26)
          holiday_date2 = Date.new(year.to_i, 8, 15)
          holiday_date3 = Date.new(year.to_i, 10, 02)
          holiday = Holiday.create(:company_id => id, :created_by => user.id, :holiday=> "Republic day", :holiday_date => holiday_date1, :description =>"Republic day of India")
          holiday = Holiday.create(:company_id => id, :created_by => user.id, :holiday=> "Independance Day", :holiday_date => holiday_date2, :description =>"Independance day of India")
          holiday = Holiday.create(:company_id => id, :created_by => user.id, :holiday=> "Mahatma Gandhi Jayanti", :holiday_date => holiday_date3, :description =>"Gandhi Jayanti celebrated in India to mark the occasion of the birthday of Mahatma Gandhi.")

          #Saving default leave types and creating the leave card if payroll is applicable in plan
          LeaveType.create_default_leave_types(id, user.id)
          Label.create_default_record(id, user.id)

          #creating default payhead with their account created simultaneously
          Account.create_default_accounts(id, user.id, fin_year)
          #creating default customers
          Customer.create_default_customers(id, user.id, fin_year)
          Vendor.create_default_vendors(id, user.id, fin_year)
          if !accounts.blank?
            Payhead.create_default_payheads(id, user.id)
          end
        end
        
        #saving default custom fields for comapny
        if !plan.free_plan?
          CustomField.create_default_record(id)
        end
        if plan.smb_plan?
          VoucherTitle.create_default_record(id)
        end
        Account.create_default_tax(id, users.first, fin_year)
        #create GST accounts
        if self.country_id==93
          Account.create_gst_accounts(self, user) if self.currency_code == 'INR'
        end   
        
        #Creating product setting for company
        ProductSetting.create(:company_id => id)
        InventorySetting.create(:company_id => id,:purchase_effects_inventory => true)

        # Saving default voucher number strategy
        VoucherSetting.add_default_voucher_number_strategy(self)


        # Creating Lead lead_activities and lead_company
        Lead.create_lead_information(self)

        #checking the email with client invitation
        ClientInvitation.get_email(self)
      	# Saving workstreame
      	Workstream.register_user_action(id, user.id, ip,
          "New signup for #{name} with #{user.first_name} as owner", "created", nil)

        # Sending mail to verify email address
        # Email.delay.verify_email(user, subscription)
        result = true
      end
      result
    end

    def days_left
     (subscription.renewal_date.to_date - Time.zone.now.to_date ).to_i
   end

   def total_values
    self.billing_invoices.sum(:amount)
  end

  def active?
    subscription.end_date.to_date > Time.zone.now.to_date
  end

  def get_status
    if status == 1
      "Green"
    elsif status == 0
     "Amber"
   else
    "Red"
  end
end

def self.get_piechart_slices(super_users)
  piechart_slices = ['#FFA07A','#20B2AA','#87CEFA','#FF69B4','#6A5ACD','#D2691E',
   '#AB4747','#009900','#000066','#0099FF','#FFFF00','#003300']
   color_codes = []
   i = 0
   while i < super_users.to_i do
    color_codes << piechart_slices[i].to_s
    i += 1
  end
  color_codes
end
def self.get_users_companies
  super_users = SuperUser.all
  users_companies = {}
  super_users.each do |super_user|
    users_companies["#{super_user.first_name}"]  = BillingInvoice.where(:closed_by => super_user.id).count
  end
  users_companies
end
def self.get_company_count(company_count)
  user_company_count = []
  company_count.each do |key,value|
    user_company_count << value
  end
  user_company_count
end

def self.get_owners(company)
  company = self.find(company)
  @owner = []
  company.users.each do |user|
    user.roles.each do |r|
      @owner << user.full_name if r.name == "Owner"
    end
  end
  @owner
end
def self.company_plans(plan)
  if !plan.blank?
    plan = Plan.find(plan)
    self.companies = plan.companies
  end
end

def self.get_sales_cycle_for_paid
  companies = Company.joins(:subscription).where("subscriptions.status = ?","Paid").order("companies.created_at DESC")
  @sales_cycle_paid = {}
  companies.each do |company|
    unless company.billing_invoices.blank?
      registration_date = company.created_at.to_date
      invoice_date = company.billing_invoices.first.invoice_date.to_date
      difference = invoice_date - registration_date
      if difference  > 0 && difference <= 7
        if @sales_cycle_paid.has_key?("1 - 7 Days")
          @sales_cycle_paid["1 - 7 Days"] += 1
        else
          @sales_cycle_paid["1 - 7 Days"] = 1
        end
      elsif difference > 7 && difference <= 15
        if @sales_cycle_paid.has_key?("7 - 15 Days")
          @sales_cycle_paid["7 - 15 Days"] += 1
        else
          @sales_cycle_paid["7 - 15 Days"] = 1
        end
      elsif difference > 15 && difference <=30
        if @sales_cycle_paid.has_key?("15 - 30 Days")
          @sales_cycle_paid["15 - 30 Days"] += 1
        else
          @sales_cycle_paid["15 - 30 Days"] = 1
        end
      elsif difference > 30
        if @sales_cycle_paid.has_key?("More than 30 Days")
          @sales_cycle_paid["More than 30 Days"] += 1
        else
          @sales_cycle_paid["More than 30 Days"] = 1
        end
      end
    end
  end
  @sales_cycle_paid
end

def currency_code
  unit = 'INR'
  if !country.blank?
    unit = country.currency_code
  end
  unit
end

def payroll_settings
 payroll_settings = PayrollSetting.find_by_company_id(id)
 payroll_settings
end

#Reset the owner password from Admin & send the email with temporary password
#Author: Ashish Wadekar
#Date: 14th November 2016
def reset_owner_password
  result = false
  user = self.users.first
  random_string = SecureRandom.hex(4)
  if user.update_attributes(:password => random_string, :reset_password => true)
    Email.welcome_email(user, random_string).deliver
    result = true
  end
  result
end

def user_joined_this_month
  users = User.where(:created_at => Time.zone.now.to_date.beginning_of_month..Time.zone.now.to_date.end_of_month, :company_id=> id, :deleted=> false)
end
def user_left_this_month
  users = User.where(:updated_at => Time.zone.now.to_date.beginning_of_month..Time.zone.now.to_date.end_of_month, :company_id=> id, :deleted=> true)
end

def self.subdomain_exist?(subdomain)
 !Company.find_by_subdomain(subdomain).blank?
end

#[FIXME] The logic can be simplified
#total income this year
def total_income(user, fyr)
  credit_total = 0
  cash_total = 0
  total = 0
  credit_invoices = self.invoices.by_branch_id(user.branch_id).by_deleted(false).by_date(fyr).by_status(0).by_cash_invoice(false)
  credit_total = credit_invoices.sum(:total_amount)
  cash_invoices = self.invoices.by_branch_id(user.branch_id).by_deleted(false).by_date(fyr).by_status(2).by_cash_invoice(true)
  cash_total = cash_invoices.sum(:total_amount)
  total = credit_total + cash_total
  total
end

def total_expense(user, fyr)
  total = 0
  expenses = self.expenses.by_branch_id(user.branch_id).by_deleted(false).by_date(fyr)
  total = expenses.sum(:total_amount)
  # expenses.each do |expense|
  #   total += expense.amount
  # end
  total
end
#Total weekly income
def total_weekly_income(user, date)
  total = 0
  invoices = self.invoices.by_branch_id(user.branch_id).by_deleted(false).by_week(date).where(:invoice_status_id => [0,2])
  total = invoices.sum(:total_amount)
  # invoices.each do |invoice|
  #   total += invoice.amount
  # end
  total
end
#total weekly expense
def total_weekly_expense(user, date)
  total = 0
  expenses = self.expenses.by_branch_id(user.branch_id).by_deleted(false).by_week(date)
  total = expenses.sum(:total_amount)
  # expenses.each do |expense|
  #   total += expense.amount
  # end
  total
end

# total month wise income
# def total_monthly_income(user, date)
#   invoices = self.invoices.by_branch_id(user.branch_id).by_deleted(false).by_month(date).where(:invoice_status_id => [0,2])
#   invoices.sum(:total_amount)
# end
def total_quarterly_income(user, date)
  total = 0
  invoices = self.invoices.by_branch_id(user.branch_id).by_deleted(false).by_quarter(date).where(:invoice_status_id => [0,2])
  total = invoices.sum(:total_amount)
  # invoices.each do |invoice|
  #   total += invoice.amount
  # end
  total
end

# total day wise income
def total_daily_income(user)
  @start_date =Time.zone.now.to_date.beginning_of_month
  @end_date = Time.zone.now.to_date.beginning_of_month
  @income = []
  while @end_date <= Time.zone.now.to_date  do
    @date= @start_date..@end_date
    invoices = self.invoices.by_branch_id(user.branch_id).by_deleted(false).by_day(@date).where(:invoice_status_id => [0,2])
    amount = invoices.sum :total_amount
    if amount!=0
      average= amount/invoices.count
      @income << average
    else
      @income<<amount
    end
    @start_date =@end_date+1
    @end_date = @start_date+3
  end
  @income
end

  # total 10days wise income
  def total_10days_income(user)
    @start_date =Time.zone.now.to_date.beginning_of_month-3.month
    @end_date = Time.zone.now.to_date.beginning_of_month-3.month
    @income = []
    while @end_date <= Time.zone.now.to_date  do
      @date= @start_date..@end_date
      invoices = self.invoices.by_branch_id(user.branch_id).by_deleted(false).by_10day(@date).where(:invoice_status_id => [0,2])
      amount = invoices.sum :total_amount
      if amount!=0
        average= amount/invoices.count
        @income << average
      else
        @income<<amount
      end
      @start_date =@end_date+1
      @end_date = @start_date+10
    end
    @income
  end

  # total monthwise income
  def total_monthwise_income(user)
    @start_date =Time.zone.now.to_date.beginning_of_year
    @end_date = Time.zone.now.to_date.beginning_of_year
    @income = []
    while @end_date <= Time.zone.now.to_date.end_of_year  do
      @date= @start_date..@end_date
      invoices = self.invoices.by_branch_id(user.branch_id).by_deleted(false).by_monthwise(@date).where(:invoice_status_id => [0,2])
      amount = invoices.sum :total_amount
      if amount!=0
        average= amount/invoices.count
        @income << average
      else
        @income<<amount
      end
      @start_date =@end_date+1
      @end_date = @start_date.end_of_month
    end
    @income
  end

#total monthly expense
# def total_monthly_expense(user, date)
#   total = 0
#   expenses = self.expenses.by_branch_id(user.branch_id).by_deleted(false).by_month(date)
#   purchases = self.purchases.by_branch_id(user.branch_id).by_deleted(false).by_month(date)
#   expenses.sum(:total_amount)+purchases.sum(:total_amount)
# end
#total quarterly expense
def total_quarterly_expense(user, date)
  total = 0
  expenses = self.expenses.by_branch_id(user.branch_id).by_deleted(false).by_quarter(date)
  expenses.sum(:total_amount)
  # expenses.each do |expense|
  #   total += expense.amount
  # end
  total
end
# total day wise expence
def total_daily_expense(user)
  @start_date =Time.zone.now.to_date.beginning_of_month
  @end_date = Time.zone.now.to_date.beginning_of_month
  @expense = []
  while @end_date <= Time.zone.now.to_date  do
    @date= @start_date..@end_date
    expenses = self.expenses.by_branch_id(user.branch_id).by_deleted(false).by_day(@date)
    amount = expenses.sum :total_amount
    if amount!=0
     average= amount/expenses.count
     @expense << average
   else
    @expense<<amount
  end
  @start_date =@end_date+1
  @end_date = @start_date+3
end
@expense
end
# total 10day wise expence
def total_10days_expense(user)
  @start_date =Time.zone.now.to_date.beginning_of_month-3.month
  @end_date = Time.zone.now.to_date.beginning_of_month-3.month
  @expense = []
  while @end_date <= Time.zone.now.to_date  do
    @date= @start_date..@end_date
    expenses = self.expenses.by_branch_id(user.branch_id).by_deleted(false).by_10day(@date)
    amount = expenses.sum :total_amount
    if amount!=0
     average= amount/expenses.count
     @expense << average
   else
    @expense<<amount
  end
  @start_date =@end_date+1
  @end_date = @start_date+10
end
@expense
end

# total monthwise expence
def total_monthwise_expense(user)
  @start_date =Time.zone.now.to_date.beginning_of_year
  @end_date = Time.zone.now.to_date.beginning_of_year
  @expense = []
  while @end_date <= Time.zone.now.to_date.end_of_year do
    @date= @start_date..@end_date
    expenses = self.expenses.by_branch_id(user.branch_id).by_deleted(false).by_monthwise(@date)
    amount = expenses.sum :total_amount
    if amount!=0
     average= amount/expenses.count
     @expense << average
   else
    @expense<<amount
  end
  @start_date =@end_date+1
  @end_date = @start_date.end_of_month
end
@expense
end
#total credit invoice amount
def total_credit_invoice_amount(user, fyr)
  total = 0
  invoices = self.invoices.by_branch_id(user.branch_id).by_deleted(false).by_date(fyr).by_status(0).by_cash_invoice(false)
  total = invoices.sum(:total_amount)
  # invoices.each do |invoice|
  #   total += invoice.amount
  # end
  total
end

def total_payment_received(user, fyr)
  total = 0
  invoices = self.invoices.includes(:receipt_vouchers).by_branch_id(user.branch_id).by_deleted(false).by_date(fyr).by_status(0).by_cash_invoice(false)
  #total = invoices.sum(receipt_vouchers.sum(:amount))
  invoices.each do |invoice|
      total += invoice.paid_amount #receipt_vouchers.where(:deleted => false).sum('amount')
    end
    total
  end
  def total_due(user, fyr)
   total = 0
   total = total_credit_invoice_amount(user, fyr) - total_payment_received(user, fyr)
   total
 end

#total cash invoice amount
def total_cash_invoice_amount(user, fyr)
  total = 0
  invoices = self.invoices.by_branch_id(user.branch_id).by_deleted(false).by_date(fyr).by_status(2).by_cash_invoice(true)
  invoices.each do |invoice|
    total += invoice.amount
  end
  total
end
def total_bank_acc_balance(user, fyr)
  bank_acc_balance = 0
  bank_accounts = self.accounts.get_bank_accounts(id)
  bank_accounts.each do |bank_acc|
    if !bank_acc.blank?
      bank_acc_balance += bank_acc.get_closing_balance(user, id, fyr, fyr.end_date, user.branch_id)
    end
    bank_acc_balance
  end
end

def total_cash_acc_balance(user, fyr)
  cash_acc_balance = 0
  cash_accounts = self.accounts.get_cash_accounts(id)
  cash_accounts.each do |cash_acc|
    if !cash_acc.blank?
      cash_acc_balance += cash_acc.get_closing_balance(user, id, fyr, fyr.end_date, user.branch_id)
    end
    cash_acc_balance
  end
end
#[FIXME] Extract month hash into a constant
def get_month(month)
  months={
   '1'=> 'January',
   '2'=> 'February',
   '3'=> 'March',
   '4'=> 'April',
   '5'=> 'May',
   '6'=> 'June',
   '7'=> 'July',
   '8'=> 'August',
   '9'=> 'September',
   '10'=> 'October',
   '11'=> 'November',
   '12' => 'December'
 }
 months[month]
end

# method for welcome screen
  def get_business_types
    types = {1=>'One owner(Sole Proprietor)', 2=>'Partnership', 3=>'Private Limited', 4=>'LLP', 5=>'Traded Company',
      6=>'Co-operative', 7=>'Charity or association', 8=>'Something else'}
    types
  end

  def business
    get_business_types[business_type]
  end

  def get_industries
    industries = {1=>'Manufacturing', 2=>'Electronics', 3=>'Trading', 4=>'Food & Beverages', 5=>'Building & Construction',
      6=>'Textile', 7=>'Medical & Pharma', 8=>'Packaging Supplies', 9=>'Mechanical Components', 10=>'Engineering services',
      12=>'Agricultural',13=>'Computers & IT', 14=>'Advertising/Event Management',15=>'Business Consultancy', 16=>'Education & Training',
      17=> 'Travel & Tourism', 18=>'Financial & Legal', 19=>'Other'}
      industries
  end

  def industry_name
    get_industries[self.industry]
  end
  
  def get_contact_source
    sources ={1=>'Internet Search', 2=>'Blog',3=>'Magazine',4=>'Newspaper',5=>'Through a Friend',6=>'Email',7=>'Deal Sites',8=>'Other'}
    sources
  end

  def source_name
    get_contact_source[self.source]
  end

  def get_other_systems
    types = {1=>'Not using anything', 2=>'Pen & Paper', 3=>'SpreadSheet',4=>'Tally',5=>'Quickbooks',6=>'Any Other System'}
    types
  end

  def accounting_system
    get_other_systems[self.current_system]
  end

  def get_deals_in
    types= {1=>'Products',2=>'Services',3=>'Both Products & Services'}
    types
  end
  
  def get_employee_count
    total={1=>'1 to 5', 2=>'5 to 15',3=>'15 to 50',4=>'50 to 100',5=>'More than 100'}
    total
  end
  
  def employee_count_range
    get_employee_count[self.total_employees]
  end

  def get_annual_turnover
    total={1=>'Upto 10 lakh',2=>'Up to 50 lakh',3=>'1Cr to 5Cr',4=>'5Cr to 25Cr',5=>'More than 25Cr'}
    total
  end

  def annual_turnover_range
    get_annual_turnover[self.annual_turnover]
  end

  def ca_status_value
    CA_STATUS[self.ca_status]
  end
  #This method was modified to suit the new revised logon flow; checking the first&last name of first user is similar to email
  #as phone number is again cpatured in signup form
  #Author: Ashish Wadekar
  #Date: 18th March 2017
  def basic_details_required?
    #you_sell.blank? || business_type.blank? || country_id.blank? || total_employees.blank? || industry.blank?
    #phone.blank? && lead_company.lead.mobile.blank?
    first_owner = users.first
    first_owner.first_name == email || first_owner.last_name == email
  end

   #This method was added to check the secondary details of the company like industry type, number of employees,
   #annual turnover and business type
   #Author: Ashish Wadekar
   #Date: 3rd November 2016
   def secondary_details_required?
     industry.blank? || total_employees.blank? || business_type.blank?
   end

   #This method was added to check if the user has added the account management details regarding CA
   #Author: Ashish Wadekar
   #Date: 10th November 2016
   def account_management_required?
    ca_status.blank?
  end

  def inventory_label
    if you_sell == 1
      "Products"
    elsif you_sell == 2
      "Services"
    else
     "Inventory"
   end
 end


  private

    def destroy_logo?
      self.logo.clear if @logo_delete == "1" and !logo.dirty?
    end

    def storage_limit
      errors[:base] << "Storage limit reached, your plan does not allow storing any more files." if Subscription.storage_limit?(id, logo_file_size, old_file_size)
    end

end

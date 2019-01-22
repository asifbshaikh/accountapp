class Customer < ActiveRecord::Base
  scope :by_name, lambda{|name| where("name like ?", "%#{name}%") unless name.blank?}
  scope :by_email, lambda{|email| where("email like ?", "%#{email}%") unless email.blank?}
  scope :by_created_by, lambda{|created_by| where(:created_by=>created_by) unless created_by.blank? }
  scope :by_primary_phone_number, lambda{|primary_phone_number| where(:primary_phone_number=>primary_phone_number) unless primary_phone_number.blank? }
  scope :by_secondary_phone_number, lambda{|secondary_phone_number| where(:secondary_phone_number=>secondary_phone_number) unless secondary_phone_number.blank? }

  belongs_to :company
  belongs_to :gst_category
  belongs_to :user, :foreign_key => :created_by
  has_one :currency
  # has_one :customer_account
  has_one :account, :dependent => :destroy
  has_many :addresses, :as => :addressable
  # has_many :contacts, :dependent => :destroy
  has_many :invoices
  has_many :sales_orders, :dependent => :destroy
  
  has_many :delivery_challans, :dependent => :destroy
  validates :name, :presence => true, :uniqueness => {:scope => :company_id}
  validates_format_of :name, :with =>/^([a-z]|[A-Z]|[0-9]|[.]|[ ]|[-]|[_]|[@]|[%]|[(]|[)]|[\/]|[&])*$/i, :message => "should start with alphabet and should not contain special characters"
  validates_format_of :email, :with =>  /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i,
                      :message => "is not in valid format", :allow_blank => true

  validates_format_of :gstn_id, :with => /[0-9]{2}[A-Z0-9]*/, :message => "is not valid" ,:if =>  lambda{|e| e.gstn_id.present? }    
  validates :gstn_id, :length => {:is=> 15}, :if =>  lambda{|e| e.gstn_id.present? }

  accepts_nested_attributes_for :account, :addresses
  attr_accessible :lbt_registration_number, :fax, :credit_limit, :name, :service_tax_reg_no, :cin, :pan, :excise_reg_no, 
    :vat_tin, :tan, :gstn_id, :tax_reg_no, :incorporated_date, :website, :credit_days, :primary_phone_number, :secondary_phone_number, 
    :email, :cst_reg_no, :account_attributes, :addresses_attributes, :currency_id, :gst_category_id


  def self.get_ids(company,name_param)
    customers = Customer.where(" company_id = ? and name like (?)",company, name_param)
    vendors = Vendor.where(" company_id = ? and name like (?)",company, name_param)
    @customer_ids = []
    customers.each do |a|
      @customer_ids << a.id
    end
    vendors.each do |a|
      @customer_ids << a.id
    end
    @customer_ids
  end

  def GSTIN
    self.gstn_id
  end

  def get_state
    if billing_address.present?
      state = billing_address.state
      state_obj = State.find_by_name(state)
      if state_obj.present?
        state_code = state_obj.state_code
      end  
    end
 end
  
  def currency
    currency = Currency.find_by_id(currency_id)
    unless currency.blank?
      currency.currency_code unless currency.currency_code==company.currency_code
    end
  end

  def address_line1
    billing_address.address_line1
  end

  def shipping_address
    addresses.where(:address_type=>0).first
  end

  def billing_address
    addresses.where(:address_type=>1).first
  end

  def contact_number
    primary_phone_number
  end

  def created_by_user
    user.full_name
  end

  class << self

    def new_customer(company, user, cust_import)
      customer = Customer.new
      customer.name = cust_import.name
      customer.company = company
      #set currency
      currency = Currency.find_by_currency_code(cust_import.currency)
      customer.currency_id = currency.id if currency.present?

      customer.primary_phone_number = cust_import.primary_phone_number
      customer.secondary_phone_number = cust_import.secondary_phone_number
      customer.email = cust_import.email
      customer.website = cust_import.website
      customer.gstn_id = cust_import.tax_number
      customer.pan = cust_import.pan
      customer.tan = cust_import.tan
      customer.vat_tin = cust_import.vat_tin
      customer.cst_reg_no = cust_import.cst_reg_no
      customer.cin = cust_import.cin
      customer.excise_reg_no = cust_import.excise_reg_no
      customer.service_tax_reg_no = cust_import.service_tax_reg_no
      customer.lbt_registration_number = cust_import.lbt_registration_number
      customer.credit_days = cust_import.credit_days
      customer.credit_limit = cust_import.credit_limit
      customer.created_by = cust_import.created_by
      #Find state code for indian company only 
      @state_code = nil
           if company.indian_company?
              @state_code = State.find_state_code(cust_import.state)
           end
      #build_billing_address
      billing_address = Address.new(:address_line1 => cust_import.billing_address, 
      :address_type => 1, :city => cust_import.city,:state_code => @state_code,
      :state => cust_import.state,
      :country => cust_import.country, :postal_code => cust_import.postal_code)
      
      #build shipping address based on above condition
      shipping_address = Address.new(:address_line1 => cust_import.shipping_address, 
      :address_type => 0, :city => cust_import.shipping_city, :state => cust_import.shipping_state,
      :country => cust_import.shipping_country, :postal_code => cust_import.shipping_postal_code)
      customer.addresses << billing_address
      customer.addresses << shipping_address
      customer.account = build_account(company, user, cust_import, customer)
      customer
    end

    def build_account(company, user, cust_import, customer)
      account_start_date = company.financial_years.last.start_date
      #reading account information required for each customer only once
      customer_account_head = company.account_heads.find_by_name("Customers (Debtors)")

      account = Account.new
      account.opening_balance = cust_import.opening_balance.blank? ? 0.0 : cust_import.opening_balance.to_d
      account.start_date = cust_import.start_date.blank? ? account_start_date : cust_import.start_date.to_date
      account.accountable_type = "SundryDebtor"
      account.company = company
      account.account_head = customer_account_head
      account.name = customer.name
      account.created_by = user.id
      account
    end

    def correct_customer(customer_id, company, user)
      imported_customer = CustomerImport.find(customer_id)
      customer = Customer.new
      customer.company_id=company.id
      customer.created_by=user.id
      currency = Currency.find_by_currency_code("#{imported_customer.currency}")
      currency_id = currency.id unless currency.blank?
      customer.name = imported_customer.name
      customer.currency_id = currency_id
      customer.primary_phone_number = imported_customer.primary_phone_number
      #customer.secondary_phone_number = imported_customer.secondary_phone_number
      customer.email = imported_customer.email
      customer.website = imported_customer.website
      if company.country_id == 93
        customer.gstn_id = imported_customer.tax_number
        customer.pan = imported_customer.pan
      end
      customer.tan = imported_customer.tan
      customer.vat_tin = imported_customer.vat_tin
      customer.cst_reg_no = imported_customer.cst_reg_no
      customer.cin = imported_customer.cin
      customer.excise_reg_no = imported_customer.excise_reg_no
      customer.service_tax_reg_no = imported_customer.service_tax_reg_no
      customer.lbt_registration_number = imported_customer.lbt_registration_number
      customer.credit_days = imported_customer.credit_days
      customer.credit_limit = imported_customer.credit_limit
      billing_address = Address.new(:address_line1 => imported_customer.billing_address, 
        :address_type => 1, :city => imported_customer.city, :state => imported_customer.state, 
        :country => imported_customer.country, :postal_code => imported_customer.postal_code, :state_code => imported_customer.state_code
      )

      customer.addresses << billing_address
      if imported_customer.shipping_address.blank?
        shipping_address = Address.new(:address_line1 => imported_customer.billing_address,:address_type => 0)
      else
        shipping_address = Address.new(:address_line1 => imported_customer.shipping_address,:address_type => 0)
      end
      customer.addresses << shipping_address
      customer
    end

    def create_default_customers(company, user, financial_year)
      customers = ["Customer 1", "Customer 2"]
      customers.each do |name|
        customer = Customer.new()
        customer.name = name
        customer.company_id=company
        customer.created_by=user
        account = Account.new()
        account.accountable_type="SundryDebtor"
        account.company_id=company
        account.account_head=AccountHead.find_by_company_id_and_name(company, "Customers (Debtors)")
        account.name=customer.name
        account.created_by=user
        account.opening_balance = 0.0
        account.start_date = financial_year.start_date
        customer.account=account
        customer.save!
      end
    end

    # FIXME - I beleive this method is no longer required as we are using the to_JSON method on model directly
    def company_customers(company)
      #customers = Customer.where(:company_id=>company)
      customers = company.customers
      arr=[]
      customers.each do |customer|
        unless customer.account.blank?
          hash={}
          hash["id"]=customer.account.id
          hash["name"]=customer.name
          arr<<hash
        end
      end
      arr.to_json
    end

  	def create_customer(params, company, user)
  		customer = Customer.new(params[:customer])
    	customer.company=company
  		customer.created_by=user.id
      customer.currency_id = Currency.find_by_currency_code(company.country.currency_code).id if customer.currency_id.blank?
      account = Account.new(:opening_balance=>(params[:opening_balance].blank? ? 0.0 : params[:opening_balance]))
      account.start_date=params[:account_starts_from].blank? ? company.financial_years.last.start_date : params[:account_starts_from]
      account.accountable_type="SundryDebtor"
      account.company=company
      account.account_head=AccountHead.find_by_company_id_and_name(company, "Customers (Debtors)")
      account.name=customer.name
      account.created_by=user
      customer.account = account
  		customer
  	end

   def email_sending_action(remote_ip, action,email1,email2,company_id,created_by)
    Workstream.register_user_action(company_id, created_by, remote_ip,
    " customer statement to #{email1} and #{email2}.", action, nil)
   end

   def get_customer_id(name, company)
    customer = Customer.find_by_name_and_company_id(name, company)
    if customer.blank?
      nil
    else
      customer.id
    end
  end

  end

  def register_user_action(remote_ip, action)
    Workstream.register_user_action(company_id, created_by, remote_ip,
    " Customer #{name} #{action}.", action, nil)
  end

  def register_delete_action(remote_ip, user, action)
    Workstream.register_user_action(company_id, user.id, remote_ip,
    " Customer #{name} #{action}.", action, nil)
  end

end

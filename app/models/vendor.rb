class Vendor < ActiveRecord::Base
  # has_one :vendor_account, :dependent => :destroy
  belongs_to :company
  belongs_to :currency
  belongs_to :gst_category
  belongs_to :user, :foreign_key => :created_by
  has_one :account, :dependent => :destroy
  has_many :addresses, :as => :addressable
  has_many :invoices
  validates :name, :presence => true, :uniqueness => {:scope => :company_id}
  validates_format_of :name, :with =>/^([a-z]|[A-Z]|[0-9]|[.]|[ ]|[-]|[_]|[@]|[%]|[(]|[)]|[\/]|[&])*$/i, :message => "should start with alphabet and should not contain special characters"
  validates_format_of :email, :with =>  /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i,
                      :message => "is not in valid format", :allow_blank => true
  
  validates_format_of :gstn_id, :with => /[0-9]{2}[A-Z0-9]*/, :message => "is not valid" ,:if =>  lambda{|e| e.gstn_id.present? }
    validates :gstn_id, :length => {:is=> 15},:if =>  lambda{|e| e.gstn_id.present? }
  accepts_nested_attributes_for :account, :addresses
  attr_accessible :lbt_registration_number, :incorporated_date, :service_tax_reg_no, :excise_reg_no, :vat_tin, :gstn_id, 
    :tax_reg_no, :pan, :tan, :name, :website, :cst, :sales_tax_no, :email, :primary_phone_number, :secondary_phone_number,
    :account_attributes, :addresses_attributes, :currency_id, :payment_information, :gst_category_id

  def GSTIN
    self.gstn_id
  end

  def get_state
    if billing_address.present?
      state = billing_address.state
      Sidekiq.logger.debug "==============================vendor state is #{state}================"
      state_obj = State.find_by_name(state)
      if state_obj.present?
        state_code = state_obj.state_code
      end  
    end
 end

  def currency_code
    if self.currency.present?
      self.currency.currency_code 
    end 
  end
  
  def shipping_address
    addresses.where(:address_type=>0).first
  end
  
  def billing_address
    addresses.where(:address_type=>1).first
  end
  def contact_number
    nil
  end

  def created_by_user
    user.full_name
  end


  class << self
    def correct_vendor(vendor_id,company,user)
      imported_vendor = VendorImport.find(vendor_id)
      vendor = Vendor.new
      vendor.company_id=company.id
      vendor.created_by=user.id
      currency = Currency.find_by_currency_code("#{imported_vendor.currency}")
      currency_id = currency.id unless currency.blank?
      vendor.name = imported_vendor.name
      vendor.currency_id = currency_id
      vendor.primary_phone_number = imported_vendor.primary_phone_number
      vendor.secondary_phone_number = imported_vendor.secondary_phone_number
      vendor.email = imported_vendor.email
      vendor.website = imported_vendor.website
      if @company.country_id == 93
        vendor.gst = imported_customer.gstn_id
        vendor.pan = imported_vendor.pan  
      else
        vendor.tax_registration_no = imported_customer.tax_reg_no
      end      
      vendor.tan = imported_vendor.tan
      vendor.vat_tin = imported_vendor.vat_tin
      vendor.excise_reg_no = imported_vendor.excise_reg_no
      vendor.service_tax_reg_no = imported_vendor.service_tax_reg_no
      vendor.sales_tax_no = imported_vendor.sales_tax_no
      vendor.lbt_registration_number = imported_vendor.lbt_registration_number
      vendor.cst = imported_vendor.cst
      billing_address = Address.new(:address_line1 => imported_vendor.billing_address,:address_type => 1,:city => imported_vendor.city,:state => imported_vendor.state,:country => imported_vendor.country,:postal_code => imported_vendor.postal_code)
      vendor.addresses << billing_address
      if imported_vendor.shipping_address.blank?
        shipping_address = Address.new(:address_line1 => imported_vendor.billing_address,:address_type => 0)
      else
        shipping_address = Address.new(:address_line1 => imported_vendor.shipping_address,:address_type => 0)
      end
      vendor.addresses << shipping_address
      vendor
    end

    def create_default_vendors(company, user, financial_year)
      vendors = ["Vendor 1", "Vendor 2"]
      vendors.each do |name|
        vendor = Vendor.new()
        vendor.name = name
        vendor.company_id=company
        vendor.created_by=user
        account=Account.new()
        account.accountable_type="SundryCreditor"
        account.company_id=company
        account.account_head=AccountHead.find_by_company_id_and_name(company, "Vendors (Creditors)")
        account.name=vendor.name
        account.created_by=user
        account.start_date = financial_year.start_date
        account.opening_balance = 0.0
        vendor.account = account
        vendor.save!
      end
    end

    def create_vendor(params, company, user)
      vendor = Vendor.new(params[:vendor])
      vendor.company_id=company.id
      vendor.created_by=user

      account=Account.new(:opening_balance=> (params[:opening_balance].blank? ? 0.0 : params[:opening_balance]))
      account.start_date=params[:account_starts_from].blank? ? company.financial_years.last.start_date : params[:account_starts_from]
      account.accountable_type="SundryCreditor"
      account.company_id=company.id
      account.account_head=AccountHead.find_by_company_id_and_name(company.id, "Vendors (Creditors)")
      account.name=vendor.name
      account.created_by=user
      vendor.account = account

      vendor
    end

    def company_vendors(company)
      vendors=Vendor.where(:company_id=>company)
      arr=[]
      vendors.each do |vendor|
        hash={}
        hash["id"]=vendor.account.id
        hash["name"]=vendor.name
        arr<<hash
      end
      arr.to_json
    end
  end
  def cst_reg_no

  end

  def register_user_action(remote_ip, action)
    Workstream.register_user_action(company_id, created_by, remote_ip,
    " Vendor #{name} #{action}.", action, nil)
  end

  def register_delete_action(remote_ip, user, action)
    Workstream.register_user_action(company_id, user.id, remote_ip,
    " Vendor #{name} #{action}.", action, nil)
  end


end

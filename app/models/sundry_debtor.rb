class SundryDebtor < ActiveRecord::Base
	has_one :account, :as => :accountable
  has_one :address, :as => :addressable
  has_many :contacts, :dependent => :destroy
  belongs_to :product_pricing_level

  accepts_nested_attributes_for :address
  accepts_nested_attributes_for :contacts#, :reject_if => lambda{|a| a[:first_name].blank? && a[:last_name].blank? && a[:position].blank? && a[:mobile].blank? && a[:email].blank? && a[:birthday].blank? && a[:anniversary].blank? }
  attr_accessible  :product_pricing_level_id, :credit_days, :notes, :bank_name, :excise_reg_no, :contact_number, :fax, :service_tax_reg_no, :micr_code, :bsr_code, :website, :cin_code, :ifsc_code, :PAN, :tan, :date_of_incorporation, :credit_limit, :email, :vat_tin, :cst, :address_attributes, :contacts_attributes
  # validates_associated :contacts, :address
  # validates_format_of :email,
                          # :with =>  /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i,
                          # :message => ":Its not a valid format", :allow_blank => true

  def pricing_level
    product_pricing_level.caption unless product_pricing_level.blank?
  end
end	

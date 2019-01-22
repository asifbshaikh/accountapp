class VendorImport < ActiveRecord::Base
  include Sidekiq::Worker
  require 'date'
  require 'csv'
  require 'open-uri'
  belongs_to :import_file
  STATUS = {0 => "Failed",1 => "Success",2 => "Duplicate"}

  # @queue = :vendor_imports_queue
  def perform(file_id,company_id,user_id)
    company = Company.find(company_id)
    user = User.find(user_id)
    imported_file = ImportFile.find(file_id)
    file = CSV.parse(open(imported_file.file.url).read)
    file.drop(1).each do |row|
      vendor_import = VendorImport.new(:import_file_id => imported_file.id)
      vendor_import.name = row[0]
      vendor_import.opening_balance = row[1]
      vendor_import.currency = row[2]
      vendor_import.phone_number = row[3]
      vendor_import.email = row[4]
      vendor_import.website = row[5]
      vendor_import.pan = row[6]
      vendor_import.tan = row[7]
      vendor_import.vat_tin = row[8]
      vendor_import.excise_reg_no = row[9]
      vendor_import.service_tax_reg_no = row[10]
      vendor_import.sales_tax_no = row[11]
      vendor_import.lbt_registration_number = row[12]
      vendor_import.cst = row[13]
      vendor_import.billing_address = row[14]
      vendor_import.city = row[15]
      vendor_import.state = row[16]
      vendor_import.country = row[17]
      vendor_import.postal_code = row[18]
      vendor_import.shipping_address = row[19]
      vendor_import.created_by = user.id
      currency_code = row[2]
      currency = Currency.find_by_currency_code("#{currency_code}")
      currency_id = currency.id unless currency.blank?
      vendor = Vendor.new
      vendor.company_id=company.id
      vendor.created_by=user.id
      vendor.name = row[0]
      vendor.currency_id = currency_id
      vendor.primary_phone_number = row[3]
      vendor.email = row[4]
      vendor.website = row[5]
      vendor.pan = row[6]
      vendor.tan = row[7]
      vendor.vat_tin = row[8]
      vendor.excise_reg_no = row[9]
      vendor.service_tax_reg_no = row[10]
      vendor.sales_tax_no = row[11]
      vendor.lbt_registration_number = row[12]
      vendor.cst = row[13]

      billing_address = Address.new(:address_line1 => row[14],:address_type => 1,:addressable_id => vendor.id,:addressable_type => "Vendor",:city => row[15],:state => row[16],:country => row[17],:postal_code => row[18])
      vendor.addresses << billing_address
      if row[19].blank?
        shipping_address = Address.new(:address_line1 => row[14],:address_type => 0,:addressable_id => vendor.id,:addressable_type => "Vendor")
      else
        shipping_address = Address.new(:address_line1 => row[19],:address_type => 0,:addressable_id => vendor.id,:addressable_type => "Vendor")
      end
      vendor.addresses << shipping_address

      account = Account.new(:opening_balance=>(row[1].blank? ? 0.0 : row[1]))
      account.start_date=row[20].blank? ? company.financial_years.last.start_date : row[20].to_date
      account.accountable_type="SundryCreditor"
      account.company_id=company.id
      account.account_head=AccountHead.find_by_company_id_and_name(company.id, "Vendors (Creditors)")
      account.name=vendor.name
      account.created_by=user
      vendor.account = account
      if vendor.valid?
        vendor_import.status = 1
        vendor.save!
      else
        vendor_import.status = 0
      end
      vendor_import.save!
    end
    imported_file.update_attributes(:status => 1)
  end
end

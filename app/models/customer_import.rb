class CustomerImport < ActiveRecord::Base
  #include Sidekiq::Worker
  require 'date'
  require 'csv'
  require 'open-uri'
  belongs_to :import_file
  STATUS = {failed: 0, success: 1, duplicate: 2}
  POS = {name: 0, opening_balance: 1, currency: 2, billing_address: 3, city: 4, state: 5,
    country: 6, postal_code: 7, shipping_address: 8, shipping_city: 9, shipping_state: 10, shipping_country: 11, 
    shipping_postal_code: 12, primary_phone_number: 13, secondary_phone_number: 14, email: 15, website: 16, tax_number: 17, 
    pan: 18, tan: 19, vat_tin: 20, cst_reg_no: 21, cin: 22, excise_reg_no: 23, service_tax_reg_no: 24,
    lbt_registration_number: 25, credit_days: 26, credit_limit: 27,  start_date: 28}

    class << self
      def new_record(company, user, imported_file, row)
        customer_import = CustomerImport.new(:import_file_id => imported_file.id)
        
        customer_import.company_id = company.id
        customer_import.name = row[POS[:name]]
        customer_import.opening_balance = row[POS[:opening_balance]]
        customer_import.currency = row[POS[:currency]]

        customer_import.billing_address = row[POS[:billing_address]]
        customer_import.city = row[POS[:city]]
        customer_import.state = row[POS[:state]]
        customer_import.country = row[POS[:country]]
        customer_import.postal_code = row[POS[:postal_code]]

        customer_import.shipping_address = row[POS[:shipping_address]]
        customer_import.shipping_city = row[POS[:shipping_city]]
        customer_import.shipping_state = row[POS[:shipping_state]]
        customer_import.shipping_country = row[POS[:shipping_country]]
        customer_import.shipping_postal_code = row[POS[:shipping_postal_code]]

        customer_import.primary_phone_number = row[POS[:primary_phone_number]]
        customer_import.secondary_phone_number = row[POS[:secondary_phone_number]]
        customer_import.email = row[POS[:email]]
        customer_import.website = row[POS[:website]]

        customer_import.tax_number=row[POS[:tax_number]]
        customer_import.pan = row[POS[:pan]]
        customer_import.tan = row[POS[:tan]]
        customer_import.vat_tin = row[POS[:tan]]
        customer_import.cst_reg_no = row[POS[:cst_reg_no]]
        customer_import.cin = row[POS[:cin]]
        customer_import.excise_reg_no = row[POS[:excise_reg_no]]
        customer_import.service_tax_reg_no = row[POS[:service_tax_reg_no]]
        customer_import.lbt_registration_number = row[POS[:lbt_registration_number]]
        
        customer_import.credit_days = row[POS[:credit_days]]
        customer_import.credit_limit = row[POS[:credit_limit]]
        customer_import.start_date = row[POS[:start_date]]
        customer_import.created_by = user.id
        customer_import
      end
    end #end of class methods

    def save_as_success
      self.status = STATUS[:success]
      self.save
    end

    def save_for_correction
      self.status = STATUS[:failed]
      self.save
    end

end

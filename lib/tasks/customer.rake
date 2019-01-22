namespace :customer do

  task :customer_account_migration => :environment do
    # for each company
    puts "Starting migration for each company. The transaction will be saved for each company"
    @companies = Company.all
    @companies.each do |company|
      ActiveRecord::Base.transaction do 
        @debtor_accounts = Account.where(:company_id => company.id, :accountable_type => 'SundryDebtor')
        if !@debtor_accounts.nil?
          @debtor_accounts.each do |account|
            puts "starting migration for account #{account.name}"
            customer = Customer.new
            customer.company_id = company.id
            customer.name = account.name
            customer.created_by = account.created_by
            if !account.accountable.nil?
              customer.phone_number = account.accountable.contact_number
              customer.email = account.accountable.email
              customer.pan = account.accountable.PAN
              customer.tan = account.accountable.tan
              customer.vat_tin = account.accountable.vat_tin
              customer.cst_reg_no  = account.accountable.cst 
              customer.excise_reg_no = account.accountable.excise_reg_no
              customer.service_tax_reg_no = account.accountable.service_tax_reg_no
              customer.website = account.accountable.website
              customer.fax = account.accountable.fax
              customer.country = account.accountable.country
              customer.weekly_off = account.accountable.weekly_off
              customer.cin = account.accountable.cin_code
              customer.bank_name = account.accountable.bank_name
              customer.ifsc_code = account.accountable.ifsc_code
              customer.micr_code = account.accountable.micr_code
              customer.bsr_code = account.accountable.bsr_code
              customer.credit_days = account.accountable.credit_days
              customer.credit_limit = account.accountable.credit_limit
              #customer.incorporated_date = account.accountable.incorporated_date
              customer.open_time = account.accountable.open_time
              customer.close_time = account.accountable.close_time
              customer.product_pricing_level_id = account.accountable.product_pricing_level_id
              customer.notes = account.accountable.notes
            end
            customer.account = account
            customer.save!
            
            puts "saved account with ID #{account.id} and name as #{account.name} as new customer with name #{customer.name}"
          end
        end
      end
      puts "transaction complete for all sundry debtor accounts in #{company.name}"
    end
    puts "Completed the migration"
  end

end  

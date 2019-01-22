namespace :vendor do

  task :vendor_account_migration => :environment do
    # for each company
    puts "Starting migration for each company. The transaction will be saved for each company"
    @companies = Company.all
    @companies.each do |company|
      ActiveRecord::Base.transaction do 
        @creditor_accounts = Account.where(:company_id => company.id, :accountable_type => 'SundryCreditor')
        if !@creditor_accounts.blank?
          @creditor_accounts.each do |account|
            puts "starting migration for account #{account.name}"
            vendor = Vendor.new
            vendor.company_id = company.id
            vendor.name = account.name
            if !account.accountable.nil?
              vendor.email = account.accountable.email
              vendor.pan = account.accountable.PAN
              vendor.sales_tax_no = account.accountable.sales_tax_number
              vendor.tan = account.accountable.tan
              vendor.vat_tin = account.accountable.vat_tin
              vendor.cst  = account.accountable.cst 
              vendor.excise_reg_no = account.accountable.excise_reg_no
              vendor.service_tax_reg_no = account.accountable.service_tax_reg_no
              # vendor.website = account.accountable.website
              #vendor.incorporated_date = account.accountable.incorporated_date
            end
            vendor.save!
            vendor.account = account
            # address = account.accountable.address
            # unless address.blank?
            #   address.addressable = vendor
            # end
            puts "saved account with ID #{account.id} and name as #{account.name} as new vendor with name #{vendor.name}"
          end
        end
      puts "transaction complete for all sundry debtor accounts in #{company.name}"
      end
    end
    puts "Completed the migration"
  end
  task :vendor_address_migration => :environment do
    vendors = Vendor.all

    vendors.each do |vendor|
      unless vendor.account.accountable.blank?
        vendor.account.accountable.address.addressable=vendor unless vendor.account.accountable.address.blank?
      end
    end
  end

  task :copy_account_created_by_to_vendor => :environment do 
    ActiveRecord::Base.transaction do
      vendors = Vendor.all
      puts"Copying..."
      vendors.each do |vendor|
        if vendor.created_by.blank?
          vendor.update_attribute(:created_by, vendor.account.created_by) unless vendor.account.blank?
        end
      end
      puts"Copied Successfully"
    end
  end
end  

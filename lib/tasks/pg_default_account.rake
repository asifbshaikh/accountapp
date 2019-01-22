namespace :pg_default_account do

task :create_online_payment_fees_account => :environment do 
  ActiveRecord::Base.transaction do 
   @companies= Company.where(:id=>[165,1081,2491, 6128, 6535,6655, 6936,6941])
    @companies.each do |company|
      account = Account.find_by_company_id_and_name(company.id, "Payment Gateway Charges")
      if account.blank? && !company.id.blank?
        account_head = AccountHead.get_root_head(company.id, "Indirect Expenses")
        unless account_head.blank? 
          puts"@@@account head is #{account_head == true}"
          account = Account.new
          account.name = "Payment Gateway Charges"
          account.erasable= false
          account.start_date=company.financial_years.first(:order=>"start_date ASC").start_date
          puts"@@ Account start date  for #{company.name} is #{account.start_date} "
          account.company_id = company.id
          account.created_by = company.users.first.id
          account.account_head_id = account_head.id
          sub_account = IndirectExpenseAccount.new
          account.accountable = sub_account
          account.save!
          puts"@@ Payment Gateway Charges account created for #{company.name}"
        end
      else
        puts"@@ company #{company.name} already has Payment Gateway Charges account"
      end
    end 
  end
end


task :create_online_payment_tax_account => :environment do 
  ActiveRecord::Base.transaction do 
     @companies = Company.where(:id=>[165,1081,6128, 6535,6655,6936,6941])
      @companies.each do |company|
      account_head = AccountHead.get_root_head(company.id, "Duties and Taxes")
      puts"@@@account head is #{account_head == true}"
        if !account_head.blank? && !company.id.blank?           
          account = Account.find_by_company_id_and_accountable_id(company.id, account_head.id)
          if account.blank?  
            account = Account.new
            account.name = "Service Tax @14% on purchase"
            account.start_date=company.financial_years.first(:order=>"start_date ASC").start_date
            account.erasable= false
            account.company_id = company.id
            account.created_by = company.users.first.id
            account.account_head_id = account_head.id
            sub_account =  DutiesAndTaxesAccounts.new(:tax_rate=> 14,:calculate_on_percent => 100,:filling_frequency=>12, :apply_to=>2)
            account.accountable = sub_account

            if account.save!
            puts"@@ #{account.name} created for #{company.name}"
            end 
          else
            puts"@@@ #{company.name} already have #{account.name}"
          end
        end


      end
  end

end



task :create_online_payment_cess_account => :environment do 
  ActiveRecord::Base.transaction do 
     @companies = Company.where(:id=>[165,1081,2491, 6128, 6535,6655, 6936,6941])
      @companies.each do |company|
      account_head = AccountHead.get_root_head(company.id, "Duties and Taxes")
      puts"@@@account head is #{account_head == true}"
        if !account_head.blank? && !company.id.blank?           
          account = Account.find_by_company_id_and_accountable_id(company.id, account_head.id)
          if account.blank?  
            account = Account.new
            account.name = "Cess @0.5% on purchase"
            account.start_date=company.financial_years.first(:order=>"start_date ASC").start_date
            account.erasable= false
            account.company_id = company.id
            account.created_by = company.users.first.id
            account.account_head_id = account_head.id
            sub_account =  DutiesAndTaxesAccounts.new(:tax_rate=> 0.5,:calculate_on_percent => 100,:filling_frequency=>12, :apply_to=>2)
            account.accountable = sub_account

            if account.save!
            puts"@@ #{account.name} created for #{company.name}"
            end 
          else
            puts"@@@ #{company.name} already have #{account.name}"
          end
        end


      end
  end

end






end
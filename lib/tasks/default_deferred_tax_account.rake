namespace :default_deferred_tax_account do

  task :create_default_account => :environment do
    @companies = Company.all
    ActiveRecord::Base.transaction do   
      @companies.each do |company|
        account_head = AccountHead.get_root_head(company.id, "Deferred Tax Asset Or Liability")
        puts"@@@account head is #{account_head == true}"
        if !account_head.blank?             
          account = Account.find_by_company_id_and_accountable_id(company.id, account_head.id)
          if account.blank?  
            account = Account.new
            account.name = "Deferred Tax Asset Or Liability"
            account.company_id = company.id
            account.created_by = company.users.first.id
            account.account_head_id = account_head.id
            if !account.account_head_id.blank?
            sub_account = DeferredTaxAssetOrLiability.new
            account.accountable = sub_account
            end
            if account.save!
            puts"@@ DTA&L account #{account.name} created for #{company.name}"
            end 
          else
            puts"@@@ #{company.name} already have #{account.name}  DTA&L account "
          end
        end
      end   
    end
  end

end
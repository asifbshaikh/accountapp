namespace :new_account_head do

  task :create_account_head => :environment do
      @companies = Company.all
      ActiveRecord::Base.transaction do 
      @companies.each do |company|
        account_head_names = ["Current Liabilities", "Reserves and Surplus", "Deferred Tax Asset Or Liability", "Other Current Assets"]      
        account_head_names.each do |name|
         account_head = AccountHead.find_by_name_and_company_id(name, company.id)
         if !account_head.blank?
          puts"@@@ #{account_head.name} already present in #{company.name}"
         else
          account_head = AccountHead.new
          account_head.company_id = company.id
          account_head.name = name
          account_head.created_by = company.users.first.id
          account_head.save!
          puts"@@@ #{account_head.name} has been created for #{company.name}"
         end
        end
      end
    end
  end
end
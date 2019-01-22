namespace :update_payhead do

  task :payhead_account => :environment do
    @companies = Company.all
    @companies.each do |company|
      if company.plan.payroll_enabled?
        puts"company plan is #{company.plan.name}"
        payheads = Payhead.find_all_by_company_id_and_account_id(company.id, 0)
        puts"@@@ payhead with account id = 0 are #{payheads.count} for #{company.name}"
        if !payheads.blank?
          payheads.each do |payhead|
            account = Account.find_by_company_id_and_name(company.id, payhead.payhead_name)
            if !account.blank?
              payhead.update_attribute(:account_id, account.id)
              puts"@@ payhead account_id updated with same account name (#{account.name}) as payhead name"
            else account = Account.find_by_company_id_and_name(company.id, "Basic")
              payhead.update_attribute(:account_id, account.id)
              puts"@@ payhead account_id updated with #{account.name} "
            end
          end
        else
          puts"@@@ #{company.name} has right payhead configuration and respective account id's"
        end
      end
    end
  end

end
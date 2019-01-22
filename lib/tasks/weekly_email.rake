namespace :weekly_email do 
  task :send_email => :environment do
  @companies = Company.all
    @companies.each do |company|
      @date = Time.zone.now - 1.weeks
      if company.active?
        @receivable_accounts = Account.get_customer_accounts(company.id)    
        @receivable_hash ={}
        for acc in @receivable_accounts
        @receivable_hash[acc.current_balance] = acc.name
        end

        @payable_accounts = Account.get_vendor_accounts(company.id)
        @payable_hash = {}
        for acc in @payable_accounts
        @payable_hash[acc.current_balance] = acc.name
        end

        @bank_accounts = Account.get_bank_accounts(company.id)
        @bank_hash ={}
        for acc in @bank_accounts
        @bank_hash[acc.current_balance] = acc.name
        end

        @cash_accounts = Account.get_cash_accounts(company.id)
        @cash_hash ={}
        for acc in @cash_accounts
        @cash_hash[acc.current_balance] = acc.name
        end
        @user = company.users.first

        @income = company.total_weekly_income(@user, @date)
        @expense = company.total_weekly_expense(@user, @date)
        puts"@@@ total income last week #{@income} and expense is #{@expense}"

        @email_template = EmailTemplate.find_by_template_name("Weekly Email Header")
        puts"@@@ template name is #{@email_template.template_name} and  "

        if !@email_template.blank? && !@email_template.header.blank? 
        @header = @email_template.header 
        @footer = @email_template.footer
        end
        puts"header is #{@header} and footer is #{@footer}"
        Email.weekly_mail(@user, company, @date, @income, @expense ,@receivable_hash, @payable_hash, @bank_hash, @cash_hash, @header, @footer).deliver
        puts"@@@@ Weekly email has been successfully send to email #{@user.email}"
      end
    end
  end
end
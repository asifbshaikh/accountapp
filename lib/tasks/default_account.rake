namespace :default_account do

  task :create_account => :environment do
      @companies = Company.all
      @companies.each do |company|
        if company.plan.payroll_enabled?
          puts"company plan is #{company.plan.name}"
          account_names = ["Basic","House Rent Allowance", "Dearness Allowance", "Travelling Allowance", "Bonus"]
          account_names.each do |name|
            account = Account.find_by_company_id_and_name(company.id, name)
            if account.blank?  
              account_head = AccountHead.get_root_head(company.id, "Indirect Expenses")
              puts"@@@account head is #{account_head == true}"
              account = Account.new
              account.name = name
              account.company_id = company.id
              account.created_by = company.users.first.id
              account.account_head_id = account_head.id
              if !account.account_head_id.blank?
                sub_account = IndirectExpenseAccount.new
                account.accountable = sub_account
              end
             if account.save!
              puts"@@ indirect expense account #{account.name} created for #{company.name}"
              payhead = Payhead.find_by_company_id_and_payhead_name(company.id, account.name)
              if payhead.blank?
                payhead = Payhead.new
                payhead.payhead_name = account.name
                payhead.company_id = company.id
                payhead.defined_by = company.users.first.id
                payhead.payhead_type = "Earnings"
                payhead.affect_net_salary = "Yes"
                payhead.use_of_gratuity = "No"
                payhead.name_appear_in_payslip = account.name
                payhead.optional = (payhead.payhead_name == "Bonus" ? true : false)
                payhead.account_id = account.id
                payhead.save!
                puts"@@ Payhead #{payhead.payhead_name} created for #{company.name}"
              else
                puts"@@@ #{company.name} already have #{payhead.payhead_name} payhead "
              end
             end 
            else
              puts"@@@ #{company.name} already have #{account.name}  Ind expense account "
            end
          end
        end
      end
  end
 
task :create_tds_acc => :environment do
  @companies = Company.all
  @companies.each do |company|
    ActiveRecord::Base.transaction do
    user = company.users.first.id
    tax_head = AccountHead.find_by_name_and_company_id("Duties and Taxes", company.id)
  
    if !tax_head.blank?
      # account head loop
      tds_receivable_head = AccountHead.find_by_name_and_company_id_and_parent_id("TDS Receivable", company.id, tax_head.id)          
      if tds_receivable_head.blank?
      tds_receivable_head = AccountHead.create(:company_id => company.id, :parent_id => tax_head.id, :name => "TDS Receivable", :created_by => user )
      puts"@@@@ New #{tds_receivable_head.name} sub account head created for #{company.name}"
      else
      puts"@@@@ #{company.name} already have #{tds_receivable_head.name} subhead"
      end
      tds_receivable_acc = Account.new(:company_id => company.id, :account_head_id => tds_receivable_head.id, :name => "tds receivable", :created_by => user)
      sub_account = DutiesAndTaxesAccounts.new(:tax_rate=> 0)
      tds_receivable_acc.accountable = sub_account
      tds_receivable_acc.save!
      
      tds_payable_head = AccountHead.find_by_name_and_company_id_and_parent_id("TDS Payable", company.id, tax_head.id)          
      if tds_payable_head.blank?
      tds_payable_head = AccountHead.create(:company_id => company.id, :parent_id => tax_head.id, :name => "TDS Payable", :created_by => user )
      puts"@@@@ New #{tds_payable_head.name} sub account head created for #{company.name}"
      else
      puts"@@@@ #{company.name} already have #{tds_payable_head.name} subhead"
      end
      names = ["Sec.193 - Interest on Debentures", "Sec.194 - Deemed Dividend", "Sec. 194A - Interest on Securities","Sec. 194B - Winnings from Lotteries or Puzzle or Game",
              "Sec. 194 BB - Winnings from Horse Race","Sec. 194 C 1- Payment to Contractors","Sec. 194 C 2- Payment to Sub-Contractors or for Advertisements","Sec. 194 D- Payment of Insurance Commission",
              "Sec. 194 EE -Payment of NSS Deposits","Sec. 194 F -Repurchase of units by Mutual Funds or UTI","Sec. 194 G - Commission on Sale of Lottery tickets","Sec. 194 H - Commission or Brokerage",
              "Sec. 194 I - Rent of Land or Building or Furniture or Plant and Machinery", "Sec. 194 IA - Transfer of Immovable Property","Sec. 194 J - Professional or technical services or royalty " ,
              "Sec. 194 J 1 - Remuneration or commission to director of the company","Sec. 194 J ba - Any remuneration or fees or commission paid to a director of a company other than Salary ", 
              "Sec. 194 L - Compensation on acquisition of Capital Asset","Sec. 194 LA - Compensation on acquisition of certain immovable property" ]
       names.each do |name|
        tds_payable_acc = Account.new(:company_id => company.id, :account_head_id => tds_payable_head.id, :name => name,:created_by => user)    
        sub_account = DutiesAndTaxesAccounts.new(:tax_rate=>0)
        tds_payable_acc.accountable = sub_account
        tds_payable_acc.save!
       end
     end
    end
  end   
end

task :create_gain_or_loss_account => :environment do 
  ActiveRecord::Base.transaction do 
   @companies = Company.all
    @companies.each do |company|
      account = Account.find_by_company_id_and_name(company.id, "Gain or loss on fluctuation in foreign currency")
      if account.blank?  
        account_head = AccountHead.get_root_head(company.id, "Indirect Expenses")
        unless account_head.blank? 
          puts"@@@account head is #{account_head == true}"
          account = Account.new
          account.name = "Gain or loss on fluctuation in foreign currency"
          account.company_id = company.id
          account.created_by = company.users.first.id
          account.account_head_id = account_head.id
          if !account.account_head_id.blank?
            sub_account = IndirectExpenseAccount.new
            account.accountable = sub_account
          end
          account.save!
          puts"@@ Gain or loss account created for #{company.name}"
        end
      else
        puts"@@ company #{company.name} already has gain or loss acc"
      end
    end 
  end
end


end
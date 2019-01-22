namespace :other_charges do

  task :create_other_charges => :environment do
    @companies = Company.all
      @companies.each do |company|
        ActiveRecord::Base.transaction do
          user = company.users.first.id
        #1) sales account loop
          indirect_expense = AccountHead.find_by_name_and_company_id("Indirect Expenses",company.id)
          if !indirect_expense.blank?
            # account head loop
            other_expense_head = AccountHead.find_by_name_and_company_id_and_parent_id("Other Charges on Sales", company.id, indirect_expense.id)          
            if other_expense_head.blank?
              other_expense_head = AccountHead.create(:name=>"Other Charges on Sales", :company_id => company.id, :created_by=> user, :parent_id=> indirect_expense.id)
              puts"@@@@ New #{other_expense_head.name} sub account head created for #{company.name}"
            else
              puts"@@@@ #{company.name} already have #{other_expense_head.name} subhead"
            end
        
            # account loop
            sales_acc_names = ["shipping charge", "adjustment on sales"] 
            sales_acc_names.each do |name|
              new_other_expense_account = Account.find_by_name_and_company_id_and_account_head_id(name, company.id, other_expense_head.id)
              if new_other_expense_account.blank?
                new_other_expense_account = Account.new(:company_id => company.id, :account_head_id => other_expense_head.id,
                :name => name, :created_by => user)
                sub_account = IndirectExpenseAccount.new(:inventoriable => false)
                new_other_expense_account.accountable = sub_account
                new_other_expense_account.save!
                puts"@@@@ New #{new_other_expense_account.name} account created for #{company.name}"
              else
                puts"@@@@ #{company.name} already have #{new_other_expense_account.name} account"
              end
            end
         #2) purchase account loop
            direct_expense = AccountHead.find_by_name_and_company_id("Direct Expenses",company.id)
            # account head loop
            purchase_other_expense_head = AccountHead.find_by_name_and_company_id_and_parent_id("Other Charges on Purchase", company.id, direct_expense.id)          
            if purchase_other_expense_head.blank?
              purchase_other_expense_head = AccountHead.create(:name=>"Other Charges on Purchase", :company_id => company.id, :created_by=> user, :parent_id=> direct_expense.id)
              puts"@@@@ New #{purchase_other_expense_head.name} sub account head for purchase created for #{company.name}"
            else
              puts"@@@@ #{company.name} already have #{purchase_other_expense_head.name} subhead for purchase"
            end
        
            # account loop
            purchase_acc_names = ["other charge on purchase","adjustment on purchase"]
            purchase_acc_names.each do |name|
              new_other_expense_purchase_account = Account.find_by_name_and_company_id_and_account_head_id(name, company.id, purchase_other_expense_head.id)
              if new_other_expense_purchase_account.blank?
                new_other_expense_purchase_account = Account.new(:company_id => company.id, :account_head_id => purchase_other_expense_head.id,
                :name =>name, :created_by => user)
                sub_account = DirectExpenseAccount.new(:inventoriable => false)
                new_other_expense_purchase_account.accountable = sub_account
                new_other_expense_purchase_account.save!
                puts"@@@@ New #{new_other_expense_purchase_account.name} account created for #{company.name}"
              else
                puts"@@@@ #{company.name} already have #{new_other_expense_purchase_account.name} account"
              end
            end
          end   
        end
      end
    end

# This task will change parent head of the purchase other charges acc head
    task :update_purchase_other_charges_head =>:environment do
      @companies = Company.all
      @companies.each do |company|
          user = company.users.first.id
          indirect_expense_head = AccountHead.find_by_name_and_company_id("Indirect Expenses",company.id)
          direct_expense_head = AccountHead.find_by_name_and_company_id("Direct Expenses",company.id)
          
        ActiveRecord::Base.transaction do
          if !indirect_expense_head.blank? && !direct_expense_head.blank?
            other_expense_head = AccountHead.find_by_name_and_company_id_and_parent_id("Other Charges on Purchase", company.id, indirect_expense_head.id)          
            account = Account.find_by_name_and_company_id_and_account_head_id("other charge on purchase", company.id, other_expense_head.id ) unless other_expense_head.blank?
            if !account.blank?
              account.accountable.destroy
              sub_account = DirectExpenseAccount.new(:inventoriable => false)
              account.accountable = sub_account
              account.save!
              other_expense_head.update_attribute("parent_id", direct_expense_head.id)
              puts"++++++ account #{account.name} updated and account head parent updated with #{other_expense_head.parent_id} for company #{company.name}"
            else              
              puts"++++++ Account not available for #{company.name}"
            end
          end
        end 

      end
    end
end
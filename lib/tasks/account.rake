namespace :account do
	desc "create default discount accounts"
	task :default_discount => :environment do
		companies = Company.all
		i=0
		j=0
		companies.each do |company|
			expense_account = Account.find_by_name_and_company_id("Discount on Sales Account", company.id)
			income_account = Account.find_by_name_and_company_id("Discount on Purchase Account", company.id)
			if expense_account.blank? || income_account.blank? 
				ActiveRecord::Base.transaction do 
					user=company.users.first
					financial_year=company.financial_years.first(:order=>"start_date ASC")
					indirect_expense = AccountHead.find_by_name_and_company_id("Indirect Expenses",company.id)
					unless indirect_expense.blank? || expense_account.present?
					  indirect_expense_account=Account.create_account(company.id, user.id, indirect_expense, financial_year, "Discount on Sales Account", "IndirectExpenseAccount")
					end
					indirect_income = AccountHead.find_by_name_and_company_id("Indirect Income",company.id)
					unless indirect_income.blank? || income_account.present?
					  indirect_income_account=Account.create_account(company.id, user.id, indirect_income, financial_year, "Discount on Purchase Account", "IndirectIncomeAccount")
					end

					i+=1
					print"#{i} companies processed out of #{companies.count}. #{j} companies are already porcessed\r"
				end
			else
				j+=1
				print"#{i} companies processed out of #{companies.count}. #{j} companies are already porcessed\r"
			end
		end
		puts"#{i} companies processed out of #{companies.count}. #{j} companies are already porcessed"
	end
	desc "create default non erasables"
	task :add_default_non_erasables => :environment do
		connection=ActiveRecord::Base.connection
		puts"---Companies where account with name Sales Account - default income doesnt exist---"
		print"Retreiving...\r"
		companies=connection.execute(" select * from companies c where not exists(select company_id from accounts a where a.company_id=c.id and a.name='Sales Account - default income')")
		i=0
		companies.each do |array|
			company=Company.find array[0].to_i
			direct_income = AccountHead.find_by_name_and_company_id("Direct Income",company.id)
			unless direct_income.blank?
				i+=1
			  Account.create_direct_income(company.id, company.users.first.id, direct_income.id)
			end
			print"#{i} new accounts added\r"
		end
		puts"#{i} new accounts added"

		puts"---Companies where account with name Purchase Account - default expense doesnt exist---"
		print"Retreiving...\r"
		companies=connection.execute(" select * from companies c where not exists(select company_id from accounts a where a.company_id=c.id and a.name='Purchase Account - default expense')")
		i=0
		companies.each do |array|
			company=Company.find array[0].to_i
			direct_expense = AccountHead.find_by_name_and_company_id("Direct Expenses",company.id)
	    unless direct_expense.blank?
				i+=1
	      expense_account = Account.create_direct_expense(company.id, company.users.first.id, direct_expense.id)
	    end
			print"#{i} new accounts added\r"
		end
		puts"#{i} new accounts added"

		puts"---Companies where account head with name Other Charges on Sales doesnt exist---"
		print"Retreiving...\r"
		companies=connection.execute("select * from companies c where not exists(select company_id from account_heads a where a.company_id=c.id and a.name='Other Charges on Sales')")
		i=0
		companies.each do |array|
			company=Company.find array[0].to_i
			indirect_expense = AccountHead.find_by_name_and_company_id("Indirect Expenses",company)
			other_expense_on_sales = AccountHead.create(:name=>"Other Charges on Sales", :company_id => company.id, :created_by=> company.users.first.id, :parent_id=> indirect_expense.id, :erasable=>false)
	    unless other_expense_on_sales.blank?
	    	i+=1
	      Account.create_other_expense_on_sales(company.id, company.users.first.id, other_expense_on_sales.id)
	    end
			print"#{i} new account heads and related accounts added\r"
		end
		puts"#{i} new account heads and related accounts added"

		puts"---Companies where account head with name Other Charges on Purchase doesnt exist---"
		print"Retreiving...\r"
		companies=connection.execute("select * from companies c where not exists(select company_id from account_heads a where a.company_id=c.id and a.name='Other Charges on Purchase')")
		i=0
		companies.each do |array|
			company=Company.find array[0].to_i
			direct_expense = AccountHead.find_by_name_and_company_id("Direct Expenses", company.id)
			other_expense_on_purchase = AccountHead.create(:name=>"Other Charges on Purchase", :company_id => company.id, :created_by=> company.users.first.id, :parent_id=> direct_expense.id, :erasable=>false) unless direct_expense.blank?
	    unless other_expense_on_purchase.blank?
	    	i+=1
        Account.create_other_expense_on_purchase(company.id, company.users.first.id, other_expense_on_purchase.id)
      end
			print"#{i} new account heads and related accounts added\r"
		end
		puts"#{i} new account heads and related accounts added"

		puts"---Companies where account head with name TDS Receivable doesnt exist---"
		print"Retreiving...\r"
		companies=connection.execute("select * from companies c where not exists(select company_id from account_heads a where a.company_id=c.id and a.name='TDS Receivable')")
		i=0
		companies.each do |array|
			company=Company.find array[0].to_i
			other_current_asset_head = AccountHead.find_by_name_and_company_id("Other Current Assets", company.id)
	    tds_receivable_head = AccountHead.create(:company_id => company.id, :parent_id => other_current_asset_head.id, :name => "TDS Receivable", :created_by => company.users.first.id, :erasable=>false )
	    unless tds_receivable_head.blank?
	    	i+=1
        Account.create_tds_receivable_acc(company.id, company.users.first.id, tds_receivable_head.id)
      end
			print"#{i} new account heads and related accounts added\r"
		end
		puts"#{i} new account heads and related accounts added"

		puts"---Companies where account head with name TDS Payable doesnt exist---"
		print"Retreiving...\r"
		companies=connection.execute("select * from companies c where not exists(select company_id from account_heads a where a.company_id=c.id and a.name='TDS Payable')")
		i=0
		companies.each do |array|
			company=Company.find array[0].to_i
			tax_head = AccountHead.find_by_name_and_company_id("Duties and Taxes", company.id)
			tds_payable_head = AccountHead.create(:company_id => company.id, :parent_id => tax_head.id, :name => "TDS Payable", :created_by => company.users.first.id, :erasable=>false ) unless tax_head.blank?
	    unless tds_payable_head.blank?
        Account.create_tds_payable_acc(company.id, company.users.first.id, tds_payable_head.id)
      end
			print"#{i} new account heads and related accounts added\r"
		end
		puts"#{i} new account heads and related accounts added"
	end

	desc "To set effective date of account"
	task :set_effective_from => :environment do
		accounts = Account.where("start_date is null")
		i=0
		accounts.each do |account|
			dates=[]
			dates<<account.ledgers.minimum(:transaction_date)
			dates<<account.created_at.to_date
			account.update_attribute("start_date", (dates.include?(nil) ? dates.last : dates.min))
			i+=1
			print"effective date to #{i} accounts out of #{accounts.count} has been set.\r"
		end
		puts"effective date to #{i} accounts out of #{accounts.count} has been set."
	end
	
	desc "to create vendors"
	task :add_vendors => :environment do
		ActiveRecord::Base.transaction do 

		end
	end

	desc "to create chart of accounts"
	task :add_accounts => :environment do
		ActiveRecord::Base.transaction do 
			SUB_ACCOUNT={"Bank Accounts"=>"BankAccount","Cash Accounts"=>"CashAccount","Fixed Assets"=>"FixedAsset","Loan Accounts"=>"LoanAccount","Secured Loan Accounts"=>"SecuredLoanAccount",
 		  "Unsecured Loan Accounts"=>"UnsecuredLoanAccount", "Direct Expenses"=>"DirectExpenseAccount",
      "Indirect Expenses"=>"IndirectExpenseAccount", "Investments"=>"InvestmentAccount","Loans and advances"=>"LoansAdvancesAccount","Provisions"=>"ProvisionAccount", "Deposits"=>"DepositAccount","Suspense Accounts"=>"SuspenseAccount",
      "Capital Accounts"=>"CapitalAccount","Direct Income"=>"DirectIncomeAccount","Indirect Income"=>"IndirectIncomeAccount", "Current Liabilities"=>"CurrentLiability", "Reserves and Surplus"=>"ReservesAndSurplusAccount", 
      "Deferred Tax Asset Or Liability"=>"DeferredTaxAssetOrLiability", "Other Current Assets"=>"OtherCurrentAsset"}
			company=Company.find 1716
			csv = CSV.read("#{Rails.root}/chart_of_accounts.csv")
			success = 0
			fail = 0
			count = 0
			account_head_not_found_counter=0
			sub_account_head_create_counter=0
			sub_account_head_not_create_counter=0
			sub_account_head_already_exist_couter=0
			saved_account_count=0
			not_saved_account_count=0

			csv.each do |row|
				head_name=row[0]
				subhead_name=row[1]
				account_name=row[2]
				opening_balance=0
				opening_balance= row[4]=="Cr" ? (row[3].to_i*-1) : row[3].to_i# unless row[3].blank?
				puts"head_name=#{head_name}, subhead_name=#{subhead_name}, account_name=#{account_name}, opening_balance=#{opening_balance}"
				account_head=company.account_heads.find_by_name(head_name)
				if account_head.blank?
					account_head_not_found_counter+=1
				else
					unless subhead_name.blank?
						sub_account_head=company.account_heads.find_by_name_and_parent_id(subhead_name, account_head.id)
						if sub_account_head.blank?
							account_head=AccountHead.new(:company_id=>company.id, :parent_id=>account_head.id,
								:name=>subhead_name, :created_by=>company.users.first.id)
							if account_head.save!
								sub_account_head_create_counter+=1
							else
								sub_account_head_not_create_counter+=1
							end
						else
							sub_account_head_already_exist_couter+=1
							account_head=sub_account_head
						end
					end
					account=company.accounts.find_by_name_and_account_head_id(account_name, account_head.id)
					if account.blank?
						account=Account.new(:company_id=>company.id, :account_head_id=>account_head.id,
							:name=>account_name, :opening_balance=> opening_balance,
							:created_by=> company.users.first.id)
						sub_account="#{SUB_ACCOUNT[account_head.root.name]}".constantize.new()
						account.accountable=sub_account
						if ["BankAccount", "SecuredLoanAccount"].include?(account.accountable_type)
							account.accountable.account_number="" 
							account.accountable.bank_name="" 
						end
						if account.save
							saved_account_count+=1
						else
							not_saved_account_count+=1
						end
					else
						saved_account_count+=1
						account.update_attribute("opening_balance", opening_balance)
					end
				end
				count+=1
			end
			puts"success=#{saved_account_count} out of count=#{count}"
		end
	end
end
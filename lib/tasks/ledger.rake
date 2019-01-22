namespace :ledger do
	desc "ading corresponding ledger id"
	task :add_corresponding_id => :environment do
		ActiveRecord::Base.transaction do 
			companies = Company.all
			companies.each do |company|
				is_shown=false
				accounts=company.accounts
				accounts.each do |account|
					ledgers = account.ledgers
					ledgers.each do |ledger|
						condition = "company_id=#{company.id} and voucher_type='#{ledger.voucher_type.to_s}' and voucher_id=#{ledger.voucher_id} and voucher_number='#{ledger.voucher_number}' and id !=#{ledger.id} and description='#{ledger.description.gsub(/\s+|\'/, '') unless ledger.description.blank?}' and "
						if ledger.debit==0 && ledger.credit==0
							condition +="debit=0.0 and credit=0.0"
						elsif ledger.debit == 0
							condition +="debit=#{ledger.credit}"
						else
							condition +="credit=#{ledger.debit}"
						end
						corresponding_accounts = Ledger.where(condition)
						if corresponding_accounts.count > 1
							puts"condition=#{condition}"
							puts"=== #{company.name}(#{company.id})" unless is_shown
							is_shown=true
							puts"corresponding accounts for #{account.name}(#{account.id}) seems #{corresponding_accounts.count} for voucher_type=#{ledger.voucher_type} and voucher_id=#{ledger.voucher_id}"
						end
					end
				end
			end
		end	
	end
end
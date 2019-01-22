namespace :stock_issue_voucher do 
	task :create_sequence => :environment do 
		ActiveRecord::Base.transaction do 
			companies = Company.all
			i=0
			puts"Creating sequences for all companies..."
			companies.each do |company|
				if StockIssueVoucherSequence.create!(:company_id => company.id)
					i+=1
				end
			end
			puts"sequences for #{i} out of #{companies.count} has been created."
		end
	end
end
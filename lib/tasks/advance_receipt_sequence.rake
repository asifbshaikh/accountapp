
namespace :gstr_advance_receipt  do
	task :create_sequence => :environment do 
		ActiveRecord::Base.transaction do
			companies =Company.all
			puts "Creating sequence number for all companies"
			i=0
			companies.each do|company|
				if company.currency_code == 'INR'
					if GstrAdvanceReceiptVoucherSequence.create(:company_id=>company.id)
						i+=1
					end
				end
			end
		puts "sequence number generated for #{i} out of #{companies.count} companies"
		end
	end					
	
end
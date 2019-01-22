#This task was written to fix issue of User ID 11427 raised on 9th September 2016
#Author : Ashish Wadekar
#Date : 9th September 2016
namespace :purchase_number do
	desc "Increment the purchase sequence to fix issue of User ID 11427 on 9th September 2016 "
	task :fix_numbering => :environment do
		date_time = "2016-09-04 00:00:01" #Time when the purchase number fix was deployed to PROD server
		counter = 0
		affected_companies = []
		companies = Company.all
		companies.each do |company|
			puts "Updating Purchase sequence for Company: #{company.name}-#{company.id}"
			purchase_sequence  = PurchaseSequence.find_by_company_id(company.id)
			if !purchase_sequence.nil?
				puts "The purchase sequence for this company was #{purchase_sequence.purchase_sequence}"
				if purchase_sequence.updated_at < date_time && purchase_sequence.purchase_sequence != 0
					company.purchase_sequence.increment_counter
					counter += 1
					affected_companies << company.id
					puts "The purchase sequence for this company is incremented."
				end
			end
		end
		puts "No. of companies affected: #{counter}"
		puts "Companies affected : #{affected_companies}"
	end
end
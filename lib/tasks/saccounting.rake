namespace :saccounting do 
	task :create_sequence => :environment do 
		ActiveRecord::Base.transaction do 
			companies = Company.all
			i=0
			puts"Creating sequences for all companies"
			companies.each do |company|
				if SaccountingSequence.create!(:company_id=> company.id)
					i+=1
				end
			end
			puts"sequences for #{i} out of #{companies.count} companies has been added."
		end	
	end
end
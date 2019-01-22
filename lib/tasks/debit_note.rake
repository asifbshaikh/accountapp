namespace :debit_note do 
	task :create_sequence => :environment do 
		ActiveRecord::Base.transaction do
			companies = Company.all
			i=0
			puts"Creating sequences for all companies.."
			companies.each do |company|
				if DebitNoteSequence.create!(:company_id=> company.id)
					i+=1
				end
			end
			puts"Sequences for #{i} out of #{companies.count} companies has been created."
		end
	end
end
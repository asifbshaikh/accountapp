namespace :lead_activity do 
	task :create => :environment do
		leads = Lead.all
		ActiveRecord::Base.transaction do 
			leads.each do |lead|
				unless lead.customer_relationships.blank?
					lead.customer_relationships.each do |cr|
						LeadActivity.create!(:lead_id => lead.id, :activity => 1, :record_date => cr.last_contact_date,
							:next_followup => cr.next_contact_date, :outcome => cr.notes)
					end
				end
			end
		end
	end
end
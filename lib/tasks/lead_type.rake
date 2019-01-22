namespace :lead do 
	task :change_lead_type => :environment do 
		ActiveRecord::Base.transaction do 
			tally_leads = Lead.where(:lead_type => 2)
			ca_leads = Lead.where(:lead_type => 3)
			institution_leads = Lead.where(:lead_type => 4)
			resseler_leads = Lead.where(:lead_type => 5)
			partner_leads = Lead.where(:lead_type => 6)
			other_leads = Lead.where(:lead_type => 7)

			puts"total #{tally_leads.count} Tally leads converting to Resseler leads"
			tally_leads.update_all(:lead_type => 3) unless tally_leads.blank?
			puts" total #{ca_leads.count} CA firms converting to CA leads"
			ca_leads.update_all(:lead_type => 2) unless ca_leads.blank?
			puts"total #{institution_leads.count} Institution leads converting to Partner leads"
			institution_leads.update_all(:lead_type => 4) unless institution_leads.blank?
			puts"total #{resseler_leads.count} Resseler leads converting to Resselers"
			resseler_leads.update_all(:lead_type => 3) unless resseler_leads.blank?
			puts"toatal #{partner_leads.count} Partner leads converting to partners"
			partner_leads.update_all(:lead_type => 4) unless partner_leads.blank?
			puts"total #{other_leads.count} Other leads converting to others"
			other_leads.update_all(:lead_type => 5) unless other_leads.blank?
		end	
	end

	task :change_activity => :environment do
		ActiveRecord::Base.transaction do
			lead_activities = LeadActivity.all
				lead_activities.each do |lead_activity|
					if lead_activity.activity == 4
					lead_activity.update_attributes(:activity => 18)
					else
						lead_activity.update_attributes(:activity => 19)
					end
					if lead_activity.next_activity == 4
						lead_activity.update_attributes(:next_activity => 18)
					else
						lead_activity.update_attributes(:next_activity => 19)
					end
				end
			puts"***********Total #{lead_activities.count} lead_activities changed"
		end
	end
end

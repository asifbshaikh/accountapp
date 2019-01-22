namespace :lead_assigned_to do 
	task :add_assigned_to => :environment do 
		ActiveRecord::Base.transaction do 
			leads = Lead.all

			leads.each do |lead|
			lead.update_attributes(:assigned_to => 9)
			puts"Assigned to added"
			end
		end	
	end

  task :add_completed_date => :environment do 
    ActiveRecord::Base.transaction do 
      lead_activities = LeadActivity.where(:activity_status => true)
      count = 0
      lead_activities.each do |lead_activity|
      lead_activity.update_attributes(:completed_date => lead_activity.updated_at.to_date)
      count += 1
      puts"Adding..."
      end
      puts"*************Total #{count} date added"
    end 
  end

  task :merge_leads => :environment do 
    ActiveRecord::Base.transaction do 
      leads = Lead.all
      count = 0
      lead_mobile = []
      leads.each do |lead|
        lead.update_attributes(:stage => 1)
        company = Company.where("phone = ? OR email = ?",lead.mobile,lead.email)
        if company.count >1
          lead_mobile << lead.mobile
        elsif company.count == 1
          LeadCompany.create!(:lead_id => lead.id,:company_id => company.first.id)
          if company.first.plan.name == "Trial"
            lead.update_attributes!(:stage => 2)
          else
            lead.update_attributes!(:stage => 3)
          end
          customer_relationships = CustomerRelationship.where(:company_id => company.first.id)
          customer_relationships.each do |cr|
            LeadActivity.create!(:lead_id => lead.id,:time_spent => cr.time_spent,:outcome => cr.notes,:next_followup => cr.next_contact_date,
              :next_follow_up_time => cr.next_folloup_time,:next_activity => cr.next_activity,:activity_status => cr.activity_status,:completed_date => cr.completed_date)
          end
            count += 1
        end 
      end
      puts"***************total #{count} records added"
      puts"***************leads mobile having multiple companies #{lead_mobile.join(',')}"
    end
  end
end
namespace :daily_emails do
  task :send_mail_to_admin => :environment do

       total_registrations = Company.where("companies.created_at between ? and ?", Time.zone.now.to_date, Time.zone.now.to_date).count
       total_paid = Company.joins(:subscription).where("subscriptions.status=? and subscriptions.updated_at BETWEEN ? and ?","Paid",Time.zone.now-1.days,Time.zone.now.to_date).count
       lead_demo = LeadActivity.where("next_activity=? and completed_date BETWEEN ? and ?",18,Time.zone.now.to_date,Time.zone.now.to_date).count
       trial_demo_online = CustomerRelationship.where("next_activity=? and completed_date BETWEEN ? and ?",2,Time.zone.now.to_date,Time.zone.now.to_date).count
       trial_demo_presonal_visit =CustomerRelationship.where("next_activity=? and record_date BETWEEN ? and ?",3,Time.zone.now.to_date,Time.zone.now.to_date).count
       total_lead_activities =LeadActivity.where("completed_date BETWEEN ? and ?",Time.zone.now.to_date,Time.zone.now.to_date).count
       total_customer_relationships_activities=CustomerRelationship.where("completed_date BETWEEN ? and ?",Time.zone.now.to_date,Time.zone.now.to_date).count
       ActiveRecord::Base.transaction do
        Email.daily_lead_activity(total_registrations,total_paid,lead_demo,trial_demo_online,trial_demo_presonal_visit,total_lead_activities,total_customer_relationships_activities).deliver
       end
  end

  task :send_morning_mail_to_admin => :environment do
     ActiveRecord::Base.transaction do
       Email.admin_morning_mail.deliver
     end
  end

  task :send_evening_mail_to_admin => :environment do
     ActiveRecord::Base.transaction do
       Email.admin_evening_mail.deliver
     end
  end

end

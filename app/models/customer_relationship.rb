class CustomerRelationship < ActiveRecord::Base
  scope :by_company, lambda{|id| where(:company_id => id) unless id.blank?}

belongs_to :company
validates_presence_of :next_contact_date

ACTIVITY = {'1' => "Welcome call", '2' => "Trial Demo (online)", '3' => "Trial Demo (Personal visit)", '4' => "Feedback", '5' => "Pre-Expiry", '6' => "Post Expiry",
'7' => "Trial Followup Notes", '8' => "Paid Demo", '9' => "Thank For Payment", '10' => "Feedback after 1 month", '11' => "Feedback 6 months before expiry", '12' => "Feedback 3 months before expiry",
'13' => "Feedback 1 month before expiry", '14' => "Feedback 1 week before expiry", '15' => "Feedback 1 day before expiry", '16' => "Feedback 1 day post Post expiry", '17' => "Paid Followup Notes",
'18' => "Lead Demo", '19' => "Lead Followup Notes"}
EMAIL_TEMPLATE = {'1' => "Welcome To ProfitBooks", '2' => "Introduction To ProfitBooks", '3' => "Regarding Costing Details", '4' => "Regarding ProfitBooks - Accounting Application", '5' => "Regarding Bank Details"}

STATUS = {'0'=> "Trial", '1'=> "Converted to paid", '3' => "Paid but Expired"}
def customer_company
  company = Company.by_company(notable_id).name
end

def customer_contact_name
  company = Company.by_company(notable_id)
  company.users.first.full_name
end

def following_by
  SuperUser.find(created_by).first_name unless created_by.blank?
end

def customer_contact_number
  company = Company.by_company(notable_id).phone
end
class << self
def get_activities(company)
  @activities = {}
  if company.subscription.status == "Paid"
    ACTIVITY.each do |key, value|
      if key.to_i >= 8 && key.to_i <= 17
        @activities.store(key, value)
      end
    end
  else
     ACTIVITY.each do |key, value|
      if key.to_i <= 7
        @activities.store(key, value)
      end
    end
  end
  @activities
end
def get_paid_activities
    ACTIVITY
end

def get_activity(index)
  ACTIVITY[index.to_s]
end
def get_templates
    EMAIL_TEMPLATE
end

def get_template(index)
  EMAIL_TEMPLATE[index.to_s]
end

def create_customer_relationships_for_trial(company)
  next_contact_date = [Time.zone.now.to_date+1.days, Time.zone.now.to_date+5.days, Time.zone.now.to_date+12.days, Time.zone.now.to_date+15.days]
  next_activity = [1,4,5,6]
  i = 0
  while i < 4 do
  customer_relationship = CustomerRelationship.new
    customer_relationship.company_id = company
    customer_relationship.next_contact_date = next_contact_date[i]
    customer_relationship.next_activity = next_activity[i]
    customer_relationship.save!
    i += 1
  end
end

def create_customer_relationships_for_paid(company)
  next_contact_date = [Time.zone.now.to_date+1.days, Time.zone.now.to_date+1.months, Time.zone.now.to_date+6.months, Time.zone.now.to_date+9.months, Time.zone.now.to_date+11.months, Time.zone.now.to_date+11.months+21.days, Time.zone.now.to_date+11.months+29.days, Time.zone.now.to_date+1.years+1.days]
  next_activity = [9,10,11,12,13,14,15,16]
  i = 0
  while i < 8 do
  customer_relationship = CustomerRelationship.new
    customer_relationship.company_id = company
    customer_relationship.next_contact_date = next_contact_date[i]
    customer_relationship.next_activity = next_activity[i]
    customer_relationship.save!
    i += 1
  end
end

def get_weekly_shedule
  weekly_shedule = CustomerRelationship.where("next_contact_date BETWEEN ? and ?",Time.zone.now.beginning_of_week,Time.zone.now.end_of_week)
end

  def get_delay_activities
  delay_activities = []
    activities =  self.where(:activity_status => true)
    activities.each do |activity|
      unless activity.next_contact_date.blank?
      time_difference = activity.completed_date - activity.next_contact_date
        if time_difference > 0
          delay_activities << activity
        end
      end
    end
    delay_activities
  end
end

end

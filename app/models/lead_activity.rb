class LeadActivity < ActiveRecord::Base
  belongs_to :lead
  # validates_presence_of :next_followup
  # validates :schedule_date, :if next_followup < = :massage => : "Schedule date not be less than today"
  attr_accessor :check_date_validation
  validate :date_of_next_followup,:if => lambda{|a| a.next_activity == 2}, :on=>:create, unless: :check_date_validation
  




  ACTIVITY = {'1' => "Welcome call", '2' => "Trial Demo (online)", '3' => "Trial Demo (Personal visit)", '4' => "Feedback", '5' => "Pre-Expiry", '6' => "Post Expiry",
'7' => "Trial Followup Notes", '8' => "Paid Demo", '9' => "Thank For Payment", '10' => "Feedback after 1 month", '11' => "Feedback 6 months before expiry", '12' => "Feedback 3 months before expiry",
'13' => "Feedback 1 month before expiry", '14' => "Feedback 1 week before expiry", '15' => "Feedback 1 day before expiry", '16' => "Feedback 1 day post Post expiry", '17' => "Paid Followup Notes",
'18' => "Lead Demo", '19' => "Lead Followup Notes"}
  
  def get_activity
    ACTIVITY[next_activity.to_s]
  end

  def get_lead_activity
    if lead_activity == false
      "Pending"
    elsif
      "Completed"
    end
  end

  def self.get_weekly_activities
    weekly_activities = LeadActivity.where("next_followup BETWEEN ? and ?",Time.zone.now.beginning_of_week,Time.zone.now.end_of_week)
  end

  def self.get_task_delay_activities
    delay_activities = []
    activities =  LeadActivity.where(:activity_status => true)
    activities.each do |activity|
      unless activity.next_followup.blank?
      time_difference = activity.completed_date - activity.next_followup
      if time_difference > 0
        delay_activities << activity
      end
    end
  end
    delay_activities
  end

  def self.create_lead_activities_for_trial(lead)
    next_followup = [Time.zone.now.to_date+1.days, Time.zone.now.to_date+5.days]
    next_activity = [1,5]
    i = 0
    while i < 2 do
    lead_activity = LeadActivity.new
      lead_activity.lead_id = lead
      lead_activity.next_followup = next_followup[i]
      lead_activity.next_activity = next_activity[i]
      lead_activity.save!
      i += 1
    end
  end

  def self.create_lead_activities_for_paid(company)
    company.lead_company.lead.update_attributes(:next_call_date => Time.zone.now.to_date+1.days, :stage => 3)
    next_followup = [Time.zone.now.to_date+1.days, Time.zone.now.to_date+1.months, Time.zone.now.to_date+6.months, Time.zone.now.to_date+9.months, Time.zone.now.to_date+11.months, Time.zone.now.to_date+11.months+21.days, Time.zone.now.to_date+11.months+29.days, Time.zone.now.to_date+1.years+1.days]
    next_activity = [9,10,11,12,13,14,15,16]
    i = 0
    while i < 8 do
    lead_activity = LeadActivity.new
      lead_activity.lead_id = company.lead_company.lead.id
      lead_activity.next_followup = next_followup[i]
      lead_activity.next_activity = next_activity[i]
      lead_activity.save!
      i += 1
    end
  end

  def self.get_activities(params)
    start_date = params[:start_date].blank? ? Time.zone.now.beginning_of_month.to_date : params[:start_date]
    end_date = params[:end_date].blank? ? Time.zone.now.to_date : params[:end_date]
    activity = params[:activity].blank? ? ACTIVITY.keys : params[:activity]
    if !params[:super_user].blank?
      @lead_activities = LeadActivity.joins(:lead).where("leads.deleted = ? and leads.assigned_to = ?",false, params[:super_user]).where("lead_activities.next_activity in (?) and lead_activities.completed_date BETWEEN ? AND ? ", activity, start_date.to_date, end_date.to_date)
    else  
      @lead_activities = LeadActivity.joins(:lead).where("leads.deleted = ?",false).where("lead_activities.next_activity in (?) and lead_activities.completed_date BETWEEN ? AND ? ", activity, start_date.to_date, end_date.to_date)
    end
  end


  def date_of_next_followup
    if next_followup.blank?
      errors.add(:next_folloup, "schedule date can't be blank.")
    elsif next_followup < Time.zone.now.to_date
      errors.add(:next_folloup, "schedule date can't be earlier than today.")
    elsif next_followup == Time.zone.now.to_date
      errors.add(:next_folloup, "schedule date should be atleast one day in advance.")
    elsif next_followup > Time.zone.now.to_date + 1.month
      errors.add(:next_folloup, "schedule date can't be more than one month.")
    end
  end

#  def next_follow_up_time
#    if next_follow_up_time < Time.zone.now.to_date
#      errors.add(:next_follow_up_time, "Schedule time can't be earlier than right now")
#      elsif next_follow_up_time > Time.zone.now.to_date
#   end
# end
       

end

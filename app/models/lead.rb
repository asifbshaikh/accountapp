class Lead < ActiveRecord::Base

  scope :by_name, lambda{|name| where(:name => name) unless name.blank?}
  scope :by_mobile, lambda{|mobile| where(:mobile => mobile) unless mobile.blank?}
  scope :by_email, lambda{|email| where(:email => email) unless email.blank?}
  scope :by_channel, lambda{|channel| where(:channel_id => channel) unless channel.blank?}
  scope :by_campaign, lambda{|campaign| where(:campaign_id => campaign) unless campaign.blank?}
  scope :by_status, lambda{|status| where(:status => status) unless status.blank?}
  scope :by_assigned, lambda{|assigned_to| where(:assigned_to => assigned_to) unless assigned_to.blank?}

  has_many :lead_activities, :dependent => :destroy
  has_many :customer_relationships, :as => :notable, :dependent => :destroy
  accepts_nested_attributes_for :customer_relationships, :lead_activities
  
  belongs_to :partner
  belongs_to :channel
  belongs_to :campaign
  belongs_to :super_user, :foreign_key => "assigned_to"
  has_one :lead_company
  has_one :company, :through => :lead_company
  attr_accessible :lead_activities_attributes,:lead_type, :next_call_date, :name, :email, :mobile, :created_by, :status, :channel_id, :organisation_name, :description,
    :city, :payment_status, :converted_to_trial, :campaign_id, :deleted_reason, :deleted_by, :notes, :deleted ,:converted_by, :converted_comment, :assigned_to,
    :stage, :trial_status, :paid_status, :source, :segment, :probability, :estimated_revenue, :plan_of_interest, :updated_at
 # validates_presence_of :name, :mobile, :email, :channel_id, :campaign_id
  #STATUS = {'1' => "Green", '2' => "Red", '0' => "Amber"}
  STATUS = {open: 0, assigned: 1, qualified: 2, won: 3, lost: 4, junk: 5}

  ACTIVITY = {'1' => "Welcome call", '2' => "Trial Demo (online)", '3' => "Trial Demo (Personal visit)", '4' => "Feedback", '5' => "Pre-Expiry", '6' => "Post Expiry",
  '7' => "Trial Followup Notes", '8' => "Paid Demo", '9' => "Thank For Payment", '10' => "Feedback after 1 month", '11' => "Feedback 6 months before expiry", '12' => "Feedback 3 months before expiry",
  '13' => "Feedback 1 month before expiry", '14' => "Feedback 1 week before expiry", '15' => "Feedback 1 day before expiry", '16' => "Feedback 1 day post Post expiry", '17' => "Paid Followup Notes",
  '18' => "Lead Demo", '19' => "Lead Followup Notes"}
  STAGE = {'1' => "Lead",'2' => "Trial", '3' => "Paid"}
  TRIAL_STATUS = {'1' => "Interested", '2' => "Might buy", '3' => "Not Interested", '4' => "On Hold", '5' => "Junk Registration, '6' => No Response"}
  PAID_STATUS = {'1' => "Active", '2' => "Inactive", '3' => "Low Activity", '4' => "Expired"}
  COMMENT = {'1' => 'Discount Given', '2' => 'Revenue'}
  DELETED_REASON ={'1' => 'Not Interested', '2' => 'Lost To Competion', '3' => 'Junk Lead','4' => 'Feature Missing','5' => 'Pricing Issue','6' => 'Others'}
  ACTIVITY_STATUS = {1 => "Completed", 0 => "Pending"}


  def assign_to_user(user)
    update_attributes(assigned_to: user.id, status: STATUS[:assigned])
  end

  def open?
    self.status == STATUS[:open]
  end

  def assigned?
    self.status == STATUS[:assigned]
  end

  def qualified?
    self.status == STATUS[:qualified]
  end

  def mark_as_junk(user)
    update_attributes(status: STATUS[:junk], deleted_by: user.id)
  end

  def mark_as_qualified(user)
    update_attributes(status: STATUS[:qualified])
  end

  def mark_as_lost(lost_reason, comments, user)
    update_attributes(status: STATUS[:lost], deleted_reason: lost_reason, 
      notes: comments, deleted_by: user, updated_at: Time.zone.now)
  end

  # attr_accessible :customer_relationships_attributes
  def get_deleted_reason
    DELETED_REASON[deleted_reason.to_s]
  end

  def get_comment
    COMMENT[converted_comment.to_s]
  end
  
  def is_paid?
    payment_status?
  end

  def is_trial?
    converted_to_trial?
  end

  def self.get_activities(stage)
    @activities = {}
    if stage == 2
      ACTIVITY.each do |key, value|
        if key.to_i == 1 || key.to_i == 2 || key.to_i == 3 || key.to_i == 4 || key.to_i == 5 || key.to_i == 6 || key.to_i == 7
          @activities.store(key, value)
        end
      end
    elsif stage == 3
      ACTIVITY.each do |key, value|
        if key.to_i == 8 || key.to_i == 9 || key.to_i == 10 || key.to_i == 11 || key.to_i == 12 || key.to_i == 13 || key.to_i == 14 || key.to_i == 15 || key.to_i == 16 || key.to_i == 17
          @activities.store(key, value)
        end
      end
    else
      ACTIVITY.each do |key, value|
        if key.to_i == 18 || key.to_i == 19
          @activities.store(key, value)
        end
      end
    end
    @activities
  end

  def self.get_activity(index)
    ACTIVITY[index.to_s]
  end

  def self.get_status_id(index)
    string = index
    if /green|Green/i.match(string)
      value = "Green"
    elsif /red| Red/i.match(string)
      value = "Red"
    elsif /amber|Amber/i.match(string)
      value = "Amber"
    end
    STATUS.index(value.to_s)
  end

  def channel_name
    channel.channel_name if channel.present?
  end

  def assigned_to_name
    super_user.first_name if super_user.present?
  end

  def campaign_name
    campaign.campaign_name if campaign.present?
  end

  def get_status
    STATUS.key(self.status)
  end

  def get_lead_type
    if lead_type == 1
      "Individual client"
    elsif lead_type == 2
     "CAs"
    elsif lead_type == 3
      "Reseller"
    elsif lead_type == 4
      "Channel partner"
    elsif lead_type == 5
      "Others"
    end    
  end

  def update_next_call_date
    Lead.next_call_date = Lead.LeadActivity.next_followup
  end

  class << self

    def all_leads(search_param)
      if search_param.present?
        leads = where("name like :search or mobile like :search or email like :search or next_call_date like :search", :search => "%#{search_param}%")#.includes(:super_user)
      # elsif params[:sSearch_0].present? || params[:sSearch_1].present? || params[:sSearch_2].present? || params[:sSearch_3].present? || params[:sSearch_4].present? || params[:sSearch_5].present? || params[:sSearch_6].present?
      #   leads =  search_leads
      else
        leads = where(:deleted => false, :converted_to_trial => false).includes(:super_user, :channel)
      end
    end

    def open_leads(search_param)
      if search_param.present?
        where(:assigned_to => nil, status: STATUS[:open]).
          where("leads.name like :search or leads.mobile like :search or leads.email like :search or leads.next_call_date like :search",
          :search => "%#{search_param}%", :status => status_id)#.includes(:super_user)
      else
        where(:assigned_to => nil, status: STATUS[:open]).includes(:super_user)
      end
    end

    def qualified_leads(search_param)
      if search_param.present?
        where(:status => STATUS[:qualified]).
          where("name like :search or mobile like :search or email like :search or next_call_date like :search ",
          :search => "%#{search_param}%")#.includes(:super_user, :channel)
      else
        where(status: STATUS[:qualified]).includes(:super_user)
      end
    end

    def junk_leads(search_param)
      if search_param.present?
        where(status: STATUS[:junk]).
          where("leads.name like :search or leads.mobile like :search or leads.email like :search or leads.next_call_date like :search ",
          :search => "%#{search_param}%")#.includes(:super_user, :channel)
      else
        where(status: STATUS[:junk]).includes(:super_user)
      end
    end


    def won_leads(search_param)
      if search_param.present?
        where(status: STATUS[:won]).
          where("leads.name like :search or leads.mobile like :search or leads.email like :search or leads.next_call_date like :search",
          :search => "%#{search_param}%", :status => status_id)#.includes(:channel, :super_user)
      else
        where(status: STATUS[:won]).includes(:super_user)
      end
    end


    def lost_leads(search_param)
      if search_param.present?
        where(status: STATUS[:lost]).
          where("leads.name like :search or leads.mobile like :search or leads.email like :search or leads.next_call_date like :search",
          :search => "%#{search_param}%", :status => status_id)#.includes(:channel, :super_user)
      else
        where(status: STATUS[:lost]).includes(:super_user)
      end
    end

    def not_interested_leads(search_param)
      if search_param.present?
        status_id = get_status_id(search_param)
        where(:deleted => false, :converted_to_trial => false, :trial_status => 3)
          where("leads.name like :search or leads.mobile like :search or leads.email like :search or leads.next_call_date like :search or leads.status = :status ",
          :search => "%#{search_param}%", :status => status_id).includes(:super_user, :channel)
      else
        where(:deleted => false, :converted_to_trial => false, :trial_status => 3).includes(:super_user, :channel)
      end
    end

    def my_leads(user, search_param)
      if search_param.present?
        where(status: STATUS[:assigned]).where(" assigned_to = ? or created_by = ?", user.id, user.id).
          where("leads.name like :search or leads.mobile like :search or leads.email like :search or leads.next_call_date like :search or leads.status = :status ",
          :search => "%#{search_param}%")#.includes(:super_user, :channel)
      else
        where(status: [STATUS[:assigned], STATUS[:qualified]]).where(" assigned_to = ? or created_by = ?", user.id, user.id).includes(:super_user, :channel)
      end
    end

    #shows leads on which sales guys have not even done any activity
    def no_activity_leads
      self.activites.where(:activity_status => true).count
    end

    def create_lead_information(company)
      leads = Lead.where(:email => company.email)
      if leads.count == 0
        new_lead = Lead.create(:name => company.users.first.full_name, :mobile => company.phone, :email => company.users.first.email, 
          :next_call_date => Time.zone.now.to_date+1.days, :organisation_name => company.name, :stage => 2, status: STATUS[:open])
        LeadActivity.create_lead_activities_for_trial(new_lead.id)
        LeadCompany.create(:lead_id => new_lead.id, :company_id => company.id)
      elsif leads.count == 1
        leads.first.update_attributes(:name => company.users.first.full_name,:email => company.users.first.email, 
          :next_call_date => Time.zone.now.to_date+1.days, :organisation_name => company.name, :stage => 2, status: STATUS[:open])
        LeadActivity.create_lead_activities_for_trial(leads.first.id)
        LeadCompany.create(:lead_id => leads.first.id,:company_id => company.id)
      end
    end

    def get_users
      users = []
      SuperUser.all.each do |usr|
        users<<user.id
      end
      users
    end

    def monthly_leads(params)
      lead_arr=[]
      month_begin = Company.financial_start_date(params)
      end_date = Company.financial_end_date(params)
      while month_begin <= end_date.beginning_of_month.to_date
        leads = Lead.where(:payment_status => 0, :created_at => month_begin..month_begin.end_of_month)
        lead_arr<<leads.count
        month_begin = month_begin + 1.month
        end
      lead_arr
    end

    def never_contacted_leads
     leads = Lead.where('deleted = ? and id NOT IN (SELECT DISTINCT(lead_id) FROM lead_activities)',false)
    end

    def get_lead_activities(params)
      start_date = params[:start_date].blank? ? Time.zone.now.to_date : params[:start_date]
      end_date = params[:end_date].blank? ? Time.zone.now.to_date : params[:end_date]
      activity_status = params[:activity_status].blank? ? true : params[:activity_status]
      if params[:super_user].present?
        @lead_activities = Lead.joins(:lead_activities).where("leads.deleted = ? and leads.assigned_to = ?",false, params[:super_user]).where("lead_activities.activity_status = ? and lead_activities.next_followup BETWEEN ? AND ? ", activity_status, start_date.to_date, end_date.to_date).group(:lead_id)
      else  
        @lead_activities = Lead.joins(:lead_activities).where("leads.deleted = ?",false).where("lead_activities.activity_status = ? and lead_activities.next_followup BETWEEN ? AND ? ", activity_status, start_date.to_date, end_date.to_date).group(:lead_id)
      end
    end

    def get_channel_summary(params)
      if params[:month].blank?
        start_date = Time.zone.now.beginning_of_month.to_date
        end_date = Time.zone.now.to_date
      else
        start_date = Date.parse(params[:month]).to_date
        end_date = start_date.end_of_month.to_date
      end
      if params[:channel].present?
        leads = Lead.where(:deleted => false,:channel_id => params[:channel],:created_at => start_date..end_date)
      else
        leads = Lead.where(:deleted => false,:created_at => start_date..end_date)
      end
      leads
    end

    def find_activity(lead,start_date,end_date)
      lead_activities = LeadActivity.where(:lead_id => lead)
      @activity = []
      lead_activities.each do |lead|
        unless lead.next_followup.blank?
          if lead.next_followup >= start_date.to_date && lead.next_followup <= end_date.to_date
            @activity << lead
          end
        end
      end
      @activity
    end

    def find_lead_followups(params)
      start_date = params[:start_date].blank? ? Time.zone.now.to_date : params[:start_date]
      end_date = params[:end_date].blank? ? Time.zone.now.to_date : params[:end_date]
      if params[:super_user].present?
        @leads = Lead.joins(:lead_activities).where("leads.deleted = ? and leads.assigned_to = ?",false, params[:super_user]).where("lead_activities.next_followup BETWEEN ? AND ? ", start_date.to_date, end_date.to_date).group(:lead_id)
      else  
        @leads = Lead.joins(:lead_activities).where("leads.deleted = ?",false).where("lead_activities.next_followup BETWEEN ? AND ? ", start_date.to_date, end_date.to_date).group(:lead_id)
      end
      @leads.each do |lead|
        @activities = {}
        lead.lead_activities.each do |lead_activity|
          unless lead_activity.time_spent.blank?
            # if lead_activity.next_followup >= start_date.to_date && lead_activity.next_followup <= end_date.to_date
            if @activities.has_key?("#{lead_activity.activity}")
              @activities["#{lead_activity.activity}"] += lead_activity.time_spent
            else
              @activities["#{lead_activity.activity}"] = lead_activity.time_spent
            end
          end
        end
      end
      @activity
    end
    
    def find_next_contact_date(lead)
      lead_activities = LeadActivity.where(:lead_id => lead)
      lead_activities.each do |lead|
        if lead.next_followup.present? && lead.next_followup = Time.zone.now.to_date
          @next_contact_date = lead.next_followup.strftime("%d-%m-%Y")
          break
        end
      end
      @next_contact_date
    end

    def find_next_activity(lead)
      lead_activities = LeadActivity.where(:lead_id => lead)
      lead_activities.each do |lead|
        if lead.next_activity.present? && lead.next_followup >= Time.zone.now.to_date
          @next_activity = lead.next_activity
          break
        end
      end
      @next_activity
    end

    def find_activity_status(lead)
      lead_activities = LeadActivity.where(:lead_id => lead)
      lead_activities.each do |lead|
        if lead.next_activity.present? && lead.next_followup >= Time.zone.now.to_date
          @activity_status = lead.activity_status
          break
        end
      end
      @activity_status
    end

    def get_activity_record(params)
      activity = params[:activity].blank? ? ACTIVITY.keys : params[:activity]
      created_by = params[:created_by]
      lead_activity = LeadActivity.first
      start_date = params[:start_date].blank? ? (LeadActivity.all.blank? ? Time.zone.now.to_date : (LeadActivity.order("record_date ASC").first.record_date.blank? ? LeadActivity.order("record_date ASC").first.created_at : LeadActivity.order("record_date ASC").first.record_date) ) : params[:start_date].to_date
      end_date = params[:end_date].blank? ? Time.zone.now.to_date : params[:end_date].to_date
      if created_by.blank?
        lead_activities = LeadActivity.where(:activity => activity, :record_date => (start_date - 1.days)..end_date).page(params[:page]).per(20) 
      else
        leads = Lead.where(:created_by => created_by.to_i)
        lead_ids = []
        leads.each do |lead|
          lead_ids<<lead.id
        end
        lead_activities = LeadActivity.where(:lead_id => lead_ids, :activity => activity, :record_date => (start_date - 1.days)..end_date).page(params[:page]).per(20) 
      end
      lead_activities
    end

    def get_lead_record(params)
      lead_type = params[:lead_type]
      status = params[:status].blank? ? [0,1,2] : params[:status]
      start_date = params[:start_date].blank? ? (Lead.all.blank? ? Time.zone.now.to_date : (Lead.order("created_at ASC").first.created_at.to_date )) : params[:start_date].to_date
      end_date = params[:end_date].blank? ? Time.zone.now.to_date : params[:end_date]

      if lead_type.present?
        leads = Lead.where(:lead_type => lead_type, :status => status, :created_at => start_date.to_date-1..end_date.to_date+1).order("created_at DESC").page(params[:page]).per(20) 
      else
        leads =Lead.where(:status => status, :created_at => start_date.to_date-1..end_date.to_date+1).order("created_at DESC").page(params[:page]).per(20)
      end
      leads
    end

    def todays_leads
      Lead.includes(:lead_activities).where("lead_activities.next_followup" => Time.zone.now.to_date)
    end

    def pending_leads(params)
      start_date = params[:start_date].blank? ? (Lead.all.blank? ? Time.zone.now.to_date : (Lead.order("created_at ASC").first.created_at.to_date )) : params[:start_date].to_date
      end_date = params[:end_date].blank? ? LeadActivity.maximum(:next_followup) : params[:end_date].to_date
      leads = Lead.includes(:lead_activities).where("lead_activities.lead_activity" => false,"lead_activities.next_followup" => start_date.to_date-1..end_date.to_date)
    end

    def paid_leads
      Lead.where(:payment_status => true , :deleted => false).order("created_at DESC")
    end

    def unpaid_leads
      Lead.where("(payment_status=? or payment_status is ?) and deleted=? ", false, nil, false).order("created_at DESC")
    end


    def schedule_activity(lead,params)
      if lead.update_attributes(params)
        if lead.lead_activities.last.activity_status == true
          lead.lead_activities.last.update_attributes(:completed_date => Time.zone.now.to_date) 
        end
        return true
      else
        return false
      end
    end

  end #private end
end
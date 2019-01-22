class Timesheet < ActiveRecord::Base
  belongs_to :company
  belongs_to :user
  has_many :timesheet_line_items, :dependent => :destroy
  accepts_nested_attributes_for :timesheet_line_items, :reject_if => lambda {|a| a[:task_id].blank? && a[:timestamp].blank? }, :allow_destroy => true
  
  attr_accessible :start_date,:end_date, :record_date, :timesheet_line_items_attributes
  
  #validations
  validates_presence_of :record_date, :start_date, :end_date
  validates_presence_of :timesheet_line_items, :allow_blank => true, :message => "timestamp can't be blank"
  validates_associated :timesheet_line_items, :message => "fields with * are mandatory"
  # validate :validate_record_date
  validate :timesheet_date
  validate :timestamp_value
  validate :total_timestamp

  def time_spent_on_project(project_id)
    project=Project.find_by_id project_id
    tasks = project.tasks
    timesheet_line_items.where(:task_id=> tasks.map { |task| id  }).sum(:timestamp)
  end

  def total_timestamp
    date_hash = {}    
    timesheet_line_items.each do |line_item|
      if date_hash[line_item.day].present?
        date_hash[line_item.day] = date_hash[line_item.day].to_f + line_item.timestamp unless line_item.timestamp.blank?
        errors.add(:base, "Hours should not be greater than 24 hours in same day") if date_hash[line_item.day].to_f > 24
      else
        date_hash[line_item.day] = line_item.timestamp
        errors.add(:base, "Hours should not be greater than 24 hours in same day") if date_hash[line_item.day].to_f > 24
      end
    end
  end

  def curresponding_timestamp(date)
    line = TimesheetLineItem.where(:day => date).first
    line.timestamp unless line.blank?
  end
  def timesheet_date
    self.timesheet_line_items.each do |line_item|
    if line_item.day < start_date || line_item.day > end_date   
    errors.add(:base, "Timesheet day must be in selected week")
   end
 end
 end
 def timestamp_value
    self.timesheet_line_items.each do |line_item|
    if !line_item.timestamp.blank? && line_item.timestamp > 24 
    errors.add(:base, "Hours should not be greater than 24 hours")
   end
 end
 end

  def total_time
    time_total = self.timesheet_line_items.sum(:timestamp)
    total = time_total
    total	
  end  
 
 def validate_record_date
   week = params[:date].to_date
   if !record_date.blank? && (record_date < week.beginning_of_week || record_date > week.end_of_week)
    errors.add(:base, "must be in current week")
  end
 end

 class << self
  def create_weekly_timesheet(params, company, user)
    timesheet = Timesheet.new(params[:timesheet])
    timesheet.record_date = Time.zone.now.to_date
    timesheet.company_id = company.id
    timesheet.user_id = user.id
    if true
      7.times do |i|
        unless params["timestamp_#{i}"].blank? || params[:task_id].blank?
          timesheet_line_item = TimesheetLineItem.new(:task_id => params[:task_id].to_i,
            :timestamp => params["timestamp_#{i}"], :day => params["day_#{i}"])
          timesheet.timesheet_line_items << timesheet_line_item
        end
      end
    else

    end
    timesheet
  end
   def new_timesheet
    timesheet = Timesheet.new
    timesheet.timesheet_line_items.build
    timesheet
   end
  def create_timesheet(params, company, user)
     timesheet = Timesheet.new(params[:timesheet])
     timesheet.record_date = Time.zone.now.to_date
     timesheet.company_id = company.id
     timesheet.user_id = user.id
     timesheet
  end
   # def update_timesheet(params, company, user)
   #   timesheet = Timesheet.find(params[:id])
   #   timesheet.start_date = timesheet.record_date.beginning_of_week
   #   timesheet.end_date = timesheet.record_date.end_of_week
   #   timesheet
   # end
  def get_task_record(task)
    task = Task.find(task)
  end
  def get_assigned_to_name(assigned_to)
    user_name = User.find(assigned_to).full_name
  end
  # def get_project(task)
  #   task = Task.find(task)
  #   project = Project.find(task.project_id).name unless task.project_id.blank?
  # end
  def get_timesheet_record(params,company,current_financial_year)
    assigned_to = params[:name]
    start_date = params[:start_date].blank? ? current_financial_year.start_date.to_date : params[:start_date]
    end_date = params[:end_date].blank? ? Time.zone.now : params[:end_date]
    # completed_start_date = params[:completed_start_date].blank? ? current_financial_year.start_date.to_date : params[:completed_start_date]
    # completed_end_date = params[:completed_end_date].blank? ? Time.zone.now : params[:completed_end_date]
    timesheets = Timesheet.where(:company_id => company.id)
    timesheet_ids = []
    timesheets.each do |timesheet|
      timesheet_ids << timesheet.id                                                                                                     
    end
    if !assigned_to.blank?
      tasks = Task.joins(:timesheet_line_items).where("timesheet_line_items.timesheet_id in (?) and tasks.task_status = ? and tasks.assigned_to = ? and tasks.created_at BETWEEN ? AND ?",timesheet_ids,true,assigned_to,start_date.to_date,end_date.to_date+1.days).group("tasks.id")
    else
      tasks = Task.joins(:timesheet_line_items).where("tasks.task_status = ? and timesheet_line_items.timesheet_id in(?) and tasks.created_at BETWEEN ? AND ?",true, timesheet_ids,start_date.to_date,end_date.to_date+1.days).group("tasks.id")
    end
  end
   def get
   end
 end

end

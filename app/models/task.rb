class Task < ActiveRecord::Base
  paginates_per 20
  scope :by_description, lambda{|description| where("description like ?", "%#{description}%") unless description.blank?}
  scope :by_project, lambda{|project| where(:project_id=>project) unless project.blank? }
  scope :by_priority, lambda{|priority| where(:priority=>priority) unless priority.blank? }
  scope :by_date_range, lambda{|start_date, end_date| where(:due_date=> start_date..end_date) unless start_date.blank? || end_date.blank? }

  belongs_to :project
  belongs_to :user
  belongs_to :company
  has_many :timesheet_line_items
  #validation start
  
  validates_presence_of :description, :due_date, :assigned_to
  validates_length_of :description, :maximum =>500
  
  validate :due_date_validation, :on=>:create

  PRIORITIES = { "1" => "High", "2" => "Normal", "3" => "Low" }
  def curresponding_timestamp(date)
    lines = TimesheetLineItem.where(:day => date, :task_id => id)
    lines.sum(:timestamp) unless lines.blank?
  end
  def timesheet_for_this_week(dates)
    task_timesheets = Timesheet.includes("timesheet_line_items").where("timesheet_line_items.task_id" => id, :start_date => dates[0], :end_date => dates[6])
    !task_timesheets.blank?
  end
  def due_date_validation
    if(!due_date.nil? && due_date < Time.zone.now.to_date)
      errors.add(:due_date, "should greter than or equal to today's date")
    end
  end

  def priority_name=(name)
      self.priority = PRIORITIES.index(name)
  end

  def priority_name
    PRIORITIES[self.priority.to_s]
  end  

  def project_name
    Project.find(project_id).name
  end

 
  class << self
    #create task method
    def create_task(params, company, user)
      task = Task.new(params[:task])
      task.company_id = company.id
      task.user_id = user.id
      task.created_by = user.id
      # task.project_id = Project.get_project_id(params[:project_id], company)
      task.assigned_to = user.id unless !company.plan.free_plan?
      task.task_status = 0
      task
    end

    def last_two
      Task.where(:task_status => 0).limit(2).order(" due_date DESC")
    end
    def today(user,company)
      Task.where(:company_id => company, :due_date => Time.zone.now.to_date, :task_status => 0, :assigned_to => user).limit(2).order("due_date ASC")
    end
    def this_week(user,company)
      Task.where("due_date between ? and ?",  Time.zone.now.to_date.beginning_of_week, Time.zone.now.to_date.end_of_week).where(:task_status => "0",:assigned_to => user, :company_id => company ).limit(2).order("due_date ASC")
    end
    def this_month(user, company)
      Task.where("due_date between ? and ?", Time.zone.now.to_date.beginning_of_month, Time.zone.now.to_date.end_of_month).where(:task_status => "0").order("due_date ASC")
    end
    def closed
      Task.where(:task_status=>"1").order("due_date ASC","priority ASC")
    end
    def open_task
     Task.where(:task_status => "o")
    end
    def closed_task
     Task.where(:task_status => "1")
    end
    def user_tasks(user_id, company_id)
      self.where("company_id=? and (created_by=? or assigned_to = ?)", company_id, user_id, user_id)
    end
  end
  
  def get_total_timestamp(task)
    lines = TimesheetLineItem.where(:task_id => task)
    lines.sum(:timestamp) unless lines.blank?
  end

  def get_project(task)
    task = Task.find(task)
    project = Project.find(task.project_id).name unless task.project_id.blank?
  end

  def assigned_user
    User.find(assigned_to).full_name
  end
  def created_by_user
    User.find(created_by).full_name
  end
  def register_user_action(remote_ip, action, branch_id)
     Workstream.register_user_action(company_id, created_by, remote_ip,
         "Task #{description} for due date #{due_date} #{action}", action, branch_id)
  end
    #method to mark the project complete
  def complete_task(user)
    result = false
    transaction do 
      if task_status == 0 
        update_attributes(:user_id => user, :task_status => 1, :completed_date => Time.zone.now.to_date)
        result = true
      else 
        update_attributes(:user_id => user, :task_status => 0)
        result = true
      end 
    end
    result
  end

end

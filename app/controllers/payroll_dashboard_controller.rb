class PayrollDashboardController < ApplicationController
  layout "payroll"

  def index
    @users = @company.users
    @tasks = @company.tasks.where("assigned_to = ? and task_status = 0 ", @current_user.id)
    @holidays = @company.holidays.find(:all, :conditions => ["holiday_date >= ?", Date.today], :limit => 5)
    @announcements = @company.organisation_announcements.find(:all, :conditions => ["created_at >= ?", Date.today], :limit => 5)
#    @employee_goals = @current_user.employee_goals.find(:all, :conditions => [""])
  #@notifications = @current_user.notifications
   @workstreams = Workstream.recent_five(@company, @user)
  end

end

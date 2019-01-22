class TimesheetLineItem < ActiveRecord::Base
 belongs_to :timesheet
 belongs_to :task
 validates_presence_of :task_id, :timestamp

 
end

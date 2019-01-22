class Recursion < ActiveRecord::Base
  belongs_to :recursive, :polymorphic => true
  has_many :recursive_invoices, :dependent => :destroy
  validate :check_schedule_date, :if => lambda{|e| e.status == true }, :on=>:create

  def change_frequency_and_create_invoice(view_context, financial_year)
  	if schedule_on.to_date == Time.zone.now.to_date
			Invoice.new_recursive_invoice(recursive, view_context, financial_year)
			update_attributes(:utilized_iteration => 1)
  	else 
  		update_attributes(:utilized_iteration => 0)
  	end
  end
  FREQUENCY = {'1' => 'Daily', '2' => 'Weekly', '3' => 'Monthly', '4' => 'Quarterly', '5' => 'Half yearly', '6' => 'Yearly'}
  
  def check_schedule_date
  	if !schedule_on.blank? && schedule_on < Time.zone.now.to_date
  		errors.add(:schedule_on, "must be today or greater")
  	end
  end

  def get_status
  	if status?
  		"Active"
  	else
  		"Inactive"
  	end
  end
  def get_frequency
		FREQUENCY[frequency.to_s]
  end

  def get_upcoming_schedule
  	date = schedule_on
		pre_iterations = utilized_iteration.blank? ? 0 : utilized_iteration
  	case frequency
  	when 1
  		date = date + pre_iterations.days
  	when 2
  		date = date + pre_iterations.weeks
  	when 3
  		date = date + pre_iterations.months
  	when 4
  		date = date + pre_iterations.months
  	when 5
  		date = date + pre_iterations.months
  	when 6
  		date = date + pre_iterations.years
  	end
  	date
  end
end

class ProcessPayroll < ActiveRecord::Base
 belongs_to :company
 belongs_to :user
 validates_presence_of :user_id, :company_id, :month, :attendance
 validate :current_month_entry


  def months()
    months={
       '1'=> 'January',
       '2'=> 'February',
       '3'=> 'March',
       '4'=> 'April',
       '5'=> 'May',
       '6'=> 'June',
       '7'=> 'July',
       '8'=> 'August',
       '9'=> 'September',
       '10'=> 'October',
       '11'=> 'November',
       '12' => 'December'
      }
  end

  def self.get_month(month)
    months={
       '1'=> 'January',
       '2'=> 'February',
       '3'=> 'March',
       '4'=> 'April',
       '5'=> 'May',
       '6'=> 'June',
       '7'=> 'July',
       '8'=> 'August',
       '9'=> 'September',
       '10'=> 'October',
       '11'=> 'November',
       '12' => 'December'
      }
   months[month]
 end

 def current_month_entry
   process_payroll = ProcessPayroll.find_by_company_id_and_user_id_and_month(company_id, user_id, month)
   if !process_payroll.blank?
      errors[:base] << "Payroll for this month has been already processed."
    end
 end

 def status
   process_payroll = ProcessPayroll.find_by_company_id_and_user_id_and_month(company_id, user_id, month)
  if !process_payroll.blank?
   "Processed"
  else
   "Pending"
  end
 end
 def self.get_status(company_id, month, fy)
  process_payroll = ProcessPayroll.where(:company_id=> company_id, :month => month, :created_at=> fy.start_date..fy.end_date)
  if !process_payroll.blank?
   "Processed"
  else
   "Pending"
  end
 end
end

class PayrollDetail < ActiveRecord::Base
belongs_to :company
has_one :payroll_execution_job
validates_presence_of :company_id, :month, :status


def get_payroll_execution_job
  if payroll_execution_job.blank?
    PayrollExecutionJob.find_by_company_id_and_execution_date_and_status(company_id, updated_at.to_date, 1)
  else
    payroll_execution_job
  end
end
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

 class << self
 
  def get_month(month)
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
   months[month.to_s] unless month.blank?
 end

 def payroll_month(month)
   get_month(month+1)
 end

 def get_status(company_id, month, fy)
  month = current_month(month)
  payroll_detail = PayrollDetail.find_by_company_id_and_month(company_id, month.beginning_of_month..month)
   if payroll_detail.blank?
      "Not processed yet"
   elsif payroll_detail.status==0
      "Pending"
   elsif payroll_detail.status == 1
      "Under process"
   elsif payroll_detail.status == 3
      "Error : Please contact support!"
   else 
      "Processed on #{get_payroll_date(company_id, month, fy)}"
   end
 end
 
 def get_payroll_date(company_id, month, fy)
  payroll_detail = PayrollDetail.find_by_company_id_and_month_and_status(company_id, month.beginning_of_month..month, 2)
   if !payroll_detail.blank?
    payroll_detail.updated_at.to_date
   end

 end
 

 def create_record(company, user, month)
    payroll_detail = PayrollDetail.new
    payroll_detail.company_id = company.id
    payroll_detail.created_by = user.id
    payroll_detail.month = month
    payroll_detail.save
 end

  private 
  def current_month(month)
    if month.blank?
      month = Time.zone.now.to_date.end_of_month
    else
      month=month.to_i
      year = (month>Time.zone.now.month) ? (Time.zone.now.year-1) : Time.zone.now.year
      month = Date.new(year, month, 1).end_of_month
    end    
  end
end
  

end

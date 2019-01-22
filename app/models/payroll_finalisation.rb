#This is a Sidekiq worker added for finalizing Payroll and return the results to table salaries and updates 
#the status in salary_computation_results
#Author: Ashish Wadekar
#Date: 12th October 2016 

class PayrollFinalisation
  include Sidekiq::Worker
  
  def perform(month, company_id)
    year = (month.to_i>Time.zone.now.month) ? (Time.zone.now.year-1) : Time.zone.now.year
    month = Date.new(year, month.to_i, 1)
    logger.debug ">>>>>>>>>Now finalizing salaries<<<<<<<<<<"
    #Fetching salaries from SalaryComputationResultTable and Posting them to Salary Table and creating ledger entries
    salaries = SalaryComputationResult.where(:company_id => company_id, :month => month.beginning_of_month..month.end_of_month)

    begin
      ActiveRecord::Base.transaction do
      	salaries.each do |salary|
      	  post_salary = Salary.create!(:company_id=>salary.company_id, :user_id=> salary.user_id, :attendance_id=>salary.attendance_id, :payhead_id=>salary.payhead_id, :amount=>salary.amount, :month=>salary.month)
      	  post_salary.create_ledger_entry(salary.processed_by, salary.account_id)
      	  salary.update_attribute(:status, 1)
      	end
        #Updating the status of PayrollDetail and PayrollExecutionJob according to finalisation
        PayrollDetail.find(salaries.first.payroll_detail_id).update_attribute(:status, 2)
        PayrollExecutionJob.find(salaries.first.payroll_execution_job_id).update_attribute(:status, 1)
      end
    rescue Exception => e
        PayrollDetail.where(:company_id => company_id, :month => payroll_execution_jobs.month.start_of_month..payroll_execution_jobs.month.start_of_month).update_attribute(:status, 3)
        ErrorMailer.experror(e, user_id).deliver
    end
  end
end

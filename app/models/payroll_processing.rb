#This is a Sidekiq worker added for processing Payroll and return the results to table salary_computation_result
#Author: Ashish Wadekar
#Date: 4th October 2016 

class PayrollProcessing
  include Sidekiq::Worker
  
  def perform(user_id, company_id)
    puts ">>>>>>>>>>>>>>>>>>>>>>>>Performing Payroll Processing (For User : #{user_id} Company: #{company_id} Execution Date : #{Time.zone.now.to_date}<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
    payroll_execution_jobs = PayrollExecutionJob.where(:company_id => company_id, :execution_date=> Time.zone.now.to_date, :status=>false)
    payroll_execution_jobs.each do |payroll_execution_job|
      begin
        ActiveRecord::Base.transaction do
          payroll_detail = payroll_execution_job.payroll_detail
          company = payroll_execution_job.company
          month = payroll_detail.month
          users = company.users.this_month_processable(month)
          puts ">>>>>>>>>>>>>>>>>>>>>>> Deleting Old records from SalaryComputationResult table<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
          SalaryComputationResult.where(:company_id => company_id, :month => month.beginning_of_month..month.end_of_month, :status => 0).delete_all
          puts ">>>>>>>>>>>>>>>>>>>>>>>>>>> Users: #{users.inspect} <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
          users.each do |user|
            salary_structure = SalaryStructure.current_salary_structure(company.id, user.id, month.month)
            if !salary_structure.blank?
              attendance = Attendance.where("company_id=? and user_id=? and month between ? and ?", company.id, user.id, month.beginning_of_month, month.end_of_month).first
              if !attendance.blank?
                variable_payhead_details = user.variable_payhead_details.where(:month=>month.beginning_of_month..month.end_of_month)

                salary_structure.salary_structure_line_items.each do |line_item|
                  # create salary here(calculte leaves)
                  amount = line_item.calculate_salary_for_this_month(attendance)
                  #TODO change the date posted in month attribute as the first date of month for which payroll is being run
                  puts ">>>>>>>>>>>>>>>> #{month} - #{month.class} <<<<<<<<<<<<<<<<<<<<<<<<<<<<"
                  salary = SalaryComputationResult.create!(:company_id=>company.id, :user_id=> user.id, :attendance_id=>attendance.id, :payhead_id=>line_item.payhead_id, :amount=>amount, :month=>month.end_of_month, :processed_by => salary_structure.created_by, :status => 0, :account_id => payroll_execution_job.account_id, :payroll_execution_job_id => payroll_execution_job.id, :payroll_detail_id => payroll_execution_job.payroll_detail_id)
                end

                variable_payhead_details.each do |variable_payhead|
                  # create salary here(calculte leaves)
                  #TODO change the date posted in month attribute as the first date of month for which payroll is being run
                  salary = SalaryComputationResult.create!(:company_id=>company.id, :user_id=> user.id, :attendance_id=>attendance.id, :payhead_id=>variable_payhead.payhead_id, :amount=>variable_payhead.amount, :month=>month.end_of_month, :processed_by => salary_structure.created_by, :status => 0, :account_id => payroll_execution_job.account_id, :payroll_execution_job_id => payroll_execution_job.id, :payroll_detail_id => payroll_execution_job.payroll_detail_id)
                end
              end
            end
          end
        end
      rescue Exception => e
        PayrollDetail.where(:company_id => company_id, :month => payroll_execution_jobs.month.start_of_month..payroll_execution_jobs.month.start_of_month).update_attribute(:status, 3)
        ErrorMailer.experror(e, user_id).deliver
      end  
    end
  end
end

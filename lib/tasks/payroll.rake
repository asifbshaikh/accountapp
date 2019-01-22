namespace  :payroll do
  task :process => :environment do
    payroll_execution_jobs = PayrollExecutionJob.where(:execution_date=> Time.zone.now.to_date, :status=>false)
    fail_companies=[]
    unprocessed_users = []
    attendance_not_taken_users=[]
    payroll_execution_jobs.each do |payroll_execution_job|
      begin
        ActiveRecord::Base.transaction do
          payroll_detail = payroll_execution_job.payroll_detail
          company = payroll_execution_job.company
          month = payroll_detail.month
          users = company.users.this_month_processable(month)
          users.each do |user|
            salary_structure = SalaryStructure.current_salary_structure(company.id, user.id, month.month)
            if !salary_structure.blank?
              attendance = Attendance.where("company_id=? and user_id=? and month between ? and ?", company.id, user.id, month.beginning_of_month, month.end_of_month).first
              if !attendance.blank?
                variable_payhead_details = user.variable_payhead_details.where(:month=>month.beginning_of_month..month.end_of_month)

                salary_structure.salary_structure_line_items.each do |line_item|
                  # create salary here(calculte leaves)
                  amount = line_item.calculate_salary_for_this_month(attendance)
                  salary = Salary.create!(:company_id=>company.id, :user_id=> user.id, :attendance_id=>attendance.id,
                    :payhead_id=>line_item.payhead_id, :amount=>amount, :month=>month)
                  # create ledger entry
                  salary.create_ledger_entry(salary_structure.created_by, payroll_execution_job.account_id)
                end

                variable_payhead_details.each do |variable_payhead|
                  # create salary here(calculte leaves)
                  salary = Salary.create!(:company_id=>company.id, :user_id=> user.id, :attendance_id=>attendance.id,
                    :payhead_id=>variable_payhead.payhead_id, :amount=>variable_payhead.amount, :month=>month)
                  # create ledger entry
                  salary.create_ledger_entry(salary_structure.created_by, payroll_execution_job.account_id)
                end
              else
                attendance_not_taken_users<<user
              end
            else
              unprocessed_users<<user
            end
          end
          payroll_detail.update_attribute(:status, 2)
          payroll_execution_job.update_attribute(:status, 1)
          user = company.users.first
          Email.payroll_processed(user, company).deliver
          puts"****** Salary structure processed for #{user.full_name} from company = #{company.name}(#{company.id})"
        end
      rescue Exception => e
        user = payroll_execution_job.company.users.first
        fail_companies<<payroll_execution_job.company
        ErrorMailer.experror(e, user).deliver
      end
    end
    unless payroll_execution_jobs.blank?
      Email.payroll_history(payroll_execution_jobs, fail_companies, unprocessed_users, attendance_not_taken_users).deliver
    end
  end

  # desc "changing payroll_execution_job"
  # task :update_execution_date => :environment do
  #   payroll_details = PayrollDetail.where(:status=>2)
  #   payroll_details.each do |pd|
  #     pej = PayrollExecutionJob.where(:status=>true, :company_id=>pd.company_id, :execution_date=>pd.updated_at.to_date).first
  #     unless pej.blank?
  #       pej.update_attributes!(:execution_date=>Time.zone.now.to_date, :status=>false, :payroll_detail_id=>pd.id)
  #       pd.update_attribute("status", 1)
  #     end
  #   end
  # end

  task :remove_unwanted => :environment do
    salaries=Salary.where(:company_id=>1597).offset(3)
    salaries.each do |salary|
      salary.destroy
    end
  end
end

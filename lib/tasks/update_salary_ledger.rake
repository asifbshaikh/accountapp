namespace :update_salary_ledger do

  task :create_ledger => :environment do
    @companies = Company.all
    @companies.each do |company|

      if company.plan.payroll_enabled?
        ActiveRecord::Base.transaction do

          @ledgers = Ledger.where(:voucher_type => "SalaryVoucher", :company_id => company.id)
          # update ledger 
          @ledgers.update_all(:deleted_by => company.users.first.id, :deleted => true, :deleted_datetime => Time.zone.now, :deleted_reason => "Kept for future reference")
          puts"@@@ #{@ledgers.count} record in ledger table marked as deleted"
          # creating  new ledger records
          @payroll_execution_job = PayrollExecutionJob.find_by_company_id_and_status(company.id, 1)
          @payroll_detail = PayrollDetail.find_by_company_id_and_status(company.id, 2)
          if !@payroll_execution_job.blank? && !@payroll_detail.blank?
            payheads = company.payheads
            puts"@@@ total payheads = #{payheads.count} in #{company.name} company"
            payheads.each do |payhead|

              @to_account = payhead.account_id
              salaries = Salary.where(:month=> @payroll_detail.month, :payhead_id => payhead.id, :company_id => company.id)
              branch_id = User.find(@payroll_detail.created_by).branch_id 

              save_result = false
              if !salaries.blank?
                salaries.each do |salary|
                  debit_ledger_entry = Ledger.new_debit_ledger(@to_account, company.id, salary.month,
                  salary.amount, "SLR"+Time.now.to_i.to_s, @payroll_detail.created_by, "created after payroll process", branch_id)

                  credit_ledger_entry = Ledger.new_credit_ledger(@payroll_execution_job.account_id, company.id, salary.month,
                  salary.amount, "SLR"+Time.now.to_i.to_s, @payroll_detail.created_by, "created after payroll process", branch_id)

                  #build and save relationship between invoice and ledgers
                  salary.ledgers << debit_ledger_entry
                  salary.ledgers << credit_ledger_entry

                  save_result = true
                end
                save_result
              end 
            end
          end 
        end
      end
    end
  end
end 
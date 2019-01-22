#This is a rake task added for hard delete finalised Payroll from salaries table, ledgers table &
#salary_computation_results, payhead_details, attendances
#Author: Ashish Wadekar
#Date: 7th December 2016

#Usage : rake payroll:hardreset[month, company_id]
#Usage : rake payroll:hardreset[9, 6941]
#Usage on production $ bundle exec rake 'payroll:hardreset[12, 6652]' RAILS_ENV=production

namespace  :payroll do
  desc 'This hard deletes the processed Payroll getting arguments as [month, company_id]'
  task :hardreset, [:month, :company_id] => [:environment] do |t, args|
    payroll_month = args[:month]
    company_id = args[:company_id]

    year = (payroll_month.to_i > Time.zone.now.month) ? (Time.zone.now.year - 1) : Time.zone.now.year
    month = Date.new(year, payroll_month.to_i, 1)



    begin
      ActiveRecord::Base.transaction do
        #Deleting Salaries from Salary Table
        Salary.where(:company_id => company_id, :month => month.beginning_of_month..month.end_of_month).delete_all

        #Deleting Salaries ledger entries
        salaries_computation_results_table = SalaryComputationResult.where(:company_id => company_id, :month => month.beginning_of_month..month.end_of_month)
        puts "#{salaries_computation_results_table.first.updated_at}"
        processing_start = salaries_computation_results_table.first.updated_at - 3.minutes
        processing_end = salaries_computation_results_table.last.updated_at + 3.minutes
        salaries_ledger = Ledger.where(:company_id => company_id, :description => "created after payroll process", :created_at => processing_start..processing_end).delete_all

        #Deleting Attendances records
        Attendance.where(:company_id => company_id, :month => month).delete_all

        #Deleting Payroll Execution Job
        payroll_details_id = PayrollDetail.where(:company_id => company_id, :month => month).select(:id).map(&:id)
        payroll_details_id.each do |id|
          PayrollExecutionJob.where(:company_id => company_id, :payroll_detail_id => id).delete_all
        end

        #Deleting Payroll Details
        PayrollDetail.where(:company_id => company_id, :month => month).delete_all

        #Deleting the Variable Payhead Details
        VariablePayheadDetail.where(:company_id => company_id, :month => month).delete_all

        # Deleting Salary Computation Result Table entries
        SalaryComputationResult.where(:company_id => company_id, :month => month.to_s.to_date.end_of_month).delete_all

        puts "Completed Payroll Hard Reset for Company ID :#{company_id} for the month of #{month}"
      end
    rescue Exception => e
      puts "Payroll Hard Reset Error : There was some error while performing hard reset of the Payroll. Here are the details : #{e}"
    end
  end
end

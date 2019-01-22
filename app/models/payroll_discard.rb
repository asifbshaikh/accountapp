#This is a Sidekiq worker added to delete calculated but unfinalised Payroll
#Author: Ashish Wadekar
#Date: 12th October 2016 

class PayrollDiscard 
	include Sidekiq::Worker

	def perform(company_id, month)
		puts ">>>>>>>>>>>> Company ID => #{company_id} Month => #{month} <<<<<<<<<<<<<<<<<"
		#Deleting Attendances records
		Attendance.where(:company_id => company_id, :month => month).delete_all
		
		#Deleting Payroll Details
		payroll_details_id = PayrollDetail.where(:company_id => company_id, :month => month).select(:id).map(&:id)
		PayrollDetail.where(:company_id => company_id, :month => month).delete_all
		
		#Deleting Payroll Execution Job
		payroll_details_id.each do |id|
			PayrollExecutionJob.where(:company_id => company_id, :payroll_detail_id => id).delete_all
		end

		#Deleting the Variable Payhead Details
		VariablePayheadDetail.where(:company_id => company_id, :month => month).delete_all

		# Deleting Salary Computation Result Table entries	
		SalaryComputationResult.where(:company_id => company_id, :month => month.to_s.to_date.end_of_month).delete_all	
	end
end
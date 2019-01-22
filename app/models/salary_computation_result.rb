class SalaryComputationResult < ActiveRecord::Base
	belongs_to :company
	belongs_to :user
	belongs_to :attendance
	belongs_to :payhead

	validates_presence_of :company_id, :user_id, :attendance_id, :payhead_id, :amount, :month, :processed_by, :status

	def self.check_payroll_processing_status(company_id, month)
	  results = self.where(:company_id => company_id, :month =>Date.new(Time.zone.now.year,month,1).end_of_month)
	  if status = results.present? ? status = 1 : status = 0
	  	return status
	  end
	end
end
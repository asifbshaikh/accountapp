class PayrollExecutionJob < ActiveRecord::Base
 belongs_to :payroll_detail
 belongs_to :company
 belongs_to :account

 validates_presence_of :account_id, :execution_date
 validate :account_effective_date

 validate :payroll_execution_date
  def account_effective_date
    if !account.blank? && !execution_date.blank? && execution_date < account.start_date
      errors.add(:execution_date, "must be after account activation, #{account.name} is activated since #{account.start_date}")
    end
  end

  def payroll_execution_date
  	if !execution_date.blank? && execution_date < Time.zone.now.to_date
  		errors.add(:execution_date, "can't not less than today")
  	end
  end
  
 class << self
  def create_record(params, company, payroll_detail)
    payroll_execution_job = PayrollExecutionJob.new(params[:payroll_execution_job])
    payroll_execution_job.company_id = company.id
    payroll_execution_job.payroll_detail_id = payroll_detail
    payroll_execution_job.status = 0
    payroll_execution_job.account_id = Account.get_account_id(params[:account_name], company.id)
    payroll_execution_job
  end

  def check_payroll_finalised(company_id, payroll_detail_id)
    self.find_by_company_id_and_payroll_detail_id(company_id, payroll_detail_id).status
  end

 end
end

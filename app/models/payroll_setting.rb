class PayrollSetting < ActiveRecord::Base
	belongs_to :company

	def self.create_default_payslip_record(company_id)
    PayrollSetting.create(company_id: company_id, enable_payslip_signatory: 0, payslip_footer: "**This Pay slip is computer generated and doesn't require any signature**")
  end

end

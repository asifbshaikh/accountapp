
namespace :payroll_setting do 
  task :customize_pay_slip => :environment do 
    ActiveRecord::Base.transaction do 
    	@companies = Company.all
      	
      	@companies.each do |company|
      
        payroll_setting = PayrollSetting.new
        payroll_setting.enable_payslip_signatory = 0
        payroll_setting.payslip_footer = "**This Pay slip is computer generated and doesn't require any signature**"
        payroll_setting.company_id = company.id
        payroll_setting.save!
      
      puts "Pay slip Details Created for #{company.name}"
     end
     
    end
  end
end
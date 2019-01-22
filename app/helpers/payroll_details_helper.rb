module PayrollDetailsHelper
	def payroll_action_button(month)
		content_tag :div, :class=>'pull-right text-primary m-t-small' do
			if PayrollDetail.get_status(@company.id, (month+1).to_s, @financial_year) == "Not processed yet"
				link_to "Run Payroll", "/attendances/new?month=#{(month+1).to_s}", :class=>'btn btn-info'
			elsif PayrollDetail.get_status(@company.id, (month+1).to_s, @financial_year) == "Pending"
				link_to "View details", "/payroll_execution_jobs/new?month=#{(month+1).to_s}", :class=>'btn btn-default'
			else
				link_to "View details", "/attendances/show?month=#{(month+1).to_s}", :class=>'btn btn-default'
			end
		end
	end
	def payroll_total(month,year)
		sum=0
		@payroll_date = Date.new(year,month.to_i, 1)
    @emps = User.where(:company_id => @company).this_month_payroll_participation(@payroll_date)
		@emps.each do |emp|
			sum+=emp.net_salary(@payroll_date) + emp.variable_pay(@payroll_date)
		end
		sum
	end
end

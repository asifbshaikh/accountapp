class FinancialYearLog < ActiveRecord::Base
	belongs_to :financial_year
	ACTIVITY={1=>"Freeze", 2=>"Unfreeze"}
	class << self
		def create_log(financial_year, user, activity)
			create(:company_id => financial_year.company_id, :financial_year_id => financial_year.id,
				:activity_on => Time.now, :activity =>activity,
				:past_opening_balance => financial_year.opening_balance,
				:past_closing_balance => financial_year.closing_balance, :created_by => user)
		end
	end
end

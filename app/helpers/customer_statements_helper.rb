module CustomerStatementsHelper
	def start_date
		params[:start_date].blank? ? @financial_year.start_date.to_date : params[:start_date]
	end

	def end_date
		params[:end_date].blank? ? Time.zone.now.end_of_month.to_date : params[:end_date]
	end
	def account_id
		params[:account_id]
	end
end

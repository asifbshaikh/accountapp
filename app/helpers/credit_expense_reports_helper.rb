module CreditExpenseReportsHelper
	def expense_report_amount(expense)
		total_amount= expense.foreign_currency? ? (expense.total_amount*expense.exchange_rate) : (expense.total_amount)
		raw(number_with_precision total_amount, :precision=>2)
	end	

	def expense_report_outstanding(expense)
		outstanding= expense.foreign_currency? ? (expense.outstanding.to_f*expense.exchange_rate.to_f) : (expense.outstanding)
		raw(number_with_precision outstanding, :precision=>2)
	end	

	def expense_report_total_amount
		amount_array=@expenses.map{|e| e.foreign_currency? ? e.total_amount*e.exchange_rate : e.total_amount }
		number_with_precision amount_array.sum, :precision=>2
	end

	def expense_report_total_outstanding
		outstanding_array=@expenses.map{|e| e.foreign_currency? ? e.outstanding*e.exchange_rate : e.outstanding }
		number_with_precision outstanding_array.sum , :precision=>2
	end
end
class ExpenseB2BRule
	def classify(expense)
		if  expense.credit_expense?
			gstn = expense.account.vendor.blank? ? expense.account.customer.gstn_id : expense.account.vendor.gstn_id
		end
		if gstn.present?
      if  expense.nil_rated_account(expense)
        type = 'NIL'
       
      else
        type = 'B2B'
      end
    else
      if  expense.nil_rated_account(expense)
        type = 'NIL'
      
      else
        type = 'B2BUR'
      end
      type
    end   
  end
end
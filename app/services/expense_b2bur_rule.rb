class ExpenseB2BURRule
    def classify(expense) 
    	if  expense.credit_expense?
          gstn = expense.account.vendor.gstn_id
         end      
              if gstn.null?
                type = 'B2BBUR'
                type
              end
      end
          
  
  
end
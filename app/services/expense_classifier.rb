class ExpenseClassifier
  require 'expense_b2b_rule'
  require 'expense_b2bur_rule'

  #Expense Classification
  RULES = [ExpenseB2BRule.new]

  def classify_expense(expense)
    type = nil
    RULES.each do |rule|
      type = rule.classify(expense)
      if type.present?
        break 
      end
    end
    
    Rails.logger.debug "classification is #{type}"
    type
  end

end

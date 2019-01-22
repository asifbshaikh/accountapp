class ExpenseTax < ActiveRecord::Base
	belongs_to :account
	belongs_to :expense_line_item
end

class ExpenseSequence < ActiveRecord::Base
	belongs_to :company

	def expense_number
		ExpenseSequence.increment_counter(:expense_sequence, self.id)
		self.reload
		self.expense_sequence.to_s.rjust(3, '0')
	end
end

class IncomeVoucherSequence < ActiveRecord::Base
	belongs_to :company

	def income_voucher_number
		IncomeVoucherSequence.increment_counter(:income_voucher_sequence, self.id)
		self.reload
		self.income_voucher_sequence.to_s.rjust(3, '0')
	end
end

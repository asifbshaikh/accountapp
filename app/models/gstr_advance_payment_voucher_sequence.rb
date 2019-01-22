class GstrAdvancePaymentVoucherSequence < ActiveRecord::Base
	 belongs_to :company

      def gstr_advance_payment_voucher_number
          #GstrAdvancePaymentVoucherSequence.increment_counter(:gstr_advance_payment_voucher_sequence, self.id)
         
           self.reload
          (self.gstr_advance_payment_voucher_sequence+1).to_s.rjust(3, '0')
      end

      def increment_counter
              GstrAdvancePaymentVoucherSequence.increment_counter(:gstr_advance_payment_voucher_sequence, self.id)
      end
end

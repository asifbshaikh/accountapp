class GstrAdvanceReceiptVoucherSequence < ActiveRecord::Base
    belongs_to :company
    belongs_to :gstr_advance_receipt

      def gstr_advance_receipt_voucher_number
          # ReceiptVoucherSequence.increment_counter(:receipt_voucher_sequence, self.id)
          
          self.reload
          (self.gstr_advance_receipt_voucher_sequence+1).to_s.rjust(3, '0')

      end

      def increment_counter
        GstrAdvanceReceiptVoucherSequence.increment_counter(:gstr_advance_receipt_voucher_sequence, self.id)
        
      end
end

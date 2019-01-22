class GstCreditNoteTax < ActiveRecord::Base
	belongs_to :account
	belongs_to :gst_credit_note_line_item
end

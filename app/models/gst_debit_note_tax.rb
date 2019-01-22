class GstDebitNoteTax < ActiveRecord::Base
	belongs_to :account
	belongs_to :gst_debit_note_line_item
end
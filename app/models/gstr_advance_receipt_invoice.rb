class GstrAdvanceReceiptInvoice < ActiveRecord::Base

belongs_to :invoice
belongs_to :gstr_advance_receipt
 
end	
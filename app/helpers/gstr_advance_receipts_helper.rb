module GstrAdvanceReceiptsHelper

GSTR_ADVANCE_RECEIPT_STATUS_BADGES = { draft: "badge", allocated: "bg-primary", unallocated: "bg-warning", settled: "bg-info", returned: "bg-inverse"}.with_indifferent_access
  #[FIXME] Move ActiveRecord code

	def gstr_advance_receipt_line_count
	columns = 5
	columns+=1 if@gstr_advance_receipt.get_discount>0
	columns+=2 if@gstr_advance_receipt.has_tax_lines? 	
	columns
	end



	 def gstr_advance_receipt_status_badge(status)
    GstrAdvanceReceiptsHelper::GSTR_ADVANCE_RECEIPT_STATUS_BADGES[status]
     end

end

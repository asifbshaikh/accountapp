class GstDebitNoteRule

	def classify(gst_debit_note)
		customer = gst_debit_note.from_account.vendor
		Rails.logger.debug "customer rule =================== #{customer.inspect}"
		if customer.present?
			gstn = customer.gstn_id
			Rails.logger.debug "gstn rule =================== #{gstn.inspect}"
		end 
		if gstn.present?
			type = 'cdnr'
		else
			type = 'cd_nur'
		end
		type
	end
end
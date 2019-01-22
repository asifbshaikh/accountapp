class GstCreditNoteRule

	def classify(gst_credit_note)
		customer = gst_credit_note.to_account.customer
		if customer.present?
			gstn = customer.gstn_id
		end 
		if gstn.present?
			type = 'cdnr'
		else
			type = 'cd_nur'
		end
		type
	end
end
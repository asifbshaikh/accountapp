module GstDebitNotesHelper
	def gst_debit_note_sub_total
		"#{gst_debit_note_currncy} #{@gst_debit_note.gst_debit_note_line_items.sum(:amount)}"
	end

	def gst_debit_note_discount
		"#{gst_debit_note_currncy} #{@gst_debit_note.discount}"
	end

	def gst_debit_note_tax_amount
		amt=0
		@gst_debit_note.tax_line_items.each do |line_item|
					 tax_account = line_item.account
       next if (tax_account.accountable_type=='DutiesAndTaxesAccounts' && tax_account.accountable.calculation_method==4 && tax_account.accountable.split_tax == 0)
       amt+= line_item.amount
   		end
   		logger.debug "tax #{amt.inspect}"
	amt
		# "#{gst_debit_note_currncy} #{@gst_debit_note.tax_line_items.sum(:amount)}"
	end

	def gst_debit_note_currncy
		@currency||=@gst_debit_note.currency
	end

	def debit_note_customer_details
		logger.debug "cu #{@gst_debit_note.from_account.vendor.inspect}"
		customer = @gst_debit_note.from_account.vendor.blank? ? @gst_debit_note.from_account.customer : @gst_debit_note.from_account.vendor
		logger.debug "custo #{customer.inspect}"
		details = content_tag :h4, @gst_debit_note.to_account_name
		details = content_tag :h4, (content_tag :strong, @gst_debit_note.to_account_name)
		details += address(customer)

		if !customer.primary_phone_number.blank?
			details += content_tag :p do
				content_tag :i, customer.primary_phone_number, :class => 'icon-phone'
			end
		end
		details
	end
	def address(customer)
		content_tag :p do
			cnt = address_line1(customer).blank? ? "" : address_line1(customer)  
			cnt += '<br/>' + address_line2(customer) unless address_line2(customer).blank?
			cnt += ', ' + city(customer) unless city(customer).blank?
			cnt += ' ' + state(customer) unless state(customer).blank?
			cnt += ', ' + country(customer) unless country(customer).blank?
			cnt += ' - ' + postal_code(customer) unless postal_code(customer).blank?
			cnt
		end
	end

	def address_line1(customer)
		if !customer.billing_address.blank?
			customer.billing_address.address_line1 unless customer.billing_address.address_line1.blank?
		end
	end

	def address_line2(customer)
		if !customer.billing_address.blank?
			customer.billing_address.address_line2 unless customer.billing_address.address_line2.blank?
		end
	end

	def city(customer)
		if !customer.billing_address.blank?
			customer.billing_address.city unless customer.billing_address.city.blank?
		end
	end

	def state(customer)
		if !customer.billing_address.blank?
			customer.billing_address.state unless customer.billing_address.state.blank?
		end
	end

	def country(customer)
		if !customer.billing_address.blank?
			customer.billing_address.country unless customer.billing_address.country.blank?
		end
	end

	def postal_code(customer)
		if !customer.billing_address.blank?
			customer.billing_address.postal_code unless customer.billing_address.postal_code.blank?
		end
	end

	def gstin
		customer = @gst_debit_note.from_account.customer.blank? ? @gst_debit_note.from_account.vendor : @gst_debit_note.from_account.customer
		if !customer.gstn_id.blank?
			gstin = customer.gstn_id
		end
		gstin
	end
end

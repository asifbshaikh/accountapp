class GstCreditNoteSerializer < ActiveModel::Serializer
attributes :typ, :ntty, :nt_num, :nt_dt, :p_gst, :rsn, :inum, :idt, :p_gst, :rsn, :inum, :idt, :val, :itms
GST_CREDIT_NOTE_CLASSIFICATION = { cdnr: 5, cd_nur: 6 }.with_indifferent_access

	def attributes
	    hash = super
	    hash.each {|key, value|
	    if value.nil?
	       hash.delete(key)
	    end
	    }
	    hash
   	end

   	def typ
   		if object.customer_GSTIN.blank?
   			"B2CL"
   		else
   			nil
   		end
   	end

	def ntty
		"C"
	end

	def nt_num
		object.gst_credit_note_number
	end

	def nt_dt
		object.gst_credit_note_date.strftime("%d-%m-%Y")
	end

	def p_gst
		"N"
	end

	def rsn
		"01-Sales Return"
	end

	def inum
		object.invoice_return.invoice.invoice_number
	end

	def idt
		object.invoice_return.invoice.invoice_date.strftime("%d-%m-%Y")
	end

	def val
		object.total_amount.to_f.round(2)
	end

	def itms
		# gst_credit_note.gst_credit_note_line_items.each_with_index do |line_item,index|

		# end

			index=0
		   	serialized_array =Array.new
		   	record=Hash.new
		  	object.gst_line_items.each_with_index do |line_item,index|
			    index = index + 1
			    # item = InvoiceLineItemSerializer.new(line_item)
			    record = line_item
			    item_hash= record.instance_variables.each_with_object({}) { |var, hash| hash[var.to_s.delete("@")] = record.instance_variable_get(var) }

			    sanitized_hash = {:rt=> item_hash["rt"].to_f.round(2),:txval => item_hash["txval"].to_f.round(2),:iamt => item_hash["iamt"].to_f.round(2), :camt=> item_hash["camt"].to_f.round(2), :samt => item_hash["samt"].to_f.round(2)}

			    serialized_array << {:num=>index,:itm_det => eliminate_null_keys(sanitized_hash)}

		  	end
		   	serialized_array
	end



  private

    def eliminate_null_keys(list)
      puts list.inspect
      hash = list
      hash.each {|key, value|
        if value.eql?(0.0)
          hash.delete(key)
        end
      }
      hash
    end

end
class GstDebitNoteSerializer < ActiveModel::Serializer
attributes :rtin, :ntty, :nt_num, :nt_dt, :p_gst, :rsn, :inum, :idt, :p_gst, :rsn, :inum, :idt, :val, :inv_typ, :itms
GST_DEBIT_NOTE_CLASSIFICATION = { cdnr: 5, cd_nur: 6 }.with_indifferent_access

	def attributes
	    hash = super
	    hash.each {|key, value|
	    if value.nil?
	       hash.delete(key)
	    end
	    }
	    hash
   	end

   	def rtin
   		object.company.GSTIN
   	end

	def ntty
		"C"
	end

	def nt_num
		object.gst_debit_note_number
	end

	def nt_dt
		object.gst_debit_note_date.strftime("%d-%m-%Y")
	end

	def rsn
		"01-Sales Return"
	end

	def p_gst
		'N'
	end

	def inum
		object.purchase_return.purchase.purchase_number
	end

	def idt
		object.purchase_return.purchase.record_date.strftime("%d-%m-%y")
	end

	def val
		object.total_amount.to_f
	end

	def inv_typ
   		if object.customer_GSTIN.blank?
   			"B2BUR"
   		else
   			nil
   		end
	end

	def itms
		# gst_debit_note.gst_debit_note_line_items.each_with_index do |line_item,index|

		# end

			index=0
		   	serialized_array =Array.new
		   	record=Hash.new
		  	object.gst_line_items.each_with_index do |line_item,index|
			    index = index + 1
			    # item = PurchaseLineItemSerializer.new(line_item)
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
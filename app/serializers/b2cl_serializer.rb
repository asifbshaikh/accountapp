class B2clSerializer < InvoiceSerializer
  attributes   :inum ,:idt,:val,:etin,:itms

  def attributes
     hash = super
     hash.each {|key, value|
      if value.nil?
        hash.delete(key)
     end
    }
    hash
   end


# def flag

# end

#  def sply_ty
 	

def inum
 	object.invoice_number
 end


 def idt
 	object.invoice_date.strftime("%d-%m-%Y")
 end


 def val
 	object.total_amount.to_f

 end

 def etin

 end


 def itms
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

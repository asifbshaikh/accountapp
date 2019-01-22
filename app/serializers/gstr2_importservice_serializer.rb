class Gstr2ImportServiceSerializer <  PurchaseSerializer

   attributes :inum, :id, :ival, :pos, :items

 
   def inum
        object.purchase_number
     
   end

   def ival
     object.total_amount.to_f
   end

   def pos
      object.company.GSTIN[0,2].to_s
   end

   def items
     import_wise_data
   end


   def import_wise_data
      
   index=0
   serialized_array =Array.new
   record=Hash.new
   itc_record =Hash.new

   object.gst_line_items.each_with_index do |line_item,index|
    index = index + 1
    record = line_item 
    item_hash= record.instance_variables.each_with_object({}) { |var, hash| hash[var.to_s.delete("@")] = record.instance_variable_get(var) }
    itc_details = object.itc_item #code for ITC
    
    sanitized_hash = {:txval => item_hash["txval"].to_f.round(2), :elg => itc_details[:eligibility].to_s, :rt=> item_hash["rt"].to_f.round(2), :iamt => item_hash["iamt"].to_f.round(2), :tx_i => item_hash["iamt"].to_f.round(2) }
    serialized_array << {:num=>index,:items => eliminate_null_keys(sanitized_hash)}
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
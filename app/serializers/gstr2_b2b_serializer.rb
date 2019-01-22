class Gstr2B2bSerializer <  PurchaseSerializer
 
  attributes :inum , :idt, :val , :pos , :rchrg, :inv_typ , :itms

  def attributes
     hash = super
     hash.each {|key, value|
      if value.nil?
        hash.delete(key)
     end
    }
    hash
   end

 def inum
  object.purchase_number
 end


 def idt
  object.record_date.strftime("%d-%m-%Y")
 end


 def val
  object.total_amount.to_f
 
 end

 def pos
  object.company.GSTIN[0,2].to_s

 end

 def rchrg
  'N'
 end

 def inv_typ
  'R'
 end

 def itms
   index=0
   serialized_array =Array.new
   record=Hash.new
   itc_record =Hash.new

   object.gst_line_items.each_with_index do |line_item,index|
    index = index + 1
   
    record = line_item
    item_hash= record.instance_variables.each_with_object({}) { |var, hash| hash[var.to_s.delete("@")] = record.instance_variable_get(var) }
   
   itc_details = object.itc_item
   
    if pos == vendor_state
  itc_record = {"elg" => itc_details[:eligibility].to_s ,"tx_c" =>  item_hash["camt"].to_f.round(2), "tx_s" =>  item_hash["samt"].to_f.round(2) }
    else

     itc_record =  { "elg" => itc_details[:eligibility].to_s, "tx_i" =>  item_hash["iamt"].to_f.round(2)}
  end
  
    sanitized_hash = {:rt=> item_hash["rt"].to_f.round(2),:txval => item_hash["txval"].to_f.round(2),:iamt => item_hash["iamt"].to_f.round(2), :camt=> item_hash["camt"].to_f.round(2), :samt => item_hash["samt"].to_f.round(2)}
    serialized_array << {:num=>index,:itm_det => eliminate_null_keys(sanitized_hash), :itc => eliminate_null_keys(itc_record)}

   end

   serialized_array
 end


def vendor_state
   current_ctin = object.vendor.present? ? object.vendor.gstn_id  : object.customer.gstn_id
   current_ctin = current_ctin.first(2)
   current_ctin 
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

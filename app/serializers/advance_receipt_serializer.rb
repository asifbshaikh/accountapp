class AdvanceReceiptSerializer < ActiveModel::Serializer
  # attributes :inum, :idt,:val,:pos,:rchrg,:etin,:inv_typ, :items
  attributes :pos, :sply_ty, :itms

  def attributes
     hash = super
     hash.each {|key, value|
      if value.nil?
        hash.delete(key)
     end
    }
    hash
   end

 def pos
  object.place_of_supply.rjust(2, '0')

 end

 def sply_ty
  if object.intra_state_supply
    "INTRA"
  else
    "INTER"
  end
 end

 def itms
   
   index=0
   serialized_array =Array.new
   record=Hash.new
   object.gst_line_items.each_with_index do |line_item,index|
    index = index + 1
    record = line_item
    item_hash= record.instance_variables.each_with_object({}) { |var, hash| hash[var.to_s.delete("@")] = record.instance_variable_get(var) }
    
    #sanitized_hash = {:rt=> item_hash["rt"].to_f.round(2),:adamt => item_hash["adamt"].to_f.round(2),:camt=> item_hash["camt"].to_f.round(2), :samt => item_hash["samt"].to_f.round(2), :iamt => item_hash["iamt"].to_f.round(2)}
    if sply_ty =="INTRA"
    serialized_array << {:rt=> item_hash["rt"].to_f.round(2),:ad_amt => item_hash["txval"].to_f.round(2),:camt=> item_hash["camt"].to_f.round(2), :samt => item_hash["samt"].to_f.round(2)}
    else
    serialized_array << {:rt=> item_hash["rt"].to_f.round(2),:ad_amt => item_hash["txval"].to_f.round(2), :iamt => item_hash["iamt"].to_f.round(2)}
   end
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
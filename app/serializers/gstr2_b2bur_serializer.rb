class Gstr2B2burSerializer < PurchaseSerializer

  attributes :inum , :idt, :val , :pos , :rchrg, :sply_ty , :itms 

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
  @pos ||= object.company.GSTIN[0,2].to_s
  # state = object.vendor.present? ? object.vendor.get_state  : object.customer.get_state
  # state.to_s
end

def rchrg
  'N'
end

def sply_ty
 # company_state = object.company.GSTIN[0,2].to_i

 if pos.to_i == place_of_supply
  'INTRA'
else
  'INTER'
end
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

    if sply_ty == 'INTRA'

      itc_record = {"elg" => itc_details[:eligibility].to_s ,"tx_c" =>  item_hash["camt"].to_f.round(2), "tx_s" =>  item_hash["samt"].to_f.round(2) }
    else

     itc_record =  { "elg" => itc_details[:eligibility].to_s, "tx_i" =>  item_hash["iamt"].to_f.round(2)}
   end

   sanitized_hash = {:rt=> item_hash["rt"].to_f.round(2),:txval => item_hash["txval"].to_f.round(2),:iamt => item_hash["iamt"].to_f.round(2), :camt=> item_hash["camt"].to_f.round(2), :samt => item_hash["samt"].to_f.round(2)}
   serialized_array << {:num=>index,:itm_det => eliminate_null_keys(sanitized_hash), :itc => itc_record  }

 end

 serialized_array
end

def place_of_supply # it is requried to define supply type
  if object.customer_state.present?
    Rails.logger.debug "========================The customer state is #{object.customer_state}========================"
    state = object.customer_state
    state.to_i
  end
 
end
private

def eliminate_null_keys(list)
  puts list.inspect
  hash = list
  hash.each {|key, value|
    if value.eql?(0)
      hash.delete(key)
    end
  }
  hash
end




end

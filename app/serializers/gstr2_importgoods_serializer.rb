class Gstr2ImportGoodsSerializer <  PurchaseSerializer

attributes :flag, :is_sez, :stin, :boe_num, :boe_dt, :boe_val, :chksum, :port_code, :items


def flag
  
end

def iz_sez
  
end

def stin
  
end

def boe_num
  object.boe_num
end

def boe_dt
  object.boe_date
end

def boe_val
  object.boe_val
end


def chksum
  
end

def port_code
  
end

def items
    index=0
   serialized_array =Array.new
   record=Hash.new
   itc_record =Hash.new

   object.gst_line_items.each_with_index do |line_item,index|
    index = index + 1
    record = line_item 
    item_hash= record.instance_variables.each_with_object({}) { |var, hash| hash[var.to_s.delete("@")] = record.instance_variable_get(var) }
    itc_details = object.itc_item #code for ITC
    sanitized_hash = {:rt=> item_hash["rt"].to_f.round(2),:txval => item_hash["txval"].to_f.round(2),:iamt => item_hash["iamt"].to_f.round(2), :camt=> item_hash["camt"].to_f.round(2), :samt => item_hash["samt"].to_f.round(2), :elg => itc_details[:eligibility].to_s, :tx_i => item_hash["iamt"].to_f.round(2) }
    serialized_array << {:num=>index,:itms => eliminate_null_keys(sanitized_hash)}
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
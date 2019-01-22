class ExpSerializer < InvoiceSerializer
  attributes  :inum,:idt,:val ,:sbpcode,:sbnum,:sbdt,:itms 

  def attributes
     hash = super
     hash.each {|key, value|
      if value.nil?
        hash.delete(key)
     end
    }
    hash
   end




 # def inv
 # 	[{:inum => inum,:idt => idt,:val => val, :sbpcode => sbpcode,:sbnum => sbnum, :sbdt => sbdt,:itms => itms}]

 # end



 def inum
 	object.invoice_number
 end


 def idt
 	object.invoice_date.strftime("%d-%m-%Y")
 end


 def val
 	(object.total_amount*object.exchange_rate).to_f.round(2)

 end

 def sbpcode
  object.sbpcode unless object.sbpcode.blank?
 end

 def sbnum
  if !object.sbnum.blank?
    object.sbnum.to_i
  end
 end

 def sbdt
  unless object.sbdate.blank?
     object.sbdate.strftime("%d-%m-%Y")
  end

 end


 def itms
   object.gst_line_items

   serialized_array =Array.new
   record=Hash.new
   object.gst_line_items.each do |line_item|
    record = line_item
    item_hash= record.instance_variables.each_with_object({}) { |var, hash| hash[var.to_s.delete("@")] = record.instance_variable_get(var) }

    sanitized_hash = {:txval => item_hash["txval"].to_f.round(2),:rt=> item_hash["rt"].to_f.round(2),:iamt => item_hash["iamt"].to_f.round(2)}

    serialized_array << sanitized_hash

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

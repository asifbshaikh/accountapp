class B2bSerializer < InvoiceSerializer
  # attributes :inum, :idt,:val,:pos,:rchrg,:etin,:inv_typ, :items
  attributes :inum , :idt, :val , :pos , :rchrg, :etin , :inv_typ , :itms 

  def attributes
     hash = super
     hash.each {|key, value|
      if value.nil?
        hash.delete(key)
     end
    }
    hash
   end

 #  def ctin
 #    object.customer.gstn_id
 #  end


 # def inv
 #  list = {:inum => inum, :idt => idt, :val => val, :pos => pos, :rchrg => rchrg, :etin => etin, :inv_typ => inv_typ, :itms => itms}
 #  [eliminate_null_keys(list)]
 # end



 def inum
  object.invoice_number
 end


 def idt
  object.invoice_date.strftime("%d-%m-%Y")
 end


 def val
  object.total_amount.to_f

 end

 def pos
  object.place_of_supply.rjust(2, '0')

 end

 def rchrg
  'N'
 end

 def etin
 end


 def inv_typ
  'R'
 end

 def itms
   #object.invoice_line_items.collect { |item| InvoiceLineItemSerializer.new(item).serializable_hash}
   # object.gst_line_items
   # serialized_array =Array.new
   # index = 0
   # invoice_items = object.invoice_line_items
   # invoice_items.each_with_index do |line_item,index|
   #  index = index + 1
   #  item = InvoiceLineItemSerializer.new(line_item)
   #  record = item.serializable_hash
   #  serialized_array << {:num=>index,:itm_det => record}
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

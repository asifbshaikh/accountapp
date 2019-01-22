require 'invoice_b2b_rule'
class GstrOneSerializer < ActiveModel::Serializer

 attributes :gstin,:fp,:gt,:cur_gt,:b2b,:b2cl,:cdnr,:b2cs,:exp,:nil,:txpd,:at,:doc_issue,:cdnur

  INVOICE_CLASSIFICATION = { B2B: 0, B2CL: 1, B2CS: 2, EXP: 3, NIL: 4}.with_indifferent_access
  GSTR_ADVANCE_RECEIPT_CLASSIFICATION = {INTRA: 7, INTER: 8}.with_indifferent_access
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


def gstin
 object.company.GSTIN
end

def fp
  object.return_period
end

def gt
  object.fy_gross_turnover.to_f
end

def cur_gt
  object.qtr_gross_turnover.to_f
end

def b2b
  data=customer_wise_grouped_data
  if data.blank? || data.empty?
    nil
  else
    data
  end    

end

def b2cl
 data=pos_wise_grouped_data
 if data.blank? || data.empty?
  nil
else
  data
end    
end

def cdnr
  data=customer_wise_gst_credit_note
  if data.blank? || data.empty?
    nil
  else
    data
  end   
end

def b2cs
    # data = object.gstr_one_items.where(:voucher_classification =>  INVOICE_CLASSIFICATION['B2CS']).collect { |voucher| B2csSerializer.new(voucher,:root=> :inv).serializable_hash}
    data = state_wise_b2cs_grouped_data
    if data.blank? || data.empty?
      nil
    else
      data
    end    
  end

  def exp
    data = export_type_grouped_data
    if data.blank? || data.empty?
      nil
    else
      data
    end  
  end

  def hsn
   hsn_summary = get_product_wise_hsn_summary
     if hsn_summary.blank? || hsn_summary.empty?
      nil
    else
       hsn_summary
       # nil
    end
  end

  def nil
    invoice_array = nil_rated_data_summary
    if invoice_array.blank? || invoice_array.empty?
      nil
    else
      {:inv => invoice_array}
    end
  end

  def txpd
  end

  def at
     data = gstr_advance_receipt_data
      if data.blank? || data.empty?
      nil
    else
      data
    end  

  end

  def doc_issue
  end

  def cdnur
    data = unregistered_customer_wise_gst_credit_note
    if data.blank? || data.empty?
      nil
    else
      data
    end
  end
def gstr_advance_receipt_data

  gstr_advance_receipt =object.company.gstr_advance_receipts.where(:id => object.gstr_one_items.where(:voucher_type => "GstrAdvanceReceipt").map{|item| item.voucher_id})
  sort_gstr_advance_receipts = gstr_advance_receipt.sort_by do |item|
    item[:place_of_supply]
  end 
 record_items = Array.new
  
  current_pos=''
  sort_gstr_advance_receipts.each do |advance_receipt|
    
    
   item =AdvanceReceiptSerializer.new(advance_receipt)
   record= item.serializable_hash
   if current_pos.eql?(advance_receipt.place_of_supply)
      record_items.push(record)
      next
    else
      record_items.push(record)
    end
    current_pos=advance_receipt.place_of_supply
   end
   record_items     
end

  def  customer_wise_grouped_data
    invoices =object.company.invoices.where(:id => object.gstr_one_items.where(:voucher_classification =>  INVOICE_CLASSIFICATION['B2B'],:voucher_type => "Invoice").map{|item| item.voucher_id})

    sort_invoice = invoices.where(:cash_invoice => 0).sort_by do |item|
      item[:customer_id]
    end 

    cash_invoice =  invoices.where(:cash_invoice => 1).sort_by do |item|
        item[:cash_customer_gstin]
    end

    serialized_array =Array.new
    current_ctin = ''
    record_items = Array.new

    sort_invoice.each do |invoice|
      item = B2bSerializer.new(invoice)
      record = item.serializable_hash
      if current_ctin.eql?(invoice.customer_GSTIN)
       record_items.push(record)
       next
     else
       record_items = []
       record_items .push(record) 
     end
     serialized_array << {:ctin=> invoice.customer_GSTIN, :inv => record_items}
     current_ctin = invoice.customer_GSTIN
   end 

   cash_invoice.each do |invoice|
      item = B2bSerializer.new(invoice)
      record = item.serializable_hash
      if current_ctin.eql?(invoice.cash_customer_gstin)
       record_items.push(record)
       next
     else
       record_items = []
       record_items .push(record) 
     end
     serialized_array << {:ctin=> invoice.customer_GSTIN, :inv => record_items}
     current_ctin = invoice.cash_customer_gstin
   end 

   serialized_array 


 end


 def  pos_wise_grouped_data
  invoices =object.company.invoices.where(:id => object.gstr_one_items.where(:voucher_classification =>  INVOICE_CLASSIFICATION['B2CL'],:voucher_type => "Invoice").map{|item| item.voucher_id})
  sort_invoice = invoices.sort_by do |item|
    item[:placy_of_supply]
  end 
  serialized_array =Array.new
  current_pos = ''
  record_items = Array.new

  sort_invoice.each do |invoice|
    item = B2clSerializer.new(invoice)
    record = item.serializable_hash
    if current_pos.eql?(invoice.place_of_supply)
     record_items.push(record)
     next
   else
     record_items = []
     record_items .push(record) 
   end
   serialized_array << {:pos=> invoice.place_of_supply.rjust(2, '0'), :inv => record_items}
   current_pos = invoice.place_of_supply
 end 
 serialized_array 


end



def  state_wise_b2cs_grouped_data
  invoices =object.company.invoices.where(:id => object.gstr_one_items.where(:voucher_classification =>  INVOICE_CLASSIFICATION['B2CS'],:voucher_type => "Invoice").map{|item| item.voucher_id})

  serialized_array =Array.new
  current_pos = ''
  record_items = Array.new
  invoice_category = Hash.new
  inter = Array.new
  intra = Array.new
  invoice_category[:inter] = inter
  invoice_category[:intra] = intra

  invoices.each do |invoice|
    if invoice.intra_state_supply
      intra.concat(invoice.gst_line_items)
    else
      inter.concat(invoice.gst_line_items)
    end
  end 

  Rails.logger.debug "=====================The B2CS data intra is #{intra.inspect}"
  Rails.logger.debug "=====================The B2CS data inter is #{inter.inspect}"


  inter.each  do |gst_line_item|
    inter_record = gst_line_item.instance_variables.each_with_object({}) { |var, hash| hash[var.to_s.delete("@")] = gst_line_item.instance_variable_get(var) }
    serialized_array << {:sply_ty => "INTER", :rt=> inter_record["rt"].to_f.round(2), :typ=> "OE", :pos => inter_record["pos"].rjust(2, '0'), :txval=> inter_record["txval"].to_f.round(2),:iamt => inter_record["iamt"].to_f.round(2) }

  end

  intra.each  do |gst_line_item|
    intra_record = gst_line_item.instance_variables.each_with_object({}) { |var, hash| hash[var.to_s.delete("@")] = gst_line_item.instance_variable_get(var) }
    serialized_array << {:sply_ty => "INTRA", :rt=> intra_record["rt"].to_f.round(2), :typ=> "OE", :pos => intra_record["pos"].rjust(2, '0'), :txval=> intra_record["txval"].to_f.round(2) ,:camt => intra_record["camt"].to_f.round(2),:samt => intra_record["samt"].to_f.round(2)}
  end
  sorted_array = serialized_array.sort_by { |k| k["rt"]}
  sorted_array


end



def nil_rated_data_summary
  invoices =object.company.invoices.where(:id => object.gstr_one_items.where(:voucher_classification =>  INVOICE_CLASSIFICATION['NIL'],:voucher_type => "Invoice").map{|item| item.voucher_id})
  serialized_array =Array.new
  invoice_category = Hash.new
  invoice_category[:interb2b] = 0
  invoice_category[:intrab2b] = 0
  invoice_category[:interb2c] = 0
  invoice_category[:intrab2c] = 0
  invoices.each do |invoice|
   type =  InvoiceB2BRule.new
   classification = type.classify(invoice)
   if invoice.intra_state_supply  &&  classification.eql?('B2B')
    invoice_category[:intrab2b] +=  invoice.total_amount
  elsif  invoice.intra_state_supply  &&  !classification.eql?('B2B')
   invoice_category[:intrab2c] += invoice.total_amount
 elsif !invoice.intra_state_supply  &&  classification.eql?('B2B')

  invoice_category[:interb2b] += invoice.total_amount

else
  invoice_category[:interb2c] += invoice.total_amount

end
end

invoice_category.each do |category|
  serialized_array << {:sply_ty => category[0].upcase , :nil_amt=> category[1].to_f.round(2)} unless category[1].eql?(0)
end

serialized_array
end



def get_product_wise_hsn_summary

  invoices =object.company.invoices.where(:id => object.gstr_one_items.where(:voucher_type => "Invoice").map{|item| item.voucher_id})
  serialized_array =Array.new
  hsn_hash =Hash.new
  hsn_data_items  = Array.new
  invoices.each do |invoice|
    serialized_array.concat(invoice.get_product_wise_summary)
  end
  serial_no = 0
  serialized_array.each do |item|
    record = item.instance_variables.each_with_object({}) { |var, hash| hash[var.to_s.delete("@")] = item.instance_variable_get(var) }
    if hsn_hash.has_key?(record["hsn_sc"])
      hsn_data = hsn_hash[record["hsn_sc"]]
      hsn_data.add_qty(record["qty"])
      hsn_data.add_value(record["val"])
      hsn_data.add_txval(record["txval"])
      hsn_data.add_iamt(record["iamt"])
      hsn_data.add_camt(record["camt"])
      hsn_data.add_samt(record["samt"])
    else 
      serial_no = serial_no + 1
      hsn_item = HsnData.new(serial_no,record["hsn_sc"], record["desc"], record["uqc"],record["qty"],record["val"],record["txval"],record["iamt"],record["camt"],record["samt"])
      hsn_hash[record["hsn_sc"]] = hsn_item  
    end
  end

  hsn_data_array = hsn_hash.values
  hsn_data_array.each do |hsn_data_obj|
     hsn_record = hsn_data_obj.instance_variables.each_with_object({}) { |var, hash| hash[var.to_s.delete("@")] = hsn_data_obj.instance_variable_get(var) }
   if !hsn_record["desc"].blank? && !hsn_record["uqc"].blank?
   hsn_data_items.push({:num => hsn_record["num"],:hsn_sc => hsn_record["hsn_cd"] ,:desc => hsn_record["desc"],:uqc => hsn_record["uqc"],
        :qty => hsn_record["qty"].to_f,
        :val => hsn_record["val"].to_f.round(2),
        :txval => hsn_record["txval"].to_f.round(2),
        :iamt => hsn_record["iamt"].to_f.round(2),
        :camt => hsn_record["camt"].to_f.round(2),
        :samt => hsn_record["samt"].to_f.round(2)})
  end
  end
  if !hsn_data_items.blank?
    {:data => eliminate_null_keys(hsn_data_items) }
  end
end



def customer_wise_gst_credit_note

  gst_credit_note=object.company.gst_credit_notes.where(:id => object.gstr_one_items.where(:voucher_classification =>  GST_CREDIT_NOTE_CLASSIFICATION['cdnr'], :voucher_type => 'GstCreditNote').map{|item| item.voucher_id})
      sort_gst_credit_note = gst_credit_note.sort_by do |item|
        item[:to_account_id]
      end 
      serialized_array =Array.new
      current_ctin = ''
      record_items = Array.new

      sort_gst_credit_note.each do |gst_credit_note|
        item = GstCreditNoteSerializer.new(gst_credit_note)
        record = item.serializable_hash
        if current_ctin.eql?(gst_credit_note.customer_GSTIN)
         record_items.push(record)
         next
       else
         record_items = []
         record_items .push(record) 
       end
       serialized_array << {:ctin=> gst_credit_note.customer_GSTIN, :nt => record_items}
       current_ctin = gst_credit_note.customer_GSTIN
     end 
     serialized_array 

  end



def export_type_grouped_data
  invoices =object.company.invoices.where(:id => object.gstr_one_items.where(:voucher_classification =>  INVOICE_CLASSIFICATION['EXP'],:voucher_type => "Invoice").map{|item| item.voucher_id})

  serialized_array =Array.new
  collection =Array.new

  invoices.each do |invoice|
    item = ExpSerializer.new(invoice)
    record = item.serializable_hash
    collection.push(record)
 end 
    if !collection.blank?
      serialized_array << {:exp_typ=>"WOPAY" , :inv => collection}
    end
    serialized_array 
end

  def unregistered_customer_wise_gst_credit_note

  gst_credit_note=object.company.gst_credit_notes.where(:id => object.gstr_one_items.where(:voucher_classification =>  GST_CREDIT_NOTE_CLASSIFICATION['cd_nur'], :voucher_type => 'GstCreditNote').map{|item| item.voucher_id})
      sort_gst_credit_note = gst_credit_note.sort_by do |item|
        item[:to_account_id]
      end 
      record_items = Array.new

      sort_gst_credit_note.each do |gst_credit_note|
        item = GstCreditNoteSerializer.new(gst_credit_note)
        record = item.serializable_hash
         record_items.push(record) 
       
     end 
     record_items 

  end



  private

   def eliminate_null_keys(list)
      puts list.inspect
      hash = list

      hash.each do |key|
        key.each  {|k, v|
          if v.eql?(nil) || v.eql?(0.0)
            hash.delete(k)
          end
          }
      end
      hash
    end

end

class GstrTwoSerializer < ActiveModel::Serializer
 attributes :gstin, :fp, :b2b , :b2bur, :cdn, :nil_supplies, :txi, :cdnur #:hsnsum, :cdnur
 PURCHASE_CLASSIFICATION = { B2B: 0, B2BUR: 1, NIL: 6}.with_indifferent_access
  ADVANCE_PAYMENT_CLASSIFICATION = { INTER: 2, INTRA: 3}.with_indifferent_access
  GST_DEBIT_NOTE_CLASSIFICATION = { cdn: 4, cd_nur: 5 }.with_indifferent_access

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

  def cdn
    data = customer_wise_gst_debit_note
    if data.blank? || data.empty?
      nil
    else
      data
    end    
  end

  def cdnur
    data = unregistered_customer_wise_gst_debit_note
    if data.blank? || data.empty?
      nil
    else
      data
    end
  end

  def txi
    advance_payment_data
  end

  def hsnsum
    hsn_summary = get_product_wise_hsn
     if hsn_summary.blank? || hsn_summary.empty?
      nil
    else
       hsn_summary
       # nil
    end
  end

def exp
    getexp
  end

  def b2b
    data = customer_wise_grouped_data
      if data.blank? || data.empty?
       nil
      else
       data
       end  
  end

  def nil_supplies

  data = purchase_wise_data
   if data.blank? || data.empty?
       nil
      else
       data
       end  
  end


  def b2bur
   data = b2bur_data
    if data.blank? || data.empty?
       nil
      else
       data
       end  
  end

  def customer_wise_gst_debit_note

  gst_debit_note=object.company.gst_debit_notes.where(:id => object.gstr_two_items.where(:voucher_classification =>  GST_DEBIT_NOTE_CLASSIFICATION['cdnr'], :voucher_type => 'GstDebitNote').map{|item| item.voucher_id})
      sort_gst_debit_note = gst_debit_note.sort_by do |item|
        item[:to_account_id]
      end 
      serialized_array =Array.new
      current_ctin = ''
      record_items = Array.new

      sort_gst_debit_note.each do |gst_debit_note|
        item = GstDebitNoteSerializer.new(gst_debit_note)
        record = item.serializable_hash
        if current_ctin.eql?(gst_debit_note.customer_GSTIN)
         record_items.push(record)
         next
       else
         # record_items = []
         record_items .push(record) 
       end
       serialized_array << {:ctin=> gst_debit_note.customer_GSTIN, :nt => record_items}
       current_ctin = gst_debit_note.customer_GSTIN
     end 
     serialized_array 

  end

  def unregistered_customer_wise_gst_debit_note

  gst_debit_note=object.company.gst_debit_notes.where(:id => object.gstr_two_items.where(:voucher_classification =>  GST_DEBIT_NOTE_CLASSIFICATION['cd_nur'], :voucher_type => 'GstDebitNote').map{|item| item.voucher_id})
      sort_gst_debit_note = gst_debit_note.sort_by do |item|
        item[:to_account_id]
      end 
      record_items = Array.new

      sort_gst_debit_note.each do |gst_debit_note|
        item = GstDebitNoteSerializer.new(gst_debit_note)
        record = item.serializable_hash
         record_items.push(record) 
       
     end 
     record_items 

  end  

  def advance_payment_data
    advance_payment = object.company.gstr_advance_payments.where(:id => object.gstr_two_items.where(:voucher_type =>  'GstrAdvancePayment').map{|item| item.voucher_id})
    sort_adv_payment = advance_payment.sort_by do |item|
      item[:to_account_id]
    end
    record_items = Array.new
    current_pos = nil
    sort_adv_payment.each do |advance_payment|
      item = AdvancePaymentSerializer.new(advance_payment)
      record = item.serializable_hash
      if current_pos.eql?(advance_payment.place_of_supply)
        record_items.push(record)
        next
      else
        record_items = []
        record_items .push(record) 
      end
      #record_items << {:pos => }
      current_pos = advance_payment.place_of_supply
    end
    record_items 
  end

  def get_product_wise_hsn

  purchases =object.company.purchases.where(:id => object.gstr_two_items.where(:voucher_type => "Purchase").map{|item| item.voucher_id})
  serialized_array =Array.new
  hsn_hash =Hash.new
  hsn_data_items  = Array.new
  purchases.each do |purchase|
    serialized_array.concat(purchase.get_product_wise_summary)
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
   hsn_data_items.push({:num => hsn_record["num"],:hsn_sc => hsn_record["hsn_cd"] ,:uqc => hsn_record["uqc"],
        :qty => hsn_record["qty"].to_f,
        :val => hsn_record["val"].to_f.round(2),
        :txval => hsn_record["txval"].to_f.round(2),
        :iamt => hsn_record["iamt"].to_f.round(2),
        :camt => hsn_record["camt"].to_f.round(2),
        :samt => hsn_record["samt"].to_f.round(2)},
        :desc => hsn_record["desc"])
  end
  end
  if !hsn_data_items.blank?
    {:data => eliminate_null_keys(hsn_data_items) }
  end
end


  def  customer_wise_grouped_data #Purchase B2B data
     purchases =object.company.purchases.where(:id => object.gstr_two_items.where(:voucher_classification =>  PURCHASE_CLASSIFICATION['B2B'], :voucher_type => 'Purchase').map{|item| item.voucher_id})
      sort_purchase = purchases.sort_by do |item|
            item[:account_id]
      end 
        serialized_array =Array.new
        current_ctin = ''
        record_items = Array.new

        sort_purchase.each do |purchase|
        item = Gstr2B2bSerializer.new(purchase)
        record = item.serializable_hash
      
            if current_ctin.eql?(purchase.vendor.gstn_id)
              record_items.push(record)
              next
            else
              record_items = []
              record_items.push(record)  
          end
        serialized_array << {:ctin=> purchase.vendor.gstn_id, :inv => record_items}
          current_ctin = purchase.vendor.gstn_id
        end 
        getexp_b2b
       serialized_array = serialized_array + getexp_b2b


  end

 def purchase_wise_data #Nil rated data
   serialized_array =Hash.new
   intra_purchase = Hash.new
   inter_purchase = Hash.new
   intra_purchase[:cpddr] = 0
   intra_purchase[:exptdsply] = 0
   intra_purchase[:ngsply] = 0
   intra_purchase[:nilsply] = 0
   inter_purchase[:cpddr] = 0
   inter_purchase[:exptdsply] = 0
   inter_purchase[:ngsply] = 0
   inter_purchase[:nilsply] = 0
 
    purchases = object.company.purchases.where(:id => object.gstr_two_items.where(:voucher_classification =>  PURCHASE_CLASSIFICATION['NIL'], :voucher_type => 'Purchase').map{|item| item.voucher_id})
       
    purchases.each do |purchase|
   
     if  purchase.customer_GSTIN.present?
        state_code = purchase.customer_GSTIN.first(2)
      else
        state_code = purchase.vendor.present? ? purchase.vendor.get_state  : purchase.customer.get_state
      end
 
      
      if gstin.first(2) == state_code

            if purchase.tax_line_items.blank?
                  intra_purchase[:ngsply] += purchase.total_amount
            else
                 purchase.tax_line_items.each do |line_item|
                    if line_item.account.name.include?("@Nil")
                     intra_purchase[:nilsply] += purchase.total_amount
                    else
                    intra_purchase[:exptdsply] += purchase.total_amount
                    end

                  end
             end

     else
              if purchase.tax_line_items.blank?
                  inter_purchase[:ngsply] += purchase.total_amount
              else
                 purchase.tax_line_items.each do |line_item|
                    if line_item.account.name.include?("@Nil")
                     inter_purchase[:nilsply] += purchase.total_amount
                    else
                    inter_purchase[:exptdsply] += purchase.total_amount
                    end

                  end
             end
        end
   end


  #here code is for nil expenses
  expenses = object.company.expenses.where(:id => object.gstr_two_items.where(:voucher_classification =>  PURCHASE_CLASSIFICATION['NIL'], :voucher_type => 'Expense').map{|item| item.voucher_id})
  expenses.each do |expense|
   
    if  expense.customer_GSTIN.present?

    state_code = expense.customer_GSTIN.first(2)
    else
        if ['CashAccount','BankAccount'].include?(expense.account.accountable_type)
             state_code = object.company.GSTIN[0,2]
        else
          state_code = expense.vendor.present? ? expense.vendor.get_state  : expense.customer.get_state
        end
    end
 
      
      if gstin.first(2) == state_code

            if expense.tax_line_items.blank?
                  intra_purchase[:ngsply] += expense.total_amount
            else
                 expense.tax_line_items.each do |line_item|
                    if line_item.account.name.include?("@Nil")
                     intra_purchase[:nilsply] += expense.total_amount
                    else
                    intra_purchase[:exptdsply] += expense.total_amount
                    end

                  end
             end

     else
              if expense.tax_line_items.blank?
                  inter_purchase[:ngsply] += expense.total_amount
              else
                 expense.tax_line_items.each do |line_item|
                    if line_item.account.name.include?("@Nil")
                     inter_purchase[:nilsply] += expense.total_amount
                    else
                    inter_purchase[:exptdsply] += expense.total_amount
                    end
                  end
               end
           end
       
 end
   sanitized_intra_hash = {:cpddr=>  intra_purchase[:cpddr].to_f.round(2), :exptdsply => intra_purchase[:exptdsply].to_f.round(2), :ngsply => intra_purchase[:ngsply].to_f.round(2), :nilsply=>  intra_purchase[:nilsply].to_f.round(2)}
    sanitized_inter_hash = {:cpddr=>  inter_purchase[:cpddr].to_f.round(2), :exptdsply => inter_purchase[:exptdsply].to_f.round(2), :ngsply => inter_purchase[:ngsply].to_f.round(2), :nilsply=>  inter_purchase[:nilsply].to_f.round(2)}
   serialized_array = {:inter => sanitized_inter_hash , :intra =>  sanitized_intra_hash }
end

 def b2bur_data #Purchase B2BUR data
     purchases =object.company.purchases.where(:id => object.gstr_two_items.where(:voucher_classification =>  PURCHASE_CLASSIFICATION['B2BUR']).map{|item| item.voucher_id})
      sort_purchase = purchases.sort_by do |item|
            item[:account_id]
      end 
        serialized_array =Array.new
        current_ctin = ''
        record_items = Array.new

        sort_purchase.each do |purchase|
        item = Gstr2B2burSerializer.new(purchase)
        record = item.serializable_hash
      
            if current_ctin.eql?(purchase.vendor.gstn_id)
              record_items.push(record)
              next
            else
              record_items = []
              record_items.push(record)  
          end
        serialized_array << {:inv => record_items}
         
        end 

       getexp_b2bur
       serialized_array = serialized_array + getexp_b2bur 

   
     end

      #following commented code is for Expenses. 
      
    def getexp_b2bur
       expenses =object.company.expenses.where(:id => object.gstr_two_items.where(:voucher_classification =>  PURCHASE_CLASSIFICATION['B2BUR'], :voucher_type => 'Expense').map{|item| item.voucher_id})
       sort_expense = expenses.sort_by do |item|
        item[:account_id]
      end 
      serialized_array =Array.new
      record_items = Array.new

      sort_expense.each do |expense|
        item = Gstr2B2burExpenseSerializer.new(expense)
        record = item.serializable_hash
       
        # if current_ctin.eql?(ctin)
        #   record_items.push(record)
        #   next
        # else
          record_items = []
          record_items .push(record)  
        # end
        serialized_array << {:inv => record_items}
        
      end 
      serialized_array 
    end


   

   def getexp_b2b
    
    expenses =object.company.expenses.where(:id => object.gstr_two_items.where(:voucher_classification =>  PURCHASE_CLASSIFICATION['B2B'], :voucher_type => 'Expense').map{|item| item.voucher_id})
      sort_expense = expenses.sort_by do |item|
            item[:account_id]
      end 
        serialized_array =Array.new
        current_ctin = ''
        record_items = Array.new

        sort_expense.each do |expense|
        item = Gstr2B2bExpenseSerializer.new(expense)
        record = item.serializable_hash
            ctin = expense.customer_GSTIN
           if current_ctin.eql?(ctin)
              record_items.push(record)
              next
            else
              record_items = []
              record_items .push(record)  
          end
        serialized_array << {:ctin=> ctin, :inv => record_items}
          current_ctin = ctin
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

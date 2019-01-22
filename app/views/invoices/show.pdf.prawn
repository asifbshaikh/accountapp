require 'open-uri'
pdf = Prawn::Document.new(:page_layout => :portrait, :page_size => "A4")
  customer = @invoice.account.customer.blank? ? @invoice.account.vendor : @invoice.account.customer
  pos_arr=[]
  y_position = pdf.cursor
  pdf.bounding_box([0, 800], :width => (pdf.bounds.width/2) - 5) do 
   unless @company.logo_file_name.blank? 
       pdf.image open("#{@company.logo.url}"), :fit=> 
      Prawn::Document::PageGeometry::SIZES["A8"]
    end
  end
  pdf.bounding_box([340, 810], :width => (pdf.bounds.width/2)) do
  pdf.table([
        [{:content => "#{@company.name}", :font_style=>:bold}],
      ],
      :width => (pdf.bounds.width - 75), :cell_style =>{:border_width => 0,:align => :right, :inline_format => true, :size => 9})do
    end
  pdf.table([
        ["#{@company.address.get_address unless @company.address.blank?}"],
        ["Phone: #{@company.phone unless @company.phone.blank?}"],
      ],
      :width => (pdf.bounds.width/2 + 55), :cell_style =>{:border_width => 0,:align => :right, :inline_format => true, :size => 8})do
    end 
  end
 pdf.move_down 10
 pdf.bounding_box([-25, y_position], :width => (pdf.bounds.width + 30)) do
  if @company.plan.smb_plan?
    pdf.move_down 10
    pdf.text "<b>#{@invoice.invoice_title}</b>", :align => :center, :inline_format => true, :size => 14
    pdf.stroke_horizontal_rule  
  else
    pdf.move_down 10
    pdf.text "<b>INVOICE</b>", :align => :center, :inline_format => true, :size => 14
    pdf.stroke_horizontal_rule  
  end
  end
  
  if @invoice.cash_invoice? 
    pdf.move_down 10
    y_position = pdf.cursor
    pdf.bounding_box([-25, y_position], :width => (pdf.bounds.width/2) - 100) do
    pdf.table([
            [{:content =>"Bill to:", :font_style => :bold, :align => :left }],
             ["<b>#{@invoice.cash_customer_name unless @invoice.cash_customer_name.blank?}</b>"],
             ["#{@invoice.cash_customer_email unless @invoice.cash_customer_email.blank?}"],
             ["#{@invoice.cash_customer_mobile unless @invoice.cash_customer_mobile.blank?}"],
             [{:content => "This sentense is not visible to you i know", :inline_format=> true, :align => :left, :text_color => 'FFFFFF'}],
             ],
             :cell_style =>{:align => :left,:inline_format => true,:border_width =>0, :size => 8, :border_color => "70B8FF" , :height=> 17})do
         row(0).borders = [:left, :right, :bottom, :top]
         row(0).background_color = 'F2F7FF'
         row(1..4).borders = [:left, :right]
         row(4).borders = [:left, :right, :bottom]
   row(0..4).border_width = 0.2
    end
    pos_arr<<pdf.y
  end
  
  else
pdf.move_down 10
y_position = pdf.cursor

pdf.bounding_box([-25, y_position], :width => (pdf.bounds.width/2)-100) do
  data = [[{:content =>"Bill To:", :font_style => :bold, :align => :left}]]
  data += [[{:content =>"#{@invoice.account.name }", :font_style => :bold, :align => :left}]]
  if !customer.billing_address.blank? 
  data += [[{:content =>"#{customer.billing_address.address_line1 unless customer.billing_address.blank?}", :align => :left}]]
  unless customer.billing_address.city.blank?
    data += [[{:content =>"City: #{customer.billing_address.city}", :font_style => :bold, :align => :left}]]  
  end
  unless customer.billing_address.state.blank?
    data += [[{:content =>"State: #{customer.billing_address.state}", :font_style => :bold, :align => :left}]]  
  end
  end
 if !customer.email.blank?
  data += [[{:content =>"Email: #{customer.email unless customer.nil?}", :font_style => :bold, :align => :left}]]
 end
 if !customer.contact_number.blank?
  data += [[{:content =>"Contact #: #{customer.contact_number unless customer.nil?}", :font_style => :bold, :align => :left}]]
 end
 if !customer.vat_tin.blank?
  data += [[{:content =>"TIN: #{customer.vat_tin unless customer.nil?}", :font_style => :bold, :align => :left}]]
end
if !customer.pan.blank?
  data += [[{:content =>"PAN: #{customer.pan unless customer.nil?}", :font_style => :bold, :align => :left}]]
end
if !customer.cst_reg_no.blank?
  data += [[{:content =>"CST Reg.#: #{customer.cst_reg_no unless customer.nil?}", :font_style => :bold, :align => :left}]]
end
    pdf.table(data,:width=>(pdf.bounds.width),  :cell_style =>{:align => :left,:inline_format => true,:border_width =>0, :size => 8, :border_color => "70B8FF" })do
         row(0).borders = [:left, :right, :bottom, :top]
         row(0).background_color = 'F2F7FF'
         row(1..(data.size-2)).borders = [:left, :right]
         row(data.size - 1).borders = [:left, :right, :bottom]
         row(0..(data.size - 1)).border_width = 0.1
      end

      pos_arr<<pdf.y
  end 

 if !customer.shipping_address.blank?
  pdf.bounding_box([200, y_position], :width => (pdf.bounds.width/2)-100 ) do
  pdf.table([
          [{:content =>"Ship to:", :font_style => :bold, :align => :left, :height=> 17} ],
          [{:content => "#{@invoice.account.name unless @invoice.account.blank?}", :font_style=> :bold, :height=> 17}],
          [{:content => "#{customer.shipping_address.address_line1 unless customer.shipping_address.address_line1.blank?}"}],
          [{:content => "This sentense will not visible to you i know", :inline_format=> true, :align => :left, :text_color => 'FFFFFF'}],
           ],
     :cell_style =>{:align => :left,:inline_format => true,:border_width =>0, :size => 8, :border_color => "70B8FF" })do
         row(0).borders = [:left, :right, :bottom, :top]
         row(0).background_color = 'F2F7FF'
         row(1..3).borders = [:left, :right]
         row(3).borders = [:left, :right, :bottom]
         row(0..3).border_width = 0.2
    end
    pos_arr<<pdf.y
  end
end
end

  pdf.bounding_box([390, y_position], :width => ((pdf.bounds.width / 2+10))  ) do
    data = [[{:content =>"Invoice #:", :font_style => :bold, :align => :left}, {:content =>"#{@invoice.invoice_number}"}]]
    data += [[{:content =>"Invoice date:", :font_style => :bold, :align => :left}, {:content =>"#{@invoice.invoice_date.strftime("%d-%m-%Y")}"}]]
    if !@invoice.cash_invoice?
    data += [[{:content =>"Due date:", :font_style => :bold, :align => :left}, {:content =>"#{@invoice.due_date.strftime("%d-%m-%Y")}"}]]
    end
    data += [[{:content =>"Amount:", :font_style => :bold, :align => :left}, {:content =>"#{@invoice.currency} #{@invoice.amount.to_s}"}]]
    
   if !@invoice.po_reference.blank?
    data += [[{:content =>"PO #:", :font_style => :bold, :align => :left}, {:content =>"#{@invoice.po_reference}"}]]
   end
  if !@custom_field.blank? && !@company.plan.free_plan?
   if !@custom_field.custom_label1.blank? && !@invoice.custom_field1.blank?
    data +=[[{:content => "#{@custom_field.custom_label1}", :font_style => :bold, :align => :left},{:content => "#{@invoice.custom_field1}"}]]
   end 

   if !@custom_field.custom_label2.blank? && !@invoice.custom_field2.blank?
    data +=[[{:content => "#{@custom_field.custom_label2}", :font_style => :bold, :align => :left},{:content => "#{@invoice.custom_field2}"}]]
   end 

    if !@custom_field.custom_label3.blank? && !@invoice.custom_field3.blank?
    data +=[[{:content => "#{@custom_field.custom_label3}", :font_style => :bold, :align => :left},{:content => "#{@invoice.custom_field3}"}]]
   end 
end
    data += [[{:content =>"Created by:", :font_style => :bold, :align => :left}, {:content =>"#{User.find(@invoice.created_by).first_name}"}]]

    pdf.table(data, :row_colors => ["F2F7FF"], :cell_style =>{:height=> 17,:align => :left, :border_width => 0, :size => 8})do
    end

    pos_arr<<pdf.y
  end

  
  n = (@invoice.time_invoice?) ? @time_line_items.count : (@invoice_line_items.count+1) 
  
      data = []
     
     if @invoice.time_invoice? 
      sub_data = ["Task","Description",{:content => "Hours",:align => :right},{:content =>"Rate", :align => :right},{:content => "Amt", :align => :right}]
      
      if @invoice.discount != 0
       sub_data.insert(4, {:content=>"Disc%", :align=>:right})
      else
        sub_data.insert(4, {:content => "HI", :inline_format=> true, :align => :right, :text_color => 'FFFFFF'})
      end
     
      if @invoice.discount != 0 && @invoice.tax != 0
       sub_data.insert(5, {:content=>"Tax Rate"})
       sub_data.insert(6, {:content=>"Tax Amt"})
      elsif @invoice.discount == 0 && @invoice.tax != 0
        sub_data.insert(4, {:content=>"Tax Rate"})
        sub_data.insert(5, {:content=>"Tax Amt"})
      end
      data<<sub_data
     
     for i in @time_line_items
      sub_data = [{:content => "#{i.item_name}"},
                    {:content => "#{i.description}"},
                    {:content =>"#{i.quantity}",:align => :right},
                    {:content => "#{i.unit_rate.to_s}", :align => :right},
                    {:content => "#{i.amount.to_s}", :align => :right}]
      
       if !i.discount_percent.blank? && i.discount_percent>0
        sub_data.insert(4, {:content=>"#{i.discount_percent}", :align=>:right})
       else
        sub_data.insert(4, {:content => "HI", :inline_format=> true, :text_color => 'FFFFFF'})
       end              
      
       if @invoice.tax != 0 && @invoice.discount != 0
        if !i.tax_account.blank?
         sub_data.insert(5, {:content=>"#{i.tax_account.name.chomp('on sales')}"})
         sub_data.insert(6, {:content=>"#{i.tax_amount}", :align=>:right})
        else
         sub_data.insert(5, {:content => "HI", :inline_format=> true, :text_color => 'FFFFFF'})
         sub_data.insert(6, {:content => "HI", :inline_format=> true, :text_color => 'FFFFFF'})
        end
       elsif @invoice.discount == 0 && @invoice.tax != 0
        if !i.tax_account.blank?
         sub_data.insert(4, {:content=>"#{i.tax_account.name.chomp('on sales')}"})
         sub_data.insert(5, {:content=>"#{i.tax_amount}", :align=>:right})
        else
         sub_data.insert(4, {:content => "HI", :inline_format=> true,:text_color => 'FFFFFF'})
         sub_data.insert(5, {:content => "HI", :inline_format=> true,:text_color => 'FFFFFF'})
        end
       end
      data<<sub_data
      
     end

    else

      sub_data =[{:content => "#{!@company.invoice_setting.item_label.blank? ? @company.invoice_setting.item_label : 'Item'}"},
       {:content => "#{!@company.invoice_setting.desc_label.blank? ? @company.invoice_setting.desc_label : 'Description'}"},
       {:content => "#{!@company.invoice_setting.qty_label.blank? ? @company.invoice_setting.qty_label : 'Qty'}",:align => :right},
       {:content =>"#{!@company.invoice_setting.rate_label.blank? ? @company.invoice_setting.rate_label : 'Unit Cost'}", :align => :right},
       {:content => "#{!@company.invoice_setting.amount_label.blank? ? @company.invoice_setting.amount_label : 'Amt'}", :align => :right}]

      if @invoice.discount != 0
       sub_data.insert(4, {:content=>"Disc%", :align=>:right})
      else
        sub_data.insert(4, {:content => "HI", :inline_format=> true, :text_color => 'FFFFFF'})
      end
     
      if @invoice.discount != 0 && @invoice.tax != 0
       sub_data.insert(5, {:content=>"Tax Rate"})
       sub_data.insert(6, {:content=>"Tax Amt"})
      elsif @invoice.discount == 0 && @invoice.tax != 0
        sub_data.insert(4, {:content=>"Tax Rate"})
        sub_data.insert(5, {:content=>"Tax Amt"})
      end
      data<<sub_data
     
     for i in @invoice_line_items
       if i.product.batch_enable?
       sub_data = [{:content =>"#{i.item_name}"},
                  {:content => "#{i.description}, Batch numbers: #{i.batch_number}"},
                  {:content =>"#{i.quantity}",:align => :right},
                  {:content => "#{i.unit_rate.to_s}", :align => :right},
                  {:content => "#{i.amount.to_s}", :align => :right}]
       else
       sub_data = [{:content =>"#{i.item_name}"},
                  {:content => "#{i.description}"},
                  {:content =>"#{i.quantity}",:align => :right},
                  {:content => "#{i.unit_rate.to_s}", :align => :right},
                  {:content => "#{i.amount.to_s}", :align => :right}]
       end

       if !i.discount_percent.blank? && i.discount_percent>0
        sub_data.insert(4, {:content=>"#{i.discount_percent}", :align=>:right})
       else
        sub_data.insert(4, {:content => "HI", :inline_format=> true, :text_color => 'FFFFFF'})
       end              
      
       if @invoice.tax != 0 && @invoice.discount != 0
        if !i.tax_account.blank?
         sub_data.insert(5, {:content=>"#{i.tax_account.name.chomp('on sales')}"})
         sub_data.insert(6, {:content=>"#{i.tax_amount}", :align=>:right})
        else
         sub_data.insert(5, {:content => "HI", :inline_format=> true, :text_color => 'FFFFFF'})
         sub_data.insert(6, {:content => "HI", :inline_format=> true, :text_color => 'FFFFFF'})
        end
       elsif @invoice.discount == 0 && @invoice.tax != 0
        if !i.tax_account.blank?
         sub_data.insert(4, {:content=>"#{i.tax_account.name.chomp('on sales')}"})
         sub_data.insert(5, {:content=>"#{i.tax_amount}", :align=>:right})
        else
         sub_data.insert(4, {:content => "HI", :inline_format=> true, :text_color => 'FFFFFF'})
         sub_data.insert(5, {:content => "HI", :inline_format=> true, :text_color => 'FFFFFF'})
        end
      end
       data<<sub_data
     end
     sub_data = ["",{:content => "Total Qty", :font_style => :bold, :align => :right},{:content => " #{ @invoice.total_quantity}", :font_style => :bold, :align => :right},"",""]
     
       if @invoice.discount != 0 
        sub_data.insert(4, {:content => "HI", :inline_format=> true, :text_color => 'FFFFFF'})
      elsif @invoice.discount == 0 
        sub_data.insert(3, {:content => "HI", :inline_format=> true, :text_color => 'FFFFFF'})
       end              
      
       if @invoice.tax != 0 && @invoice.discount != 0
         sub_data.insert(5, {:content => "HI", :inline_format=> true, :text_color => 'FFFFFF'})
         sub_data.insert(6, {:content => "HI", :inline_format=> true, :text_color => 'FFFFFF'})
       elsif @invoice.discount == 0 && @invoice.tax != 0
         sub_data.insert(4, {:content => "HI", :inline_format=> true, :text_color => 'FFFFFF'})
         sub_data.insert(5, {:content => "HI", :inline_format=> true, :text_color => 'FFFFFF'})
      end
    data<<sub_data
end

   

  pdf.bounding_box([-25, (pos_arr.min.to_i-50)], :width => (pdf.bounds.width + 30)) do 
     pdf.table(data, :header => true,  :width => pdf.bounds.width,:row_colors => ["FFFFFF"] , :cell_style =>{:border_width => 0,:border_color => "70B8FF",  :size => 8}, :column_widths => {0 => 100, 1 => 150 }) do
      row(0).font_style = :bold
      row(0).background_color = 'F2F7FF'
      row(0).borders = [:top,:right,:left ,:bottom]
      row(1..n).borders = [:right,:left]
      row(n).borders = [:top,:right,:left, :bottom]
      row(0..n).border_width = 0.2
      row(n).border_width = 0.2
    end
   end
   
   data=[]
   m = @shipping_line_items.count+1
   m+= @invoice.tax_line_items.count+1
   m+=2
    for i in @tax_line_items
      sub_data = ["","","",{:content => "#{i.account.name.chomp('on sales')}", :align => :right},
                {:content => "#{@invoice.group_tax_amt(i.account_id).to_s}", :align => :right}]
      
      unless @invoice.discount == 0
        sub_data.insert(3, "")
       end              
       unless @invoice.tax ==0
        sub_data.insert(4, "")
        sub_data.insert(5, "")
       end
       data<<sub_data
      end 
    
    
    
    for i in @shipping_line_items
     sub_data = ["","","",{:content => "#{i.account.name}", :align => :right},{:content => "#{i.amount.to_s}", :align => :right}]
      
      unless @invoice.discount == 0
        sub_data.insert(3, "")
       end              
       unless @invoice.tax ==0
        sub_data.insert(4, "")
        sub_data.insert(5, "")
       end

      data<<sub_data
    end 
    

  
  sub_data = ["","","",{:content => "Sub total", :font_style => :bold, :align => :right},{:content => " #{@invoice.currency} #{@invoice.sub_total.to_s}", :font_style => :bold, :align => :right}]

     unless @invoice.discount == 0
      sub_data.insert(3, "")
     end              
     unless @invoice.tax ==0
      sub_data.insert(4, "")
      sub_data.insert(5, "")
     end
     data<<sub_data
  
  if !@invoice.discount.blank? && @invoice.discount != 0 
    sub_data = ["","","","",{:content => "Discount", :font_style => :bold, :align => :right},{:content => " #{@invoice.currency} #{@invoice.discount.to_s}", :font_style => :bold, :align => :right}]

     unless @invoice.tax ==0
      sub_data.insert(4, "")
      sub_data.insert(5, "")
     end
     data<<sub_data
  end

    if  @invoice.tax!= 0
      sub_data = ["","","",{:content => "Tax", :font_style => :bold, :align => :right},{:content => " #{@invoice.currency} #{@invoice.tax.to_s}", :font_style => :bold, :align => :right}]
       unless @invoice.discount == 0
        sub_data.insert(3, "")
       end              
       unless @invoice.tax ==0
        sub_data.insert(4, "")
        sub_data.insert(5, "")
       end
      data<<sub_data
    end
    
    sub_data = ["","","",{:content => "Total", :font_style => :bold, :align => :right},{:content => " #{@invoice.currency} #{@invoice.amount.to_s}", :font_style => :bold, :align => :right}]
  
     unless @invoice.discount == 0
      sub_data.insert(3, "")
     end              
     unless @invoice.tax ==0
      sub_data.insert(4, "")
      sub_data.insert(5, "")
     end
    data<<sub_data

   if !@invoice.cash_invoice?
        sub_data = [{:content=>"#{'LBT Reg.No.' unless @company.lbt_registration_number.blank?}", :font_style=>:bold, :align=>:right},{:content=>"#{@company.lbt_registration_number}", :align=>:left },"",{:content => "Payment received", :font_style => :bold, :align => :right},{:content => " #{@invoice.currency} #{@invoice.received_amt.to_s}", :font_style => :bold, :align => :right}]
      
    if @invoice.receipt_vouchers.sum(:tds_amount) > 0
      sub_data = ["","","",{:content => "TDS Amount", :font_style => :bold, :align => :right},{:content => " #{@invoice.currency}  #{@invoice.tds_amt.to_s}", :font_style => :bold, :align => :right}]

       unless @invoice.discount == 0
        sub_data.insert(3, "")
       end              
       unless @invoice.tax ==0
        sub_data.insert(4, "")
        sub_data.insert(5, "")
       end
      data<<sub_data
    end

   if @invoice.invoice_status_id == 0 && @invoice.outstanding > 0
    sub_data = ["","","",{:content => "Balance due", :font_style => :bold, :align => :right},{:content => " #{@invoice.currency} #{@invoice.outstanding.to_s}", :font_style => :bold, :align => :right}]
   end 
 
  if @invoice.invoice_status_id == 2 && @invoice.exchange_rate !=0
    if !@invoice.discount.blank? && @invoice.discount != 0
    data += [["","","","",{:content => "#{(@invoice.gain_or_loss > 0) ? "Loss" : "Gain"}", :font_style => :bold, :align => :right},{:content => "#{@invoice.gain_or_loss.abs}", :font_style => :bold, :align => :right}]]
    else
    data += [["","","",{:content => "#{(@invoice.gain_or_loss > 0) ? "Loss" : "Gain"}", :font_style => :bold, :align => :right},{:content => "#{@invoice.gain_or_loss.abs}", :font_style => :bold, :align => :right}]]
    end
  end

  end
   unless @invoice.discount == 0
    sub_data.insert(3, "")
   end              
   unless @invoice.tax ==0
    sub_data.insert(4, "")
    sub_data.insert(5, "")
   end
  data<<sub_data

  y_position = pdf.cursor
  pdf.bounding_box([-25, (y_position)], :width => (pdf.bounds.width + 30)) do 
    pdf.table(data, :header => true,  :width => (pdf.bounds.width+5),:row_colors => ["FFFFFF"] , :cell_style =>{:border_width => 0,:border_color => "70B8FF",  :size => 8, :height=> 17}) do
                row(m).borders = [:top, :bottom]
                row(m).border_width = 0.2
                row(m).background_color = 'F2F7FF'
                
    end
   end
  
pdf.move_down 20
 y_position = pdf.cursor
  pdf.span(100, :position => :left) do
  if !@company.pan.blank? || !@company.tin.blank? || !@company.VAT_no.blank? || !@company.CST_no.blank? || !@company.service_tax_reg_no.blank?
    pdf.text "<b>Tax Details: </b>", :size=> 8, :inline_format => true
  end
  
  if !@company.pan.blank? 
    pdf.text"<b>PAN:</b> #{@company.pan}", :size=> 8, :inline_format => true
  end
  if !@company.tin.blank? 
    pdf.text"<b>TIN:</b> #{@company.tin}", :size=> 8, :inline_format => true
  end
  if !@company.VAT_no.blank? 
    pdf.text"<b>VAT:</b> #{@company.VAT_no}", :size=> 8, :inline_format => true
  end
  if !@company.CST_no.blank? 
    pdf.text"<b>CST:</b> #{@company.CST_no}", :size=> 8, :inline_format => true
  end
  if !@company.service_tax_reg_no.blank? 
    pdf.text"<b>Service Tax No.:</b> #{@company.service_tax_reg_no}", :size=> 8, :inline_format => true
  end
end
 
if !@invoice.cash_invoice?
pdf.move_down 25
  if @invoice.receipt_vouchers.blank?
       pdf.text "Payment is due for this invoice.",:size => 8
      else
       pdf.text "Payment recieved for this invoice",:size => 8
       pdf.move_down 10
         n = @receipt_vouchers.count
       if @receipt_vouchers.sum('tds_amount') > 0
       data = [["Voucher Number","Voucher Date","Payment Received Date","Payment Mode" ,{:content => "TDS", :align => :right},{:content => "Amount", :align => :right}]]
       else
       data = [["Voucher Number","Voucher Date","Payment Received Date","Payment Mode" ,{:content => "Amount", :align => :right}]]
       end
       for i in @receipt_vouchers
        receipt_voucher = i.receipt_voucher
       if !i.tds_amount.blank? && i.tds_amount>0
      data +=[["#{receipt_voucher.voucher_number}","#{receipt_voucher.voucher_date}","#{receipt_voucher.received_date}","#{receipt_voucher.payment_detail.payment_mode}",{:content => "#{@invoice.currency} #{i.tds_amount.to_s}", :align => :right},{:content => "#{@invoice.currency} #{i.amount.to_s}", :align => :right}]]
      else
       data +=[["#{receipt_voucher.voucher_number}","#{receipt_voucher.voucher_date}","#{receipt_voucher.received_date}","#{receipt_voucher.payment_detail.payment_mode}",{:content => "#{@invoice.currency} #{i.amount.to_s}", :align => :right}]]
      end
      end
      if @receipt_vouchers.sum('tds_amount') > 0
      data += [["","","","",{:content => "Total", :font_style => :bold, :align => :right},{:content => " #{@invoice.currency} #{(@invoice.total_received_amt).to_s}", :font_style => :bold, :align => :right}]]
      else
  data += [["","","",{:content => "Total", :font_style => :bold, :align => :right},{:content => " #{@invoice.currency} #{(@invoice.total_received_amt).to_s}", :font_style => :bold, :align => :right}]]
  end
       pdf.table(data, :header => true, :width => (pdf.bounds.width),:row_colors => ["FFFFFF"] , :cell_style =>{:height => 17, :border_width => 0,:border_color => "70B8FF",  :size => 8}) do
  row(0).font_style = :bold
        row(0).background_color = 'F2F7FF'
        row(0).borders = [:top, :bottom]
        row(0).border_width = 0.2
        row(n).borders = [:bottom]
        row(n).border_width = 0.2 
        row(n+1).background_color = ["70B8FF"]
        row(n+1).borders = [:top, :bottom]
        row(n+1).border_width = 0.2
    end
   end
  end 

pdf.move_down 10
 if !@invoice.customer_notes.blank?   
 pdf.span(530, :position => :left) do
    pdf.text"<b>#{@company.label.customer_label} Notes:</b>", :size=> 8, :inline_format => true
     pdf.text "#{(@invoice.customer_notes)}",:size => 8
 end
end

 
 pdf.move_down 10
 y_position = pdf.cursor
 if !@invoice.terms_and_conditions.blank?   
  pdf.span(530, :position => :left) do
        pdf.text "<b>Terms & Conditions</b>",:size => 8, :inline_format => true
        pdf.text "#{(@invoice.terms_and_conditions)}",:size => 8
  end
 end  



pdf.move_down 10
y_position = pdf.cursor
if @company.invoice_setting.footer_enabled? 
  pdf.bounding_box([0, y_position], :width => (pdf.bounds.width)) do
    pdf.fill_color "000000"
    pdf.text "#{@company.invoice_setting.invoice_footer}", :inline_format=>true, :size => 7
  end
end

pdf.page_count.times do |i|
  pdf.go_to_page(i+1)
  pdf.fill_color "ADADAD"
  if @footer.nil? || @footer.strip == ''
   pdf.draw_text "#{@company.watermark unless @company.watermark.blank?}", :at=>[0,-10], :size => 7
  else
    pdf.draw_text @footer.strip, :at => [0,-10], :size => 7
  end
  pdf.fill_color "000000"
  pdf.draw_text "Page : #{i+1} / #{pdf.page_count}", :at=>[pdf.bounds.width - 50,-10], :size => 8
end
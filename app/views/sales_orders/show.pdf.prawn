require 'open-uri'

pdf = Prawn::Document.new(:page_layout => :portrait, :page_size => "A4")
  
  y_position = pdf.cursor
  if !@sales_order.customer_id.blank?
  customer =  @sales_order.customer
  end
  pos_arr=[]

pdf.bounding_box([0, 790], :width => (pdf.bounds.width/2) - 5) do 
  
   unless @company.logo_file_name.blank? 
     pdf.image open("#{@company.logo.url}"), :fit=> 
      Prawn::Document::PageGeometry::SIZES["A8"]
    end
  
  end
  pdf.bounding_box([340, 790], :width => (pdf.bounds.width/2)) do
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
  pdf.move_down 20
  pdf.text "<b>SALES ORDER</b>", :align => :center, :inline_format => true, :size => 14
  pdf.stroke_horizontal_rule	

pdf.move_down 10
  y_position = pdf.cursor
  pdf.bounding_box([0, y_position], :width => (pdf.bounds.width/2)-100) do
  data = [[{:content =>"Bill To:", :font_style => :bold, :align => :left}]]
  data += [[{:content =>"#{@sales_order.customer_name unless @sales_order.customer_id.blank?}", :font_style => :bold, :align => :left}]]
 if !customer.blank? 
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
 if !customer.primary_phone_number.blank?
  data += [[{:content =>"Contact #: #{customer.primary_phone_number unless customer.nil?}", :font_style => :bold, :align => :left}]]
 end
 if !customer.vat_tin.blank?
  data += [[{:content =>"TIN: #{customer.vat_tin unless customer.nil?}", :font_style => :bold, :align => :left}]]
end
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

 pdf.bounding_box([330, y_position], :width => (pdf.bounds.width / 2) - 5) do
    data = [[{:content =>"Sales Order Number:", :font_style => :bold, :align => :left}, {:content =>"#{@sales_order.voucher_number}"}]]
    data += [[{:content =>"Status:", :font_style => :bold, :align => :left}, {:content =>"#{@sales_order.get_status}"}]]
    data += [[{:content =>"Billing Status:", :font_style => :bold, :align => :left}, {:content =>"#{@sales_order.get_billing_status}"}]]
    data += [[{:content =>" date:", :font_style => :bold, :align => :left}, {:content =>"#{@sales_order.voucher_date}"}]]
    data += [[{:content =>"Amount", :font_style => :bold, :align => :left}, {:content =>"#{@currency+" "+ format_amount(@sales_order.amount.to_s)}"}]]
    data += [[{:content =>"PO Ref", :font_style => :bold, :align => :left}, {:content =>"#{@sales_order.po_reference}"}]] unless @sales_order.po_reference.blank?
    data += [[{:content =>"PO Date", :font_style => :bold, :align => :left}, {:content =>"#{@sales_order.po_date}"}]] unless @sales_order.po_date.blank?
    data += [[{:content =>"Created by:", :font_style => :bold, :align => :left}, {:content =>"#{@sales_order.created_by_user}"}]]
    data += [[{:content =>"Place of supply:", :font_style => :bold, :align => :left}, {:content =>"#{@sales_order.place_of_supply_state}"}]]

    pdf.table(data, :row_colors => ["F2F7FF"], :cell_style =>{:height=>17,:align => :left, :border_width => 0, :size => 8})do
    end
    pos_arr<<pdf.y
  end

 pdf.move_down 60
	n = @sales_order_line_items.count 


if !@sales_order.get_discount.blank? && @sales_order.get_discount != 0 
     
     data = [[{:content => "#{!@company.invoice_setting.item_label.blank? ? @company.invoice_setting.item_label : 'Item'}"},
     {:content => "#{!@company.invoice_setting.desc_label.blank? ? @company.invoice_setting.desc_label : 'Description'}"},
     {:content => "#{!@company.invoice_setting.qty_label.blank? ? @company.invoice_setting.qty_label : 'Qty'}",:align => :right},
     {:content =>"#{!@company.invoice_setting.rate_label.blank? ? @company.invoice_setting.rate_label : 'Unit Cost'}", :align => :right},
     {:content => "#{!@company.invoice_setting.discount_label.blank? ? @company.invoice_setting.discount_label : 'Discount %'}",:align =>:right},
     {:content => "#{!@company.invoice_setting.amount_label.blank? ? @company.invoice_setting.amount_label : 'Amount'}", :align => :right}]]
    
     for i in @sales_order_line_items
      data += [["#{i.item_name}","#{(i.description)}",{:content =>"#{i.quantity} #{i.product.unit_of_measure}",:align => :right},{:content => "#{format_amount(i.unit_rate.to_s)}", :align => :right},{:content => "#{format_amount(i.discount)}", :align => :right},{:content => "#{format_amount(i.amount.to_s)}", :align => :right}]]
     end 
     data += [["",{:content => "Total Qty", :font_style => :bold, :align => :right},{:content => " #{@sales_order.total_quantity}", :font_style => :bold, :align => :right},"","",""]]
     for i in @tax_line_items
      data += [["",{:content => "#{i.account.name}", :align => :right},"","","",{:content => "#{ @sales_order.group_tax_amt(i.account_id).to_s}", :align => :right}]]
     end 
    
  else
  
   data = [["Item","Description",{:content => "Qty",:align => :right},{:content =>"Unit Cost", :align => :right},{:content => "Amount", :align => :right}]]
  
   for i in @sales_order_line_items
      data += [["#{i.item_name}","#{(i.description)}",{:content =>"#{i.quantity} #{i.product.unit_of_measure unless i.product.blank?}",:align => :right},{:content => "#{ i.unit_rate.to_s}", :align => :right},{:content => "#{format_amount(i.amount.to_s)}", :align => :right}]]
   end  
   data += [["",{:content => "Total Qty", :font_style => :bold, :align => :right},{:content => " #{ @sales_order.total_quantity}", :font_style => :bold, :align => :right},"",""]]
   
   for i in @tax_line_items
   tax_account = i.account
      next if (tax_account.accountable_type=='DutiesAndTaxesAccounts' && tax_account.accountable.calculation_method==4 && tax_account.accountable.split_tax == 0)      
    data += [["",{:content => "#{i.account.name}", :align => :right},"","",{:content => "#{@sales_order.group_tax_amt(i.account_id).to_s}", :align => :right}]]
   end 
  
  end
   pdf.bounding_box([0, (pos_arr.min.to_i-50)], :width => (pdf.bounds.width)) do 
   pdf.table(data, :header => true,  :width => (pdf.bounds.width),:row_colors => ["FFFFFF"] ,:cell_style =>{:border_width => 0,:border_color => "70B8FF",  :size => 8}, :column_widths => {0 => 100, 1 => 150 }) do
    row(0).font_style = :bold
                row(0).background_color = 'F2F7FF'
                row(0).borders = [:top,:bottom]
                row(0).border_width = 0.2
                row(n).borders = [:bottom]
                row(n).border_width = 0.2
                
    end
  end
  if !@sales_order.get_discount.blank? && @sales_order.get_discount != 0 
 
    data = [["","","","",{:content => "Sub total", :font_style => :bold, :align => :right},{:content => " #{@currency +" "+ format_amount(@sales_order_line_items.sum(:amount).to_s)}", :font_style => :bold, :align => :right}]] 
    
    data += [["","","","",{:content => "Discount", :font_style => :bold, :align => :right},{:content => " #{@currency +" "+ format_amount(@sales_order.get_discount.to_s)}", :font_style => :bold, :align => :right}]] 
    
    if  @sales_order.tax!= 0
     data += [["","","","",{:content => "Tax", :font_style => :bold, :align => :right},{:content => " #{@currency +" "+ format_amount(@sales_order.tax.to_s)}", :font_style => :bold, :align => :right}]]
    end
  
   for i in @shipping_line_items
      data += [["","","","",{:content => "#{i.account.name}", :align => :right, :font_style=> :bold},{:content => "#{format_amount(i.amount.to_s)}", :align => :right,:font_style => :bold}]]
   end 
     

    data += [["","","","",{:content => "Total", :font_style => :bold, :align => :right},{:content => " #{@currency +" "+ format_amount(@sales_order.amount.to_s)}", :font_style => :bold, :align => :right}]]
  
   else
   
     data = [["","","",{:content => "Sub total", :font_style => :bold, :align => :right},{:content => " #{@currency +" "+ format_amount(@sales_order_line_items.sum(:amount).to_s)}", :font_style => :bold, :align => :right}]] 
   
    if @sales_order.tax!= 0  
     data += [["","","",{:content => "Tax", :font_style => :bold, :align => :right},{:content => " #{@currency +" "+ format_amount(@sales_order.tax.to_s)}", :font_style => :bold, :align => :right}]]
    end
   
    for i in @shipping_line_items
      data += [["","","",{:content => "#{i.account.name}", :align => :right, :font_style=> :bold},{:content => "#{format_amount(i.amount.to_s)}", :align => :right,:font_style => :bold}]]
   end 
      
   
    data += [["","","",{:content => "Total", :font_style => :bold, :align => :right},{:content => " #{@currency +" "+ format_amount(@sales_order.amount.to_s)}", :font_style => :bold, :align => :right}]]
   
  end
   if @sales_order.get_discount != 0 && @sales_order.tax != 0 
    pdf.table(data, :header => true,  :width => (pdf.bounds.width),:row_colors => ["FFFFFF"] ,:cell_style =>{:border_width => 0,:border_color => "70B8FF",  :size => 8, :height=> 17}) do
                row(3).borders = [:top, :bottom]
                row(3).border_width = 0.2
                row(3).background_color = 'F2F7FF'
                
    end
    elsif (@sales_order.get_discount != 0 && @sales_order.tax == 0) || (@sales_order.get_discount == 0 && @sales_order.tax != 0 )
    pdf.table(data, :header => true,  :width => (pdf.bounds.width),:row_colors => ["FFFFFF"] ,:cell_style =>{:border_width => 0,:border_color => "70B8FF",  :size => 8, :height=> 17}) do
                row(2).borders = [:top, :bottom]
                row(2).border_width = 0.2
                row(2).background_color = 'F2F7FF'
                
    end
    elsif @sales_order.get_discount == 0 && @sales_order.tax == 0
    pdf.table(data, :header => true,  :width => (pdf.bounds.width),:row_colors => ["FFFFFF"] ,:cell_style =>{:border_width => 0,:border_color => "70B8FF",  :size => 8, :height=> 17}) do
                row(1).borders = [:top, :bottom]
                row(1).border_width = 0.2
                row(1).background_color = 'F2F7FF'
                
    end
   end
	
	
pdf.move_down 20
y_position = pdf.cursor
 if !@sales_order.customer_notes.blank?
    pdf.bounding_box([0, y_position], :width => (pdf.bounds.width/2)-10) do
     pdf.text"<b>#{@company.label.customer_label} Notes:</b>", :size=> 8, :inline_format => true
     pdf.text "#{(@sales_order.customer_notes)}",:size => 8
    end
 end
 
 
pdf.draw_text "-------------------", :at =>[pdf.bounds.width-70, 40]
pdf.draw_text "Authorised Signatory",:size => 8,:at=>[pdf.bounds.width-70, 32]

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
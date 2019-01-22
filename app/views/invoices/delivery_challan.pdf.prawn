require 'open-uri'
pdf = Prawn::Document.new(:page_layout => :portrait, :page_size => "A4")
  y_position = pdf.cursor
  pos_arr=[]
  customer = @invoice.account.customer.blank? ? @invoice.account.vendor : @invoice.account.customer
  pdf.bounding_box([0, 790], :width => (pdf.bounds.width/2) - 5) do 
   unless @company.logo_file_name.blank? 
      pdf.image open("#{@company.logo.url}"), :fit=> 
      Prawn::Document::PageGeometry::SIZES["A8"]
    end
  end
  pdf.bounding_box([340, 780], :width => (pdf.bounds.width/2)) do
    pdf.move_down 10
    pdf.text "<b>DELIVERY CHALLAN</b>", :align => :center, :inline_format => true, :size => 12
  end
  
 
  pdf.line_width(2)
  pdf.move_down 40
  y_position = pdf.cursor
  pdf.bounding_box([0, y_position], :width => (pdf.bounds.width/3)) do
   pdf.stroke_horizontal_rule

    pdf.move_down 3
    data = [[{:content =>"Delivery Challan #:", :font_style => :bold, :align => :left}, {:content =>"DL" "#{@invoice.invoice_number}"}]]
    data += [[{:content =>"Challan date:", :font_style => :bold, :align => :left}, {:content =>"#{@invoice.invoice_date.strftime("%d-%m-%Y")}"}]]
    
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
    data += [[{:content =>"Created by:", :font_style => :bold, :align => :left}, {:content =>"#{User.find(@invoice.created_by).full_name}"}]]
    
    pdf.table(data, :row_colors => ["ffffff"], :cell_style =>{:height=> 17,:align => :left, :border_width => 0, :size => 8})do
    end
    pos_arr<<pdf.y
  end
  
  pdf.bounding_box([200, y_position], :width => (pdf.bounds.width/3) ) do
    pdf.stroke_horizontal_rule
    pdf.table([[{:content =>"From:", :align => :left}],
        [{:content => "#{@company.name}", :font_style=>:bold}],
      ],
      :width => (pdf.bounds.width - 75), :cell_style =>{:border_width => 0,:align => :left, :inline_format => true, :size => 9})do
    end
  pdf.table([
        ["#{@company.address.get_address unless @company.address.blank?}"],
        ["Phone: #{@company.phone unless @company.phone.blank?}"],
      ],
      :width => (pdf.bounds.width/2 + 55), :cell_style =>{:border_width => 0,:align => :left, :inline_format => true, :size => 8})do
    end 
    pos_arr<<pdf.y
  end

  pdf.bounding_box([390, y_position], :width => (pdf.bounds.width / 3)-20  ) do
   pdf.stroke_horizontal_rule
  if @invoice.cash_invoice?
    pdf.table([
            [{:content =>"Shipping Address:",:align => :left }],
             ["<b>#{@invoice.cash_customer_name unless @invoice.cash_customer_name.blank?}</b>"],
             ["#{@invoice.cash_customer_email unless @invoice.cash_customer_email.blank?}"],
             ["#{@invoice.cash_customer_mobile unless @invoice.cash_customer_mobile.blank?}"],],
             :cell_style =>{:align => :left,:inline_format => true,:border_width =>0, :size => 8, :border_color => "ffffff" })do
    end
    pos_arr<<pdf.y
  else
 
  data = [[{:content =>"Shipping Address:",  :align => :left}]]
  data += [[{:content =>"#{@invoice.account.name }", :font_style => :bold, :align => :left}]]
  data += [[{:content =>"#{customer.billing_address.address_line1 unless customer.billing_address.blank?}", :align => :left}]]
  if !customer.email.blank?
   data += [[{:content =>"Email: #{customer.email unless customer.nil?}", :align => :left}]]
  end
  if !customer.contact_number.blank?
   data += [[{:content =>"Contact #: #{customer.contact_number unless customer.nil?}",  :align => :left}]]
  end
  
    pdf.table(data, :cell_style =>{:align => :left,:inline_format => true,:border_width =>0, :size => 8, :border_color => "ffffff" })do
    end
    pos_arr<<pdf.y
  end
  end
  n = @invoice_line_items.count 
 
     data = [[{:content => "#{!@company.invoice_setting.item_label.blank? ? @company.invoice_setting.item_label : 'Item'}"},
     {:content => "#{!@company.invoice_setting.desc_label.blank? ? @company.invoice_setting.desc_label : 'Description'}"},
     {:content => "#{!@company.invoice_setting.qty_label.blank? ? @company.invoice_setting.qty_label : 'Qty'}",:align => :right}
     ]]
    
     for i in @invoice_line_items
      if i.product.batch_enable?
      data += [[{:content =>"#{i.item_name}"},
                {:content => "#{i.description}, Batch numbers: #{i.batch_number}"},
                {:content =>"#{i.quantity}",:align => :right}
                ]]
      else
      data += [[{:content =>"#{i.item_name}"},
                {:content => "#{i.description}"},
                {:content =>"#{i.quantity}",:align => :right}
                ]]
      end

     end 
  pdf.bounding_box([0, (pos_arr.min.to_f - 50)], :width => pdf.bounds.width  ) do 
   pdf.table(data, :header => true,  :width => pdf.bounds.width,:row_colors => ["FFFFFF"] , :cell_style =>{:border_width => 0,:border_color => "70B8FF",  :size => 8}) do
    row(0).font_style = :bold
                row(0).background_color = 'F2F7FF'
                row(0).borders = [:top,:bottom]
                row(0).border_width = 0.2
                row(n).borders = [:bottom]
                row(n).border_width = 0.2
                
    end
  end
    data = [["",{:content => "Total", :font_style => :bold, :align => :right},{:content => " #{@invoice.total_quantity }", :font_style => :bold, :align => :right}]]
   
    pdf.table(data, :header => true,  :width => (pdf.bounds.width),:row_colors => ["FFFFFF"] , :cell_style =>{:border_width => 0,:border_color => "70B8FF",  :size => 8, :height=> 17}) do
                row(1).borders = [:top, :bottom]
                row(1).border_width = 0.2
                row(1).background_color = 'F2F7FF'
                
    end 
   
   pdf.move_down 60
   pdf.text "-------------------", :align => :right
   pdf.text "Receiver Signatory",:size => 8,:align => :right

 
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
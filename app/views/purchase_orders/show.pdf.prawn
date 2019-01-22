require 'open-uri'
pdf = Prawn::Document.new(:page_layout => :portrait, :page_size => 'A4')
y_position = pdf.cursor
pos_arr=[]
vendor = @purchase_order.vendor
pdf.bounding_box([0, 790], :width => (pdf.bounds.width/2) - 5) do 
   unless @company.logo_file_name.blank? 
      pdf.image open("#{@company.logo.url}"), :fit=> 
      Prawn::Document::PageGeometry::SIZES["A8"]
    end
  end
  pdf.bounding_box([340, 790], :width => (pdf.bounds.width/2)) do
  pdf.table([
       [ "<b>#{@company.name}</b>"],
       [ "#{@company.address.get_address unless @company.address.blank?}"],
       ["Phone : #{@company.phone unless @company.phone.blank?}"],
      ],
      :width => (pdf.bounds.width/3*2), :cell_style =>{:border_width => 0,:align => :right, :inline_format => true, :size => 9})do
    end 
  end
  pdf.move_down 20
  pdf.text "<b>PURCHASE ORDER</b>", :align => :center, :inline_format => true, :size => 14
  pdf.stroke_horizontal_rule

  pdf.move_down 10
  y_position = pdf.cursor
  pdf.bounding_box([0, y_position], :width => (pdf.bounds.width/2) - 100) do
    data =  [[{:content =>"Bill from:", :font_style => :bold, :align => :left}]]
    sub_data=["<b>#{@purchase_order.account.name unless @purchase_order.account.blank?}</b>"]
    data<<sub_data
    billing_address=vendor.billing_address
    unless billing_address.blank?
      sub_data=["#{vendor.billing_address.address_line1}"]
      data<<sub_data
    end
    unless vendor.email.blank?
      sub_data=["Email : #{vendor.email}"]
      data<<sub_data
    end
    unless vendor.contact_number.blank?
      sub_data=["Contact : #{vendor.contact_number}"]
      data<<sub_data
    end
    unless vendor.pan.blank?
      sub_data=["PAN : #{vendor.pan}"]
      data<<sub_data
    end
    
  pdf.table(data, :width=> pdf.bounds.width , :cell_style =>{:align => :left,:inline_format => true,:border_width =>0, :size => 9, :border_color => "70B8FF" })do
     row(0).borders = [:left, :right, :bottom, :top]
     row(0).background_color = 'F2F7FF'
     row(1..(data.size-2)).borders = [:left, :right]
     row(data.size - 1).borders = [:left, :right, :bottom]
  	 row(0..(data.size - 1)).border_width = 0.1
    end
    pos_arr<<pdf.y
  end	

 pdf.bounding_box([365, y_position], :width => (pdf.bounds.width / 2) - 10) do
    data = [[{:content =>"Purchase order#:", :font_style => :bold, :align => :left}, {:content =>"#{@purchase_order.purchase_order_number}"}]]

    data += [[{:content =>"Due date:", :font_style => :bold, :align => :left}, {:content =>"#{@purchase_order.record_date.strftime("%d-%m-%Y")}"}]]

    data += [[{:content =>"Amount", :font_style => :bold, :align => :left}, {:content =>"#{@purchase_order.currency} #{@purchase_order.amount}"}]]
    
    pdf.table(data, :row_colors => ["F2F7FF"], :cell_style =>{:align => :left, :border_width => 0, :size => 9})do
    end
    pos_arr<<pdf.y
  end

	n = @purchase_order_line_items.count 
  data = []
  sub_data = ["Item","Description",{:content => "Qty",:align => :right},{:content =>"Unit Cost", :align => :right}, {:content => "Amount (#{@purchase_order.currency})", :align => :right}]
  unless @discount == 0
    sub_data.insert(4, {:content=>"Disc%", :align=>:right})
  end
  data<<sub_data
	for i in @purchase_order_line_items
    sub_data = ["#{i.item_name}","#{i.description}",{:content =>"#{i.quantity} #{i.product.unit_of_measure}",:align => :right},{:content => "#{i.unit_rate}", :align => :right},{:content => "#{i.amount}", :align => :right}]
    unless @discount == 0
      sub_data.insert(4, {:content=>"#{i.discount_percent}", :align=>:right})
    end
    data<<sub_data
  end	

   data += [["",{:content => "Total Qty", :font_style => :bold, :align => :right},{:content => " #{ @purchase_order.total_quantity}", :font_style => :bold, :align => :right},"",""]]
  
  for i in @tax_line_items
    sub_data=["",{:content => "#{i.account.name}", :align => :right},"","",{:content => "#{ @purchase_order.group_tax_amt(i.account_id).to_s}", :align => :right}]
    unless @discount == 0
      sub_data.insert(4, "")
    end
    data<<sub_data
  end 
  
  sub_data=["","","",{:content => "Sub Total", :font_style => :bold, :align => :right},{:content => "#{@purchase_order.sub_total}", :font_style => :bold, :align => :right}] 
   unless @discount == 0
      sub_data.insert(3, "")
    end
   data<<sub_data

   sub_data=["","","",{:content => "Tax", :font_style => :bold, :align => :right},{:content => "#{@purchase_order.tax}", :font_style => :bold, :align => :right}] 
   unless @discount == 0
      sub_data.insert(3, "")
    end
   data<<sub_data
    
  for i in @other_charge_line_items
    sub_data=["","","",{:content => "#{i.account.name}", :align => :right, :font_style=>:bold},{:content => "#{ i.amount.to_s}", :align => :right, :font_style=>:bold}]
    unless @discount == 0
      sub_data.insert(3, "")
    end
    data<<sub_data
  end 
  
    unless @discount == 0
      data<<["","","","",{:content => "Discount", :font_style => :bold, :align => :right},{:content => "#{@discount}", :font_style => :bold, :align => :right}]
    end

   sub_data=["","","",{:content => "Total", :font_style => :bold, :align => :right},{:content => "#{@purchase_order.amount}", :font_style => :bold, :align => :right}]

    unless @discount == 0
       sub_data.insert(3, "")
     end
    data<<sub_data
  y_position = pdf.cursor
  pdf.bounding_box([0, (pos_arr.min.to_f - 50)], :width => (pdf.bounds.width) - 10) do
    pdf.table(data, :header => true,  :width => (pdf.bounds.width),:row_colors => ["FFFFFF","F2F7FF"] , :cell_style =>{:border_width => 0,:border_color => "70B8FF",  :size => 8},:column_widths => {0 => 100, 1 =>150 }) do
      row(0).font_style = :bold
      row(0).borders = [:top, :bottom]
      row(0).border_width = 0.1
      row(n).borders = [:bottom]
      row(n).border_width = 0.1
    end    
  end            
  
pdf.move_down 10
  if !@purchase_order.customer_notes.blank?
      pdf.span(530, :position => :left) do
        pdf.table([["<b>Customer Notes</b>"],
		   [" #{@purchase_order.customer_notes}"]],
	 :cell_style =>{:border_width => 0, :inline_format=> true, :size => 9})do
	end
       end
 end

pdf.move_down 10
 if !@purchase_order.terms_and_conditions.blank?	  
	  pdf.span(530, :position => :left) do
        pdf.table([[ "<b>Terms and Conditions </b>"],
		  [" #{@purchase_order.terms_and_conditions}"]],
       :cell_style =>{:border_width => 0, :inline_format => true, :align => :left, :size => 9})do
		end
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
		pdf.draw_text "Page : #{i+1} / #{pdf.page_count}", :at=>[pdf.bounds.width - 50,-10], :size => 9
	end

pdf = Prawn::Document.new(:page_layout => :portrait, :page => 'A4')
	pdf.bounding_box([0, pdf.cursor], :width => (pdf.bounds.width) ) do
		pdf.text "<b>#{@company.name }</b>", :align => :center, :inline_format => true, :size =>14
		pdf.text "#{@company.address.get_address unless @company.address.blank?}", :align => :center, :size => 10
	end
pdf.move_down 10
   		
pdf.text "<b><u>Stock Wastage Register</u></b>", :align => :center, :inline_format => true, :size => 12
		if !params[:branch_id].blank?   
		 pdf.text "Branch: #{Branch.find(params[:branch_id]).name} ", :align => :center, :size => 6 
		end     
		pdf.move_down 5
   
    pdf.text "#{ (params[:start_date].blank?)?@financial_year.start_date : params[:start_date] unless @stock_wastage_vouchers.blank?} To #{ (params[:end_date].blank?)? ((Time.zone.now.to_date > @financial_year.end_date)? @financial_year.end_date : Time.zone.now.to_date) : params[:end_date] }", :align => :center, :size => 6
 
	pdf.move_down 10
	
	if @custom_field.blank?

	data = [['Date', 'Voucher Number', {:content => "#{@company.label.warehouse_label}"},'Product','P a r t i c u l a r s',  {:content =>'Quantity', :align => :right}]]
	
  total_quantity = 0
   i = 0
   @stock_wastage_vouchers.each do |swv| 
   quantity = 0
   swv.stock_wastage_line_items.each do |line_item| 
		data +=[[{:content => "#{ swv.voucher_date.to_date}"},
					{:content => " #{swv.voucher_number}"},
					{:content => "#{swv.warehouse.name}"},
					{:content => "#{line_item.product.name}"},
					{:content => "#{line_item.reason}"},
					{:content => "#{line_item.quantity}", :align => :right}]]
		quantity += line_item.quantity
	end
	  total_quantity += quantity
	end
		i+=1
	
	data += [["","",{:content =>'Total quantity', :font_style => :bold},"","",{:content => "#{total_quantity}", :font_style => :bold, :align => :right}]]
  
	pdf.table(data, :header => true, :width => pdf.bounds.width,:row_colors => ["FFFFFF","F2F7FF"] , :cell_style => {:border_width => 0, :border_color => "70B8FF", :size => 9})do
		row(0).borders = [:top, :bottom]
		row(0).border_width = 0.1
		row(0).font_style = :bold
		row(i + 1).column(4..5).borders = [:top]
		row(i + 1).column(4..5).border_width = 0.1
		row(i + 3).column(4..5).borders = [:bottom]
		row(i + 3).column(4..5).border_width = 0.1
	end
	else
	data = [
	        ['Date', 
	         'Voucher Number', 
		          
	           "#{ @custom_field.custom_label1 unless @custom_field.custom_label1.blank? }" ,
	           
	           
	            "#{ @custom_field.custom_label2 unless @custom_field.custom_label2.blank? }" ,
	           
	           
	           "#{ @custom_field.custom_label3 unless @custom_field.custom_label3.blank? }",
	           
	          'Warehouse',
	          'Product',
	          'P a r t i c u l a r s', 
	          {:content =>'Quantity', :align => :right}]
	          ]
	
  total_quantity = 0
   i = 0
   @stock_wastage_vouchers.each do |swv| 
   quantity = 0
   swv.stock_wastage_line_items.each do |line_item| 
		data +=[[{:content => "#{ swv.voucher_date.to_date}"},
					{:content => " #{swv.voucher_number}"},
					 
					  {:content => " #{(!@custom_field.custom_label1.blank? && !swv.custom_field1.blank?) ? swv.custom_field1 : " "}"},
					 
          
					  {:content => " #{(!@custom_field.custom_label2.blank? && !swv.custom_field2.blank?) ? swv.custom_field2 : " "}"},
					
          
					  {:content => " #{(!@custom_field.custom_label3.blank? && !swv.custom_field3.blank?) ? swv.custom_field3 : " "}"},
					
					{:content => "#{swv.warehouse.name}"},
					{:content => "#{line_item.product.name}"},
					{:content => "#{line_item.reason}"},
					{:content => "#{line_item.quantity}", :align => :right}]]
		quantity += line_item.quantity
	end
	  total_quantity += quantity
	end
		i+=1
	
	data += [["","",
	          if !@custom_field.custom_label1.blank? 
	           " "
	          end,
	           if !@custom_field.custom_label1.blank? 
	           " "
	          end,
	           if !@custom_field.custom_label1.blank? 
	           " "
	          end,
	           {:content =>'Total quantity', :font_style => :bold},"","",
	           {:content => "#{total_quantity}", :font_style => :bold, :align => :right}]]
  
	pdf.table(data, :header => true, :width => pdf.bounds.width,:row_colors => ["FFFFFF","F2F7FF"] , :cell_style => {:border_width => 0, :border_color => "70B8FF", :size => 9})do
		row(0).borders = [:top, :bottom]
		row(0).border_width = 0.1
		row(0).font_style = :bold
		row(i + 1).column(7..8).borders = [:top]
		row(i + 1).column(7..8).border_width = 0.1
		row(i + 3).column(7..8).borders = [:bottom]
		row(i + 3).column(7..8).border_width = 0.1
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
		pdf.draw_text "Page : #{i+1} / #{pdf.page_count}", :at=>[pdf.bounds.width - 50,-10], :size => 9
	end

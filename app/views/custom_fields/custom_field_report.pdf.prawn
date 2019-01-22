pdf = Prawn::Document.new(:page_layout => :portrait, :page => 'A4')
	pdf.bounding_box([0, pdf.cursor], :width => (pdf.bounds.width) ) do
		pdf.text "<b>#{@company.name }</b>", :align => :center, :inline_format => true, :size =>14
		pdf.text "#{@company.address.get_address unless @company.address.blank?}", :align => :center, :size => 10
	end
pdf.move_down 10
  y_position = pdf.cursor
	pdf.bounding_box([0, y_position], :width => (pdf.bounds.width / 2) - 5) do
		pdf.table([
			   ["<b>Custom Field Report</b>"],],
			:width => (pdf.bounds.width - 10), :cell_style =>{:border_width => 0,:align => :left, :inline_format => true, :size => 12})do
		end
	 pdf.text "#{ (params[:start_date].blank?)?@financial_year.start_date : params[:start_date] } To #{ (params[:end_date].blank?)? ((Time.zone.now.to_date > @financial_year.end_date)? @financial_year.end_date : Time.zone.now.to_date) : params[:end_date] }", :size => 6
	end
    pdf.move_down 5
	pdf.bounding_box([(pdf.bounds.width / 2) + 5, y_position], :width => (pdf.bounds.width / 2) - 10) do
		pdf.table([
			 ["Voucher Type: <b>#{params[:voucher_type]}</b>"],],
		:width => (pdf.bounds.width - 10), :cell_style =>{:border_width => 0,:align => :right, :inline_format => true, :size => 12})do
		end
	end

 
	pdf.move_down 10
	if !params[:voucher_type].blank? && params[:voucher_type] == "Invoice"
	data = [['Sr. No.', 'Invoice #', {:content=> "#{@company.label.customer_label}"},'Invoice Date','Amount',{:content => "#{@custom_field.custom_label1}"},{:content => "#{@custom_field.custom_label2}"},{:content => "#{@custom_field.custom_label3}"}]]
	i =0
    @vouchers.each_with_index do |invoice, index| 
    if !invoice.custom_field1.blank? || !invoice.custom_field2.blank? || !invoice.custom_field3.blank?
  	data +=[[{:content => "#{ index+1}"},
					{:content => "#{invoice.invoice_number}"},
					{:content => "#{truncate(invoice.customer_name, :length=> 40)}"},
					{:content => "#{invoice.invoice_date}"},
					{:content => "#{invoice.total_amount}"},
			{:content => "#{invoice.custom_field1 unless @custom_field.custom_label1.blank?}"},
			{:content => "#{invoice.custom_field2 unless @custom_field.custom_label2.blank?}"},
			{:content => "#{invoice.custom_field3 unless @custom_field.custom_label3.blank?}"}
					]]
	end
	end
		pdf.table(data, :header => true, :width => pdf.bounds.width,:row_colors => ["FFFFFF","F2F7FF"] , :cell_style => {:border_width => 0, :border_color => "70B8FF", :size => 8})do
			row(0).borders = [:top, :bottom]
			row(0).border_width = 0.2
			row(0).font_style = :bold
		end

	elsif params[:voucher_type] == "Estimate"
	data = [['Sr. No.', {:content=> "#{@company.label.estimate_label}#"}, {:content=> "#{@company.label.customer_label}"},{:content=> "#{@company.label.estimate_label} Date"},'Amount',{:content => "#{@custom_field.custom_label1}"},{:content => "#{@custom_field.custom_label2}"},{:content => "#{@custom_field.custom_label3}"}]]
	i =0
    @vouchers.each_with_index do |estimate, index| 
  	if !estimate.custom_field1.blank? || !estimate.custom_field2.blank? || !estimate.custom_field3.blank?
  	data +=[[{:content => "#{ index+1}"},
					{:content => "#{estimate.estimate_number}"},
					{:content => "#{estimate.customer_name}"},
					{:content => "#{estimate.estimate_date}"},
					{:content => "#{estimate.total_amount}"},
			{:content => "#{estimate.custom_field1 unless @custom_field.custom_label1.blank?}"},
			{:content => "#{estimate.custom_field2 unless @custom_field.custom_label2.blank?}"},
			{:content => "#{estimate.custom_field3 unless @custom_field.custom_label3.blank?}"}
					]]
	end
	end
	pdf.table(data, :header => true, :width => pdf.bounds.width,:row_colors => ["FFFFFF","F2F7FF"] , :cell_style => {:border_width => 0, :border_color => "70B8FF", :size => 8})do
			row(0).borders = [:top, :bottom]
			row(0).border_width = 0.2
			row(0).font_style = :bold
		end
	elsif params[:voucher_type] == "Purchase"
	data = [['Sr. No.', 'Purchase #', 'Vendor','Purchase Date','Amount',{:content => "#{@custom_field.custom_label1}"},{:content => "#{@custom_field.custom_label2}"},{:content => "#{@custom_field.custom_label3}"}]]
	i =0
    @vouchers.each_with_index do |purchase, index| 
  	if !purchase.custom_field1.blank? || !purchase.custom_field2.blank? || !purchase.custom_field3.blank?
  	data +=[[{:content => "#{ index+1}"},
					{:content => "#{purchase.purchase_number}"},
					{:content => "#{purchase.vendor_name}"},
					{:content => "#{purchase.record_date}"},
					{:content => "#{purchase.total_amount}"},
			{:content => "#{purchase.custom_field1 unless @custom_field.custom_label1.blank?}"},
			{:content => "#{purchase.custom_field2 unless @custom_field.custom_label2.blank?}"},
			{:content => "#{purchase.custom_field3 unless @custom_field.custom_label3.blank?}"}
					]]
	end
	end
	pdf.table(data, :header => true, :width => pdf.bounds.width,:row_colors => ["FFFFFF","F2F7FF"] , :cell_style => {:border_width => 0, :border_color => "70B8FF", :size => 8})do
			row(0).borders = [:top, :bottom]
			row(0).border_width = 0.2
			row(0).font_style = :bold
		end
	elsif params[:voucher_type] == "StockIssueVoucher"
	data = [['Sr. No.', 'Voucher #', 'Voucher Date',{:content=> "#{@company.label.warehouse_label}"},{:content => "#{@custom_field.custom_label1}"},{:content => "#{@custom_field.custom_label2}"},{:content => "#{@custom_field.custom_label3}"}]]
	i =0
    @vouchers.each_with_index do |stock, index| 
    if !stock.custom_field1.blank? || !stock.custom_field2.blank? || !stock.custom_field3.blank?
    data +=[[{:content => "#{ index+1}"},
					{:content => "#{stock.voucher_number}"},
					{:content => "#{stock.voucher_date}"},
					{:content => "#{stock.warehouse.name}"},
			{:content => "#{stock.custom_field1 unless @custom_field.custom_label1.blank?}"},
			{:content => "#{stock.custom_field2 unless @custom_field.custom_label2.blank?}"},
			{:content => "#{stock.custom_field3 unless @custom_field.custom_label3.blank?}"}
					]]
	end
	end
	pdf.table(data, :header => true, :width => pdf.bounds.width,:row_colors => ["FFFFFF","F2F7FF"] , :cell_style => {:border_width => 0, :border_color => "70B8FF", :size => 8})do
			row(0).borders = [:top, :bottom]
			row(0).border_width = 0.2
			row(0).font_style = :bold
		end
	elsif params[:voucher_type] == "StockReceiptVoucher" 
	data = [['Sr. No.', 'Voucher #', 'Voucher Date',{:content=> "#{@company.label.warehouse_label}"},{:content => "#{@custom_field.custom_label1}"},{:content => "#{@custom_field.custom_label2}"},{:content => "#{@custom_field.custom_label3}"}]]
	i =0
    @vouchers.each_with_index do |stock, index| 
    if !stock.custom_field1.blank? || !stock.custom_field2.blank? || !stock.custom_field3.blank?
    data +=[[{:content => "#{ index+1}"},
					{:content => "#{stock.voucher_number}"},
					{:content => "#{stock.voucher_date}"},
					{:content => "#{stock.warehouse.name}"},
		    {:content => "#{stock.custom_field1 unless @custom_field.custom_label1.blank?}"},
			{:content => "#{stock.custom_field2 unless @custom_field.custom_label2.blank?}"},
			{:content => "#{stock.custom_field3 unless @custom_field.custom_label3.blank?}"}
						]]
	end
	end
	pdf.table(data, :header => true, :width => pdf.bounds.width,:row_colors => ["FFFFFF","F2F7FF"] , :cell_style => {:border_width => 0, :border_color => "70B8FF", :size => 8})do
			row(0).borders = [:top, :bottom]
			row(0).border_width = 0.2
			row(0).font_style = :bold
		end
	elsif params[:voucher_type] == "StockWastageVoucher"
	data = [['Sr. No.', 'Voucher #', 'Voucher Date',{:content=> "#{@company.label.warehouse_label}"},{:content => "#{@custom_field.custom_label1}"},{:content => "#{@custom_field.custom_label2}"},{:content => "#{@custom_field.custom_label3}"}]]
	i =0
    @vouchers.each_with_index do |stock, index| 
    if !stock.custom_field1.blank? || !stock.custom_field2.blank? || !stock.custom_field3.blank?
    data +=[[{:content => "#{ index+1}"},
					{:content => "#{stock.voucher_number}"},
					{:content => "#{stock.voucher_date}"},
					{:content => "#{stock.warehouse.name}"},
			{:content => "#{stock.custom_field1 unless @custom_field.custom_label1.blank?}"},
			{:content => "#{stock.custom_field2 unless @custom_field.custom_label2.blank?}"},
			{:content => "#{stock.custom_field3 unless @custom_field.custom_label3.blank?}"}
					]]
	end
	end
	i+1
	pdf.table(data, :header => true, :width => pdf.bounds.width,:row_colors => ["FFFFFF","F2F7FF"] , :cell_style => {:border_width => 0, :border_color => "70B8FF", :size => 8})do
			row(0).borders = [:top, :bottom]
			row(0).border_width = 0.2
			row(0).font_style = :bold
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

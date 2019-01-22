pdf = Prawn::Document.new(:page_layout => :portrait, :page => 'A4')
	pdf.bounding_box([0, pdf.cursor], :width => (pdf.bounds.width) ) do
		pdf.text "<b>#{@company.name }</b>", :align => :center, :inline_format => true, :size =>14
		pdf.text "#{@company.address.get_address unless @company.address.blank?}", :align => :center, :size => 10
	end
pdf.move_down 10
  y_position = pdf.cursor
	pdf.bounding_box([0, y_position], :width => (pdf.bounds.width / 2) - 5) do
		pdf.table([
			   ["<b><u>Inventory Valuation Report</u></b>"],],
			:width => (pdf.bounds.width - 10), :cell_style =>{:border_width => 0,:align => :left, :inline_format => true, :size => 12})do
		end
	end
	pdf.text "As on: #{@date}", :align => :left, :size => 8

	pdf.bounding_box([(pdf.bounds.width / 2) + 5, y_position], :width => (pdf.bounds.width / 2) - 10) do
		pdf.table([
			 ["<b>All warehouses</b>"],],
		:width => (pdf.bounds.width - 10), :cell_style =>{:border_width => 0,:align => :right, :inline_format => true, :size => 12})do
		end
		if !params[:branch_id].blank?
		 pdf.text "Branch: #{Branch.find(params[:branch_id]).name} ", :align => :right, :size => 6
		end
	end


	pdf.move_down 10


	data = [['Sr. No.', 'Product', 'Description' ,'Available Qty', 'Valuation']]
	i =0
	line=0
	total_valuation = 0
  @products.each_with_index do |product, index|
    inventory_value = product.inventory_valuation(@date)
    total_valuation+=inventory_value

		data +=[[{:content => "#{ index+1}"},
					{:content => " #{product.name}"},
					{:content => "#{product.description}"},
					{:content => "#{product.opening_stock_on_date(@date, @branch_id)} #{product.unit_of_measure}", :align => :center},
					{:content => "#{format_currency inventory_value}", :align => :left}
					]]
		line=index
	end
	i+1
	data +=[[{:content => ""},
				{:content => ""},
				{:content => ""},
				{:content => "Total Valuation", :align => :center},
				{:content => "#{format_currency total_valuation}", :align => :right}
				]]


		pdf.table(data, :header => true, :width => pdf.bounds.width,:row_colors => ["FFFFFF","F2F7FF"] ,
			 :cell_style => {:border_width => 0, :border_color => "70B8FF", :size => 8},:column_widths => {2 => 200}) do
			row(0).borders = [:top, :bottom]
			row(0).border_width = 0.1
			row(0).font_style = :bold
			row(i + 1).column(4..5).borders = [:top]
			row(i + 1).column(4..5).border_width = 0
			row(i + 3).column(4..5).borders = [:bottom]
			row(i + 4).column(4..5).border_width = 0
			row(571).font_style = :bold
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

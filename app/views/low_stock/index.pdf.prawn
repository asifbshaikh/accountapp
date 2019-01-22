pdf = Prawn::Document.new(:page_layout => :portrait, :page => 'A4')
	pdf.bounding_box([0, pdf.cursor], :width => (pdf.bounds.width) ) do
		pdf.text "<b>#{@company.name }</b>", :align => :center, :inline_format => true, :size =>14
		pdf.text "#{@company.address.get_address unless @company.address.blank?}", :align => :center, :size => 10
	end
pdf.move_down 10
   		
pdf.text "<b><u>Low product Register</u></b>", :align => :center, :inline_format => true, :size => 12
		if !params[:branch_id].blank?   
		 pdf.text "Branch: #{Branch.find(params[:branch_id]).name} ", :align => :center, :size => 6 
		end     
		pdf.move_down 5
   pdf.text "#{ (params[:for_date].blank?) ? Time.zone.now.to_date : params[:for_date] unless @products.blank?} ", :align => :center, :size => 6
	
	pdf.move_down 10
	
	data = [['Product', 'P a r t i c u l a r s', {:content=> 'Unit of measure',:align => :right},  {:content =>'Avalable Quantity', :align => :center},{:content => 'Reorder Level', :align => :center}]]
	
   i = 0
   @products.each do |product| 
    if !product.blank? && product.inventoriable? && !product.reorder_level.blank? && product.reorder_level >= product.quantity
   	data +=[[{:content => "#{ product.name}", :align => :center},
					{:content => " #{product.description}"},
					{:content => "#{product.unit_of_measure}", :align=>:center},
					{:content => "#{product.quantity}", :align=>:center},
					{:content => "#{product.reorder_level}", :align=>:center}]]
		
	   end
	end
		i+=1
	
	pdf.table(data, :header => true, :width => pdf.bounds.width,:row_colors => ["FFFFFF","F2F7FF"] , :cell_style => {:border_width => 0, :border_color => "70B8FF", :size => 9}, :column_widths => {0 => 56, 1 => 114, 2 => 99 })do
		row(0).borders = [:top, :bottom]
		row(0).border_width = 0.1
		row(0).font_style = :bold
		row(i + 1).column(3..4).borders = [:top]
		row(i + 1).column(3..4).border_width = 0.1
		row(i + 3).column(3..4).borders = [:bottom]
		row(i + 3).column(3..5).border_width = 0.1
	end
	
	pdf.page_count.times do |i|
		pdf.go_to_page(i+1)
		pdf.fill_color "ADADAD"
		if @footer.nil? || @footer.strip == ''
			pdf.draw_text "Generated from www.profitnext.net", :at=>[0,-10], :size => 7
		else
			pdf.draw_text @footer.strip, :at => [0,-10], :size => 7
		end
		pdf.fill_color "000000"
		pdf.draw_text "Page : #{i+1} / #{pdf.page_count}", :at=>[pdf.bounds.width - 50,-10], :size => 9
	end

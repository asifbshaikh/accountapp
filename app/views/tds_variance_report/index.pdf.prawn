pdf = Prawn::Document.new(:page_layout => :portrait, :page_size =>'A4')
	pdf.bounding_box([0, pdf.cursor], :width =>pdf.bounds.width, :height => 80) do
		pdf.text "<b>#{@company.name}</b>", :align => :center, :inline_format => true, :size =>14
		pdf.text "<u>TDS Varience</u>", :align => :center, :inline_format => true, :size => 12
		pdf.text "1-Apr-2010 to 31-Mar-2011", :align => :center, :size => 10
	end
	
	pdf.table([[{:content => 'For all Employee under group :' , :align => :left, :size => 10}, {:content => 'Financial Year : 1-Apr2010 to 31-Mar-2010', :align => :right, :size => 10}]], :width => pdf.bounds.width, :cell_style => {:background_color => "B8DBFF"}) do
			row(0).border_width = 0
	end
	
	pdf.move_down 10
	data = [["P a r t i c u l a r s", "TDS Amount", "Varience Amount"]]
	
	@month_array = ['April', 'May', 'June', 'July', 'Augest', 'September', 'Octomber', 'November', 'December', 'January', 'February', 'March']
	i=0 
	12.times do 
		data += [["#{@month_array[i]}", "", ""]]
		i+=1
	end
	
	data += [[{:content => "G r a n t  T o t a l", :align => :center},"115327",""]]
	pdf.table(data,:header => true , :width => pdf.bounds.width, :row_colors => ["FFFFFF","F2F7FF"], :cell_style =>{:size =>9, :border_width => 0, :border_color => "70B8FF"}, :column_widths => {1=>120, 2=>120})do
			row(0).borders = [:top, :bottom]
			row(0).border_width = 0.1
			row(0).font_style = :bold
			row(i + 1).column(0..1).borders = [:top, :bottom]
			row(i + 1).column(0..1).border_width = 0.1
	end
	
	pagecount = pdf.page_count
	Prawn::Document.generate("footer.pdf", :skip_page_creation => true) do
		pdf.page_count.times do |i|
			pdf.go_to_page(i+1)
			pdf.fill_color "ADADAD"
			pdf.draw_text "Generated from www.profitbooks.net", :at=>[0,-10], :size => 7
			pdf.fill_color "000000"
			pdf.draw_text "Page : #{i+1} / #{pdf.page_count}", :at=>[pdf.bounds.width-50,-10], :size => 9
		end
	end

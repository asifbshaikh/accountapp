Prawn::Document.generate('cash_book.pdf', :page_layout => :portrait, :page => 'A4')
	pdf.bounding_box([0,pdf.cursor], :width => pdf.bounds.width, :height =>80) do
		pdf.text "<b>#{@company.name}</b>", :align => :center, :inline_format => true, :size =>14
		pdf.text "<u>Bank Reconcilation</u>", :align => :center, :inline_format => true, :size => 12
		pdf.move_down 10
		pdf.text "1-Apr-2011 to 31-Mar-2011", :align => :center, :size => 10
	end
	pdf.move_down 10
	
	data = [['Date', 'Corresponding A/C', 'Description', {:content => "Debit", :align => :right}, {:content => "Credit", :align => :right}]]
	
	debit = 0
	credit = 0
	prev_date = nil 
	closing_balance = 0
	i = 0
	for ledger in @ledgers 
		data +=[[{:content => "#{ledger.transaction_date}"},
					{:content => "#{Account.find(ledger.retrieve_corresponding_account).name}"},
					{:content => "#{ledger.description}"},
					{:content => "#{ledger.credit}", :align => :right},
					{:content => "#{ledger.debit}", :align => :right }]]
		
		i += 1
	end
	
	pdf.table(data, :header => true, :width => pdf.bounds.width,:row_colors => ["FFFFFF","F2F7FF"] , :cell_style => {:border_width => 0, :border_color => "70B8FF", :size => 9}, :column_widths => {0 => 60, 1 => 140, 2 => 140})do
		row(0).borders = [:top, :bottom]
		row(0).border_width = 0.1
		row(0).font_style = :bold
		row(i + 1).column(4..5).borders = [:top]
		row(i + 1).column(4..5).border_width = 0.1
		row(i + 3).column(4..5).borders = [:bottom]
		row(i + 3).column(4..5).border_width = 0.1
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

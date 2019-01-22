Prawn::Document.generate('ledger.pdf', :page_layout => :portrait, :page => 'A4')
	
   y_position = pdf.cursor
	pdf.bounding_box([0, pdf.cursor], :width => (pdf.bounds.width) ) do
		pdf.text "<b>#{@company.name}</b>", :align => :center, :inline_format => true, :size =>14
		pdf.text "#{@company.address.get_address unless @company.address.blank?}", :align => :center, :size => 10
	end
     pdf.move_down 10

	y_position = pdf.cursor
	pdf.bounding_box([0, y_position], :width => (pdf.bounds.width / 2) - 5) do
		pdf.table([
			   ["<b><u>Gain or Loss Report</u></b>"],],
			:width => (pdf.bounds.width - 10), :cell_style =>{:border_width => 0,:align => :left, :inline_format => true, :size => 12})do
		end
	end
	pdf.text "#{ (params[:start_date].blank?)? @ledgers.first.transaction_date: params[:start_date] } To #{ (params[:end_date].blank?)? Time.zone.now.to_date : params[:end_date] }",:align => :left, :size => 6

	pdf.bounding_box([(pdf.bounds.width / 2) + 5, y_position], :width => (pdf.bounds.width / 2) - 10) do
		pdf.table([
			 ["<b>#{@account.name}</b>"],],
		:width => (pdf.bounds.width - 10), :cell_style =>{:border_width => 0,:align => :right, :inline_format => true, :size => 12})do
		end
	end
	pdf.move_down 10
	
	data = [['Date', 'Customer','Cust Currency ','Voucher Number' ,'Type', {:content => 'Gain', :align => :right}, {:content => 'Loss', :align => :right}]]
     
     
	debit = 0
	credit = 0
	
	prev_date = nil 
	i = 0
	for ledger in @ledgers 
    acc = Account.find(ledger.retrieve_corresponding_account)
		data +=[[{:content => "#{(ledger.transaction_date.strftime("%d-%m-%Y") == prev_date)? '': ledger.transaction_date.strftime("%d-%m-%Y")}"},
					{:content => "#{(!ledger.debit.blank? && ledger.debit > 0)? "To":"By" } #{acc.name}"},
					{:content => "#{acc.get_currency}"},
					{:content => "#{truncate(ledger.voucher_number, :length =>14)}"},
					{:content => "#{truncate(ledger.voucher_type, :length =>15)}"},
					{:content => "#{format_currency(ledger.credit)}", :align => :right},
					{:content => "#{format_currency(ledger.debit)}", :align => :right }]]
		debit += ledger.credit
		credit += ledger.debit unless ledger.debit.blank?
		prev_date = ledger.transaction_date.strftime("%d-%m-%Y")
		i += 1
	end
	
	data += [["","","","",{:content => "Total", :font_style => :bold, :align => :right},{:content => "#{format_currency(debit)}", :font_style => :bold, :align => :right},{:content => "#{format_currency(credit)}", :font_style => :bold, :align => :right}]]
	
	pdf.table(data, :header => true, :width => pdf.bounds.width,:row_colors => ["FFFFFF","F2F7FF"] , :cell_style => {:border_width => 0, :border_color => "70B8FF", :size => 8}, :column_widths => {0 => 56, 1 => 114, 2 => 50})do
		row(0).borders = [:top, :bottom]
		row(0).border_width = 0.2
		row(0).font_style = :bold
		row(i + 1).column(5..7).borders = [:top]
		row(i + 1).column(5..7).border_width = 0.2
		row(i + 5).column(5..7).borders = [:top, :bottom]
		row(i + 5).column(5..7).border_width = 0.2
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

def add_page_break_if_overflow(pdf, &block)
  current_page = pdf.page_count
  roll = pdf.transaction do
    yield(pdf)
  
    pdf.rollback if pdf.page_count > current_page
  end
  
  if roll == false
    pdf.start_new_page
    yield(pdf)
  end
end

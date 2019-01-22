pdf = Prawn::Document.new(:page_layout => :portrait, :page => 'A4')
	pdf.bounding_box([0, pdf.cursor], :width => (pdf.bounds.width) ) do
		pdf.text "<b>#{@company.name}</b>", :align => :center, :inline_format => true, :size =>14
		pdf.text "#{@company.address.get_address unless @company.address.blank?}", :align => :center, :size => 10
	end
pdf.move_down 10
   		
pdf.text "<b><u>Day Book</u></b>", :align => :center, :inline_format => true, :size => 12
		pdf.move_down 5
		if !params[:branch_id].blank?   
		pdf.text "Branch: #{Branch.find(params[:branch_id]).name} ", :align => :center, :size => 6 
		end
    pdf.text "#{ (params[:for_date].blank?) ? @ledgers.first.transaction_date : params[:for_date] unless @ledgers.blank?} ", :align => :center, :size => 6
 
	pdf.move_down 10
	
	data = [['Date', 'Account', 'Description', 'Voucher No.', {:content =>'Debit ', :align => :right}, {:content => 'Credit', :align =>:right}]]
	
	debit = 0
	credit = 0
	prev_date = nil 
	i = 0
	for ledger in @ledgers 
		data +=[[{:content => "#{ ledger.transaction_date.strftime("%d-%m-%Y")}"},
					{:content => " #{ledger.multiple_correlate_ledgers? ? "Multiple accounts" :Account.find(ledger.retrieve_corresponding_account).name}"},
					{:content => "#{ledger.description}"},
					{:content => "#{ledger.voucher_number}"},
					{:content => "#{format_currency(ledger.debit)}", :align => :right},
					{:content => "#{format_currency(ledger.credit)}", :align => :right }]]
		debit += ledger.debit
		credit += ledger.credit
		prev_date = ledger.transaction_date.strftime("%d-%m-%Y")
		i += 1
	end
	
	closing_balance = debit - credit
	data += [["","","","",{:content => "#{format_currency(debit)}", :font_style => :bold, :align => :right},{:content => "#{format_currency(credit)}", :font_style => :bold, :align => :right}]]
	if closing_balance < 0
		data += [["","",{:content =>'Closing Balance', :font_style => :bold},"",{:content => "#{format_currency(-1*closing_balance)}", :font_style => :bold, :align => :right},""]]
	    data += [["","","","",{:content => "#{format_currency(debit + -1*closing_balance)}",:font_style => :bold, :align => :right},{:content =>"#{format_currency(credit)}", :font_style => :bold, :align => :right}]]
	else
	    data += [["","",{:content =>'Closing Balance', :font_style => :bold},"","",{:content => "#{format_currency(closing_balance)}", :font_style => :bold, :align => :right}]]
	    data += [["","","","",{:content => "#{format_currency(debit)}",:font_style => :bold, :align => :right},{:content =>"#{format_currency(credit + closing_balance)}", :font_style => :bold, :align => :right}]]
	end
	pdf.table(data, :header => true, :width => pdf.bounds.width,:row_colors => ["FFFFFF","F2F7FF"] , :cell_style => {:border_width => 0, :border_color => "70B8FF", :size => 9}, :column_widths => {0 => 56, 1 => 114, 2 => 99 })do
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

Prawn::Document.generate('gst_debit_note_register.pdf', :page => 'A4', :page_layout => :portrait)
	pdf.bounding_box([0,pdf.cursor], :width => pdf.bounds.width, :height =>80) do
		pdf.text "<b>#{@company.name }</b>", :align => :center, :inline_format => true, :size =>14
	    
		pdf.text "<u>Gst Debit Note Register</u>", :align => :center, :inline_format => true, :size => 12
		
		 pdf.move_down 5
    pdf.text "#{(params[:account_id].nil?)? Account.find(@accounts.first.id).name  : Account.find(params[:account_id]).name}", :align => :center, :inline_format => true, :size =>10
		if !params[:branch_id].blank?   
		 pdf.text "Branch: #{Branch.find(params[:branch_id]).name} ", :align => :center, :size => 6 
		end
    pdf.move_down 5
    pdf.text "#{ (params[:start_date].blank?)?@financial_year.start_date : params[:start_date] unless @ledgers.blank?} To #{ (params[:end_date].blank?)? ((Time.zone.now.to_date > @financial_year.end_date)? @financial_year.end_date : Time.zone.now.to_date) : params[:end_date] }", :align => :center, :size => 6
  end
	pdf.move_down 10
	
	data = [['Date', 'Corresponding Account', 'P a r t i c u l a r s', 'Type', {:content => 'Debit', :align => :right}, {:content => 'Credit', :align => :right}]]
	
	debit = 0
	credit = 0
	prev_date = nil 
	i = 0
	for ledger in @ledgers
		if !ledger.retrieve_corresponding_account.nil?
		data += [["#{(ledger.transaction_date.strftime("%d-%m-%Y") == prev_date)? "": ledger.transaction_date.strftime("%d-%m-%Y")}",
			"#{(ledger.debit > 0)? 'To':'By'} #{Account.find(ledger.retrieve_corresponding_account).name}",
			"#{ledger.description}",
			"#{ledger.voucher_type}",
			{:content =>"#{ledger.debit}", :align => :right},
			{:content =>"#{ledger.credit}", :align => :right}]]
		debit += ledger.debit
			credit += ledger.credit
			prev_date = ledger.transaction_date.strftime("%d-%m-%Y")
			i += 1
		end
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
	pdf.table(data, :header => true, :width => pdf.bounds.width,:row_colors => ["FFFFFF","F2F7FF"] , :cell_style => {:border_width => 0, :border_color => "70B8FF", :size => 9}, :column_widths => {0 => 56, 1 => 114, 2 => 99})do
		row(0).borders = [:top, :bottom]
		row(0).border_width = 0.1
		row(0).font_style = :bold
		
	end

	pdf.page_count.times do |i|
		pdf.go_to_page(i+1)
		pdf.fill_color "ADADAD"
			pdf.draw_text "#{@company.watermark unless @company.watermark.blank?}", :at=>[0,-10], :size => 7
		pdf.fill_color "000000"
		pdf.draw_text "Page : #{i+1} / #{pdf.page_count}", :at=>[pdf.bounds.width - 50,-10], :size => 9
	end

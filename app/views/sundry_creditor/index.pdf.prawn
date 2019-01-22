pdf = Prawn::Document.new(:page_layout => :portrait, :page => 'A4')
	pdf.bounding_box([0,pdf.cursor], :width => pdf.bounds.width, :height =>80) do
		pdf.text "<b>#{@company.name }</b>", :align => :center, :inline_format => true, :size =>14
		pdf.text "<u>Sundry Creditor</u>", :align => :center, :inline_format => true, :size => 12
		pdf.move_down 10
		pdf.move_down 5
    pdf.text "#{(params[:account_id].blank?)? Account.find(@accounts.first.id).name  : Account.find(params[:account_id]).name}", :align => :center, :inline_format => true, :size =>10
		if !params[:branch_id].blank?   
		 pdf.text "Branch: #{Branch.find(params[:branch_id]).name} ", :align => :center, :size => 6 
		end     
    pdf.move_down 5
    pdf.text "#{ (params[:start_date].blank?)?@financial_year.start_date : params[:start_date] unless @ledgers.blank?} To #{ (params[:end_date].blank?)? ((Time.zone.now.to_date > @financial_year.end_date)? @financial_year.end_date : Time.zone.now.to_date) : params[:end_date] }", :align => :center, :size => 6
  end
	pdf.move_down 10
	
	data = [['Date', 'Corresponding Account', 'P a r t i c u l a r s', 'Type', 'Debit ', 'Credit']]
	
	debit = 0
	credit = 0
	prev_date = nil 
	i = 0
	for ledger in @ledgers 
        if !ledger.retrieve_corresponding_account.nil?
		data +=[[{:content => "#{(ledger.transaction_date.strftime("%d-%m-%Y") == prev_date)? '': ledger.transaction_date.strftime("%d-%m-%Y")}"},
					{:content => "#{(ledger.debit > 0)? "To":"By" } #{ledger.multiple_correlate_ledgers? ? "Multiple accounts" : (truncate(Account.find(ledger.retrieve_corresponding_account).name, :length => 25))}"},
					{:content => "#{truncate(ledger.description, :length => 25)}"},
					{:content => "#{ledger.voucher_type}"},
					{:content => "#{format_currency(ledger.debit)}"},
					{:content => "#{format_currency(ledger.credit)}" }]]
		debit += ledger.debit
		credit += ledger.credit
		prev_date = ledger.transaction_date.strftime("%d-%m-%Y")
		i += 1
	end
	end
	data += [["","","","",{:content => "#{format_currency(debit)}", :font_style => :bold},{:content => "#{format_currency(credit)}", :font_style => :bold}]]
    data += [["","",{:content =>'Closing Balance', :font_style => :bold},"","",{:content => "#{format_currency(closing_balance = debit - credit)}", :font_style => :bold}]]
    data += [["","","","",{:content => "#{format_currency(debit)}",:font_style => :bold},{:content =>"#{format_currency(credit + closing_balance)}", :font_style => :bold}]]
	
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
			pdf.draw_text "Generated from www.profitnext.com", :at=>[0,-10], :size => 7
		else
			pdf.draw_text @footer.strip, :at => [0,-10], :size => 7
		end
		pdf.fill_color "000000"
		pdf.draw_text "Page : #{i+1} / #{pdf.page_count}", :at=>[pdf.bounds.width - 50,-10], :size => 9
	end
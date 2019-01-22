Prawn::Document.generate('cash_book.pdf', :page_layout => :portrait, :page => 'A4')
	pdf.bounding_box([0,pdf.cursor], :width => pdf.bounds.width, :height =>80) do
		pdf.text "<b>#{@company.name}</b>", :align => :center, :inline_format => true, :size =>14
		pdf.text "<u>Cash Book</u>", :align => :center, :inline_format => true, :size => 12
		 pdf.move_down 5
    pdf.text "#{(params[:account_id].blank?)? Account.find(@accounts.first.id).name : Account.find(params[:account_id]).name}", :align => :center, :inline_format => true, :size =>10
    if !params[:branch_id].blank?
     pdf.text "Branch: #{Branch.find(params[:branch_id]).name}", :align => :center, :inline_format => true, :size =>6
    end
    pdf.move_down 5
    pdf.text "#{ @start_date } To #{ @end_date }", :align => :center, :size => 6
  end
	pdf.move_down 10
	
	data =[['Date', 'Corresponding Account', 'P a r t i c u l a r s', 'Voucher No', {:content => 'Debit', :align => :right}, {:content => 'Credit', :align => :right}, {:content => 'Closing Balance', :align => :right}]]
	
	debit = 0
	credit = 0
	prev_date = nil 
	closing_balance = 0
	i = 0
	@opening_balance = @account.opening_balance_on_date(@start_date)
	
	  if !@opening_balance.blank? && @opening_balance > 0
              
   data +=[['','','Opening Balance','',{:content => "#{format_currency @opening_balance.abs}",:align => :right},'']]
   	  else
   	data +=[['','','Opening Balance','','',{:content => "#{format_currency @opening_balance.abs}",:align => :right}]]  	
      end

  if !@opening_balance.blank? && @opening_balance > 0
                debit = @opening_balance
              elsif !@opening_balance.blank?
                credit = @opening_balance.abs
              end


	for ledger in @ledgers 
		debit += ledger.debit
		credit += ledger.credit
		closing_balance = debit - credit
		data +=[[{:content => "#{ledger.transaction_date.strftime("%d-%m-%Y")}"},
					{:content => "#{(ledger.debit > 0)? "To":"By" } #{ledger.multiple_correlate_ledgers? ? "Multiple accounts" : ledger.retrieve_corresponding_account.name}"},
					{:content => "#{ledger.description}"},
					{:content => "#{ledger.voucher_number}"},
					{:content => "#{format_currency(ledger.debit)}", :align => :right},
					{:content => "#{format_currency(ledger.credit)}", :align => :right },
					{:content => "#{format_currency(closing_balance)}", :align => :right }]]
		
		prev_date = ledger.transaction_date.strftime("%d-%m-%Y")
		i += 1
	end
	
	data += [["","","",{:content => "Total", :font_style => :bold},{:content => "#{format_currency(debit)}", :font_style => :bold, :align => :right},{:content => "#{format_currency(credit)}", :font_style => :bold, :align => :right},{:content => "#{format_currency(closing_balance)}", :font_style => :bold, :align => :right}]]
	
	pdf.table(data, :header => true, :width => pdf.bounds.width,:row_colors => ["FFFFFF","F2F7FF"] , :cell_style => {:border_width => 0, :border_color => "70B8FF", :size => 9}, :column_widths => {0 => 56, 1 => 114, 2 => 99})do
		row(0).borders = [:top, :bottom]
		row(0).border_width = 0.1
		row(0).font_style = :bold
		row(i + 1).column(4..6).borders = [:bottom]
		row(i + 1).column(4..6).border_width = 0.1
		row(i + 3).column(4..6).borders = [:bottom]
		row(i + 3).column(4..6).border_width = 0.1
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

pdf = Prawn::Document.new(:page_layout => :portrait, :page => 'A4')
	pdf.bounding_box([0,pdf.cursor], :width => pdf.bounds.width, :height =>100) do
		pdf.text "<b>#{@company.name}</b>", :align => :center, :inline_format => true, :size =>14

    pdf.text "#{@company.address.get_address unless @company.address.blank?}",:align => :center, :size => 10		   

    pdf.move_down 10

		pdf.text "<u>Bills Payable</u>", :align => :center, :inline_format => true, :size => 12
  	pdf.move_down 5
    
    pdf.text "#{(params[:account_id].blank?)? "All vendors" : Account.find(params[:account_id]).name}", :align => :center, :inline_format => true, :size =>10
		if !params[:branch_id].blank?   
		 pdf.text "Branch: #{Branch.find(params[:branch_id]).name} ", :align => :center, :size => 6 
		end     
    pdf.move_down 5
    
    pdf.text "#{@start_date} To #{ @end_date}", :align => :center, :size => 6
  end

	pdf.move_down 10
	
	data = [['Voucher', "Party's Name", 'Date', 'Due on', "Amount (#{@company.currency_code})", 'Overdue by Days']]
	i = 0
	total = 0
	@purchases.each do |purchase|
	  days_overdue=Time.zone.now.to_date - purchase.due_date
	  outstanding = purchase_outstanding(purchase)
			data +=[["#{purchase.purchase_number}",
					{:content => "#{purchase.account.name}"},
					{:content => "#{purchase.record_date}"},
					{:content => "#{purchase.due_date}"},
					{:content => "#{outstanding}", :align => :right },
					{:content => "#{days_overdue<=0 ? '-' :"#{days_overdue.to_i} days"}"}]]
		total += outstanding
		i += 1
	end
	
	data += [["","", "", {:content =>'Grand Total', :font_style => :bold},{:content => "#{format_currency(total)}", :font_style => :bold, :align => :right}, ""]]
	
	pdf.table(data, :header => true, :width => pdf.bounds.width,:row_colors => ["FFFFFF","F2F7FF"] , :cell_style => {:border_width => 0, :border_color => "70B8FF", :size => 9}, :column_widths => {0 => 100, 1 => 150, 2 => 60, 3=>60})do
		row(0).borders = [:top, :bottom]
		row(0).border_width = 0.1
		row(0).font_style = :bold
		row(i + 1).column(3).borders = [:top, :bottom]
		row(i + 1).column(3).border_width = 0.1
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

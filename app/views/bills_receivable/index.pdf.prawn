pdf = Prawn::Document.new(:page_layout => :portrait, :page => 'A4')
	pdf.bounding_box([0,pdf.cursor], :width => pdf.bounds.width, :height =>100) do

		pdf.text "<b>#{@company.name}</b>", :align => :center, :inline_format => true, :size =>14

		pdf.text "#{@company.address.get_address unless @company.address.blank?}",:align => :center, :size => 10

    pdf.move_down 10

		pdf.text "<u>Bills Receivable</u>", :align => :center, :inline_format => true, :size => 12

		pdf.move_down 5

    pdf.text "#{(@account.blank?)? 'All customers' : @account.name}", :align => :center, :inline_format => true, :size =>10
    if !params[:branch_id].blank?
		 pdf.text "Branch: #{Branch.find(params[:branch_id]).name} ", :align => :center, :size => 6
		end
    pdf.move_down 5

    pdf.text "#{ @start_date } To #{ @end_date }", :align => :center, :size => 6
  end

	pdf.move_down 10

	data = [['Voucher', "Party's Name", 'Date', 'Due on', {:content => "Amount (#{@company.currency_code})", :align => :right}, {:content => 'Overdue by Days',:align => :center}]]
	i = 0
	total = 0
	@invoices.each do |invoice|
		days_overdue=Time.zone.now.to_date - invoice.due_date
		outstanding_amt =invoice.outstanding
		if outstanding_amt >0
			data +=[[invoice.invoice_number,
			{:content => "#{invoice.account.name}"},
			invoice.invoice_date,
			invoice.due_date,
			{:content => "#{outstanding_amt}", :align => :right },
			{:content => "#{invoice_overdue_days_in_words(invoice.due_date)}", :align => :center}]]
		end
		total += outstanding_amt
		i += 1
	end
	data += [["","", "", {:content =>'Grand Total', :font_style => :bold},{:content => "#{format_currency(total)}", :font_style => :bold, :align => :right}, ""]]



	pdf.table(data, :header => true, :width => pdf.bounds.width,:row_colors => ["FFFFFF","F2F7FF"] , :cell_style => {:border_width => 0, :border_color => "70B8FF", :size => 9}, :column_widths => {0 => 120, 1 => 150, 2 => 60, 3=>60, 4 => 100})do
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

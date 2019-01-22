pdf = Prawn::Document.new(:page_layout => :portrait, :page => 'A4')
pdf.bounding_box([0,pdf.cursor], :width => pdf.bounds.width, :height =>100) do
		
		pdf.text "<b>#{@company.name}</b>", :align => :center, :inline_format => true, :size =>14
		pdf.text "#{@company.address.get_address unless @company.address.blank?}",:align => :center, :size => 10
		 pdf.move_down 10
		
		pdf.text "<u>Invoice Settlement</u>", :align => :center, :inline_format => true, :size => 12
		pdf.move_down 5
		pdf.text "#{(@account.blank?)? 'All customers' : @account.name}", :align => :center, :inline_format => true, :size =>10
		if !params[:branch_id].blank?   
		 pdf.text "Branch: #{Branch.find(params[:branch_id]).name} ", :align => :center, :size => 6 
		end 
     pdf.move_down 5
      pdf.text "#{ @start_date } To #{ @end_date }", :align => :center, :size => 6
		end
		pdf.move_down 10
		data = [['Voucher No', "#{@company.label.customer_label}", 'Settled to', 'Due on','Settled on','Settled by',{:content=>'Invoice Amount', :align=>:right},{:content=>'Settled Amount', :align=>:right}]]
		i = 0
	total = 0
	@invoices.each do|invoice|
	data +=[[invoice.invoice_number,
	{:content => "#{invoice.account.name}"},
	invoice.settlement_account.name,
	invoice.due_date,
	invoice.invoice_date,
	invoice.created_by_user,
	{:content=>"#{invoice.currency} #{invoice.total_amount}", :align=>:right },
	{:content=>"#{invoice.currency} #{invoice.outstanding}", :align=>:right }]]
	 end


	 pdf.table(data, :header => true, :row_colors => ["FFFFFF","F2F7FF"] , :cell_style => {:border_width => 0, :border_color => "70B8FF", :size => 9})do
		row(0).borders = [:top, :bottom]
		row(0).border_width = 0.1
		row(0).font_style = :bold
		row(i + 1).borders = [:top, :bottom]
		row(i + 1).border_width = 0.1
		
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
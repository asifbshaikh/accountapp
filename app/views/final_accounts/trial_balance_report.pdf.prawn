pdf = Prawn::Document.new(:page_layout => :portrait, :page => 'A4')
	pdf.bounding_box([0,pdf.cursor], :width => pdf.bounds.width, :height =>80) do
		pdf.text "<b>#{@company.name }</b>", :align => :center, :inline_format => true, :size =>14
		pdf.text "<u>Trial Balance</u>", :align => :center, :inline_format => true, :size => 12
		pdf.move_down 10
		pdf.text "1-Apr-2011 to 31-Mar-2011", :align => :center, :size => 10
	end
	pdf.move_down 10
	
	data = [[ 'P a r t i c u l a r s','','','', 'Debit ', 'Credit']]
	
    for acc_head in @account_heads
		data +=[[{:content => "#{acc_head.name}", :font_style => :bold},'','','','','']]
	  for acc in Account.find_all_by_account_head_id(acc_head.id)
	     amount = acc.closing_balance
	     if amount <= 0
		   data +=[[".....#{acc.name}","","","",{:content => "#{-1*amount}", :align => :right},{:content =>"#{00}", :align => :right}]]
		else
	       data +=[[".....#{acc.name}","","","",{:content => "#{00}", :align => :right},{:content =>"#{amount}", :align => :right}]]
		end
	  end	
	end
	

    data += [[{:content =>'Grand Total', :font_style => :bold},"","","",{:content => "#{@total_debit}",:font_style => :bold},{:content =>"#{@total_credit}", :font_style => :bold}]]
	
	pdf.table(data, :header => true, :width => pdf.bounds.width,:row_colors => ["FFFFFF","F2F7FF"] , :cell_style => {:border_width => 0, :border_color => "70B8FF", :size => 9}, :column_widths => {0 => 160, 4 => 60, 5 => 60})do
		row(0).borders = [:top, :bottom]
		row(0).border_width = 0.1
		row(0).font_style = :bold
		
	end
	
	pdf.page_count.times do |i|
		pdf.go_to_page(i+1)
		pdf.fill_color "ADADAD"
		if @footer.nil? || @footer.strip == ''
			pdf.draw_text "Generated from www.profitbooks.net", :at=>[0,-10], :size => 7
		else
			pdf.draw_text @footer.strip, :at => [0,-10], :size => 7
		end
		pdf.fill_color "000000"
		pdf.draw_text "Page : #{i+1} / #{pdf.page_count}", :at=>[pdf.bounds.width - 50,-10], :size => 9
	end

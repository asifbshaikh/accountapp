pdf = Prawn::Document.new(:page_layout => :portrait, :page => 'A4')
	pdf.bounding_box([0,pdf.cursor], :width => pdf.bounds.width, :height =>80) do
		pdf.text "<b>#{@company.name }</b>", :align => :center, :inline_format => true, :size =>14
		pdf.text "<u>Vertical Balance</u>", :align => :center, :inline_format => true, :size => 12
		pdf.move_down 10
		pdf.text "1-Apr-2011 to 31-Mar-2011", :align => :center, :size => 10
	end
	pdf.move_down 10
	
	data = [[ 'P a r t i c u l a r s','','','', '1-Apr-2010 to 31-Mar-2011'],
	        [{:content => "Sources of Fund :", :font_style => :bold},'','','',''],
	        ['Capital Account','','','',{:content => "#{@total_capital_amount}", :align => :right}],
	        ['Loans (Liability)','','','',{:content => "#{@total_loan_amount}", :align => :right}],
	        ['Current Liabilities','','','',{:content => "#{@total_liability_amount}", :align => :right}],
	        ['Profit and Loss Accounts','','','',{:content => "#{@nett_profit}", :align => :right}],
	        [{:content => "Total :", :font_style => :bold},'','','',{:content => "#{@total_capital_amount + @total_loan_amount + @total_liability_amount + @nett_profit}", :align => :right , :font_style => :bold}],
	        [{:content => "Application of Fund :", :font_style => :bold},'','','',''],
	        ['Fixed Assets','','','',{:content => "#{@total_fixed_asset_amount}", :align => :right}],
	        ['Investments','','','',{:content => "#{@total_investment_amount}", :align => :right}],
	        ['Current Assets','','','',{:content => "#{@total_current_asset_amount}", :align => :right}],
	        [{:content => "Total :", :font_style => :bold},'','','',{:content => "#{@total_fixed_asset_amount + @total_investment_amount + @total_current_asset_amount}", :align => :right, :font_style => :bold}]
	        
	        ]
	
	pdf.table(data, :header => true, :width => pdf.bounds.width,:row_colors => ["FFFFFF","F2F7FF"] , :cell_style => {:border_width => 0, :border_color => "70B8FF", :size => 9}, :column_widths => {0 => 160, 5 => 80})do
		row(0).borders = [:top, :bottom]
		row(0).border_width = 0.1
		row(0).font_style = :bold
		row(6).column(0).borders = [:top, :bottom]
		row(6).column(0).border_width = 0.1
		row(6).column(4).borders = [:top, :bottom]
		row(6).column(4).border_width = 0.1
		row(11).column(0).borders = [:top, :bottom]
		row(11).column(0).border_width = 0.1
		row(11).column(4).borders = [:top, :bottom]
		row(11).column(4).border_width = 0.1
		
		
		
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

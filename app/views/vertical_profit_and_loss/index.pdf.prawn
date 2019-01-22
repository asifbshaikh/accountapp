pdf = Prawn::Document.new(:page_layout => :portrait, :page => 'A4')
	pdf.bounding_box([0,pdf.cursor], :width => pdf.bounds.width, :height =>80) do
		pdf.text "<b>#{@company.name }</b>", :align => :center, :inline_format => true, :size =>14
		pdf.text "<u>Profit and Loss Account</u>", :align => :center, :inline_format => true, :size => 12
		pdf.move_down 10
		pdf.text "1-Apr-2011 to 31-Mar-2011", :align => :center, :size => 10
	end
	pdf.move_down 10
	
	data = [[ 'P a r t i c u l a r s','','','', '1-Apr-2010 to 31-Mar-2011']]
	data +=[[{:content => "Trading Account :", :font_style => :bold},'','','','']]
	data +=[[{:content => "Sales Account", :font_style => :bold},'','','',{:content => "#{@sales_total_amount}", :font_style => :bold, :align => :right}]]
	
	
    for account in @sale_accounts
      data +=[[".....#{account.name}",'','',{:content => "#{account.closing_balance}",:align => :right},'']]
    end
    
	data +=[[{:content => "Cost of Sales", :font_style => :bold},'','','',{:content => "#{sales_cost = @total_purchase_amount + @opening_stock - @closing_stock}", :font_style => :bold, :align => :right}],
	        ['.....Opening Stock','','',{:content => "#{@opening_stock}",:align => :right},''],
	        ['.....Add:Purchase Accounts','','',{:content => "#{@total_purchase_amount}",:align => :right},''],
	        ['.....Less:Closing Stock','','',{:content => "#{@opening_stock}",:align => :right},''],
	        [{:content => "Direct Expenses", :font_style => :bold},'','','',{:content => "#{ @total_direct_expence}", :font_style => :bold, :align => :right}]
	  
	        ]
    
    
     for exps in @direct_expenses
      data +=[["....#{exps.name}",'','',{:content => "#{exps.closing_balance}",:align => :right},'']]
    end
   
    data +=[[{:content => "Gross Profit", :font_style => :bold},'','','',{:content => "#{gross_profit = @sales_total_amount - (sales_cost + @total_direct_expence)}", :font_style => :bold, :align => :right}],
            [{:content => "Income Statement :", :font_style => :bold},'','','',''],
	        ['Indirect Incomes','','',{:content => "#{@total_purchase_amount}",:align => :right},''],
	        [{:content => "Indirect Expenses", :font_style => :bold},'','','',{:content => "#{@total_indirect_expence}", :font_style => :bold, :align => :right}]
	  
	        ]
    
         for inexps in @indirect_expenses
            data +=[[".....#{inexps.name}",'','',{:content => "#{inexps.closing_balance}",:align => :right},'']]
		 end 
    
           data +=[[{:content => "Nett Profit :", :font_style => :bold},'','','',{:content => "#{gross_profit - (@total_indirect_expence)}", :font_style => :bold, :align => :right}]]
        
	
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

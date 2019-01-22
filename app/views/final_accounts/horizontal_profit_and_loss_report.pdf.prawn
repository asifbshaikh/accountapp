
	
	pdf = Prawn::Document.new(:page_layout => :portrait, :page_size => 'A4')

pdf.bounding_box([0,pdf.cursor], :width => pdf.bounds.width, :height =>100) do
		pdf.text "<b>#{@company.name }</b>", :align => :center, :inline_format => true, :size =>14
		pdf.text "123, raja marg,\nMagarpatta road , Hadapsar", :align => :center, :size => 10
		pdf.move_down 10
		pdf.text "<u>Horizontal Profit and Loss Account</u>", :align => :center, :inline_format => true, :size => 12
		pdf.move_down 10
	end
pdf.move_down 10

	pdf.table([["Expense",{:content =>"1-Apr-2010 to 31-Mar-2011", :align => :right},"Income" ,{:content => "1-Apr-2010 to 31-Mar-2011", :align => :right}]],
	 :header => true, :width => pdf.bounds.width , :cell_style =>{:border_width => 0,:border_color => "70B8FF", :size => 9}) do
		row(0).font_style = :bold
		row(0).borders = [:bottom, :top]
		row(0).border_width = 0.1
		
	end
pdf.move_down 10
	net_profit = @total_sales_amount + @total_inventories - (@total_purchase_amount + @total_direct_expence  + @total_indirect_expence)

	y_position = pdf.cursor
	pdf.bounding_box([0, y_position], :width => (pdf.bounds.width / 2) - 5) do
	
	data = []
	i = 0
	
	if !@inventories.nil?
	 for inv in @inventories 
	 
			data += [["manjeet s bhatkar",{:content => "1234567890", :align => :right},"1234567890"]]
		i += 1
	end
   end		
	    
	    data += [["Purchase Accounts","",{:content => "#{@total_purchase_amount}", :align => :right}]]
	    i += 1
	    
    if !@purchase_accounts.nil?
	 for p_acc in @purchase_accounts
			data += [["...#{p_acc.name}",{:content => "#{p_acc.closing_balance}", :align => :right},""]]
		i += 1
	end
 end
	
	data += [["Direct Expences","",{:content => "#{@total_direct_expence}", :align => :right}]]
	
	i += 1
	if !@direct_expenses.nil?
		for exp in @direct_expenses
			data += [["...#{exp.name}",{:content => "#{exp.closing_balance}", :align => :right},""]]
		i += 1
	end
 end
	
	data += [["Indirect Expences","",{:content => "#{@total_indirect_expence}", :align => :right}]]
	
	i += 1
	if !@indirect_expenses.nil?
	  for inexp in @indirect_expenses
			data += [["...#{inexp.name}",{:content => "#{inexp.closing_balance}", :align => :right},""]]
		i += 1
	end
 end
	
		data += [["Net Profit","",{:content => "#{net_profit}", :align => :right}]]
		
		data += [["Total","",{:content => "#{@total_purchase_amount + @total_direct_expence  + @total_indirect_expence + net_profit}", :align => :right}]]
		
	
	
		pdf.table(data, :width => (pdf.bounds.width - 10),:row_colors => ["FFFFFF","F2F7FF"] , :cell_style =>{:border_width => 0, :border_color => "70B8FF", :size => 9})do
			row(0).borders = [:top]
			row(0).border_width = 0.1
            row(i+1).borders = [:bottom]
            row(i+1).border_width = 0.1
                
		end
	end



	pdf.bounding_box([(pdf.bounds.width / 2) + 5, y_position], :width => (pdf.bounds.width / 2) - 10) do
	
		data = [["Sales Accounts","",{:content => "#{@total_sales_amount}", :align => :right}]]
	
	
	i = 0
  if !@sale_accounts.nil?
	for s_acc in @sale_accounts
			data += [["...#{s_acc.name}",{:content => "#{s_acc.closing_balance }", :align => :right},""]]
		i += 1
	end
 end		
	  
	    
      data += [["Direct Incomes","",{:content => "#{@total_direct_income_amount}", :align => :right}]]
	
	   i += 1
	if !@direct_income_accounts.nil?
		for s_acc in @direct_income_accounts
			data += [["...#{s_acc.name}",{:content =>  "#{s_acc.closing_balance}", :align => :right},""]]
		i += 1
	end
 end	
	
	data += [["Indirect Incomes","",{:content => "#{@total_indirect_income_amount}", :align => :right}]]
	
	i += 1
	if !@indirect_income_accounts.nil?
	  for s_acc in @indirect_income_accounts
			data += [["...#{s_acc.name}",{:content => "#{s_acc.closing_balance}", :align => :right},""]]
		i += 1
	end
 end	
	    
		 data += [["Total","",{:content => "#{@total_sales_amount + @total_inventories}", :align => :right}]]
		
		pdf.table(data, :width => (pdf.bounds.width - 10),:row_colors => ["FFFFFF","F2F7FF"] , :cell_style =>{:border_width => 0, :border_color => "70B8FF", :size => 9})do
			row(0).borders = [:top]
			row(0).border_width = 0.1
            row(i+1).borders = [:bottom]
            row(i+1).border_width = 0.1
                
		end
	end
	
	pdf.move_down 35
	
	
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
	
	
	

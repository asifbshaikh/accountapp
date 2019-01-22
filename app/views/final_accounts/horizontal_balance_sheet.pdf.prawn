pdf = Prawn::Document.new(:page_layout => :portrait, :page_size => 'A4')

pdf.bounding_box([0,pdf.cursor], :width => pdf.bounds.width, :height =>100) do
		pdf.text "<b>#{@company.name }</b>", :align => :center, :inline_format => true, :size =>14
		pdf.text "123, raja marg,\nMagarpatta road , Hadapsar", :align => :center, :size => 10
		pdf.move_down 10
		pdf.text "<u>Horizontal Balance Sheet </u>", :align => :center, :inline_format => true, :size => 12
		pdf.move_down 10
	end
pdf.move_down 10

	pdf.table([["Liabilities",{:content =>"1-Apr-2010 to 31-Mar-2011", :align => :right},"Assets" ,{:content => "1-Apr-2010 to 31-Mar-2011", :align => :right}]],
	 :header => true, :width => pdf.bounds.width , :cell_style =>{:border_width => 0,:border_color => "70B8FF", :size => 9}) do
		row(0).font_style = :bold
		row(0).borders = [:bottom, :top]
		row(0).border_width = 0.1
		
	end
pdf.move_down 10

	y_position = pdf.cursor
	pdf.bounding_box([0, y_position], :width => (pdf.bounds.width / 2) - 5) do
	
	data = [["Capital Accounts","",{:content => "#{(@total_capital_amount >=0)? "#{@total_capital_amount} Cr" : "#{-1*@total_capital_amount} Dr"}", :align => :right}]]
	
	
	i = 0
	for c_acc in @capital_accounts 
	 closing_balance = c_acc.closing_balance
			data += [["...#{c_acc.name}",{:content => "#{closing_balance}#{(closing_balance >= 0)? 'Cr':'Dr'}", :align => :right},""]]
		i += 1
	end
		data += [["Profit and Loss Account","",{:content => "#{@nett_profit + @opening_balance}", :align => :right}]]
		i += 1
	    data += [["...Opening Balance","",""]]
	    i += 1
		data += [["...Current Period",{:content => "#{@nett_profit}", :align => :right},""]]
		i += 1
	    
	    data += [["Loan Accounts","",{:content => "#{(@total_loan_amount >=0 )? "#{@total_loan_amount} Cr" : "#{-1*@total_loan_amount}Dr"}", :align => :right}]]
	    i += 1
	    
    for l_acc in @loan_accounts
	 closing_balance = c_acc.closing_balance
			data += [["...#{l_acc.name}",{:content => "#{l_acc.closing_balance}", :align => :right},""]]
		i += 1
	end
	
	
	data += [["Secured Loan Accounts","",{:content => "#{(@total_capital_amount >=0)? "#{@total_capital_amount} Cr" : "#{-1*@total_capital_amount} Dr"}", :align => :right}]]
	
	i += 1
	for l_acc in @secured_loan_accounts 
	 closing_balance = l_acc.closing_balance
			data += [["...#{l_acc.name}",{:content => "#{(closing_balance >=0 )? "#{closing_balance}Cr":"#{-1*closing_balance} Dr"}", :align => :right},""]]
		i += 1
	end
	
	
	data += [["Unsecured Loan Accounts","",{:content => "#{(@total_capital_amount >=0)? "#{@total_capital_amount}Cr" : "#{-1*@total_capital_amount} Dr"}", :align => :right}]]
	
	i += 1
	for l_acc in @unsecured_loan_accounts  
	 closing_balance = l_acc.closing_balance
			data += [["...#{l_acc.name}",{:content => "#{(closing_balance >= 0)? "#{closing_balance}Cr" : "#{-1*closing_balance}Dr"}", :align => :right},""]]
		i += 1
	end
	
	
	data += [["Sundry Creditors","",{:content => "#{(@total_capital_amount >=0)? "#{@total_capital_amount} Cr" : "#{-1*@total_capital_amount}Dr"}", :align => :right}]]
	
	i += 1
	for cl_acc in @sundry_creditor_accounts 
	 closing_balance = cl_acc.closing_balance
			data += [["...#{cl_acc.name}",{:content => "#{(closing_balance >= 0)? "#{closing_balance}Cr" : "#{-1*closing_balance} Dr"}", :align => :right},""]]
		i += 1
	end
	
	
	data += [["Duties and Taxes","",{:content => "#{(@total_duties_and_taxes_amount >=0 )? "#{@total_duties_and_taxes_amount} Cr" : "#{-1*@total_duties_and_taxes_amount}Dr"}", :align => :right}]]
	
	i += 1
	for l_acc in @duties_and_taxes_accounts 
	 closing_balance = l_acc.closing_balance
			data += [["...#{cl_acc.name}",{:content => "#{(closing_balance >= 0)? "#{closing_balance}Cr" : "#{-1*closing_balance}Dr"}", :align => :right},""]]
		i += 1
	end
	
	
	data += [["Provisions","",{:content => "#{(@total_provision_amount >= 0)? "#{@total_provision_amount} Cr" : "#{-1*@total_provision_amount}Dr"}", :align => :right}]]
	
	i += 1
	for l_acc in @provision_accounts 
	 closing_balance = l_acc.closing_balance
			data += [["...#{l_acc.name}",{:content => "#{(closing_balance >= 0 )? "#{closing_balance}Cr" : "#{-1*closing_balance}Dr"}", :align => :right},""]]
		i += 1
	end
	
	if @total_suspense_amount > 0
	data += [["Suspense Accounts","",{:content => "#{(@total_suspense_amount >= 0 )? "#{@total_suspense_amount}Cr" : "#{-1*@total_suspense_amount}Dr"}", :align => :right}]]
	
	i += 1
	for ca_acc in @suspense_accounts
	 closing_balance = ca_acc.closing_balance
			data += [["...#{ca_acc.name}",{:content => "#{ (closing_balance >= 0 )? "#{closing_balance} Cr" : "#{-1*closing_balance}Dr"}", :align => :right},""]]
		i += 1
	end
   end	
	
		data += [["Total","",{:content => "#{@total_liabilities}", :align => :right}]]
	
	
		pdf.table(data, :width => (pdf.bounds.width - 10),:row_colors => ["FFFFFF","F2F7FF"] , :cell_style =>{:border_width => 0, :border_color => "70B8FF", :size => 9})do
			row(0).borders = [:top]
			row(0).border_width = 0.1
            row(i+1).borders = [:bottom]
            row(i+1).border_width = 0.1
                
		end
	end



	pdf.bounding_box([(pdf.bounds.width / 2) + 5, y_position], :width => (pdf.bounds.width / 2) - 10) do
	
		data = [["Fixed Asset","",{:content => "#{(@total_fixed_asset_amount >= 0 )? "#{@total_fixed_asset_amount}Dr" :"#{-1*@total_fixed_asset_amount}Cr"}", :align => :right}]]
	
	
	i = 0
   for f_acc in @fixed_asset_accounts
	 closing_balance = f_acc.closing_balance
			data += [["...#{f_acc.name}",{:content => "#{(closing_balance >= 0)? "#{closing_balance} Cr" : "#{-1*closing_balance} Dr" }", :align => :right},""]]
		i += 1
	end
		data += [["Investments","",{:content => "#{@total_investment_amount}", :align => :right}]]
		i += 1
	  
	    
      data += [["Bank Accounts","",{:content => "#{(@total_provision_amount >= 0)? "#{@total_provision_amount}Cr" : "#{-1*@total_provision_amount} Dr"}", :align => :right}]]
	
	   i += 1
	for ca_acc in @bank_accounts 
	 closing_balance = ca_acc.closing_balance
			data += [["...#{ca_acc.name}",{:content => "#{(closing_balance >= 0 )? "#{closing_balance} Cr" : "#{-1*closing_balance} Dr"}", :align => :right},""]]
		i += 1
	end
	
	
	data += [["Cash Accounts","",{:content => "#{(@total_cash_amount >= 0 )? "#{@total_cash_amount}Dr" : "#{-1*@total_cash_amount} Cr"}", :align => :right}]]
	
	i += 1
	for ca_acc in @cash_accounts 
	 closing_balance = ca_acc.closing_balance
			data += [["...#{ca_acc.name}",{:content => "#{(closing_balance >= 0 )? "#{closing_balance}Cr" : "#{-1*closing_balance} Dr"}", :align => :right},""]]
		i += 1
	end
	
	
	data += [["Sundry Debtors","",{:content => "#{(@total_sundry_debtor_amount >= 0)? "#{@total_sundry_debtor_amount}Dr" : "#{-1*@total_sundry_debtor_amount}Cr"}", :align => :right}]]
	
	i += 1
   for ca_acc in @sundry_debtor_accounts  
	 closing_balance = ca_acc.closing_balance
			data += [["...#{ca_acc.name}",{:content => "#{(closing_balance >= 0 )? "#{closing_balance}Cr" : "#{-1*closing_balance} Dr"}", :align => :right},""]]
		i += 1
	end
	
	
	data += [["Deposit","",{:content => "#{(@total_deposit_amount >= 0)? "#{@total_deposit_amount} Dr" : "#{-1*@total_deposit_amount}Cr"}", :align => :right}]]
	
	i += 1
	for ca_acc in @deposit_accounts 
	 closing_balance = ca_acc.closing_balance
			data += [["...#{ca_acc.name}",{:content => "#{(closing_balance >= 0)? "#{closing_balance} Cr" : "#{-1*closing_balance} Dr"}", :align => :right},""]]
		i += 1
	end
	
	
	data += [["Loans and Advances","",{:content => "#{(@total_loan_and_advance_amount >= 0 )? "#{@total_loan_and_advance_amount}Dr" : "#{-1*@total_loan_and_advance_amount}Cr"}", :align => :right}]]
	
	i += 1
	for ca_acc in @loan_and_advance_accounts 
	 closing_balance = ca_acc.closing_balance
			data += [["...#{ca_acc.name}",{:content => "#{(closing_balance >= 0 )? "#{closing_balance} Cr" : "#{-1*closing_balance}Dr"}", :align => :right},""]]
		i += 1
	end
	
	
	
	
	if @total_suspense_amount < 0
	data += [["Suspense Accounts","",{:content => "#{ (@total_suspense_amount >= 0 )? "#{@total_suspense_amount} Cr" : "#{-1*@total_suspense_amount} Dr"}", :align => :right}]]
	
	i += 1
	for ca_acc in @suspense_accounts
	 closing_balance = ca_acc.closing_balance
			data += [["...#{ca_acc.name}",{:content => "#{ (closing_balance >= 0 )? "#{closing_balance}Cr" : "#{-1*closing_balance}Dr"}", :align => :right},""]]
		i += 1
	end
   end	
	
			data += [["Total","",{:content => "#{@total_assets}", :align => :right}]]
	
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
	
	
	

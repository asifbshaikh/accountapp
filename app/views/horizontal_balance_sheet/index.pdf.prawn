pdf = Prawn::Document.new(:page_layout => :portrait, :page => 'A4')
  y_position = pdf.cursor
	pdf.bounding_box([0, pdf.cursor], :width => (pdf.bounds.width) ) do
		pdf.text "<b>#{@company.name}</b>", :align => :center, :inline_format => true, :size =>14
		pdf.text "#{@company.address.get_address unless @company.address.blank?}", :align => :center, :size => 10
	end
	branch = @branch
  start_date = @start_date
  end_date = @end_date

     pdf.move_down 10


     pdf.text "<b><u>Balance Sheet</u></b>", :align => :center, :inline_format => true, :size => 12
    pdf.text " As on date #{ @end_date }",:align => :center, :size => 6

 data = [[{:content => "Liabilities"},{:content => "as at #{@end_date}", :align => :right, :size => 10}, {:content => "Assets"},{:content => "as at #{@end_date}", :align => :right, :size => 10}]]

  data += [[{:content => "Capital Accounts"},{:content => "#{format_currency(@balance_sheet.capital_account_balance)}", :align => :right},{:content => "Fixed Assets"},{:content => "#{format_currency(@balance_sheet.fixed_asset_account_balance)}", :align => :right}]]
  data += [[{:content => "Profit and Loss Account"},{:content => "#{format_currency(@balance_sheet.profit_and_loss)}", :align => :right },{:content =>"Investments"},{:content => "#{format_currency(@balance_sheet.investment_account_balance)}",:align => :right}]]
  data += [[{:content =>"Opening Balance"},{:content => "#{format_currency(@balance_sheet.opening_profit_loss)}",:align => :right},{:content => "Bank Accounts"},{:content => "#{format_currency(@balance_sheet.bank_account_balance)}",:align => :right}]]
  data += [[{:content => "Current Period"},{:content => "#{format_currency(@balance_sheet.current_profit_loss)}",:align => :right},{:content => "Cash Accounts"},{:content => "#{format_currency(@balance_sheet.cash_account_balance)}",:align => :right}]]
  data += [[{:content =>"Loan Account"},{:content => "#{format_currency(@balance_sheet.loan_account_balance)}",:align => :right},{:content => "Customers (Debtors)"},{:content => "#{format_currency(@balance_sheet.sundry_debtor_account_balance)}",:align => :right}]]
  data += [[{:content =>"secured Loan Account"},{:content => "#{format_currency(@balance_sheet.secured_loan_account_balance)}",:align => :right},{:content => "Deposits"},{:content =>"#{format_currency(@balance_sheet.deposit_account_balance)}",:align => :right}]]
  data += [[{:content =>"Unsecure Loan Account"},{:content => "#{format_currency(@balance_sheet.unsecured_loan_account_balance)}",:align => :right},{:content => "Loans and Advances"},{:content => "#{format_currency(@total_loan_and_advance_amount)}",:align => :right}]]
  data += [[{:content =>"Vendors (Creditors)"},{:content => "#{format_currency(@balance_sheet.sundry_creditor_account_balance)}",:align => :right},{:content => "Difference in opening balance"},{:content => "#{format_currency(@opening_balance_diff)}",:align => :right}]]
  data += [[{:content =>"Duties And Taxes"},{:content => "#{format_currency(@balance_sheet.duties_and_taxes_account_balance)}",:align => :right},"",""]]
  data += [[{:content =>"Provisions"},{:content => "#{format_currency(@balance_sheet.provision_account_balance)}",:align => :right},"",""]]
  data += [[{:content =>"Total "},{:content => "#{format_currency(@balance_sheet.total_liabilities)}",:align => :right},{:content =>"Total "},{:content => "#{format_currency(@balance_sheet.total_assets)}",:align => :right}]]



     pdf.table(data, :header => true, :width => pdf.bounds.width,:row_colors => ["FFFFFF","F2F7FF"] , :cell_style => {:border_width => 0, :border_color => "70B8FF", :size => 9}, :column_widths => {0 => 160, 4 => 60, 5 => 60})do
		row(0).borders = [:top, :bottom]
		row(0).border_width = 0.2
		row(0).font_style = :bold
		row(11).borders = [:top, :bottom]
		row(11).border_width = 0.2
		row(11).font_style = :bold

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





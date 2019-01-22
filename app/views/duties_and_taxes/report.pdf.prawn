Prawn::Document.generate('ledger.pdf', :page_layout => :portrait, :page => 'A4')
  
   y_position = pdf.cursor
  pdf.bounding_box([0, pdf.cursor], :width => (pdf.bounds.width) ) do
    pdf.text "<b>#{@company.name}</b>", :align => :center, :inline_format => true, :size =>14
    pdf.text "#{@company.address.get_address unless @company.address.blank?}", :align => :center, :size => 10
  end
     pdf.move_down 10

  y_position = pdf.cursor
  pdf.bounding_box([0, y_position], :width => (pdf.bounds.width / 2) - 5) do
  pdf.text "Tax details", :align => :left, :size => 12  
  pdf.text "#{ (params[:start_date].blank?)? @financial_year.start_date: params[:start_date] } To #{ (params[:end_date].blank?)? Time.zone.now.to_date : params[:end_date] }",:align => :left, :size => 6
  end

  pdf.bounding_box([(pdf.bounds.width / 2) + 5, y_position], :width => (pdf.bounds.width / 2) - 10) do

    pdf.text "#{(params[:account_id].blank?)? @tax_accounts.first.name : Account.find(params[:account_id]).name}".html_safe, :align => :right, :size => 12

    pdf.text "For #{ @tax_account.tax_on_sales? ? 'customer' : 'vendor' unless @tax_account.accountable_type== "OtherCurrentAsset"}: #{@cv_account.blank? ? 'All' : @cv_account.name}",:align => :right, :size => 7
  end
  pdf.move_down 10
  
  data = [['Date', 'Customer/Vendor', 'Product', 'P a r t i c u l a r s', {:content => 'Debit', :align => :right}, {:content => 'Credit', :align => :right}]]
        
     data += [["","", "",{:content =>'Opening Balance', :font_style => :bold},"",{:content => "#{(params[:account_id].blank?)? @tax_accounts.first.opening_balance : Account.find(params[:account_id]).opening_balance}", :font_style => :bold, :align => :right}]]
  debit = 0
  credit = 0
  prev_date = nil 
  i = 0
  for ledger in @ledgers 
    acc = Account.find(ledger.retrieve_corresponding_account)
    if @cv_account.blank? || acc.eql?(@cv_account)
      data +=[[{:content => "#{(ledger.transaction_date.strftime("%d-%m-%Y") == prev_date)? '': ledger.transaction_date.strftime("%d-%m-%Y")}"},
          {:content => "#{(!ledger.debit.blank? && ledger.debit > 0)? "To":"By" } #{ledger.multiple_correlate_ledgers? ? "Multiple accounts" : acc.name}"},
          {:content => "#{ledger.get_curresponding_product}", :inline_format => true},
          {:content => "#{ledger.description}"},
          {:content => "#{format_currency(ledger.credit)}", :align => :right},
          {:content => "#{format_currency(ledger.debit)}", :align => :right }]]
    end
    debit += ledger.credit
    credit += ledger.debit unless ledger.debit.blank?
    prev_date = ledger.transaction_date.strftime("%d-%m-%Y")
    i += 1
  end
  closing_balance = debit - credit
  data += [["","","","",{:content => "#{format_currency(debit)}", :font_style => :bold, :align => :right},{:content => "#{format_currency(credit)}", :font_style => :bold, :align => :right}]]
  if closing_balance < 0
    data += [["","","",{:content =>'Closing Balance', :font_style => :bold},{:content => "#{format_currency(-1*closing_balance)}", :font_style => :bold, :align => :right},""]]
      data += [["","","","",{:content => "#{format_currency(debit + -1*closing_balance)}",:font_style => :bold, :align => :right},{:content =>"#{format_currency(credit)}", :font_style => :bold, :align => :right}]]
  else
      data += [["","","",{:content =>'Closing Balance', :font_style => :bold},"",{:content => "#{format_currency(closing_balance)}", :font_style => :bold, :align => :right}]]
      data += [["","","","",{:content => "#{format_currency(debit)}",:font_style => :bold, :align => :right},{:content =>"#{format_currency(credit + closing_balance)}", :font_style => :bold, :align => :right}]]
  end
  
  pdf.table(data, :header => true, :width => pdf.bounds.width,:row_colors => ["FFFFFF","F2F7FF"] , :cell_style => {:border_width => 0, :border_color => "70B8FF", :size => 9}, :column_widths => {0 => 56, 1 => 114, 2 => 99})do
    row(0).borders = [:top, :bottom]
    row(0).border_width = 0.1
    row(0).font_style = :bold
    row(i + 1).column(4..5).borders = [:top]
    row(i + 1).column(4..5).border_width = 0.1
    row(i + 3).column(4..5).borders = [:top, :bottom]
    row(i + 3).column(4..5).border_width = 0.1
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

def add_page_break_if_overflow(pdf, &block)
  current_page = pdf.page_count
  roll = pdf.transaction do
    yield(pdf)
  
    pdf.rollback if pdf.page_count > current_page
  end
  
  if roll == false
    pdf.start_new_page
    yield(pdf)
  end
end

pdf = Prawn::Document.new(:page_layout => :portrait, :page => 'A4')
  pdf.bounding_box([0,pdf.cursor], :width => pdf.bounds.width, :height =>80) do
        pdf.text "<b>#{@company.name }</b>", :align => :center, :inline_format => true, :size =>14
      pdf.text "#{@company.address.get_address unless @company.address.blank?}",:align => :center, :size => 10
    pdf.move_down 5
        pdf.text "<u>Group Summary Report</u>", :align => :center, :inline_format => true, :size => 12
        pdf.text "<b>#{params[:transaction_type]}</b>", :align => :center, :inline_format => true, :size => 7
    pdf.text "#{@start_date} To #{@end_date}", :align => :center, :size => 7
  end
  pdf.move_down 10


   total_debit = 0
   total_credit = 0
   total_closing_balance = 0
   total_opening_balance = 0
   branch = params[:branch_id].blank? ? @current_user.branch_id : params[:branch_id].to_i

    data = [[ 'P a r t i c u l a r s','', 'Opening Balance', 'Debit ', 'Credit', 'Closing Balance']]

    for acc in @accounts
      opening_balance = 0
      opening_balance = acc.opening_balance_on_date(@start_date)
      total_opening_balance += opening_balance

      opening_balance_sufix=''
      if opening_balance < 0
        opening_balance_sufix = " Cr"
        opening_balance = opening_balance.abs
      elsif opening_balance > 0
        opening_balance_sufix = " Dr"
      end

      credit = Ledger.by_branch(branch).ledgers_in_current_year(@company.id, acc.id, @start_date, @end_date).sum(:credit)
      debit = Ledger.by_branch(branch).ledgers_in_current_year(@company.id, acc.id, @start_date, @end_date).sum(:debit)
      total_credit += credit
      total_debit += debit

      closing_balance = 0
      closing_balance = acc.balance_on_date(@end_date)
      total_closing_balance += closing_balance
      closing_balance_sufix=''
     if closing_balance < 0
       closing_balance_sufix = " Cr"
       closing_balance = closing_balance.abs
     elsif closing_balance > 0
       closing_balance_sufix = " Dr"
     end

      # amount = acc.closing_balance

       data +=[["#{acc.name}","",{:content => "#{format_currency(opening_balance)}#{opening_balance_sufix}"},{:content => "#{format_currency(debit)}"},{:content =>"#{format_currency(credit)}"}, {:content => "#{format_currency(closing_balance)}#{closing_balance_sufix}"}]]
    end

    data += [[{:content =>'Grand Total', :font_style => :bold},"",{:content => "#{format_currency total_opening_balance}",:font_style => :bold},{:content => "#{format_currency(total_debit)}",:font_style => :bold},{:content =>"#{format_currency(total_credit)}", :font_style => :bold},{:content => "#{format_currency total_closing_balance}",:font_style => :bold}]]

    pdf.table(data, :header => true, :width => pdf.bounds.width,:row_colors => ["FFFFFF","F2F7FF"] , :cell_style => {:border_width => 0, :border_color => "70B8FF", :size => 7}, :column_widths => {0 => 140, 4 => 60, 5 => 70})do
    row(0).borders = [:top, :bottom]
    row(0).border_width = 0.1
    row(0).font_style = :bold

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

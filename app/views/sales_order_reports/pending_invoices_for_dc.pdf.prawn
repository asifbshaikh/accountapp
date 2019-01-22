pdf = Prawn::Document.new(:page_layout => :portrait, :page => 'A4')
  pdf.bounding_box([0,pdf.cursor], :width => pdf.bounds.width, :height =>100) do
    
    pdf.text "<b>#{@company.name}</b>", :align => :center, :inline_format => true, :size =>14
    
    pdf.text "#{@company.address.get_address unless @company.address.blank?}",:align => :center, :size => 10       
    
    pdf.move_down 10
    
    pdf.text "<b>Pending Invoices For Delivery Challan</b>", :align => :center, :inline_format => true, :size => 12
    
    pdf.move_down 5
    
    pdf.text "#{(@customer.blank?)? 'All customers' : @customer.name}", :align => :center, :inline_format => true, :size =>10
    if !params[:branch_id].blank?   
     pdf.text "Branch: #{Branch.find(params[:branch_id]).name} ", :align => :center, :size => 6 
    end                   
    pdf.move_down 5
    pdf.text "#{ (params[:start_date].blank?) ? @financial_year.start_date : params[:start_date]} To #{ (params[:end_date].blank?)? ((Time.zone.now.to_date > @financial_year.end_date)? @financial_year.end_date : Time.zone.now.to_date) : params[:end_date] }", :align => :center, :size => 6
  end
  
  pdf.move_down 10
  
  data = [['Date', "Sales Order", 'Delivery Challan', 'Unbilled Amount']]
  i=0
  prev_date = nil
  so_no = nil
  amt = nil
   @delivery_challans.each do |dc|
    data +=[[{:content => "#{(dc.voucher_date == prev_date) ? " " : dc.voucher_date}"},
    {:content => "#{(dc.sales_order.voucher_number == so_no) ? " " : dc.sales_order.voucher_number}"},
    {:content => "#{dc.voucher_number}"},
    {:content => "#{(dc.sales_order.unbilled_amount == amt) ? " ": dc.sales_order.unbilled_amount}" }
    ]]
    prev_date = dc.voucher_date
    so_no = dc.sales_order.voucher_number
    amt = dc.sales_order.unbilled_amount
    i += 1
  end
  
  pdf.table(data, :header => true, :width => pdf.bounds.width,:row_colors => ["FFFFFF","F2F7FF"] , :cell_style => {:border_width => 0, :border_color => "70B8FF", :size => 9})do
    row(0).borders = [:top, :bottom]
    row(0).border_width = 0.1
    row(0).font_style = :bold
    row(i).borders = [:bottom]
    row(i).border_width = 0.1
    
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

pdf = Prawn::Document.new(:page_layout => :portrait, :page => 'A4')
  pdf.bounding_box([0,pdf.cursor], :width => pdf.bounds.width, :height =>100) do
    
    pdf.text "<b>#{@company.name}</b>", :align => :center, :inline_format => true, :size =>14
    
    pdf.text "#{@company.address.get_address unless @company.address.blank?}",:align => :center, :size => 10       
    
    pdf.move_down 10
    
    pdf.text "<b>Product Wise Pending/Unexecuted Order</b>", :align => :center, :inline_format => true, :size => 12
    
    pdf.move_down 5
    
    pdf.text "#{@product.name} (Available stock : #{@product.stocks.sum(:quantity)})", :align => :center, :inline_format => true, :size =>10
    if !params[:branch_id].blank?   
     pdf.text "Branch: #{Branch.find(params[:branch_id]).name} ", :align => :center, :size => 6 
    end               
    pdf.move_down 5
    pdf.text "#{ (params[:start_date].blank?) ? @financial_year.start_date : params[:start_date]} To #{ (params[:end_date].blank?)? ((Time.zone.now.to_date > @financial_year.end_date)? @financial_year.end_date : Time.zone.now.to_date) : params[:end_date] }", :align => :center, :size => 6
  end
  
  pdf.move_down 10
  
  data = [['Date', "Sales Order", 'Customer', 'Quantity','Executed', 'Unexecuted']]
  i=0
  total_quantity = 0
  total_delivered_quantity = 0
  total_remaining_quantity = 0 
  prev_date = nil
  so_no = nil
   @sales_order_line_items.each do |line_item|
    so = line_item.sales_order
    data +=[[{:content => "#{(so.voucher_date == prev_date) ? " " : so.voucher_date}"},
    {:content => "#{(so.voucher_number == so_no) ? " " : so.voucher_number}"},
    {:content => "#{so.customer_name}"},
    {:content => "#{line_item.quantity}" },
    {:content => "#{line_item.delivered_quantity}" },
    {:content => "#{line_item.remaining_quantity}" }
    ]]
    prev_date = so.voucher_date
    so_no = so.voucher_number
    total_quantity += line_item.quantity
    total_delivered_quantity += line_item.delivered_quantity
    total_remaining_quantity += line_item.remaining_quantity 
    i += 1
  end
  data += [["","",{:content =>'Total', :font_style => :bold},{:content => "#{total_quantity}", :font_style => :bold},{:content => "#{total_delivered_quantity}", :font_style => :bold},{:content => "#{total_remaining_quantity}", :font_style => :bold}]]
    
   
  
  pdf.table(data, :header => true, :width => pdf.bounds.width,:row_colors => ["FFFFFF","F2F7FF"] , :cell_style => {:border_width => 0, :border_color => "70B8FF", :size => 9})do
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

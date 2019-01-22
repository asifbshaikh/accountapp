pdf = Prawn::Document.new(:page_layout => :portrait, :page => 'A4')
  pdf.bounding_box([0, pdf.cursor], :width => (pdf.bounds.width) ) do
    pdf.text "<b>#{@company.name }</b>", :align => :center, :inline_format => true, :size =>14
    pdf.text "#{@company.address.get_address unless @company.address.blank?}", :align => :center, :size => 10
  end
pdf.move_down 10
  y_position = pdf.cursor
  pdf.bounding_box([0, y_position], :width => (pdf.bounds.width / 2) - 5) do
    pdf.table([
         ["<b><u>Invoice Report</u></b>"],],
      :width => (pdf.bounds.width - 10), :cell_style =>{:border_width => 0,:align => :left, :inline_format => true, :size => 12})do
    end
  end
  pdf.text "As on #{ (params[:end_date].blank?)? (Time.zone.now.to_date) : params[:end_date] }", :align => :left, :size => 6

  pdf.move_down 10
  
  
  data = [['Invoice Number','Invoice Date', 'Customer Name', 'Quantity', 'Taxable Amount', 'CGST', 'SGST', 'IGST', 'Total']]
i = 0 
   @invoices.each do |invoice|
   data +=[[{:content => " #{invoice.invoice_number }"},
           {:content => "#{invoice.invoice_date}", :align => :center},   
          {:content => "#{invoice.get_party.name}", :align => :left},   
          {:content => "#{invoice.total_quantity}", :align => :center},
          {:content => "#{invoice.sub_total }", :align => :center},
          {:content => "#{invoice.calc_cgst_tax_amt}", :align => :center},
          {:content => "#{invoice.calc_sgst_tax_amt }", :align => :center},
          {:content => "#{invoice.calc_igst_tax_amt }", :align => :center},
           {:content => "#{invoice.total_amount }", :align => :center},

          ]]
   end
   i+1
  
  
    pdf.table(data, :header => true, :width => pdf.bounds.width,:row_colors => ["FFFFFF","F2F7FF"] , :cell_style => {:border_width => 0, :border_color => "70B8FF", :size => 9}, :column_widths => {2 =>125})do
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

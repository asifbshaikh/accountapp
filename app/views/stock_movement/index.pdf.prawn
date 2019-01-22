pdf = Prawn::Document.new(:page_layout => :portrait, :page => 'A4')
  pdf.bounding_box([0, pdf.cursor], :width => (pdf.bounds.width) ) do
    pdf.text "<b>#{@company.name }</b>", :align => :center, :inline_format => true, :size =>14
    pdf.text "#{@company.address.get_address unless @company.address.blank?}", :align => :center, :size => 10
  end
pdf.move_down 10
  y_position = pdf.cursor
  pdf.bounding_box([0, y_position], :width => (pdf.bounds.width / 2) - 5) do
    pdf.table([
         ["<b><u>Product Wise Stock</u></b>"],],
      :width => (pdf.bounds.width - 10), :cell_style =>{:border_width => 0,:align => :left, :inline_format => true, :size => 12})do
    end
  end
  pdf.text "As on #{ (params[:end_date].blank?)? (Time.zone.now.to_date) : params[:end_date] }", :align => :left, :size => 6

  pdf.move_down 10
  
  
  data = [['Sr. No.', 'Product', 'Unit of Measurement','Available quantity','Reorder Level']]
  i =0
   @products.each_with_index do |product, index|
   data +=[[{:content => "#{ index+1}"},
          {:content => " #{product.name}"},
          {:content => "#{product.unit_of_measure}", :align => :center},
          {:content => "#{product.stocks.sum(:quantity)}", :align => :center},
          {:content => "#{product.reorder_level}", :align => :center}
          ]]
   end
    i+1
  
    pdf.table(data, :header => true, :width => pdf.bounds.width,:row_colors => ["FFFFFF","F2F7FF"] , :cell_style => {:border_width => 0, :border_color => "70B8FF", :size => 9})do
    row(0).borders = [:top, :bottom]
    row(0).border_width = 0.1
    row(0).font_style = :bold
    row(i + 1).column(4..5).borders = [:top]
    row(i + 1).column(4..5).border_width = 0.1
    row(i + 3).column(4..5).borders = [:bottom]
    row(i + 4).column(4..5).border_width = 0.1
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

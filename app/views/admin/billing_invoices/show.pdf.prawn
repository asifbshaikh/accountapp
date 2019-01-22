pdf = Prawn::Document.new(:page_layout => :portrait, :page_size => "A4")
y_position = pdf.cursor
pdf.bounding_box([0, y_position], :width => (pdf.bounds.width/2) - 5) do 
  pdf.image"#{Rails.root}/app/assets/images/logo.png", :width => 120
end
pdf.bounding_box([350, y_position], :width => (pdf.bounds.width/2)-5) do
  pdf.table([
     [ "<b>Profitbooks.net</b>"],
      ["21, Kumar Place, Above Manali Jewellers, 2408, East Street, Camp, Pune- 411001"],
     ["+91 84 85 86 3000"],
    ],
    :width => (pdf.bounds.width/3*2), :cell_style =>{:border_width => 0,:align => :right, :inline_format => true, :size => 12})do
  end 
end

pdf.move_down 20
pdf.text "<b>Billing Invoice</b>", :align => :center, :inline_format => true, :size => 14
pdf.stroke_horizontal_rule 

pdf.move_down 10
y_position = pdf.cursor

pdf.bounding_box([0, y_position], :width => (pdf.bounds.width/2) - 5) do
  pdf.table([
          [{:content =>"Bill to:", :font_style => :bold, :align => :left}],
          ["<b>#{@user.full_name unless @user.blank?}</b>"],
          ["#{@user.email unless @user.nil?}"],
          [" #{@company.phone unless @company.phone.nil?}"],
          [" #{@company.pan unless @company.pan.nil?}"],
          [" #{@company.address.get_address unless @company.address.blank?}"],
           ],
     :cell_style =>{:align => :left,:inline_format => true,:border_width =>0, :size => 9, :border_color => "70B8FF" })do
         row(0).borders = [:left, :right, :bottom, :top]
         row(0).background_color = 'F2F7FF'
         row(1..4).borders = [:left, :right]
         row(5).borders = [:left, :right, :bottom]
   row(0..5).border_width = 0.1
    end
  end

  pdf.bounding_box([340, y_position], :width => (pdf.bounds.width) - 10) do
   
    data = [[{:content =>"Invoice #:", :font_style => :bold, :align => :left}, {:content =>"#{@billing_invoice.invoice_number}"}]]
    data = [[{:content =>"GSTIN:", :font_style => :bold, :align => :left}, {:content =>"#{@company.GSTIN}"}]]
    data += [[{:content =>"Payment date:", :font_style => :bold, :align => :left}, {:content =>"#{@billing_invoice.invoice_date.strftime("%d-%m-%Y")}"}]]
    data += [[{:content =>"Amount :", :font_style => :bold, :align => :left}, {:content =>"#{@company.currency_code.html_safe} "+"#{@billing_invoice.amount.to_s}"}]]
    
    if !@billing_invoice.payment_detail.blank?
    data += [[{:content =>"Payment mode :", :font_style => :bold, :align => :left}, {:content =>"#{@billing_invoice.payment_detail.payment_mode}"}]]
    end

    data += [[{:content =>"Created by:", :font_style => :bold, :align => :left}, {:content =>"#{@billing_invoice.received_by.blank? ? User.find(@billing_invoice.created_by).full_name : @billing_invoice.received_by }"}]]
    pdf.table(data, :row_colors => ["F2F7FF"], :cell_style =>{:align => :left, :border_width => 0, :size => 9})do
    end
  end

pdf.move_down 70
n = @billing_invoice.billing_line_items.count 

data = [["Item","Description",{:content => "Amount", :align => :right}]]

@billing_invoice.billing_line_items.each do |line_item|
  if line_item.billing_type != 'coupon'
    data += [["#{line_item.line_item} (Valid till #{ @billing_invoice.invoice_date.to_date + line_item.validity.to_i.months})","",{:content => "#{@company.currency_code} #{line_item.amount.to_s}", :align => :right}]]
  elsif line_item.billing_type == 'coupon' && line_item.amount =0
  data += [[{:content => "#{line_item.line_item}(1 month extended validity)"}, "",""]]
  else
    data += [["Coupon code:#{line_item.line_item}","",{:content => "#{@company.currency_code} #{line_item.amount.to_s}", :align => :right}]]
  end
end


data += [["",{:content => "Total", :font_style => :bold, :align => :right},{:content => " #{@company.currency_code} #{ @billing_invoice.amount.to_s}", :font_style => :bold, :align => :right}]]

pdf.table(data, :header => true,  :width => (pdf.bounds.width-10),:row_colors => ["FFFFFF","F2F7FF"] , 
                   :cell_style =>{:border_width => 0,:border_color => "70B8FF",  :size => 9}) do
    row(0).font_style = :bold
                row(0).borders = [:top, :bottom]
                row(0).border_width = 0.1
    row(n).borders = [:bottom]
                row(n).border_width = 0.1
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
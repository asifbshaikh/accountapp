require 'open-uri'
pdf = Prawn::Document.new(:page_layout => :portrait, :page_size => "A4")
  
  y_position = pdf.cursor
  pdf.bounding_box([0, 790], :width => (pdf.bounds.width/2) - 5) do 
   unless @company.logo_file_name.blank? 
     pdf.image open("#{@company.logo.url}"), :fit=> 
      Prawn::Document::PageGeometry::SIZES["A8"]
    end
  end
  pdf.bounding_box([340, 790], :width => (pdf.bounds.width/2)) do
  pdf.table([
	     [ "<b>#{@company.name}</b>"],
	     [ "#{@company.address.get_address unless @company.address.blank?}"],
	     ["#{@company.phone unless @company.phone.blank?}"],
	    ],
	    :width => (pdf.bounds.width/3*2), :cell_style =>{:border_width => 0,:align => :right, :inline_format => true, :size => 9})do
	  end	
  end
  
  pdf.move_down 20
  pdf.text "<b>Income Voucher</b>", :align => :center, :inline_format => true, :size => 14
  pdf.stroke_horizontal_rule	
	
  pdf.move_down 10
  y_position = pdf.cursor
  pdf.bounding_box([0, y_position], :width => (pdf.bounds.width/2) - 100) do
  pdf.table([
	  [{:content =>"Paid to:", :font_style => :bold, :align => :left}],
          ["<b>#{@income_voucher.from_account_name unless @income_voucher.from_account_id.blank?}</b>"],
          [{:content => "This sentense will not visible to you i know", :inline_format=> true, :align => :left, :text_color => 'FFFFFF'}],
          ],
	   :cell_style =>{:align => :left,:inline_format => true,:border_width =>0, :size => 9, :border_color => "70B8FF" })do
         row(0).borders = [:left, :right, :bottom, :top]
         row(0).background_color = 'F2F7FF'
         row(1).borders = [:left, :right, :bottom]
	       row(0..1).border_width = 0.1
    end
  end


  pdf.bounding_box([360, y_position], :width => (pdf.bounds.width / 2) - 10) do
    data = [[{:content =>"Voucher #:", :font_style => :bold, :align => :left}, {:content =>"#{@income_voucher.voucher_number}"}]]
    data += [[{:content =>"Income date:", :font_style => :bold, :align => :left}, {:content =>"#{@income_voucher.income_date.strftime("%d-%m-%Y")}"}]]
    data += [[{:content =>"Amount", :font_style => :bold, :align => :left}, {:content =>"#{@currency +" "+ @income_voucher.amount.to_s}"}]]
    pdf.table(data, :row_colors => ["F2F7FF"], :cell_style =>{:align => :left, :border_width => 0, :size => 9})do
    end
  end


  pdf.move_down 70
     data = [["Payment Method", "Received on" ,{:content => "Amount", :align => :right}]]
	  
    data += [["#{@income_voucher.payment_detail.payment_mode}","#{@income_voucher.income_date}", {:content => "#{@currency +" "+ @income_voucher.amount.to_s}", :align => :right}]]
    
   
   data += [["",{:content => "Total", :font_style => :bold, :align => :right},{:content => " #{@currency +" "+ @income_voucher.amount.to_s}", :font_style => :bold, :align => :right}]]
 	
  pdf.table(data, :header => true,  :width => (pdf.bounds.width-10),:row_colors => ["FFFFFF","F2F7FF"] , 
                   :cell_style =>{:border_width => 0,:border_color => "70B8FF",  :size => 9}) do
		row(0).font_style = :bold
                row(0).borders = [:top, :bottom]
                row(0).border_width = 0.1
		            row(1).borders = [:bottom]
                row(1).border_width = 0.1
end                


pdf.move_down 40 
   if @income_voucher.payment_detail.type == 'Chequeincome'
       pdf.text "Chaque details:"
      
       pdf.move_down 10
       data = [["Cheque number","Cheque Date","Bank name","Branch" ]]
       data +=[["#{@income_voucher.payment_detail.account_number}","#{@income_voucher.payment_detail.income_date}","#{@income_voucher.payment_detail.bank_name}","#{@income_voucher.payment_detail.branch}"]]
       pdf.table(data, :header => true, :width => (pdf.bounds.width),:row_colors => ["FFFFFF","F2F7FF"] , 
                         :cell_style =>{:border_width => 0,:border_color => "70B8FF",  :size => 9}) do
        row(0).font_style = :bold
        row(0).borders = [:top, :bottom]
        row(0).border_width = 0.1
        row(1).borders = [:bottom]
        row(1).border_width = 0.1 
    end
  elsif @income_voucher.payment_detail.type == 'Cardincome'    
       pdf.text "Card details:"
      
       pdf.move_down 10
       data = [["Card number","Transaction Date","Transaction reference" ]]
       data +=[["#{@income_voucher.payment_detail.account_number}","#{@income_voucher.payment_detail.income_date}","#{@income_voucher.payment_detail.transaction_reference}"]]
       pdf.table(data, :header => true, :width => (pdf.bounds.width),:row_colors => ["FFFFFF","F2F7FF"] , 
                         :cell_style =>{:border_width => 0,:border_color => "70B8FF",  :size => 9}) do
        row(0).font_style = :bold
        row(0).borders = [:top, :bottom]
        row(0).border_width = 0.1
        row(1).borders = [:bottom]
        row(1).border_width = 0.1 
    end
  
  elsif @income_voucher.payment_detail.type == 'InternetBankingincome'    
       pdf.text "Internet Banking details:"
      
       pdf.move_down 10
       data = [["Transaction Date","Bank name","Transaction reference" ]]
       data +=[["#{@income_voucher.payment_detail.income_date}","#{@income_voucher.payment_detail.bank_name}","#{@income_voucher.payment_detail.transaction_reference}"]]
       pdf.table(data, :header => true, :width => (pdf.bounds.width),:row_colors => ["FFFFFF","F2F7FF"] , 
                         :cell_style =>{:border_width => 0,:border_color => "70B8FF",  :size => 9}) do
  row(0).font_style = :bold
        row(0).borders = [:top, :bottom]
        row(0).border_width = 0.1
        row(1).borders = [:bottom]
        row(1).border_width = 0.1 
    end
  
  end 

pdf.move_down 10
y_position = pdf.cursor

  if !@income_voucher.description.blank?
       pdf.bounding_box([0, y_position], :width => (pdf.bounds.width/2)) do
        pdf.table([["<b>Description</b>"],
		   [" #{@income_voucher.description}"]],
	 :cell_style =>{:border_width => 0, :inline_format=> true, :size => 9})do
	end
       end
 end
pdf.draw_text "-------------------", :at =>[pdf.bounds.width-70, 40]
pdf.draw_text "Receiver's Signature",:size => 8,:at=>[pdf.bounds.width-70, 32]


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
	
	
	

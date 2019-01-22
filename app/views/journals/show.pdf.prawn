require 'open-uri'

pdf = Prawn::Document.new(:page_layout => :portrait, :page_size => 'A4')
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
  pdf.text "<b>JOURNAL ENTRY</b>", :align => :center, :inline_format => true, :size => 14
  pdf.stroke_horizontal_rule

  pdf.move_down 10
  y_position = pdf.cursor
  pdf.bounding_box([0, y_position], :width => (pdf.bounds.width/2) - 5) do
  pdf.table([
	  [{:content =>"To account:", :font_style => :bold, :align => :left}],
          ["<b>#{ @journal.old_voucher? ? @journal.account.name : "Multiple accounts" }</b>"],
          [""],],
	   :cell_style =>{:align => :left,:inline_format => true,:border_width =>0, :size => 9, :border_color => "70B8FF" })do
         row(0).borders = [:left, :right, :bottom, :top]
         row(0).background_color = 'F2F7FF'
         row(1).borders = [:left, :right]
         row(2).borders = [:left, :right, :bottom]
	 row(0..2).border_width = 0.1
    end
  end
 pdf.bounding_box([370, y_position], :width => (pdf.bounds.width / 2) - 10) do
    data = [[{:content =>"Voucher #:", :font_style => :bold, :align => :left}, {:content =>"#{@journal.voucher_number}"}]]
    data += [[{:content =>"Voucher date:", :font_style => :bold, :align => :left}, {:content =>"#{@journal.date.strftime("%d-%m-%Y")}"}]]
    data += [[{:content =>"Amount", :font_style => :bold, :align => :left}, {:content =>"#{@company.currency_code} #{format_amount(@journal.amount)}"}]]
    data += [[{:content =>"Project", :font_style => :bold, :align => :left}, {:content =>" #{@journal.project.name}"}]] unless @journal.project.blank?
    pdf.table(data, :row_colors => ["F2F7FF"], :cell_style =>{:align => :left, :border_width => 0, :size => 9})do
    end
  end

pdf.move_down 35
	n = @journal_line_items.count
     if @journal.old_voucher? 
     data = [["From Account","","","",{:content => "Amount",:align => :right}]]
     else
     data = [["From Account","","",{:content => "Debit",:align => :right},{:content => "Credit",:align => :right}]]
     end
	  for i in @journal_line_items
      if @journal.old_voucher?
       data += [["#{Account.find(i.from_account_id).name}","","","",{:content => "#{format_amount(i.amount)}", :align => :right}]]
      else
       data += [["#{Account.find(i.from_account_id).name}","","",{:content => "#{format_amount(i.amount)}", :align => :right},{:content => "#{format_amount(i.credit_amount)}", :align => :right}]]
      end
    end	
    if @journal.old_voucher?
     data += [["","","",{:content => "Total", :font_style => :bold, :align => :right},{:content => "#{format_amount(@journal.amount)}", :font_style => :bold, :align => :right}]]
   	else
    data += [["","",{:content => "Total", :font_style => :bold, :align => :right},{:content => "#{format_amount(@journal.amount)}", :font_style => :bold, :align => :right},{:content => "#{format_amount(@journal.credit_amount)}", :font_style => :bold, :align => :right}]]
    end
  
  pdf.table(data, :header => true,  :width => (pdf.bounds.width),:row_colors => ["FFFFFF","F2F7FF"] , 
                   :cell_style =>{:border_width => 0,:border_color => "70B8FF",  :size => 9}) do
		row(0).font_style = :bold
                row(0).borders = [:top, :bottom]
                row(0).border_width = 0.1
		row(n).borders = [:bottom]
                row(n).border_width = 0.1
end           
	
	
	
	pdf.move_down 10
	y_position = pdf.cursor
  if !@journal.description.blank?
	pdf.bounding_box([0, y_position], :width => (pdf.bounds.width / 2) ) do
		pdf.table([["<b>Description</b>"],
					[" #{@journal.description}"]],
					 :cell_style =>{:border_width => 0,:inline_format=> true, :size => 9})do
		end
	end
  end
  	
   if !@journal.tags.blank?	
	pdf.bounding_box([300 , y_position], :width => (pdf.bounds.width / 2)) do
		pdf.table([
					[ "<b> Tags </b>"],
					[" #{@journal.tags}"]],
					:width => pdf.bounds.width, :cell_style =>{:border_width => 0,:inline_format=> true, :size => 9})do
		end
	end
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
	
	
	
	
	

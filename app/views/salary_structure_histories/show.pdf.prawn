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
	    ],
	    :width => (pdf.bounds.width/3*2), :cell_style =>{:border_width => 0,:align => :right, :inline_format => true, :size => 9})do
	  end	
  end
 pdf.move_down 20
  pdf.text "<b>Salary Structure History</b>", :align => :center, :inline_format => true, :size => 14
  pdf.stroke_horizontal_rule

pdf.move_down 10
  y_position = pdf.cursor
  pdf.bounding_box([0, y_position], :width => (pdf.bounds.width/2) - 100) do
  pdf.table([
	  [{:content =>"Employee Name:", :font_style => :bold, :align => :left}],
          ["<b>#{@salary_structure_history.for_employee_name}</b>"],
          [""],
          [{:content => "This sentense will not visible to you i know", :inline_format=> true, :align => :left, :text_color => 'FFFFFF'}],
          ],
	   :cell_style =>{:align => :left,:inline_format => true,:border_width =>0, :size => 9, :border_color => "70B8FF" })do
         row(0).borders = [:left, :right, :bottom, :top]
         row(0).background_color = 'F2F7FF'
         row(1).borders = [:left, :right]
         row(2).borders = [:left, :right, :bottom]
	 row(0..2).border_width = 0.1
    end
  end
 
  
  pdf.bounding_box([370, y_position], :width => (pdf.bounds.width / 2) - 10) do
    data = [[{:content =>"Effective From Date:", :font_style => :bold, :align => :left}, {:content =>"#{@salary_structure_history.effective_from_date}"}]]
    data += [[{:content =>"Total", :font_style => :bold, :align => :left}, {:content =>"#{@salary_structure_history.total_amount}"}]]
    data += [[{:content =>"Created On", :font_style => :bold, :align => :left}, {:content =>"#{@salary_structure_history.created_at.to_date}"}]]
    data += [[{:content =>"Updated On", :font_style => :bold, :align => :left}, {:content =>"#{@salary_structure_history.updated_at.to_date}"}]]
    pdf.table(data, :row_colors => ["F2F7FF"], :cell_style =>{:align => :left, :border_width => 0, :size => 9})do
    end
  end

 

pdf.move_down 70
	n = @salary_structure_history_line_items.count 
     data = [["Payhead","Payhead Type",{:content => "Amount",:align => :right}]]
	for i in @salary_structure_history_line_items
    data += [["#{Payhead.find(i.payhead_id).payhead_name}","#{Payhead.find(i.payhead_id).payhead_type}",{:content => "#{@currency+" "+i.amount.to_s}", :align => :right}]]
    end	
   data += [["",{:content => "Total", :font_style => :bold, :align => :right},{:content => "#{@currency +" "+ @salary_structure_history.total_amount.to_s}", :font_style => :bold, :align => :right}]]
 	
  pdf.table(data, :header => true,  :width => (pdf.bounds.width),:row_colors => ["FFFFFF","F2F7FF"] , :cell_style =>{:border_width => 0,:border_color => "70B8FF",  :size => 8}, :column_widths => {0 => 150, 1 => 300 }) do
		row(0).font_style = :bold
                row(0).borders = [:top, :bottom]
                row(0).border_width = 0.1
		row(n).borders = [:bottom]
                row(n).border_width = 0.1
end                	
	
pdf.draw_text "-------------------", :at =>[0, 40]
pdf.draw_text "Authorised Signatory",:size => 8,:at=>[0, 32]
  
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
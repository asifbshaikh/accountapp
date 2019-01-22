pdf = Prawn::Document.new(:page_layout => :portrait, :page_size => 'A4')

pdf.bounding_box([0,pdf.cursor], :width => pdf.bounds.width, :height =>80) do
	pdf.text "<b>#{@company.name }</b>", :align => :center, :inline_format => true, :size =>14
	pdf.text "<u>Gratuity Summary</u>", :align => :center, :inline_format => true, :size => 12
	pdf.text "For all Employee", :align => :center, :size => 10
	pdf.text "As on 31-Mar-2011", :align => :center, :size => 10
end

data = [[{:content => 'P a r t i c u l a r'},"Date of Joining","Date of Leaving","Gratuity Eligible Salary","Gratuity Amount"]]
i = 0
j = 0
for dept in @departments 
	@user_dept = User.find_all_by_department_id(dept.id) 
	if @user_dept.count > 0
		data += [[{:content => dept.name, :font_style => :bold},"","","",""]]
    	for user_dept in @user_dept
    		data += [[{:content => ".   #{user_dept.first_name } #{user_dept.last_name}"},"#{UserSalaryDetail.find_by_user_id(user_dept.id).date_of_joining unless UserSalaryDetail.find_by_user_id(user_dept.id).nil?}","","",""]]
			j += 1		
		end    		
	end
	i += 1
end
data += [["","","",{:content => 'Net Amount',:font_style => :bold, :align => :center},{:content => '12345', :font_style => :bold}]]
pdf.table(data, :header => true, :width => pdf.bounds.width,:row_colors => ["FFFFFF","F2F7FF"] , :cell_style => {:border_width => 0, :border_color => "70B8FF", :size => 9}, :column_widths =>{0 => 200})do
	row(0).borders = [:top, :bottom]
	row(0).border_width = 0.1
	row(0).font_style = :bold
	
	row(1 + i + j).column(3..4).borders = [:top, :bottom]
	row(1 + i + j).column(3..4).border_width = 0.1
end

pagecount = pdf.page_count
	pdf.page_count.times do |i|
		pdf.go_to_page(i + 1)
		pdf.fill_color "ADADAD"
		pdf.draw_text "Generated from www.profitbooks.net", :at=>[0,-10], :size => 7
		pdf.fill_color "000000"
		pdf.draw_text "Page : #{i+1} / #{pdf.page_count}", :at=>[pdf.bounds.width - 50,-10], :size => 9
	end

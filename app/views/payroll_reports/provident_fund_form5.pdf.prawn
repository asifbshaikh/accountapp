pdf = Prawn::Document.new(:page_layout => :landscape, :page_size => 'A4')
	pdf.bounding_box([0,pdf.cursor], :width => pdf.bounds.width, :height =>100) do
		pdf.text "<b>FORM 5</b>", :align => :center, :inline_format => true, :size =>20
		pdf.text "THE EMPLOYEES'PROVIDENT FUND SCHEME, 1952\n[Paragraph 36(2)(a) & THE EMPLOYEES PENSION SCHEME,1995 Paragraph 20(2)]", :align => :center, :inline_format => true, :size => 14
	end	
	
	pdf.text "Returns of Employees'qualifying for membership of the employees'Pension Fund and Employees'Deposite linked insurance fund for the first time during the month of April 2010(To be sent to the Commitionar with form2 (EPF)&(EPS))",
	 :indent_paragraphs => 15, :size => 13
 	
 	pdf.table([["Name and address of Factory/Establishment",": #{@company.name }\n at post khalkhoni tq bhatkuli dist amravati mh"],
 				["Code no. of the Factory/Establishment",": #{@company.id}"]], :width => (pdf.bounds.width / 2), :cell_style => {:border_width => 0})
	
	data = [[{:content => 'Sl.No.', :font_style => :bold},
			{:content => "Account No.", :font_style => :bold},
			{:content => "Name of Employee(in block latters)", :font_style => :bold},
			{:content => "Fathers name or Husbands name(in case of married women)", :font_style => :bold},
			{:content => "Date of Birth", :font_style => :bold},
			{:content => "sex", :font_style => :bold},
			{:content => "Date of joining the Fund", :font_style => :bold},
			{:content => "Total period of previous service as on the date of joining the fund(Enclose Scheme Certificate if applicable", :font_style => :bold},
			{:content => "Remark", :font_style => :bold}],
			
			[{:content => '1', :font_style => :bold},
			{:content => '2', :font_style => :bold},
			{:content => '3', :font_style => :bold},
			{:content => '4', :font_style => :bold},
			{:content => '5', :font_style => :bold },
			{:content => '6', :font_style => :bold},
			{:content => '7', :font_style => :bold},
			{:content => '8', :font_style => :bold},
			{:content => '9', :font_style => :bold}]]
			
	data += [["99","12345678909876","Manjeet S. Bhatkar","Subhash G. Bhatkar","29-jan-1987","Male","19-Oct-2011","",""]]
	
	pdf.table(data, :header => true, :width => pdf.bounds.width, :row_colors => ['FFFFFF', 'F2F7FF'], :cell_style => {:border_width => 0, :border_color =>"70B8FF"}, :column_widths => {0 => 30, 1 => 120, 2 => 120, 3 => 120, 4 => 80, 5 => 50, 6 => 80, 7 => 100}) do
		row(0..1).borders = [:top, :bottom]
		row(0..1).border_width = 1
	end
	pdf.move_down 30
	pdf.text "Date : #{Time.zone.now.to_date}"
	pdf.move_down 20
	pdf.text "Signatur of employer or other authorised \nofficer of the Factory/Establishment and stamp of \nthe Factory/Establishment", :align => :right
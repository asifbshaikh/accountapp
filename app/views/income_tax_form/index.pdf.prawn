pdf = Prawn::Document.new(:page_layout => :portrait, :page_size => 'A4')
  	pdf.bounding_box([0, pdf.cursor], :width =>pdf.bounds.width, :height => 80) do
		pdf.text "<b>FORM NO. 16</b>", :align => :center, :inline_format => true, :size =>14
		pdf.text "[See rule 31(I)(a)]", :align => :center, :inline_format => true, :size => 12
	end
	
	pdf.table([[{:content => 'PART A', :align => :center, :size => 12}]], :width => pdf.bounds.width, :cell_style => {:background_color => "F2F7FF"}) do
			row(0).border_width = 0
	end
	pdf.move_down 10
	pdf.text "Certificate under Section 203 of the Income-Tax Act, 1961 for Tax Deduction at Source on Salary", :size => 10
	pdf.move_down 10
	y_position = pdf.cursor
	pdf.bounding_box([0, y_position], :width => (pdf.bounds.width / 2) - 10) do
		pdf.table([["Name And Address of Employee"],
					[{:content => @company.name , :font_style => :bold}],
					["22 United apartment 2407, East street,camp, Pune(MH).pin:411001"]],
					:row_colors => ["FFFFFF","F2F7FF"], :cell_style =>{:border_width => 0, :border_color => "70B8FF", :size => 9})do
			row(0).borders = [:top, :bottom]
			row(0).border_width = 0.1
			row(0).font_style = :bold
			row(2).style :padding_left => 15
		end
	end
	
	pdf.bounding_box([(pdf.bounds.width / 2) + 10, y_position], :width => (pdf.bounds.width / 2) - 10) do
		pdf.table([["Name And Designation of Employee"],
					[{:content => @user.first_name  + ' ' + @user.last_name, :font_style => :bold}],
					["#{(@designation.nil?)? '' : @designation.title }"]],
					:width => pdf.bounds.width, :row_colors => ["FFFFFF","F2F7FF"], :cell_style =>{:border_width => 0, :border_color => "70B8FF", :size => 9})do
			row(0).borders = [:top, :bottom]
			row(0).border_width = 0.1
			row(0).font_style = :bold
			row(2).style :padding_left => 15
		end
	end
	
	y_position = pdf.cursor - 20
	pdf.bounding_box([0, y_position], :width => (pdf.bounds.width / 2) - 10) do
		pdf.table([["PAN of Deducter","TAN of Deducter"],
					["#{@company.pan unless @company.nil?}","#{@company.tin unless @company.nil?}"]],
					:width => pdf.bounds.width, :row_colors => ["FFFFFF","F2F7FF"], :cell_style =>{:border_width => 0, :border_color => "70B8FF", :size => 9})do
			row(0).borders = [:top, :bottom]
			row(0).border_width = 0.1
			row(0).font_style = :bold
		end
	end
	
	pdf.bounding_box([(pdf.bounds.width / 2) + 10, y_position], :width => (pdf.bounds.width / 2) - 10) do
		pdf.table([["PAN of Employee"],
					["#{@user_salary_details.PAN unless @user_salary_details.nil?}"]],
					:width => pdf.bounds.width, :row_colors => ["FFFFFF","F2F7FF"], :cell_style =>{:border_width => 0, :border_color => "70B8FF", :size => 9})do
			row(0).borders = [:top, :bottom]
			row(0).border_width = 0.1
			row(0).font_style = :bold
		end
	end
	
	y_position = pdf.cursor - 20
	pdf.bounding_box([0, y_position], :width => (pdf.bounds.width / 2) - 10) do
		pdf.table([["CIT(TDS)",""],
					[{:content => "Address", :font_style => :bold},"22 United apartment 2407, East street,camp, Pune(MH).pin:411001"],
					[{:content => "City", :font_style => :bold},"Pune"],
					[{:content => "Pincode", :font_style => :bold},"444602"]],
					:width => pdf.bounds.width, :row_colors => ["FFFFFF","F2F7FF"], :cell_style =>{:border_width => 0, :border_color => "70B8FF", :size => 9}, :column_widths => {0 => 70})do
			row(0).borders = [:top, :bottom]
			row(0).border_width = 0.1
			row(0).font_style = :bold
		end
	end
	
	pdf.bounding_box([(pdf.bounds.width / 2) + 10, y_position], :width => (pdf.bounds.width / 2) - 10) do
		pdf.table([["Assessment Year","Periods"],
					["2011-2012","From : 1-Apr-2010 To : 31-Mar-2011"]],
					:width => pdf.bounds.width, :row_colors => ["FFFFFF","F2F7FF"], :cell_style =>{:border_width => 0, :border_color => "70B8FF", :size => 9})do
			row(0).borders = [:top, :bottom]
			row(0).border_width = 0.1
			row(0).font_style = :bold
		end
	end
	
	pdf.start_new_page
	pdf.text "Summary of Tax deducted at Source", :size => 14, :font_style => :bold
	data = [["Qwarter", "Receipt no on original statment of TDS under section(3) of Section 200", "Amount of TAX deduction in respect of the Employee", "Amount of TAX Deposited/Remitted in respect of the Employee"],
	["Qwarter1", "", "", ""],
	["Qwarter2", "", "", ""],
	["Qwarter3", "", "", ""],
	["Qwarter4", "", "", ""],
	[{:content => 'Total', :font_style => :bold}, "", "", ""],]
	
	pdf.table(data,
					:width => pdf.bounds.width, :row_colors => ["FFFFFF","F2F7FF"], :cell_style =>{:border_width => 0, :border_color => "70B8FF", :size => 9}, :column_widths => {0 => 70, 1 => 300})do
			row(0).borders = [:top, :bottom]
			row(0).border_width = 0.1
			row(0).font_style = :bold
		end
	
		pdf.move_down 10	
	pdf.table([[{:content => 'PART B(Refer Note 1)', :align => :center, :size => 12}]], :width => pdf.bounds.width, :cell_style => {:background_color => "F2F7FF"}) do
			row(0).border_width = 0
	end
	pdf.move_down 10
	pdf.text "Details of salary paid and any other income and tax deducted", :size => 10, :font_style => :bold
	pdf.move_down 10
	
	data = [["Sl.No.", "P a r t i c u l a r s", "Amount", "Amount", "Amount"],
			[{:content => "1.", :font_style => :bold}, {:content => "Gross Salary", :font_style => :bold}, "", "", ""],
			["", ".  Salary as per provisions contained in sec 17(1) ", "281820 ", "", ""],
			["", ".  Value of perquisites u/s 17(2) (as per Form No. 12BA wherever applicable) ", "", "", ""],
			["", ".  Profit in liue of salary under section 17(3) (as per Form No. 12BA wherever applicable)", "", "", ""],
			["", {:content => "Total", :font_style => :bold}, "", "281820 ", ""],
			[{:content => "2.", :font_style => :bold}, {:content => "	Less: Allowance to the Extent u/s 10", :font_style => :bold}, "", "281820 ", ""],
			["", ".  Conveyance Allownce ", "8800", "", ""],
			["", {:content => "Total", :font_style => :bold}, "", "8800 ", ""],
			[{:content => "3.", :font_style => :bold}, {:content => "Balance(1-2)", :font_style => :bold}, "", " ", "273020"],
			[{:content => "4.", :font_style => :bold}, {:content => "Deductions", :font_style => :bold}, "", " ", ""],
			["", ".  Profesional Tax(Tax on Employment)", "2200", "", ""],
			[{:content => "5.", :font_style => :bold}, {:content => "Aggregate of Deductions", :font_style => :bold}, "", "2200", ""],
			[{:content => "6.", :font_style => :bold}, {:content => "Income chargable under the head 'salaries'(3-5)", :font_style => :bold}, "", "", "270820"],
			[{:content => "7.", :font_style => :bold}, {:content => "Add: any other income reported by the employee", :font_style => :bold}, "", "", ""],
			["", ".  Income Frome House Property ", "", "", ""],
			["", ".  Income Frome Other Sources  ", "", "", ""],
			[{:content => "8.", :font_style => :bold}, {:content => "Gross total Income(6+7)", :font_style => :bold}, "", "", "270820"],
			[{:content => "9.", :font_style => :bold}, {:content => "Deductions under Chapter VIA", :font_style => :bold}, "", "", ""],
			["", {:content => "(A) Section 80C, 80CCC and 80CCD", :font_style => :bold}, "", "", ""],
			["", ".  Employee Provident Fund(EPF)", "38360", "", ""],
			["", ".  Provident Fund(PF) ", "38360", "", ""],
			["", {:content => "Total", :font_style => :bold}, "", "76720", ""],
			["", "1.  Aggregate amount deducted under section 80C shall not exceed one lakh rupees.", "38360", "", ""],
			["", "2.  Aggregate amount deducted under the three section, ie.80C, 80CCC and 80CCD shall not exceed one lakh rupees. ", "", "", ""]]
			
	pdf.table(data, :header => true, :width => pdf.bounds.width, :row_colors => ["FFFFFF","F2F7FF"], :cell_style =>{:border_width => 0, :border_color => "70B8FF", :size => 9}, :column_widths => {0 => 50, 2 => 80, 3 => 80, 4 => 80})do
			row(0).borders = [:top, :bottom]
			row(0).border_width = 0.1
			row(0).font_style = :bold
	end
	
	pagecount = pdf.page_count
	Prawn::Document.generate("footer.pdf", :skip_page_creation => true) do
		pdf.page_count.times do |i|
			pdf.go_to_page(i+1)
			pdf.fill_color "ADADAD"
			pdf.draw_text "Generated from www.profitbooks.net", :at=>[0,-10], :size => 7
			pdf.fill_color "000000"
			pdf.draw_text "Page : #{i+1} / #{pdf.page_count}", :at=>[pdf.bounds.width - 50,-10], :size => 9
		end
	end

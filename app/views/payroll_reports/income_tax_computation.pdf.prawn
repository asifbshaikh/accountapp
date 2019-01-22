Prawn::Document.generate('income_tax_computation.pdf', :page_layout => :portrait, :page_size => 'A4') do |pdf|

	pdf.bounding_box([0, pdf.cursor], :width =>pdf.bounds.width, :height => 80) do
		pdf.text "<b>#{@company.name }</b>", :align => :center, :inline_format => true, :size =>14
		pdf.text "<u>Income Tax Computation</u>", :align => :center, :inline_format => true, :size => 12
	end
	pdf.table([[{:content => 'Income Tax Computation For :' + @user.first_name  + ' ' + @user.last_name, :align => :left, :size => 10}, {:content => 'Financial Year : 1-Apr2010 to 31-Mar-2010', :align => :right, :size => 10}]], :width => pdf.bounds.width, :cell_style => {:background_color => "B8DBFF"}) do
			row(0).border_width = 0
	end
	pdf.move_down 10
	y_position = pdf.cursor
	pdf.bounding_box([0, y_position], :width => ((pdf.bounds.width * 2) / 3) - 5) do
		pdf.table([[{:content => "Employee Details", :size => 10},"","",""],
					["Employee No.", ": #{@user.id}","PAN No.",": #{@user_salary_detail.PAN}"],
					["Gender",": #{@user_information.gender}", "Computed Based On", ": Proof Value"],
					["Date of Joining",": #{@user_salary_detail.date_of_joining}", "Computed for the Month", ": April-2011"],
					["Date of Birth",": #{@user_information.birth_date}", "Assessment Year", ": 2011-2012"]],
					:width => pdf.bounds.width, :row_colors => ["FFFFFF","F2F7FF"], :cell_style =>{:size => 9, :border_width => 0, :border_color => "70B8FF"}, :column_widths => {0 => 80, 2 => 70})do
			row(0).borders = [:top, :bottom]
			row(0).border_width = 0.1
			row(0).font_style = :bold
		end
	end
	
	pdf.bounding_box([((pdf.bounds.width * 2) / 3) + 5, y_position], :width => (pdf.bounds.width  / 3) - 5) do
		pdf.table([["Income Tax Details",""],
					["Total Income Tax", ": 31694"],
					["Less: Deduction till Feb-2011",": 28661#{}"],
					["Balance Deductible",": 3033#{}"],
					["Tax per Month from Mar-2011",": 3033#{}"]],
					:width => pdf.bounds.width, :row_colors => ["FFFFFF","F2F7FF"], :cell_style =>{:size => 9, :border_width => 0, :border_color => "70B8FF"})do
			row(0).borders = [:top, :bottom]
			row(0).border_width = 0.1
			row(0).font_style = :bold
		end
	end
	
	pdf.move_down 10
	data = [["Sl.No.", "P a r t i c u l a r s", "Amount", "Amount"],
		[{:content => '1.', :font_style => :bold},{:content => 'Gross Salary', :font_style => :bold},"",{:content => "554232", :font_style => :bold}],
		["",".  Salary as per previous contained in Sec 17(1)","54232",""],
		["", ".  Value of Perquisites u/s 17(2)(as per Form 12BA)","",""],
		["",".  Profits in lieu of salary u/s 17(3)(as per Form 12BA)", "", ""],
		[{:content => '2.', :font_style => :bold},{:content => 'Less: Allowance to the extent exempted U/s 10', :font_style => :bold},"", {:content => '8000', :font_style => :bold}],
		["", ".  Conveyance Allowance", "8000",""],
		[{:content => '3.', :font_style => :bold},{:content => 'Ballance(1-2)', :font_style => :bold},"",{:content => '546232', :font_style => :bold}],
		[{:content => '4.', :font_style => :bold},{:content => 'Deduction U/s 16', :font_style => :bold},"",{:content => '2000',:font_style => :bold}],
		["",".  Professional Tax(Tax on Employment)","2000",""],
		[{:content => "5.", :font_style => :bold},{:content => "Total income frome salary(3-4)", :font_style => :bold},"",{:content => "554232", :font_style => :bold}],
		[{:content => "6.", :font_style => :bold},{:content => "Add other income declared by employee", :font_style => :bold},"",""],
		[{:content => "7.", :font_style => :bold},{:content => "Gross Total Income(5+6)", :font_style => :bold}, "",{:content => "554232", :font_style => :bold}],
		[{:content => "8.", :font_style => :bold},{:content => "Deduction under chapter vi-A", :font_style => :bold},"", {:content => "76533", :font_style => :bold}],
		["", ".  Investments(80C and 80CCF)","76553",""],
		["", ".  Others(80D, 80DD, 80E etc)","", ""],
		[{:content => "9.", :font_style => :bold},{:content => "Total Income chargable to Tax(7-8)", :font_style => :bold},"",{:content => "467700", :font_style => :bold}],
		[{:content => "10.", :font_style => :bold}, {:content => "Tax on total Income", :font_style => :bold},"", {:content => "31694", :font_style => :bold}],
		[{:content => "11.", :font_style => :bold},{:content => "Less: Relief", :font_style => :bold},"",""],
		[{:content => "12.", :font_style => :bold},{:content => "Tax Payable after Relief(10-11)", :font_style => :bold},"",{:content => "31694", :font_style => :bold}],
		[{:content => "13.", :font_style => :bold},{:content => "Less: Tax Deducted", :font_style => :bold}, "", {:content => "28661", :font_style => :bold}],
		["", "a) Advance Tax declared by Employee","",""],
		["", "b) Tax Dedicted by the previous Employer", "", ""],
		["", "c) Tax declared other then Salary","",""],
		["", "d) Tax paid by the Employer","",""],
		["", "e) Self Assessment Tax Declared by Employee","",""],
		["", "f) Tax declared till Date","28661",""],
		["",{:content => "B a l a n c e  T a x  P a y a b l e / D e d u c t i b l e", :font_style => :bold},"",{:content => "3.033", :font_style => :bold}]
	]
	
	pdf.table(data, :header => true, :width => pdf.bounds.width, :row_colors => ["FFFFFF","F2F7FF"], :cell_style =>{:size => 9, :border_width => 0, :border_color => "70B8FF"}, :column_widths => {0 => 45, 2 => 120, 3 => 120})do
			row(0).borders = [:top, :bottom]
			row(0).border_width = 0.1
			row(0).font_style = :bold
	end
	
	pagecount = pdf.page_count
	Prawn::Document.generate("footer.pdf", :skip_page_creation => true) do
		pdf.page_count.times do |i|
			pdf.go_to_page(i+1)
			pdf.fill_color "ADADAD"
			pdf.draw_text "Generated from www.profitnext.com", :at=>[0,-10], :size => 7
			pdf.fill_color "000000"
			pdf.draw_text "Page : #{i+1} / #{pdf.page_count}", :at=>[pdf.bounds.width - 50,-10], :size => 9
		end
	end
end
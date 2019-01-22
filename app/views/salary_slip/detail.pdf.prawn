pdf = Prawn::Document.new(:page_layout => :portrait, :page_size => 'A4')
	y_position = pdf.cursor
    pdf.bounding_box([0, y_position], :width => (pdf.bounds.width/2) - 5) do 
     	if Rails.env.production?
		    pdf.image(open("#{@company.logo.url}"), :fit=>Prawn::Document::PageGeometry::SIZES["A10"]) unless @company.logo_file_name.blank?
		  end	
    end
	pdf.bounding_box([0, y_position], :width =>pdf.bounds.width, :height => 80) do
		pdf.text "<b>#{@company.name }</b>", :align => :center, :inline_format => true, :size =>14
		pdf.text "<u>Salary Slip</u>", :size => 12, :align => :center, :inline_format => true
		pdf.text "#{@month.strftime("%B-%Y")}", :size => 8, :align => :center, :inline_format => true
	end
	
	pdf.move_down 10
		pdf.table([["#{@user.first_name } #{@user.last_name}"]], :width => pdf.bounds.width, :cell_style => {:background_color => "F2F7FF", :size => 10}) do
			row(0).align = :center
			row(0).border_width = 0
		end
		
	pdf.move_down 10
	y_position = pdf.cursor
	pdf.bounding_box([0, y_position], :width => (pdf.bounds.width / 2) - 5) do
		pdf.table([["Personal Details",""],
					["Employee No.", ": #{@user_salary_details.employee_no unless @user_salary_details.blank? }"],
					["Designation",": #{@designation.title  unless @designation.nil?}"],
					["Location",": #{@user_salary_details.work_location unless @user_salary_details.nil?}"],
					["Date of Joining",": #{@user_salary_details.date_of_joining unless @user_salary_details.nil?}"],
					["Attandance","#{@attendance.days_absent.to_i} days absent"]],
					:width => (pdf.bounds.width - 10), :row_colors => ["FFFFFF","F2F7FF"], :cell_style =>{:border_width => 0, :border_color => "70B8FF", :size => 9})do
			row(0).borders = [:top, :bottom]
			row(0).border_width = 0.1
			row(0).font_style = :bold
		end
	end
	pdf.bounding_box([(pdf.bounds.width / 2) + 5, y_position], :width => (pdf.bounds.width / 2) - 10) do
		pdf.table([["Bank Details",""],
					["Bank Name", ": #{ @user_salary_details.bank_name unless  @user_salary_details.nil?}"],
					["Income Tax No.(PAN)",": #{@user_salary_details.PAN unless @user_salary_details.nil?}"],
					["PF Account No.",": #{@user_salary_details.PF_account_number unless @user_salary_details.nil?}"],
					["ESI No.",": #{@user_salary_details.EPS_account_number unless @user_salary_details.nil?}"],[]],
					:width => pdf.bounds.width, :row_colors => ["FFFFFF","F2F7FF"], :cell_style =>{:border_width => 0, :border_color => "70B8FF", :size => 9})do
			row(0).borders = [:top, :bottom]
			row(0).border_width = 0.1
			row(0).font_style = :bold
		end
	end
	
	pdf.move_down 15
	data = [["Earning",{:content => "Amount", :align => :right},"Deduction",{:content => "Amount", :align => :right}]]
	count = @count
	for i in 0..(@count - 1)
		data += [["#{@earning_arr[i]}",{:content => "#{@earning_amount_arr[i]}", :align => :right},"#{@deduction_arr[i]}",{:content => "#{@deduction_amount_arr[i]}", :align => :right}]]
	end
	
	data += [["Total Earning Amount",{:content => "#{number_with_precision @total_earning,:precision=>2}", :align => :right},"Total Deduction Amount",{:content => "#{number_with_precision @total_deduction,:precision=>2}", :align => :right}]]
	data += [["","","Net Amount",{:content => "#{number_with_precision (@total_earning - @total_deduction), :precision=>2}", :align => :right}]]
	 net_amount = (@total_earning - @total_deduction) 
	pdf.table(data, :header => true, :width => pdf.bounds.width,:row_colors => ["FFFFFF","F2F7FF"] , :cell_style =>{:border_width => 0,:border_color => "70B8FF", :size => 9}) do
		row(0).font_style = :bold
		row(0).borders = [:bottom, :top]
		row(0).border_width = 0.1
		
		row(count + 1).column(1).borders= [:bottom, :top]
		row(count + 1).column(1).border_width = 0.1
		row(count + 1).column(3).borders= [:top]
		row(count + 1).column(3).border_width = 0.1
		row(count + 1).font_style = :bold
		
		row(count + 2).column(3).borders= [:bottom]
		row(count + 2).column(3).border_width = 0.1
		row(count + 2).font_style = :bold
	end
	 if @company.currency_code =='INR' || @company.currency_code =='BDT' || @company.currency_code =='LKR' || @company.currency_code =='NPR' || @company.currency_code =='PKR' 
	pdf.move_down 10
	pdf.text "Amount in words in #{@company.currency_code}", :size => 10
	pdf.text amount_in_words(net_amount.to_f), :size => 10
	end
 	if @company.payroll_settings.enable_payslip_signatory == true
	pdf.move_down 10
	pdf.text "Authorised Signatory", :align => :right, :size => 10
	end
	pdf.move_down 10
	pdf.text "#{@company.payroll_settings.payslip_footer}", :size => 8
	pagecount = pdf.page_count
	Prawn::Document.generate("footer.pdf", :skip_page_creation => true) do
		pdf.page_count.times do |i|
			pdf.go_to_page(i+1)
			pdf.fill_color "ADADAD"
			pdf.draw_text "**This Pay slip is computer generated and doesn't require any signature**", :at=>[0,-10], :size => 7
			pdf.fill_color "000000"
			pdf.draw_text "Page : #{i+1} / #{pdf.page_count}", :at=>[pdf.bounds.width-50,-10], :size => 9
		end
	end
	
pdf.render_file('salary_slip.pdf')
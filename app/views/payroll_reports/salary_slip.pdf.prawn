pdf = Prawn::Document.new(:page_layout => :portrait, :page_size => 'A4')

	pdf.bounding_box([0, pdf.cursor], :width =>pdf.bounds.width, :height => 80) do
		pdf.text "<b>#{@company.name }</b>", :align => :center, :inline_format => true, :size =>14
		pdf.text "<u>Salary Slip</u>", :size => 12, :align => :center, :inline_format => true
		pdf.text "#{(params[:month].nil? || params[:month].blank?)? @months[Time.zone.now.to_date.month] : @months[params[:month].to_i]}-#{(params[:year].nil? || params[:year].blank?)? Time.zone.now.to_date.year : params[:year]}", :size => 8, :align => :center, :inline_format => true
	end
	
	pdf.move_down 10
		pdf.table([["#{@current_user.first_name } #{@current_user.last_name}"]], :width => pdf.bounds.width, :cell_style => {:background_color => "F2F7FF", :size => 10}) do
			row(0).align = :center
			row(0).border_width = 0
		end
		
	pdf.move_down 10
	y_position = pdf.cursor
	pdf.bounding_box([0, y_position], :width => (pdf.bounds.width / 2) - 5) do
		pdf.table([["Personal Details",""],
					["Employee No.", ": #{@current_user.id}"],
					["Designation",": #{@designation.title  unless @designation.nil?}"],
					["Location",": #{@user_salary_details.work_location unless @user_salary_details.nil?}"],
					["Date of Joining",": #{@user_salary_details.date_of_joining unless @user_salary_details.nil?}"]],
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
					["ESI No.",": #{@user_salary_details.EPS_account_number unless @user_salary_details.nil?}"]],
					:width => pdf.bounds.width, :row_colors => ["FFFFFF","F2F7FF"], :cell_style =>{:border_width => 0, :border_color => "70B8FF", :size => 9})do
			row(0).borders = [:top, :bottom]
			row(0).border_width = 0.1
			row(0).font_style = :bold
		end
	end
	
	pdf.move_down 10
	data = [["Earning",{:content => "Amount", :align => :right},"Deduction",{:content => "Amount", :align => :right}]]
	count = @count
	for i in 0..(@count - 1)
		data += [["#{@earning_arr[i]}",{:content => "#{@earning_amount_arr[i]}", :align => :right},"#{@deduction_arr[i]}",{:content => "#{@deduction_amount_arr[i]}", :align => :right}]]
	end
	
	data += [["Total Earning Amount",{:content => "#{@total_earning}", :align => :right},"Total Deduction Amount",{:content => "#{@total_deduction}", :align => :right}]]
	data += [["","","Net Amount",{:content => "#{(@total_earning - @total_deduction)}", :align => :right}]]
	
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
	
	pdf.move_down 10
	pdf.text "Amount In Words", :size => 10
	pdf.text "****************"
	pdf.move_down 10
	pdf.text "Authorised Signatury", :align => :right, :size => 10
	
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
pdf = Prawn::Document.new(:page_layout => :portrait, :page_size => 'A4')
	pdf.bounding_box([0, pdf.cursor], :width =>pdf.bounds.width, :height => 80) do
		pdf.text "<b>#{@company.name }</b>", :align => :center, :inline_format => true, :size =>14
		pdf.text "<u>Payment Advice</u>", :align => :center, :inline_format => true, :size => 12
	end

	pdf.move_down 10
	pdf.text "The Manager", :size => 10
	pdf.text "#{@account.accountable.bank_name unless @account.accountable_type == "CashAccount"|| @account.accountable.bank_name.blank?}", :size => 10
	pdf.move_down 20
	pdf.text "Dear Sir ,", :size => 10
	pdf.text "<u><b>Payment Advice from #{@company.name} A/C #{@account.name } for #{@date.strftime("%B-%Y")}</b></u>", :inline_format => true,:indent_paragraphs =>20, :size => 10
	
	pdf.text "Please make the payroll tranfer from above account to the below mentioned account numbers 
	employee salaries", :size => 10
	
	data = [["Sl.No.","Name of the Employee","Account No.","Bank Name","Branch","Amount (#{@company.currency_code})"]]
	 m = 1
     @amount=0  
                  
	for i in @users
		@earning_arr = []
	    @earning_amount_arr = []
	    @deduction_arr = []
	    @deduction_amount_arr = []
	    @count = 0
	    @total_earning = 0
	    @total_deduction = 0

        salaries = Salaries.where("user_id = ? and month between ? and ?",i.id, @date.beginning_of_month, @date.end_of_month)

        for salary in salaries
           payhead = Payhead.find(salary.payhead_id) 
           if payhead.payhead_type == "Earnings" 
             @earning_arr << payhead.payhead_name
             @earning_amount_arr << salary.amount
             @total_earning +=salary.amount
           else
             @deduction_arr << payhead.payhead_name
             @deduction_amount_arr << salary.amount
             @total_deduction +=salary.amount
           end 
            @net_amount = @total_earning - @total_deduction
         end
            
		sal_detail = UserSalaryDetail.find_by_user_id(i.id)

		data += [[m,"#{i.full_name}","#{sal_detail.bank_account_number unless sal_detail.nil?}","#{sal_detail.bank_name unless sal_detail.nil?}","#{ sal_detail.branch  unless sal_detail.nil?}","#{@net_amount}"]]
		
		m+=1
		@amount += @net_amount
	end
	data += [["","","","","Total","#{@amount}"]]
	pdf.move_down 20
	pdf.table(data, :header => true, :width => pdf.bounds.width, :row_colors => ["FFFFFF","F2F7FF"], :cell_style =>{:border_width => 0, :border_color => "70B8FF", :size => 9}, :column_widths => {0 => 50, 2 => 80, 3 => 80, 4 => 80})do
		row(0).borders = [:top, :bottom]
		row(0).border_width = 0.1
		row(0).font_style = :bold
		row(m).column(4..5).borders = [:top, :bottom]
		row(m).column(4..5).border_width = 0.1
	end
pdf.move_down 10
pdf.text "Yours Sincerely", :size => 10
pdf.text "<b>For #{@company.name }</b>", :inline_format => true, :size => 10
pdf.move_down 20
pdf.text "Authorised Signatory", :size => 10

creation_date = Time.zone.now.strftime('%d-%m-%Y')
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

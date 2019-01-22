class CustomerStatementPdf < Prawn::Document
	include PdfBase
	include ApplicationHelper

	def initialize(view_context, company, current_user, accounts, customer, invoices, receipt_vouchers, reimbursement_notes, reimbursement_vouchers, journal_line_items, opening_balance, closing_balance, receipt_amount, invoiced_amount, start_date, end_date)
	  super(PAGE_LAYOUT)
	  @view_context=view_context
	  @accounts=accounts
	  @invoices=invoices
	  @receipt_vouchers=receipt_vouchers
		@reimbursement_notes = reimbursement_notes
		@reimbursement_vouchers = reimbursement_vouchers
	  @journal_line_items=journal_line_items
	  @company=company
	  @current_user=current_user
	  @party=customer.get_party
	  @start_date=start_date
	  @end_date=end_date
	  @opening_balance=opening_balance
	  @closing_balance=closing_balance
	  @receipt_amount=receipt_amount
	  @invoiced_amount=invoiced_amount
	  @pos_arr=[]
	  @header_pos=[]
	  send "generate_expense_report"
	end

	def generate_expense_report
		y_pos=cursor
		bounding_box([0, cursor], :width => (bounds.width/2)-5) do
		  company_logo
		  @header_pos<<y
		end

		bounding_box([(bounds.width/2), y_pos], :width => (bounds.width/2)) do
			company_name_and_address
			@header_pos<<y
		end

		bounding_box([0, (@header_pos.min.to_i-30)], :width=>bounds.width) do
			text "<b>CUSTOMER STATEMENT</b>", :align => :center, :inline_format => true, :size => 14
			stroke_horizontal_rule
		end
		y_pos=cursor-5
		bounding_box([0, cursor-5], :width => (bounds.width/2)-5) do
		  customer_details
		  @header_pos<<y
		end

		bounding_box([(bounds.width/2), y_pos], :width => (bounds.width/2)) do
			account_details
			@header_pos<<y
		end
		unless @invoices.blank?
			self.y=@header_pos.min-5
			invoice_summery
		end

		unless @receipt_vouchers.blank?
			self.y-=5
			receipt_summery
		end

		unless @journal_line_items.blank?
			self.y-=5
			journal_summery
		end

		unless @reimbursement_notes.blank?
			self.y-=5
			reimbursement_note_summary
		end

		unless @reimbursement_vouchers.blank?
			self.y-=5
			reimbursement_voucher_summary
		end

		page_footer
	end
	# def branch_address
	#   address=Array.new
	#   address<<[{:content=>"#{@company.name}", :font_style=> :bold}]
	#   if !@current_user.branch.blank?
	#     address<<["#{@current_user.branch.address.get_address}"]  unless @current_user.branch.address.blank?
	#     address<<["Phone: #{@current_user.branch.phone}"] unless @current_user.branch.phone.blank?
	#   else
	#     address<<["#{@company.address.get_address}"] unless @company.address.blank?
	#     address<<["Phone: #{@company.phone}"] unless @company.phone.blank?
	#   end
	#   address
	# end
	def invoice_summery
		text"<b>Invoices Summery</b>", :align=>:left, :size=>8, :inline_format=>true
		data=[["Voucher", "Date",{:content=>"Amount", :align=>:right}, {:content=>"Received", :align=>:right}, {:content=>"Balance due", :align=>:right}]]
		@invoices.each do |invoice|
			data<<["#{invoice.invoice_number}", "#{invoice.invoice_date}",{:content=>"#{number_with_precision @view_context.sales_amount(invoice), :precision=>2}", :align=>:right}, {:content=>"#{number_with_precision @view_context.received_amount(invoice), :precision=>2 }", :align=>:right}, {:content=>"#{number_with_precision invoice.outstanding, :precision=>2}", :align=>:right}]
		end
		table(data, :header=>true, :width=>bounds.width,:row_colors => ["FFFFFF","F2F7FF"] , :cell_style =>{:border_width => 0,:border_color => "70B8FF",  :size => 8}) do
			row(0).font_style=:bold
			row(0).borders=[:top, :bottom]
			row(0).border_width=0.2
		end
	end

	def receipt_summery
		text"<b>Receipts Summery</b>", :align=>:left, :size=>8, :inline_format=>true
		data=[["Voucher", "Received Date",{:content=>"Amount", :align=>:right}, "Payment mode"]]
		@receipt_vouchers.each do |receipt_voucher|
			data<<["#{receipt_voucher.voucher_number}", "#{receipt_voucher.received_date}",{:content=>"#{number_with_precision @view_context.receipt_voucher_amount(receipt_voucher), :precision=>2}", :align=>:right}, "#{receipt_voucher.payment_detail.payment_mode}"]
		end
		table(data, :header=>true, :width=>bounds.width,:row_colors => ["FFFFFF","F2F7FF"] , :cell_style =>{:border_width => 0,:border_color => "70B8FF",  :size => 8}) do
			row(0).font_style=:bold
			row(0).borders=[:top, :bottom]
			row(0).border_width=0.2
		end
	end

	def reimbursement_note_summary
		text"<b>Reimbursement Voucher Summary</b>", :align=>:left, :size=>8, :inline_format=>true
		data=[["Voucher", "Date",{:content=>"Amount", :align=>:right}, "Status"]]
		@reimbursement_notes.each do |reimbursement_note|
			data<<["#{reimbursement_note.reimbursement_note_number}", "#{reimbursement_note.transaction_date}",{:content=>"#{format_currency reimbursement_note.amount}", :align=>:right}, reimbursement_note.submitted ? "Reimbursed" : "Overdue by #{((Time.zone.now.to_date - reimbursement_note.transaction_date).to_f).ceil} days"]
		end
		table(data, :header=>true, :width=>bounds.width,:row_colors => ["FFFFFF","F2F7FF"] , :cell_style =>{:border_width => 0,:border_color => "70B8FF",  :size => 8}) do
			row(0).font_style=:bold
			row(0).borders=[:top, :bottom]
			row(0).border_width=0.2
		end
	end

	def reimbursement_voucher_summary
		text"<b>Reimbursement Receipt Summary</b>", :align=>:left, :size=>8, :inline_format=>true
		data=[["Voucher", "Date",{:content=>"Amount", :align=>:right}, "Payment mode"]]
		@reimbursement_vouchers.each do |reimbursement_voucher|
			data<<["#{reimbursement_voucher.voucher_number}", "#{reimbursement_voucher.received_date}",{:content=>"#{format_currency reimbursement_voucher.amount}", :align=>:right}, "#{reimbursement_voucher.payment_detail.payment_mode}"]
		end
		table(data, :header=>true, :width=>bounds.width,:row_colors => ["FFFFFF","F2F7FF"] , :cell_style =>{:border_width => 0,:border_color => "70B8FF",  :size => 8}) do
			row(0).font_style=:bold
			row(0).borders=[:top, :bottom]
			row(0).border_width=0.2
		end
	end


	def journal_summery
		text"<b>Journals Summery</b>", :align=>:left, :size=>8, :inline_format=>true
		data=[["Voucher", "Date",{:content=>"Amount", :align=>:right}]]
		@journal_line_items.each do |line_item|
			prefix=line_item.amount>0? "Dr" : "Cr"
			data<<["#{line_item.journal.voucher_number}", "#{line_item.journal.date}",{:content=>"#{number_with_precision (line_item.amount+line_item.credit_amount), :precision=>2 }#{prefix}", :align=>:right}]
		end
		table(data, :header=>true, :width=>bounds.width,:row_colors => ["FFFFFF","F2F7FF"] , :cell_style =>{:border_width => 0,:border_color => "70B8FF",  :size => 8}) do
			row(0).font_style=:bold
			row(0).borders=[:top, :bottom]
			row(0).border_width=0.2
		end
	end

	def account_details
		data=[[{:content =>"Customer Details Dated #{@start_date} to #{@end_date}", :font_style => :bold, :align => :left}]]
		data<<["<b>Opening outstanding: #{@view_context.format_currency @opening_balance}</b>"]
		data<<["<b>Billed in invoices: #{@view_context.format_currency @invoiced_amount}</b>"]
		data<<["<b>Received: #{@view_context.format_currency @receipt_amount}</b>"]
		data<<["<b>Balance due: #{@view_context.format_currency @closing_balance}</b>"]
	  table(data, :width=>bounds.width,:cell_style =>{:align => :left,:inline_format => true,:border_width =>0, :size => 9, :border_color => "70B8FF" })do
			row(0).borders = [:left, :right, :bottom, :top]
			row(0).background_color = 'F2F7FF'
			row(1..(data.size - 2)).borders = [:left, :right]
			row(data.size - 1).borders = [:left, :right, :bottom]
 			row(0..(data.size - 1)).border_width = 0.2
    end
	end

	# def report_details
	# 	text"<b><u>Outstanding Expenses</u></b>", :align=>:center, :size=>8, :inline_format=>true
	# 	text"Outstanding for #{(@account.blank?)? 'All vendors' : @account.name}", :align=>:center, :size=>8, :inline_format=>true
	# end

	# def outstanding_expenses_details
	# 	data=Array.new
	# 	data<<table_header
	# 	data=data.concat(report_data)
	# 	data<<grand_total
	# 	table(data, :header=>true, :width=>bounds.width,:row_colors => ["FFFFFF","F2F7FF"] , :cell_style =>{:border_width => 0,:border_color => "70B8FF",  :size => 8}) do
	# 		row(0).font_style=:bold
	#     row(0).borders=[:top, :bottom]
	#     row(0).border_width=0.2
 #    end
	# end
	# def grand_total
	# 	outstanding_array=@expenses.map{|e| e.outstanding }
	# 	["", "", {:content=>"Grand Total", :font_style=>:bold, :align=>:right}, {:content=>"#{ number_with_precision @view_context.expense_report_total_amount, :precision=>2}", :font_style=>:bold, :align=>:right}, {:content=>"#{number_with_precision @view_context.expense_report_total_outstanding, :precision=>2}", :font_style=>:bold, :align=>:right}, ""]
	# end
	# def report_data
	# 	data=Array.new
	# 	@expenses.each do |expense|
	# 		data<<["#{expense.voucher_number}", "#{expense.due_date}", "#{expense.account.name}", {:content=>"#{@view_context.expense_report_amount(expense)}", :align=>:right}, {:content=>"#{@view_context.expense_report_outstanding(expense)}", :align=>:right}, {:content=>"#{@view_context.distance_of_time_in_words(expense.due_date, Time.zone.now.to_date)}", :align=>:right}]
	# 	end
	# 	data
	# end
	# def table_header
	# 	["Voucher", "Due date", "Vendor", {:content=>"Amount(#{@company.currency_code})", :align=>:right}, {:content=>"Outstanding(#{@company.currency_code})", :align=>:right}, {:content=>"Overdue by days", :align=>:right}]
	# end
end

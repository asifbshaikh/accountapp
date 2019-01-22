class ExpenseReportPdf < Prawn::Document
	include PdfBase
	require 'open-uri'
	include ActionView::Helpers::NumberHelper
	def initialize(view_context, expenses, account, company)
	  super(PAGE_LAYOUT)
	  @view_context=view_context
	  @expenses=expenses
	  @account=account
	  @company=company
	  @pos_arr=[]
	  @header_pos=[]
	  send "generate_expense_report"
	end

	def generate_expense_report
		y_pos=cursor
		bounding_box([0, y_pos], :width=>bounds.width) do
			company_name_and_address_in_center
			report_details
		end
		outstanding_expenses_details
		page_footer
	end

	def report_details
		text"<b><u>Outstanding Expenses</u></b>", :align=>:center, :size=>8, :inline_format=>true
		text"Outstanding for #{(@account.blank?)? 'All vendors' : @account.name}", :align=>:center, :size=>8, :inline_format=>true
	end

	def outstanding_expenses_details
		data=Array.new
		data<<table_header
		data=data.concat(report_data)
		data<<grand_total
		table(data, :header=>true, :width=>bounds.width,:row_colors => ["FFFFFF","F2F7FF"] , :cell_style =>{:border_width => 0,:border_color => "70B8FF",  :size => 8}) do
			row(0).font_style=:bold
	    row(0).borders=[:top, :bottom]
	    row(0).border_width=0.2
    end
	end
	def grand_total
		outstanding_array=@expenses.map{|e| e.outstanding }
		["", "", {:content=>"Grand Total", :font_style=>:bold, :align=>:right}, {:content=>"#{ number_with_precision @view_context.expense_report_total_amount, :precision=>2}", :font_style=>:bold, :align=>:right}, {:content=>"#{number_with_precision @view_context.expense_report_total_outstanding, :precision=>2}", :font_style=>:bold, :align=>:right}, ""]
	end
	def report_data
		data=Array.new
		@expenses.each do |expense|
			data<<["#{expense.voucher_number}", "#{expense.due_date}", "#{expense.account.name}", {:content=>"#{@view_context.expense_report_amount(expense)}", :align=>:right}, {:content=>"#{@view_context.expense_report_outstanding(expense)}", :align=>:right}, {:content=>"#{@view_context.distance_of_time_in_words(expense.due_date, Time.zone.now.to_date)}", :align=>:right}]
		end
		data
	end
	def table_header
		["Voucher", "Due date", "Vendor", {:content=>"Amount(#{@company.currency_code})", :align=>:right}, {:content=>"Outstanding(#{@company.currency_code})", :align=>:right}, {:content=>"Overdue by days", :align=>:right}]
	end
end
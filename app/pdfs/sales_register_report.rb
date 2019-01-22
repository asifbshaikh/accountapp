class SalesRegisterReport < Prawn::Document
	include PdfBase
	require 'open-uri'
	include ActionView::Helpers::NumberHelper
	def initialize(view_context, invoices, account, company, start_date, end_date, branch_id)
	  super(PAGE_LAYOUT)
	  @view_context=view_context
	  @invoices=invoices
	  @account=account
	  @company=company
	  @start_date=start_date
	  @end_date=end_date
	  @branch_id=branch_id
	  @pos_arr=[]
	  @header_pos=[]
	  send "generate_sales_register"
	end

	def generate_sales_register
		y_pos=cursor
		bounding_box([0, y_pos], :width=>bounds.width) do
			company_name_and_address_in_center
			report_details
		end
		sales_register_details
		page_footer
	end

	def report_details
		text"<b><u>Sales Register</u></b>", :align=>:center, :size=>8, :inline_format=>true
		text"#{(@account.blank?)? 'All customers' : @account.name}", :align=>:center, :size=>8, :inline_format=>true
		unless @branch_id.blank?
		 text"#{@view_context.display_branch(@branch_id)}", :inline_format=>true, :align => :center, :size => 6
		end
		text"#{@start_date} to #{@end_date}", :align=>:center, :size=>8, :inline_format=>true
	end

	def sales_register_details
		data=Array.new
		data<<table_header
		data=data.concat(report_data)
		table(data, :header=>true, :width=>bounds.width,:row_colors => ["FFFFFF","F2F7FF"] , :cell_style =>{:border_width => 0,:border_color => "70B8FF",  :size => 8}) do
			row(0).font_style=:bold
	    row(0).borders=[:top, :bottom]
	    row(0).border_width=0.2
    end
	end

	def report_data
		data=Array.new
		total_amount=0
		@invoices.each do |invoice|
			data<<["#{invoice.invoice_date}","#{invoice.invoice_number}", "#{invoice.customer_name}","#{invoice.due_date}","#{invoice.get_status}", {:content=>"#{number_with_precision (sales_amount=@view_context.sales_amount(invoice)), :precision=>2}", :align=>:right},"#{invoice.created_by_user}"]
			total_amount+=sales_amount
		end
		data<<["", "", "","",{:content=>"Total", :align=>:right, :font_style=>:bold}, {:content=>"#{number_with_precision total_amount, :precision=>2}", :align=>:right, :font_style=>:bold}]
		data
	end

	def table_header
		["Create Date", "invoice No.", "Customer Name", "Due Date", "Status", 
			{:content=>"Amount(#{@company.currency_code})", :align=>:right}, "Created By"]
	end
end
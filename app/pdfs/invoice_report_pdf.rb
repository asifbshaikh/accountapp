class InvoiceReportPdf < Prawn::Document
	include PdfBase
	require 'open-uri'
	include ActionView::Helpers::NumberHelper
	def initialize(view_context, invoices, account, company, start_date, end_date)
	  super(PAGE_LAYOUT)
	  @view_context=view_context
	  @invoices=invoices
	  @account=account
	  @company=company
	  @start_date=start_date
	  @end_date=end_date
	 
	  # @pos_arr=[]
	  # @header_pos=[]
	  send 
	end

	# def generate_sales_register
	# 	y_pos=cursor
	# 	bounding_box([0, y_pos], :width=>bounds.width) do
	# 		company_name_and_address_in_center
	# 		report_details
	# 	end
	# 	sales_register_details
	# 	page_footer
	# end

	def report_details
		text"<b><u>Invoice Report</u></b>", :align=>:center, :size=>8, :inline_format=>true
		text"#{(@account.blank?)? 'All customers' : @account.name}", :align=>:center, :size=>8, :inline_format=>true
		
		 
	
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
	
		@invoices.each do |invoice|
			data<<["#{invoice.invoice_number}","#{invoice.invoice_date}", "#{invoice.invoice.get_party.name}","#{invoice.total_quantity}","#{invoice.sub_total}","#{invoice.calc_cgst_tax_amt}","#{invoice.calc_cgst_tax_amt}","#{invoice.calc_igst_tax_amt}","#{invoice.total_amount}"]
			
		end
		
		data
	end

	def table_header
		["Invoice Number","Invoice Date","Customer Name","Quantity"," Total","CGST","SGST","IGST","Total"]
			
	end
end
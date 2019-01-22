class StockStatementPdf < Prawn::Document
	include PdfBase
	require 'open-uri'
	include ActionView::Helpers::NumberHelper

	def initialize(view_context, company, stock_summaries, start_date, end_date, branch_id)
	  super(HORIZONTAL_PAGE_LAYOUT)
	  @view_context=view_context
	  @company=company
	  @stock_summaries=stock_summaries
	  @start_date=start_date
	  @end_date=end_date
	  @branch_id=branch_id
	  generate_pdf
	end

	def generate_pdf
		y_pos=cursor
		bounding_box([0, y_pos], :width=> bounds.width) do
			company_name_and_address_in_center
			report_details
		end
		stock_statement_details
		page_footer
	end

	def report_details
		text"<b><u>Stock Summary</u></b>", :align=>:center, :size=>8, :inline_format=>true
		unless @branch_id.blank?
		 text "#{@view_context.display_branch(@branch_id)}", :inline_format=>true, :align => :center, :size => 6
		end
		text"#{@start_date} to #{@end_date}", :align=>:center, :size=>8, :inline_format=>true
	end

	def stock_statement_details
		data=Array.new
		data<<table_header
		data=data.concat(report_data)
		table(data, :header=>true, :width=>bounds.width,:row_colors => ["FFFFFF","F2F7FF"] , :cell_style =>{:border_width => 0,:border_color => "70B8FF", :size => 7, :font => "Helvetica"}) do
			row(0).font_style=:bold
	    row(0).borders=[:top, :bottom]
	    row(0).border_width=0.2
    end
	end

	def table_header
		["Item",
			{:content=>"Opening stock qty", :align=>:right},
			{:content=>"Opening stock value", :align=>:right},
			{:content=>"Purchased Qty.", :align=>:right},
			{:content=>"Purchased total", :align=>:right},
			{:content=>"Avg. purchase price", :align=>:right},
			{:content=>"Purchase Return Qty.", :align=>:right},
			{:content=>"Produced qty", :align=>:right},
			{:content=>"Produced value", :align=>:right},
			{:content=>"Qty issued for prodution", :align=>:right},
			{:content=>"Issued qty value", :align=>:right},
			{:content=>"Wasted quantity", :align=>:right},
			{:content=> "Sold Quantity", :align=>:right},
			{:content=>"Sales total (#{@company.currency_code})", :align=>:right},
			{:content=> "Avg. sales price (#{@company.currency_code})", :align=>:right},
			{:content=> "Sales Return Quantity", :align=>:right},
			{:content=>"Net quantity", :align=>:right},
			{:content=>"Net total (#{@company.currency_code})", :align=>:right}
		]
	end

	def report_data
		data=Array.new
		@stock_summaries.each do |stock_summary|
			data<<["#{stock_summary.product.name}",
				{:content=>"#{stock_summary.opening_stock_quantity}", :align=>:right},
				{:content=>"#{number_with_precision stock_summary.opening_stock_valuation, precision: 2}", :align=>:right},
				{:content=>"#{stock_summary.purchase_quantity}", :align=>:right},
				{:content=>"#{number_with_precision stock_summary.purchase_amount, precision: 2}", :align=>:right},
				{:content=>"#{number_with_precision stock_summary.average_purchase_price, precision: 2}", :align=>:right},
				{:content=>"#{stock_summary.purchase_return_quantity}", :align=>:right},
				{:content=>"#{stock_summary.stock_received_quantity}", :align=>:right},
				{:content=>"#{number_with_precision stock_summary.stock_received_amount, precision: 2}", :align=>:right},
				{:content=>"#{stock_summary.stock_issued_quantity}", :align=>:right},
				{:content=>"#{number_with_precision stock_summary.stock_issued_amount, precision: 2}", :align=>:right},
				{:content=>"#{stock_summary.stock_wasted_quantity}", :align=>:right},
				{:content=>"#{stock_summary.sales_quantity}", :align=>:right},
				{:content=>"#{number_with_precision stock_summary.sales_amount, precision: 2}", :align=>:right},
				{:content=>"#{number_with_precision stock_summary.average_sales_price, precision: 2}", :align=>:right},
				{:content=>"#{stock_summary.sales_return_quantity}", :align=>:right},
				{:content=>"#{stock_summary.net_quantity}", :align=>:right},
				{:content=>"#{number_with_precision stock_summary.inventory_valuation, precision: 2}", :align=>:right}
			]
		end
		data
	end
end

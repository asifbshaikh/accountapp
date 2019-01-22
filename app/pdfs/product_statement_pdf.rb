class ProductStatementPdf < Prawn::Document
	include PdfBase
	require 'open-uri'
	include ApplicationHelper
	include ActionView::Helpers::NumberHelper
	def initialize(view_context, company,product, stocks_data, purchase_line_items, invoice_line_items, start_date, end_date, branch_id)
	  super(PAGE_LAYOUT)
	  @view_context=view_context
	  @company=company
	  @product=product
	  @stocks_data = stocks_data
	  @purchase_line_items=purchase_line_items
	  @invoice_line_items=invoice_line_items
	  @start_date=start_date
	  @end_date=end_date
	  @branch_id=branch_id
	  @cursor_pos=[]
	  generate_pdf
	end

	def generate_pdf
		y_pos=cursor
		bounding_box([0, y_pos], :width=>bounds.width) do
			company_name_and_address_in_center
			report_details
		end
		y_pos=cursor
		box_width = bounds.width/2
		bounding_box([0, y_pos], :width=>box_width) do
			report_header_left
		end
		bounding_box([box_width, y_pos], :width=>box_width) do
			report_header_right
		end
		y_pos=cursor-15
		if @product.type=="ResellerItem" || @product.type=="PurchaseItem"
			box_width=bounds.width/3
			bounding_box([0, y_pos], :width=>box_width*2) do
				purchase_summary_left
				@cursor_pos<<y
			end

			bounding_box([((box_width*2)+80), (y_pos-11)], :width=>(box_width-10)) do
				purchase_summary_right
				@cursor_pos<<y
			end
		end
		if @product.type=="ResellerItem" || @product.type=="SalesItem"
			box_width=bounds.width/3
			y_pos= @cursor_pos.blank? ? y_pos : (@cursor_pos.min.to_i-50)
			bounding_box([0, y_pos], :width=>box_width*2) do
				sales_summary_left
			end
			y_pos= @cursor_pos.blank? ? (y_pos-11) : (@cursor_pos.min.to_i-61)
			bounding_box([((box_width*2)+80), y_pos], :width=>(box_width-10)) do
				sales_summary_right
			end
		end
		# stock_statement_details
		page_footer
	end

	def purchase_summary_left
		text"Purchase Summary", :size=>10, :inline_format=>true
		data=Array.new
		data<<["Voucher#","Vendor Name", "Date", {:content=>"Unit Price (#{@company.currency_code})", :align=>:right},
			{:content=>"Quantity", :align=>:right}, {:content=>"Total (#{@company.currency_code})", :align=>:right}]
		@purchase_line_items.each do |line_item|
			purchase=line_item.purchase
			data<<["#{purchase.purchase_number}", "#{purchase.vendor.name}", "#{purchase.record_date}", {:content=>"#{number_with_precision line_item.unit_rate, :precision=>2}", :align=>:right},
			{:content=>"#{number_with_precision line_item.quantity, :precision=>2}", :align=>:right}, {:content=>"#{number_with_precision line_item.amount, :precision=>2}", :align=>:right}]
		end
		table(data, :header=>true, :width=>bounds.width+50,:row_colors => ["FFFFFF","F2F7FF"] , :cell_style =>{:border_width => 0,:border_color => "70B8FF",  :size => 8}) do
			row(0).font_style=:bold
	    row(0).borders=[:top, :bottom]
	    row(0).border_width=0.2
    end
	end
	def purchase_summary_right
		data=Array.new
		data<<["Purchase Summary"]
		data<<["Total Purchased #{format_currency  @stocks_data.purchase_amount}"]
		data<<["Avg. Unit Price #{format_currency @stocks_data.average_purchase_price}"]
		table(data,:width=>bounds.width/2,  :cell_style=>{:align =>:left,:inline_format=> true,:border_width =>0, :size => 8, :border_color => "70B8FF" })do
		  row(0).borders = [:left, :right, :bottom, :top]
		  row(0).background_color = 'F2F7FF'
		  row(1..(data.size-2)).borders = [:left, :right]
		  row(data.size - 1).borders = [:left, :right, :bottom]
		  row(0..(data.size - 1)).border_width = 0.1
		end
	end

		def sales_summary_left
			text"Sales Summary", :size=>10, :inline_format=>true
			data=Array.new
			data<<["Voucher#", "Customer Name", "Date", {:content=>"Unit Price (#{@company.currency_code})", :align=>:right},
				{:content=>"Quantity", :align=>:right}, {:content=>"Total (#{@company.currency_code})", :align=>:right}]
			@invoice_line_items.each do |line_item|
				invoice=line_item.invoice
				data<<["#{invoice.invoice_number}","#{invoice.get_party.name}", "#{invoice.invoice_date}", {:content=>"#{number_with_precision line_item.item_cost, :precision=>(line_item.item_cost == line_item.item_cost.round(2) ? 2 : 4)}", :align=>:right},
				{:content=>"#{number_with_precision line_item.quantity, :precision=>2}", :align=>:right}, {:content=>"#{number_with_precision (line_item.item_cost * line_item.quantity), :precision=>2}", :align=>:right}]
			end
			table(data, :header=>true, :width=>bounds.width+50,:row_colors => ["FFFFFF","F2F7FF"] , :cell_style =>{:border_width => 0,:border_color => "70B8FF",  :size => 8}) do
				row(0).font_style=:bold
		    row(0).borders=[:top, :bottom]
		    row(0).border_width=0.2
	    end
		end
		def sales_summary_right
			data=Array.new
			data<<["Sales Summary"]
			data<<["Total Invoiced #{format_currency @stocks_data.sales_amount}"]
			data<<["Avg. Unit Price #{format_currency @stocks_data.average_sales_price }"]
			table(data,:width=>bounds.width/2,  :cell_style=>{:align =>:left,:inline_format=> true,:border_width =>0, :size => 8, :border_color => "70B8FF" })do
			  row(0).borders = [:left, :right, :bottom, :top]
			  row(0).background_color = 'F2F7FF'
			  row(1..(data.size-2)).borders = [:left, :right]
			  row(data.size - 1).borders = [:left, :right, :bottom]
			  row(0..(data.size - 1)).border_width = 0.1
			end
		end

	def report_header_left
		text"<b><u>#{@product.name}</b></u>", :inline_format=>true
		text"Showing details from #{@start_date} to #{@end_date}", :size=>8
	end

	def report_header_right
		text"Net Quantity #{@stocks_data.net_quantity}", :align=>:right, :size=>8, :inline_format=>true
		text"Net Profit/Loss #{number_with_precision Product.net_total(@product,@start_date,@end_date,@branch_id)}", :align=>:right, :size=>8
	end

	def report_details
		text"<b><u>Product Statement</u></b>", :align=>:center, :size=>8, :inline_format=>true
		unless @branch_id.blank?
		  text "#{@view_context.display_branch(@branch_id)}", :inline_format=>true, :align => :center, :size => 6
		end
	end

	def stock_statement_details
		data=Array.new
		data<<table_header
		data=data.concat(report_data)
		table(data, :header=>true, :width=>bounds.width,:row_colors => ["FFFFFF","F2F7FF"] , :cell_style =>{:border_width => 0,:border_color => "70B8FF",  :size => 8}) do
			row(0).font_style=:bold
	    row(0).borders=[:top, :bottom]
	    row(0).border_width=0.2
    end
	end
	def table_header
		["Item", {:content=>"Purchased Qty.", :align=>:right}, {:content=>"Total (#{@company.currency_code})", :align=>:right},
		{:content=>"Avg. Price (#{@company.currency_code})", :align=>:right},
		{:content=> "Sold Qty.", :align=>:right}, {:content=>"Total (#{@company.currency_code})", :align=>:right},
		{:content=> "Avg. Price (#{@company.currency_code})", :align=>:right},
		{:content=>"Net Qty.", :align=>:right}, {:content=>"Net Total (#{@company.currency_code})", :align=>:right}]
	end

	def report_data
		data=Array.new
		@products.each do |product|
			data<<["#{product.name}", {:content=>"#{@view_context.purchase_quantity(product)}", :align=>:right}, {:content=>"#{@view_context.purchase_total(product)}", :align=>:right},
			{:content=>"#{@view_context.purchase_average_price(product)}", :align=>:right},
			{:content=>"#{@view_context.sales_quantity(product)}", :align=>:right}, {:content=>"#{@view_context.sales_total(product)}", :align=>:right},
			{:content=>"#{@view_context.sales_average_price(product)}", :align=>:right},
			{:content=>"#{@view_context.net_quantity(product)}", :align=>:right}, {:content=>"#{@view_context.net_total(product)}", :align=>:right}]
		end
		data
	end
end

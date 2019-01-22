class PurchaseSettlementPdf < Prawn::Document
	include PdfBase
	require 'open-uri'
	include ActionView::Helpers::NumberHelper
	def initialize(view_context, company,purchases, start_date, end_date, branch_id, accounts, account)
	  super(PAGE_LAYOUT)
	  @view_context=view_context
	  @company=company
	  @purchases=purchases
	  @start_date=start_date
	  @end_date=end_date
	  @branch_id=branch_id
	  @accounts=accounts
	  @account=account
	  generate_pdf
	end

	def generate_pdf
		y_pos=cursor
		bounding_box([0, y_pos], :width=>bounds.width) do
			company_name_and_address_in_center
			report_details
		end
		purchase_settlement_details
		page_footer
	end
	def report_details
		text"<b><u>Purchase Settlement</u></b>", :align=>:center, :size=>8, :inline_format=>true
		unless @branch_id.blank?
		 text "#{@view_context.display_branch(@branch_id)}", :inline_format=>true, :align => :center, :size => 6 
		end 
		text"#{@start_date} to #{@end_date}", :align=>:center, :size=>8, :inline_format=>true
	end

	def purchase_settlement_details
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
		["Voucher", "Vendor", "Account","Due on","Settled on","Settled by",
		{:content=>"Total", :align=>:right}, {:content=>"Settled Amount", :align=>:right}]
	end

	def report_data
		data=Array.new
		@purchases.each do |purchase|
			data<<["#{purchase.purchase_number}", "#{purchase.vendor_name}", "#{purchase.settlement_account.name}","#{purchase.due_date}",
			"#{purchase.updated_at.to_date}", "#{purchase.created_by_user}",
			{:content=>"#{purchase.total_amount}", :align=>:right},
			{:content=>"#{purchase.settled_amount}", :align=>:right}]
		end
		data
	end
end
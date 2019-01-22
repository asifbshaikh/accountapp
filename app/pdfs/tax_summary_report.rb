class TaxSummaryReport < Prawn::Document
	include PdfBase
	require 'open-uri'
	include ActionView::Helpers::NumberHelper
	def initialize(view_context, company, ledgers, tax_hash, start_date, end_date)
	  super(PAGE_LAYOUT)
	  @view_context=view_context
	  @ledgers=ledgers
	  @tax_hash=tax_hash
	  @start_date=start_date
	  @end_date=end_date
	  @company=company
	  @pos_arr=[]
	  @header_pos=[]
	  send "generate_tax_report"
	end

	def generate_tax_report
		y_pos=cursor
		bounding_box([0, y_pos], :width=>bounds.width) do
			company_name_and_address_in_center
			report_details
		end
		tax_summary_details
		page_footer
	end

	def report_details
		text"<b><u>Tax Summary Report</u></b>", :align=>:center, :size=>8, :inline_format=>true
		text"Duration: #{@start_date} To #{@end_date}", :align=>:center, :size=>8, :inline_format=>true
	end

	def tax_summary_details
		data=Array.new
		data<<table_header
		data=data.concat(report_data)
		# data<<grand_total
		table(data, :header=>true, :width=>bounds.width,:row_colors => ["FFFFFF","F2F7FF"] , :cell_style =>{:border_width => 0,:border_color => "70B8FF",  :size => 8}) do
			row(0).font_style=:bold
	    row(0).borders=[:top, :bottom]
	    row(0).border_width=0.2
    end
	end

	def table_header
		["Date", "Voucher No.", "Account", {:content=>"Voucher Value(#{@company.currency_code})", :align=>:right}, "Tax Applied", {:content=>"Total Tax(#{@company.currency_code})", :align=>:right}]
	end

	def report_data
		data=Array.new
		@ledgers.each do |ledger|
			voucher_amount=ledger.voucher.total_amount
			curresponding_account = Account.find_by_id(ledger.retrieve_corresponding_account)
			data<<["#{ledger.transaction_date}", "#{ledger.voucher_number}", "#{curresponding_account.name}", {:content=>"#{number_with_precision voucher_amount, :precision=>2}", :align=>:right}, "#{ledger.account.name}", {:content=>"#{number_with_precision(tax_amount=(ledger.debit+ledger.credit), :precision=>2)}", :align=>:right}]
			@tax_hash["#{ledger.account.name}"]+=ledger.debit+ledger.credit
		end

		@tax_hash.each do |key, value|
			data<<["", "", "", "", {:content=> "#{key}", :align=>:right, :font_style=>:bold}, {:content=>"#{number_with_precision value, :precision=>2}", :align=>:right, :font_style=>:bold}] if value>0
		end
		data<<["", "", "", "", {:content=> "Total Tax :", :align=>:right, :font_style=>:bold}, {:content=>"#{number_with_precision (@ledgers.sum(:debit)+@ledgers.sum(:credit)), :precision=>2}", :align=>:right, :font_style=>:bold}]
		data
	end
end
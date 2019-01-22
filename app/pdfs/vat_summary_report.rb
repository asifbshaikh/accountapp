class VatSummaryReport < Prawn::Document
	include PdfBase
	require 'open-uri'
	include DutiesAndTaxesHelper
	include ActionView::Helpers::NumberHelper
	def initialize(view_context, company, sales_ledgers, purchase_ledgers, other_ledgers, tax_hash, start_date, end_date)
	  super(PAGE_LAYOUT)
	  @view_context=view_context
	  @sales_ledgers=sales_ledgers
	  @purchase_ledgers = purchase_ledgers
	  @other_ledgers = other_ledgers
	  @tax_hash=tax_hash
	  @start_date=start_date
	  @end_date=end_date
	  @company=company
	  @total_output_VAT = 0
	  @total_other_output_VAT = 0
	  @total_input_VAT = 0
	  @total_other_input_VAT = 0
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
		vat_summary_details
		page_footer
	end

	def report_details
		text"<b><u>VAT Summary Report</u></b>", :align=>:center, :size=>8, :inline_format=>true
		text"Duration: #{@start_date} To #{@end_date}", :align=>:center, :size=>8, :inline_format=>true
	end

	def vat_summary_details
		data=Array.new
		data<<table_header
		data=data.concat(sales_report_data)
		#data<<table_header
		data=data.concat(purchase_report_data)
		# data<<table_header
		data=data.concat(other_output_report_data)
		data=data.concat(other_input_report_data)

		data= data.concat(summary_data)
		table(data, :header=>true, :width=>bounds.width, :row_colors => ["FFFFFF","F2F7FF"] , :cell_style =>{:border_width => 0,:border_color => "70B8FF", :size => 8}) do
			row(0).font_style=:bold
	    row(0).borders=[:top, :bottom]
	    row(0).border_width=0.2
    end
	end

	def table_header
		["Date", "Voucher No.", "Account", {:content=>"Voucher Value(#{@company.currency_code})", :align=>:right},
			"Tax Applied", "VAT TIN ",
			{:content=>"Total Tax(#{@company.currency_code})", :align=>:right}]
	end

	def sales_report_data
		data=Array.new
		data <<[{content: "Output VAT", width: 100,:font_style=>:bold},"","","","","",""]
		current_tax_total = 0
		current_account = nil
		@sales_ledgers.each do |ledger|
			if(current_account.blank?)
				current_account = ledger.account
				data <<[{content: current_account.name, width: 100},"","","","","",""]
			elsif current_account!= ledger.account
				data<<["", "", "", "", {:content=> "Subtotal #{current_account.name}", :align=>:right, :font_style=>:bold, width: 150}, "", {:content=>"#{number_with_precision current_tax_total, :precision=>2}", :align=>:right, :font_style=>:bold}]
				current_account = ledger.account
				current_tax_total = 0
				data <<[{content: current_account.name, width: 100},"","","","","",""]
			end
			current_account = ledger.account
			voucher_amount=ledger.voucher.total_amount
			curresponding_account = Account.find_by_id(ledger.retrieve_corresponding_account)
			data<<["#{ledger.transaction_date}", "#{ledger.voucher_number}",
				"#{curresponding_account.name}", {:content=>"#{number_with_precision voucher_amount, :precision=>2}", :align=>:right},
				"#{ledger.account.name}", "#{curresponding_account.get_party.vat_tin unless curresponding_account.get_party.blank?}",
				{:content=>"#{number_with_precision(tax_amount=sales_vat_amount(ledger), :precision=>2)}", :align=>:right}]
			tax_amount= sales_vat_amount(ledger)
			current_tax_total+=tax_amount
			@total_output_VAT+=tax_amount
		end
		data<<["", "", "", "", {:content=> "Subtotal #{current_account.name unless current_account.blank?}", :align=>:right, :font_style=>:bold, width: 150}, "", {:content=>"#{number_with_precision current_tax_total, :precision=>2}", :align=>:right, :font_style=>:bold}]
		data<<["", "", "", "", {:content=> "Total Output VAT", :align=>:right, :font_style=>:bold}, "", {:content=>"#{number_with_precision @total_output_VAT, :precision=>2}", :align=>:right, :font_style=>:bold}]
		data
	end

	def purchase_report_data
		data=Array.new
		data <<[{content: "Input VAT", width: 100, :font_style=>:bold},"","","","","",""]
		current_tax_total = 0
		tax_on_sales=0
		tax_on_purchase=0
		current_account = nil
		@purchase_ledgers.each do |ledger|
			if(current_account.blank?)
				current_account = ledger.account
				data <<[{content: current_account.name, width: 100},"","","","","",""]
			elsif current_account!= ledger.account
				data<<["", "", "", "", {:content=> "Subtotal #{current_account.name}", :align=>:right, :font_style=>:bold, width: 150}, "", {:content=>"#{number_with_precision current_tax_total, :precision=>2}", :align=>:right, :font_style=>:bold}]
				current_account = ledger.account
				current_tax_total = 0
				data <<[{content: current_account.name, width: 100},"","","","","",""]
			end
			current_account = ledger.account
			voucher_amount=ledger.voucher.total_amount
			curresponding_account = Account.find_by_id(ledger.retrieve_corresponding_account)
			data<<["#{ledger.transaction_date}", "#{ledger.voucher_number}",
				"#{curresponding_account.name}", {:content=>"#{number_with_precision voucher_amount, :precision=>2}", :align=>:right},
				"#{ledger.account.name}", "#{curresponding_account.get_party.vat_tin unless curresponding_account.get_party.blank?}",
				{:content=>"#{number_with_precision(tax_amount=purchase_vat_amount(ledger), :precision=>2)}", :align=>:right}]
			tax_amount= purchase_vat_amount(ledger)
			current_tax_total+=tax_amount
			@total_input_VAT+=tax_amount
		end
		data<<["", "", "", "", {:content=> "Subtotal #{current_account.name unless current_account.blank?}", :align=>:right, :font_style=>:bold, width: 150}, "", {:content=>"#{number_with_precision current_tax_total, :precision=>2}", :align=>:right, :font_style=>:bold}]
		data<<["", "", "", "", {:content=> "Total Input VAT", :align=>:right, :font_style=>:bold}, "", {:content=>"#{number_with_precision @total_input_VAT, :precision=>2}", :align=>:right, :font_style=>:bold}]
		data
	end

	def other_output_report_data
		data=Array.new
		data <<[{content: "Other Output VAT", width: 100,:font_style=>:bold},"","","","","",""]
		current_tax_total = 0
		current_account = nil
		@other_ledgers.each do |ledger|
			if ledger.account.name.include? "sales"
				if(current_account.blank?)
					current_account = ledger.account
					data <<[{content: current_account.name, width: 100},"","","","","",""]
				elsif current_account!= ledger.account
					data<<["", "", "", "", {:content=> "Subtotal #{current_account.name}", :align=>:right, :font_style=>:bold, width: 150}, "", {:content=>"#{number_with_precision current_tax_total, :precision=>2}", :align=>:right, :font_style=>:bold}]
					current_account = ledger.account
					current_tax_total = 0
					data <<[{content: current_account.name, width: 100},"","","","","",""]
				end
				current_account = ledger.account
				voucher_amount=ledger.voucher.total_amount
				curresponding_account = Account.find_by_id(ledger.retrieve_corresponding_account)
				data<<["#{ledger.transaction_date}", "#{ledger.voucher_number}",
					"#{curresponding_account.name}", {:content=>"#{number_with_precision voucher_amount, :precision=>2}", :align=>:right},
					"#{ledger.account.name}", "#{curresponding_account.get_party.vat_tin unless curresponding_account.get_party.blank?}",
					{:content=>"#{number_with_precision(tax_amount=other_vat_amount(ledger, current_account.name), :precision=>2)}", :align=>:right}]
				tax_amount= other_vat_amount(ledger, current_account.name)
				current_tax_total+=tax_amount
				@total_other_output_VAT+=tax_amount
			end
		end
		data<<["", "", "", "", {:content=> "Subtotal #{current_account.name unless current_account.blank?}", :align=>:right, :font_style=>:bold, width: 150}, "", {:content=>"#{number_with_precision current_tax_total, :precision=>2}", :align=>:right, :font_style=>:bold}]
		data<<["", "", "", "", {:content=> "Total Other Output VAT", :align=>:right, :font_style=>:bold}, "", {:content=>"#{number_with_precision @total_other_output_VAT, :precision=>2}", :align=>:right, :font_style=>:bold}]
		data
	end

	def other_input_report_data
		data=Array.new
		data <<[{content: "Other Input VAT", width: 100,:font_style=>:bold},"","","","","",""]
		current_tax_total = 0
		current_account = nil
		@other_ledgers.each do |ledger|
			if ledger.account.name.include? "purchase"
				if(current_account.blank?)
					current_account = ledger.account
					data <<[{content: current_account.name, width: 100},"","","","","",""]
				elsif current_account!= ledger.account
					data<<["", "", "", "", {:content=> "Subtotal #{current_account.name}", :align=>:right, :font_style=>:bold, width: 150}, "", {:content=>"#{number_with_precision current_tax_total, :precision=>2}", :align=>:right, :font_style=>:bold}]
					current_account = ledger.account
					current_tax_total = 0
					data <<[{content: current_account.name, width: 100},"","","","","",""]
				end
				current_account = ledger.account
				voucher_amount=ledger.voucher.total_amount
				curresponding_account = Account.find_by_id(ledger.retrieve_corresponding_account)
				data<<["#{ledger.transaction_date}", "#{ledger.voucher_number}",
					"#{curresponding_account.name}", {:content=>"#{number_with_precision voucher_amount, :precision=>2}", :align=>:right},
					"#{ledger.account.name}", "#{curresponding_account.get_party.vat_tin unless curresponding_account.get_party.blank?}",
					{:content=>"#{number_with_precision(tax_amount=other_vat_amount(ledger, current_account.name), :precision=>2)}", :align=>:right}]
				tax_amount= other_vat_amount(ledger, current_account.name)
				current_tax_total+=tax_amount
				@total_other_input_VAT+=tax_amount
			end
		end
		data<<["", "", "", "", {:content=> "Subtotal #{current_account.name unless current_account.blank?}", :align=>:right, :font_style=>:bold}, "", {:content=>"#{number_with_precision current_tax_total, :precision=>2}", :align=>:right, :font_style=>:bold}]
		data<<["", "", "", "", {:content=> "Total Other Input VAT", :align=>:right, :font_style=>:bold}, "", {:content=>"#{number_with_precision @total_other_input_VAT, :precision=>2}", :align=>:right, :font_style=>:bold, :width => 50}]
		data
	end

	def summary_data
    grand_total_output_VAT = @total_output_VAT+@total_other_output_VAT
    grand_total_input_VAT = @total_input_VAT+@total_other_input_VAT
    net_payable_VAT = grand_total_output_VAT - grand_total_input_VAT

		data=Array.new
		data <<["","","",{content: "Summary", width: 100,:font_style=>:bold},"","","",]
		data<<["", "",{:content=> "Total Output VAT", :align=>:right, :font_style=>:bold}, {:content=>"#{number_with_precision grand_total_output_VAT, :precision=>2}", :align=>:right, :font_style=>:bold},"","",""]
		data<<["", "",{:content=> "Less: Total Input VAT", :align=>:right, :font_style=>:bold}, {:content=>"#{number_with_precision grand_total_input_VAT, :precision=>2}", :align=>:right, :font_style=>:bold},"","",""]
		data<<["", "",{:content=> "Difference VAT Payable", :align=>:right, :font_style=>:bold}, {:content=>"#{number_with_precision net_payable_VAT, :precision=>2}", :align=>:right, :font_style=>:bold},"","",""]
		data
	end

end

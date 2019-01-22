class ExpensePdf < Prawn::Document
	include PdfBase
	require 'open-uri'
	include ActionView::Helpers::NumberHelper
	include ApplicationHelper
	def initialize(view_context, expense)
	  super(PAGE_LAYOUT)
	  @view_context=view_context
	  @expense=expense
	  @company=@expense.company
	  @expense_line_items = @expense.expense_line_items
	  @tax_line_items = @expense.tax_line_items.group(:account_id)
	  @payment_vouchers=@expense.expenses_payments
	  @tds_amount=@payment_vouchers.sum(:tds_amount)
	  @pos_arr=[]
	  @header_pos=[]
	  send "generate_expense"
	end

	def generate_expense
		y_pos=cursor
		bounding_box([0, cursor], :width => (bounds.width/2) - 5) do 
		  company_logo
		  @header_pos<<y
		end

		bounding_box([(bounds.width/2), y_pos], :width => (bounds.width/2)) do
			company_name_and_address
			@header_pos<<y
		end
		
		bounding_box([0, (@header_pos.min.to_i-30)], :width=>bounds.width) do
			text "<b>EXPENSE</b>", :align => :center, :inline_format => true, :size => 14
			stroke_horizontal_rule
		end

		y_pos=cursor-5
		box_width=(bounds.width-20)/3
		bounding_box([0, y_pos], :width=>box_width) do
			paid_from
	  end
		@pos_arr<<y
	  bounding_box([(box_width*2)+20, y_pos], :width=>box_width) do
	  	voucher_details
	  end
  	@pos_arr<<y
  	bounding_box([0, (@pos_arr.min.to_f-50)], :width => bounds.width) do
  		voucher_line_item_and_calculation_details
  	end

  	if @expense.credit_expense?
	  	@pos_arr<<y

	  	bounding_box([0, (@pos_arr.min.to_f-50)], :width => bounds.width) do
	  		if @payment_vouchers.blank?
	  			text "Payment is due for this expense."
	  		else
	  			text "Payment Details."
	  			self.y-=5
	  			payment_details
	  		end
	  	end
	  end

  	self.y-=10
    unless @expense.customer_notes.blank?
	    span(y, :position => :left) do
	    	text "<b>Customer Notes</b>", :size=>10, :inline_format=>:true
		  	text @view_context.breaking_word_wrap(@expense.customer_notes), :inline_format=>true, :size=>8
		  end
		end
		self.y-=10
		unless @expense.tags.blank?
	    span(y, :position => :left) do
	    	text "<b>Tags</b>", :size=>10, :inline_format=>:true
		  	text @view_context.breaking_word_wrap(@expense.tags), :inline_format=>true, :size=>8
		  end
		end
		signatory
		page_footer
	end

	def payment_details
		n=@payment_vouchers.count
		data=Array.new
		data<<payment_table_header
		data=data.concat(payment_lines)
		data<<total_payment
		table(data, :header=>true, :width=>bounds.width,:row_colors => ["FFFFFF","F2F7FF"] , :cell_style =>{:border_width => 0,:border_color => "70B8FF",  :size => 8}, :column_widths => {0 => 100, 1 => 120 }) do
  		row(0).font_style=:bold
      row(0).borders=[:top, :bottom]
      row(0).border_width=0.2
  		row(n).borders=[:bottom]
      row(n).border_width=0.2
    end
	end
	def total_payment
		data=["","","",{:content => "Total", :align => :right}, {:content => "#{ format_amount(@expense.paid_amount)}", :align => :right}]
		data.insert(3, {:content => "", :align => :right}) if @tds_amount > 0
		data
	end
	def payment_table_header
		data=["Voucher Number","Voucher Date","Payment Date","Payment Mode", {:content => "Amount (#{format_amount(@expense.currency)})", :align => :right}]
		data.insert(4, {:content => "TDS (#{@expense.currency})", :align => :right}) if @tds_amount > 0
		data
	end

	def payment_lines
		data=Array.new
		@payment_vouchers.each do |payment|
			payment_voucher = payment.payment_voucher
			sub_data=["#{payment_voucher.voucher_number}","#{payment_voucher.voucher_date}","#{payment_voucher.payment_date}","#{payment_voucher.payment_detail.payment_mode}", {:content => "#{format_amount(payment.amount)}", :align => :right}]
			sub_data.insert(4, {:content => "#{format_amount(payment.tds_amount)}", :align => :right}) if @tds_amount > 0
			sub_data
			data<<sub_data
		end
		data
	end
	def voucher_line_item_and_calculation_details
		n=@expense_line_items.count
		data=Array.new
		data<<table_header
		data=data.concat(expense_lines)
		table(data, :header=>true, :width=>bounds.width,:row_colors => ["FFFFFF","F2F7FF"] , :cell_style =>{:border_width => 0,:border_color => "70B8FF",  :size => 8}, :column_widths => {0 => 100, 1 => 120 }) do
  		row(0).font_style=:bold
      row(0).borders=[:top, :bottom]
      row(0).border_width=0.2
  		row(n).borders=[:bottom]
      row(n).border_width=0.2
    end
	end

	def expense_lines
		line_items=Array.new

		@expense_line_items.each do |line_item|
			line_items<<build_line_item(line_item)
		end

		@tax_line_items.each do |line_item|
			tax_account = line_item.account
     		 next if (tax_account.accountable_type=='DutiesAndTaxesAccounts' && tax_account.accountable.calculation_method==4 && tax_account.accountable.split_tax == 0)      
			line_items<<build_tax_lines(line_item)			
		end

		line_items<<sub_total
		line_items<<total_tax
		line_items<<total_amount
		if @expense.gst_expense? && @expense.reverse_charge?
			line_items<<reverse_charge
		end
		line_items<<paid_amount
		line_items<<tds_amount if @expense.applied_tds?
		line_items<<outstanding
		line_items
	end

	def tds_amount
		data=["", {:content=>"TDS Deducted", :align=>:right}, {:content=>"#{@view_context.expense_tds_amount}", :align=>:right} ]
		unless @tax_line_items.blank?
			data.insert(1, "")
			data.insert(2, "")
		end
		data
	end
	def sub_total
		data=["", {:content=>"Sub Total", :align=>:right}, {:content=>"#{format_amount(@view_context.expense_sub_total)}", :align=>:right} ]
		unless @tax_line_items.blank?
			data.insert(1, "")
			data.insert(2, "")
		end
		data
	end

	def total_tax
		data=["", {:content=>"Tax", :align=>:right}, {:content=>"#{format_amount(@view_context.total_tax_amount)}", :align=>:right} ]
		unless @tax_line_items.blank?
			data.insert(1, "")
			data.insert(2, "")
		end
		data
	end

	def total_amount
		data=["", {:content=>"Total", :align=>:right}, {:content=>"#{@view_context.format_amount @expense.total_amount}", :align=>:right} ]
		unless @tax_line_items.blank?
			data.insert(1, "")
			data.insert(2, "")
		end
		data
	end

	def reverse_charge
		data=["", {:content=>"Reverse charge", :align=>:right}, {:content=>"#{format_amount(@view_context.total_tax_amount)}", :align=>:right} ]
		unless @tax_line_items.blank?
			data.insert(1, "")
			data.insert(2, "")
		end
		data
	end


	def paid_amount
		data=["", {:content=>"Payment Made", :align=>:right}, {:content=>"#{format_amount(@view_context.expense_paid_amount) }", :align=>:right} ]
		unless @tax_line_items.blank?
			data.insert(1, "")
			data.insert(2, "")
		end
		data
	end

	def outstanding
		data=["", {:content=>"Outstanding", :align=>:right}, {:content=>"#{format_amount(@view_context.expense_outstanding)}", :align=>:right} ]
		unless @tax_line_items.blank?
			data.insert(1, "")
			data.insert(2, "")
		end
		data
	end

	def build_line_item(line_item)
		data=[{:content=>"#{line_item.account.name}", :align=>:left}, {:content=>"#{line_item.description}", :align=>:left},
			{:content=>"#{format_amount(line_item.amount)}", :align=>:right} ]
		unless @tax_line_items.blank?
			data.insert(2, {:content=>"#{format_amount(@view_context.applied_taxes_on_expense(line_item))}"})
			data.insert(3, {:content=>"#{format_amount(line_item.tax_amount)}", :align=>:right})
		end
		data
	end

	def build_tax_lines(line_item)
		data=["", {:content=>"#{line_item.account.name}", :align=>:right},
			{:content=>"#{format_amount(@expense.group_tax_amt(line_item.account_id))}", :align=>:right} ]
		unless @tax_line_items.blank?
			data.insert(1, "")
			data.insert(2, "")
		end
		data
	end

	def table_header
		data=[{:content=>'Expense', :align=>:left}, {:content=>'Description', :align=>:left},
			{:content=>"Amount(#{format_amount(@expense.currency)})", :align=>:right} ]
		unless @tax_line_items.blank?
			data.insert(2, {:content=>"Tax Rate"})
			data.insert(3, {:content=>"Tax Amount", :align=>:right})
		end
		data
	end

	def voucher_details
		data=[[{:content =>"Under project:", :font_style => :bold, :align => :left}, {:content =>"#{@expense.project_name}"}]]
		data<<[{:content =>"Expense #:", :font_style => :bold, :align => :left}, {:content =>"#{@expense.voucher_number}"}]
		data<<[{:content =>"Expense on:", :font_style => :bold, :align => :left}, {:content =>"#{@expense.expense_date}"}]
		data<<[{:content =>"Due date:", :font_style => :bold, :align => :left}, {:content =>"#{@expense.due_date}"}]
		data<<[{:content =>"Amount:", :font_style => :bold, :align => :left}, {:content =>"#{@expense.currency} #{format_amount(@expense.total_amount)}"}]
		table(data, :width=>bounds.width, :row_colors => ["F2F7FF"], :cell_style =>{:align => :left, :border_width => 0, :size => 9})do
		end
	end

	def paid_from
		table([
	     [ @expense.credit_expense? ? "<b>Vendor</b>" : "<b>Paid From</b>"] ,
	     [ "<b>#{@expense.account.name unless @expense.account.blank?}</b>"],
	    ], :width => bounds.width, :cell_style =>{:border_width => 0,:align => :left, :inline_format => true, :size => 9, :border_color => "70B8FF" })do
			
			row(0).borders = [:left, :right, :bottom, :top]
			row(0).background_color = 'F2F7FF'
			row(1).borders = [:left, :right, :bottom]
			row(0..2).border_width = 0.1
	  end
	end
end
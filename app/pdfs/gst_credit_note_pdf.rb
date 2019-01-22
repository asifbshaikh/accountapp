class GstCreditNotePdf < Prawn::Document
	include PdfBase
	include ApplicationHelper
	require 'open-uri'
	def initialize(view_context, gst_credit_note, company)
		super(PAGE_LAYOUT)
		@gst_credit_note=gst_credit_note
		@gst_credit_note_line_items=gst_credit_note.gst_credit_note_line_items
		@tax_line_items = gst_credit_note.tax_line_items
		@company=company
		@party = gst_credit_note.to_account.customer
		@pos_arr=[]
		@column=0
		generate_pdf
	end

	def generate_pdf
		y_pos=cursor
		bounding_box([0, cursor], :width => (bounds.width/2) - 5) do
		  company_logo
		end

		bounding_box([(bounds.width/2), y_pos], :width => (bounds.width/2)) do
			company_name_and_address
		end

		self.y+5
		text "<b>GST CREDIT NOTE</b>", :align => :center, :inline_format => true, :size => 14
		stroke_horizontal_rule

		y_pos=cursor-5
		box_width=(bounds.width-20)/3
		bounding_box([0, y_pos], :width=>box_width) do
			customer_details
	  end
		@pos_arr<<y

	  bounding_box([(box_width*2)+20, y_pos], :width=>box_width) do
	  	voucher_details
	  end
  	@pos_arr<<y

  	bounding_box([0, (@pos_arr.min.to_f-50)], :width => bounds.width) do
  		voucher_line_item_and_calculation_details
  	end


  	page_footer
	end

	def voucher_details
		data=[[{:content =>"GST credit note :", :font_style => :bold, :align => :left}, {:content =>"#{@gst_credit_note.gst_credit_note_number}"}]]
		data<<[{:content =>"Invoice return#:", :font_style => :bold, :align => :left}, {:content =>"#{@gst_credit_note.invoice_return.invoice_return_number}"}]
		data<<[{:content =>"Amount", :font_style => :bold, :align => :left}, {:content =>"#{@gst_credit_note.currency} #{format_amount(@gst_credit_note.total_amount)}"}]
		table(data, :width=>bounds.width, :row_colors => ["F2F7FF"], :cell_style =>{:align => :left, :border_width => 0, :size => 9})do
		end
	end

	def voucher_line_item_and_calculation_details
		n=@gst_credit_note_line_items.count
		data=Array.new
		data<<table_header
		data=data.concat(return_lines)
		data=data.concat(calculation_lines)
		table(data, :header=>true, :width=>bounds.width,:row_colors => ["FFFFFF","F2F7FF"] , :cell_style =>{:border_width => 0,:border_color => "70B8FF",  :size => 8}, :column_widths => {0 => 100, 1 => 120 }) do
  		row(0).font_style=:bold
      row(0).borders=[:top, :bottom]
      row(0).border_width=0.2
  		row(n).borders=[:bottom]
      row(n).border_width=0.2
    end
	end

	def calculation_lines
		data=Array.new
		data<<["", "", "", {:content=>"Sub total", :align=>:right}, {:content=>gst_credit_note_sub_total, :align=>:right}]
		data<<["", "", "", {:content=>"Discount", :align=>:right}, {:content=>gst_credit_note_discount, :align=>:right}]
		data<<["", "", "", {:content=>"Tax", :align=>:right}, {:content=>gst_credit_note_tax_amount, :align=>:right}]
		data<<["", "", "", {:content=>"Total", :align=>:right}, {:content=>"#{format_amount @gst_credit_note.total_amount}", :align=>:right}]
		data
	end

	def return_lines
		line_items=Array.new

		@gst_credit_note_line_items.each do |line_item|
			line_items<<build_line_item(line_item)
		end

		@tax_line_items.each do |line_item|
			line_items<<build_tax_lines(line_item)
		end
		line_items
	end

	def build_tax_lines(line_item)
		["","","", {:content=>line_item.account.name, :align=>:right},
			{:content=>"#{number_with_precision @gst_credit_note.group_tax_amt(line_item.account_id), :precision=>2}", :align=>:right} ]
	end

	def build_line_item(line_item)
		[{:content=>line_item.product.name, :align=>:left},{:content=>"#{number_with_precision line_item.quantity, :precision=>2} #{line_item.product.unit_of_measure}", :align=>:right},
			{:content=>"#{number_with_precision line_item.unit_rate, :precision=>(line_item.unit_rate==line_item.unit_rate.round(2)? 2 : 4)}", :align=>:right}, {:content=>"#{number_with_precision line_item.discount_percent, :precision=>2}", :align=>:right},
			{:content=>"#{format_amount line_item.amount}", :align=>:right} ]
	end

	def table_header
		[{:content=>'Item', :align=>:left},{:content=>'Qantity', :align=>:right},
			{:content=>'Unit Cost', :align=>:right}, {:content=>"Discount(%)", :align=>:right},
			{:content=>"Amount(#{@gst_credit_note.currency})", :align=>:right} ]
	end

	def gst_credit_note_sub_total
		"#{number_with_precision @gst_credit_note.gst_credit_note_line_items.sum(:amount), :precision=>2 }"
	end

	def gst_credit_note_discount
		"#{number_with_precision @gst_credit_note.discount, :precision=>2}"
	end

	def gst_credit_note_tax_amount
		"#{number_with_precision @gst_credit_note.tax_line_items.sum(:amount), :precision=>2}"
	end
end
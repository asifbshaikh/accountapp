class GstDebitNotePdf < Prawn::Document
	require 'open-uri'
	include PdfBase
	include ApplicationHelper
	def initialize(gst_debit_note)
		super(:page_layout=>:portrait, :paper_size=>"A4", :top_margin=>10, :left_margin=>10, :right_margin=>20)
		@gst_debit_note=gst_debit_note
		@company=gst_debit_note.company
		@party=gst_debit_note.customer
		@pos_arr=Array.new
		@columns=0
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
		text "<b>GST DEBIT NOTE</b>", :align => :center, :inline_format => true, :size => 14
		stroke_horizontal_rule

		y_pos=cursor-5
		box_width=(bounds.width-20)/3
		bounding_box([0, y_pos], :width=>box_width) do
			vendor_details
	  end
		@pos_arr<<y

	  bounding_box([(box_width*2)+20, y_pos], :width=>box_width) do
	  	voucher_details
	  end
  	@pos_arr<<y

	  bounding_box([0, (@pos_arr.min.to_f-50)], :width => bounds.width) do
	  	voucher_line_item_and_calculation_details
	  end

	  # bounding_box([0, bounds.width], :width => bounds.width) do
	  # 	text @gst_debit_note.customer_notes, :align=>:center, :inline_format=>true, :size=>8
	  # end

	  page_footer
	end

	def voucher_details
		data=[[{:content =>"Gst Debit Note#:", :font_style => :bold, :align => :left}, {:content =>"#{@gst_debit_note.gst_debit_note_number}"}]]
		data<<[{:content =>"Purchase Return #:", :font_style => :bold, :align => :left}, {:content =>"#{@gst_debit_note.purchase_return.purchase_return_number}"}]
		data<<[{:content =>"Amount", :font_style => :bold, :align => :left}, {:content =>"#{@gst_debit_note.currency} #{format_amount @gst_debit_note.total_amount}"}]
		table(data, :width=>bounds.width, :row_colors => ["F2F7FF"], :cell_style =>{:align => :left, :border_width => 0, :size => 9})do
		end
	end

	def voucher_line_item_and_calculation_details
		n=@gst_debit_note.gst_debit_note_line_items.count
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
		data<<["", "", "", {:content=>"Sub total", :align=>:right}, {:content=>gst_debit_note_sub_total, :align=>:right}]
		data<<["", "", "", {:content=>"Discount", :align=>:right}, {:content=>gst_debit_note_discount, :align=>:right}]
		data<<["", "", "", {:content=>"Tax", :align=>:right}, {:content=>gst_debit_note_tax_amount, :align=>:right}]
		data<<["", "", "", {:content=>"Total", :align=>:right}, {:content=>"#{@gst_debit_note.total_amount}", :align=>:right}]
		data
	end

	def return_lines
		line_items=Array.new

		@gst_debit_note.gst_debit_note_line_items.each do |line_item|
			line_items<<build_line_item(line_item)
		end

		@gst_debit_note.tax_line_items.each do |line_item|
			line_items<<build_tax_lines(line_item)			
		end
		line_items
	end

	def build_tax_lines(line_item)
		["","","", {:content=>line_item.account.name, :align=>:right},
			{:content=>"#{@gst_debit_note.group_tax_amt(line_item.account_id)}", :align=>:right} ]
	end

	def build_line_item(line_item)
		[{:content=>line_item.product.name, :align=>:left},{:content=>"#{line_item.quantity} #{line_item.product.unit_of_measure}", :align=>:right},
			{:content=>"#{line_item.unit_rate.round(2)}", :align=>:right}, {:content=>"#{line_item.discount_percent}", :align=>:right},
			{:content=>"#{line_item.amount.round(2)}", :align=>:right} ]
	end

	def table_header
		[{:content=>'Item', :align=>:left},{:content=>'Qantity', :align=>:right},
			{:content=>'Unit Cost', :align=>:right}, {:content=>"Discount(%)", :align=>:right},
			{:content=>"Amount(#{@gst_debit_note.currency})", :align=>:right} ]
	end

	def gst_debit_note_sub_total
		"#{@gst_debit_note.gst_debit_note_line_items.sum(:amount)}"
	end

	def gst_debit_note_discount
		"#{@gst_debit_note.discount}"
	end

	def gst_debit_note_tax_amount
		"#{@gst_debit_note.tax_line_items.sum(:amount)}"
	end
end
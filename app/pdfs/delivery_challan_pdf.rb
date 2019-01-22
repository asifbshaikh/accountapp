class DeliveryChallanPdf < Prawn::Document
	include PdfBase
	require 'open-uri'
	include ActionView::Helpers::NumberHelper
	def initialize(view_context, company, delivery_challan)
	  super(PAGE_LAYOUT)
	  @view_context=view_context
	  @company=company
	  @delivery_challan=delivery_challan
	  @created_by_user = @company.users.find_by_id(@delivery_challan.created_by)
	  @pos_arr=[]
	  @header_pos=[]
	  send "generate_challan"
	end

	def generate_challan
		y_pos=cursor
		bounding_box([0, y_pos], :width => (bounds.width/2) - 5) do
			company_logo
			@header_pos<<y
		end

		bounding_box([(bounds.width/2), y_pos], :width => (bounds.width/2)) do
      text "<b>DELIVERY CHALLAN</b>", :align=>:right, :inline_format => true, :size => 14
			@header_pos<<y
		end

		box_width=(bounds.width-20)/3
		bounding_box([0, @header_pos.min.to_i-40], :width=>(box_width)) do
			stroke_horizontal_rule
			self.y=y-2
		  table(challan_info, :width=>(box_width), :row_colors=>["ffffff"], :cell_style=>{:align=>:left, :border_width=>0, :size=>8})do
      end
      @pos_arr<<y
		end
		bounding_box([(box_width+10), @header_pos.min.to_i-40], :width=>(box_width)) do
		  stroke_horizontal_rule
			self.y=y-2
		  table(branch_address, :width=>(box_width), :row_colors=>["ffffff"], :cell_style=>{:align=>:left, :border_width=>0, :size=>8})do
      end
      @pos_arr<<y
		end

		bounding_box([(2*box_width)+20, @header_pos.min.to_i-40], :width=>(box_width)) do
		  stroke_horizontal_rule
			self.y=y-2
		  table(bill_to, :width=>(box_width), :row_colors=>["ffffff"], :cell_style=>{:align=>:left, :border_width=>0, :size=>8})do
      end
      @pos_arr<<y
		end

		challan_rows

		delivery_terms_and_conditions
		delivery_customer_notes

		signatory

		page_footer
	end

	def challan_info
		challan_info=[]
		challan_info<<[{:content=>"Delivery Challan #:", :font_style=>:bold, :align=>:left}, {:content=>"#{@delivery_challan.voucher_number}"}]
		challan_info<<[{:content=>"Challan date:", :font_style=>:bold, :align=>:left}, {:content=>"#{@delivery_challan.voucher_date}"}]
		challan_info<<[{:content=>"PO Ref#:", :font_style=>:bold, :align=>:left}, {:content=>"#{@delivery_challan.sales_order.po_reference}"}] unless @delivery_challan.sales_order.po_reference.blank?
		challan_info<<[{:content=>"PO Date:", :font_style=>:bold, :align=>:left}, {:content=>"#{@delivery_challan.sales_order.po_date}"}] unless @delivery_challan.sales_order.po_date.blank?
		challan_info<<[{:content=>"Created by:", :font_style=>:bold, :align=>:left}, {:content=>"#{@delivery_challan.created_by_user}"}]
		challan_info
	end

	def branch_address
		address=Array.new
		address<<[{:content=>"From:", :font_style=>:bold}]
		address<<[{:content=>"#{@company.name}", :font_style=> :bold}]
		if !@created_by_user.branch.blank?
			address<<[{:content=> "#{@created_by_user.branch.address.get_address}"}]  unless @created_by_user.branch.address.blank?
			address<<[{:content=> "Phone: #{@created_by_user.branch.phone}"}] unless @created_by_user.branch.phone.blank?
		else
			address<<[{:content=> "#{@company.address.get_address}"}] unless @company.address.blank?
			address<<[{:content=> "Phone: #{@company.phone}"}] unless @company.phone.blank?
		end
		address
	end

	def bill_to
		address=Array.new
		customer=@delivery_challan.customer
		address<<[{:content=>"Shipping Address:", :font_style=>:bold}]
		address<<[{:content=>"#{@delivery_challan.customer_name }", :font_style=> :bold}]
		if !customer.shipping_address.blank?
			address<<[{:content=> "#{customer.shipping_address.get_address}"}]
		end
    if !customer.email.blank?
			address<<[{:content =>"Email: #{customer.email unless customer.blank?}", :align => :left}]
		end
		if !customer.primary_phone_number.blank?
		 address<<[{:content =>"Contact: #{customer.primary_phone_number unless customer.blank?}", :align => :left}]
		end
		address
	end

	def challan_rows
		lines=Array.new
		n=@delivery_challan.delivery_challan_line_items.count
		lines<<header
		lines=lines.concat(delivery_challan_lines)
		self.y=@pos_arr.min.to_i-5
		span(bounds.width, :position=>:left) do
			table(lines, :header=>true, :width=>bounds.width,:row_colors => ["FFFFFF"] , :cell_style =>{:border_width => 0,:border_color => "70B8FF",  :size => 8}, :column_widths => {0 => 100, 1 => 150 }) do
	      row(0).font_style = :bold
	      row(0).background_color = 'F2F7FF'
	      row(0).borders = [:top,:bottom]
	      row(0).border_width = 0.2
		    row(n).borders = [:bottom]
		    row(n).border_width = 0.2
	    end
	  end
	end

	def delivery_challan_lines
		lines=Array.new
		@delivery_challan.delivery_challan_line_items.each do |line_item|
			description = "#{line_item.description}"
			description+=", Batch numbers: #{line_item.product_batch.batch_number}" if line_item.product.batch_enable?
			lines<<[{:content =>"#{line_item.item_name}"},
	            {:content => "#{description}"},
	            {:content => "#{line_item.sales_order_line_item.quantity} #{line_item.product.unit_of_measure}",:align =>:right},
	            {:content =>"#{line_item.quantity} #{line_item.product.unit_of_measure}",:align => :right}
	            ]
		end
		lines<<["", "", {:content => "Total",:align =>:right, :font_style=>:bold},
            {:content =>"#{@delivery_challan.total_quantity}",:align => :right, :font_style=>:bold}
            ]
		lines
	end

	def header
		[{:content => "#{!@company.invoice_setting.item_label.blank? ? @company.invoice_setting.item_label : 'Item'}"},
     {:content => "#{!@company.invoice_setting.desc_label.blank? ? @company.invoice_setting.desc_label : 'Description'}"},
     {:content => "#{'Qty in SO'}",:align => :right},
     {:content => "#{'Qty Delivered'}",:align => :right}
     ]
	end

	#Added this method show delivery terms and condition in PDF
	#Author: Ashish Wadekar
	#Date: 4th January 2017
	def delivery_terms_and_conditions
	  go_to_page(page_count)
	  if @delivery_challan.terms_and_conditions.present?
	  	draw_text "Terms & Conditions", :at=>[0, cursor-525], :size => 9, :style => :bold
	   	bounding_box([0, cursor-530], :width => 250) do
				text "#{@delivery_challan.terms_and_conditions}", :size => 7, :inline_format=> true
	   	end 
		end
	end

	#Added this method show delivery terms and condition in PDF
	#Author: Naveen Thota
	#Date: 22-Jan-2017
	def delivery_customer_notes
	  go_to_page(page_count)
	  if @delivery_challan.terms_and_conditions.present?
	  	draw_text "Customer notes", :at=>[350, cursor-525], :size => 9, :style => :bold
	   	bounding_box([350, cursor-530], :width => 250) do
				text "#{@delivery_challan.customer_notes}", :size => 7, :inline_format=> true
	   	end 
		end
	end

end

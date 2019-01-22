class ReimbursementNotePdf < Prawn::Document
	include PdfBase
	require 'open-uri'
	include ActionView::Helpers::NumberHelper
	include ApplicationHelper
	def initialize(view_context, reimbursement_note)
	  super(PAGE_LAYOUT)
	  @view_context=view_context
	  @reimbursement_note=reimbursement_note
	  @company = @reimbursement_note.company
	  @reimbursement_note_line_items = @reimbursement_note.reimbursement_note_line_items
		@payment_vouchers = @company.reimbursement_vouchers.find(@reimbursement_note.reimbursement_voucher_id) unless @reimbursement_note.reimbursement_voucher_id.blank?
	  @pos_arr=[]
	  @header_pos=[]
	  send "generate_reimbursement_note"
	end

	def generate_reimbursement_note
		y_pos=cursor
		bounding_box([0, cursor-10], :width => (bounds.width/2) - 5) do
		  company_logo
		  @header_pos<<y
		end

		bounding_box([(bounds.width/1.5), y_pos], :width => (bounds.width/3)) do
			company_name_and_address
			@header_pos<<y
		end

		y_pos=cursor-10
		bounding_box([0, (@header_pos.min.to_i-40)], :width=>bounds.width) do
			text "<b>REIMBURSEMENT VOUCHER</b>", :align => :center, :inline_format => true, :size => 14
			stroke_horizontal_rule
		end

		y_pos=cursor-10
		box_width=(bounds.width-20)/3
		bounding_box([0, y_pos], :width=>box_width) do
			customer_details
	  end

		@pos_arr<<y
	  bounding_box([(box_width*2)+20, y_pos], :width=>box_width) do
	  	voucher_details
	  end

		box_width=(bounds.width)

		@pos_arr<<y
  	bounding_box([0, (@pos_arr.min.to_f-50)], :width => box_width) do
  		reimbursement_note_lines
  	end

		@pos_arr<<y
	  bounding_box([0, (@pos_arr.min.to_f-50)], :width=> box_width) do
	  	voucher_line_item_and_calculation_details
	  end

		if @payment_vouchers.present?
			@pos_arr<<y
			bounding_box([0, (@pos_arr.min.to_f-50)], :width => bounds.width) do
				text "Payment Details"
				self.y-=5
				payment_details
			end
		end

  	self.y-=10

		signatory
		page_footer
	end

	def reimbursement_note_lines
		line_items=Array.new

		@reimbursement_note_line_items.each do |line_item|
			line_items<<build_line_item(line_item)
		end
		line_items<<total_amount
		line_items
	end

	def voucher_line_item_and_calculation_details
		n=@reimbursement_note_line_items.count
		data=Array.new
		data<<table_header
		data=data.concat(reimbursement_note_lines)
		table(data, :header=>true, :width => bounds.width,:row_colors => ["FFFFFF","F2F7FF"] , :cell_style =>{:border_width => 0,:border_color => "70B8FF", :inline_format => true, :size => 9}, :column_widths => {0 => 150, 1 => 100}) do
  		row(0).font_style=:bold
      row(0).borders=[:top, :bottom]
      row(0).border_width=0.2
  		row(n).borders=[:bottom]
      row(n).border_width=0.2
    end
	end

	def total_amount
		data=["", {:content=>"", :align=>:right}, {:content=>"<b>Grand Total</b>            #{@view_context.format_amount @reimbursement_note.total_amount}", :align=>:right} ] #Kindly mind the whitespace after Grand Total
		data
	end

	def build_line_item(line_item)
		data=[{:content=>"#{Account.find(line_item.expense_account_id).name}", :align=>:left}, {:content=>"#{line_item.description}", :align=>:left},
			{:content=>"#{format_amount line_item.amount}", :align=>:right} ]
		data
	end

	def table_header
		data=[{:content=>'Expense', :align=>:left}, {:content=>'Description', :align=>:left},
			{:content=>"Amount(#{@company.currency_code})", :align=>:right} ]
		data
	end

	def voucher_details
		data=[[{:content =>"Voucher #:", :font_style => :bold, :align => :left}, {:content =>"#{@reimbursement_note.reimbursement_note_number}"}]]
		data<<[{:content =>"Date:", :font_style => :bold, :align => :left}, {:content =>"#{@reimbursement_note.transaction_date}"}]
		data<<[{:content =>"Amount(#{@company.currency_code}):", :font_style => :bold, :align => :left}, {:content =>"#{format_amount(@reimbursement_note.total_amount)}"}]
		table(data, :width=>bounds.width, :row_colors => ["F2F7FF"], :cell_style =>{:align => :left, :border_width => 0, :size => 9})do
		end
	end

	def customer_details
		account = @reimbursement_note.from_account_id
		entity = @company.accounts.find(@reimbursement_note.from_account_id).customer.blank? ? @company.accounts.find(@reimbursement_note.from_account_id).vendor : @company.accounts.find(@reimbursement_note.from_account_id).customer
		if entity.billing_address.present?
			entity_address = entity.billing_address.address_line1 unless entity.blank?
			entity_city = entity.billing_address.city unless entity.blank?
			entity_state = entity.billing_address.state unless entity.blank?
			entity_country = entity.billing_address.country unless entity.blank?
			entity_pincode = entity.billing_address.postal_code.present? ? " - #{entity.billing_address.postal_code}" : ""  unless entity.blank?
		end
		data = [["<b>Customer</b>"]]
		data << ["<b>#{entity.name}</b>"]
		data << ["#{entity_address}"] unless entity_address.blank?
		data << ["#{entity_city}"] unless entity_city.blank?
		data << ["#{entity_state}"] unless entity_state.blank?
		data << ["#{entity_country}#{entity_pincode}"] unless entity_country.blank?
		table(data, :width => bounds.width, :cell_style =>{:padding => 2, :border_width => 0,:align => :left, :inline_format => true, :size => 9})
	end

	def payment_details
		n=@payment_vouchers.reimbursement_voucher_line_items.count
		data=Array.new
		data<<payment_table_header
		data=data.concat(payment_lines)
		data<<total_payment
		table(data, :header=>true, :width=>bounds.width,:row_colors => ["FFFFFF","F2F7FF"] , :cell_style =>{:border_width => 0,:border_color => "70B8FF", :inline_format => true, :size => 9}, :column_widths => {0 => 100, 1 => 120 }) do
  		row(0).font_style=:bold
      row(0).borders=[:top, :bottom]
      row(0).border_width=0.2
  		row(n).borders=[:bottom]
      row(n).border_width=0.2
    end
	end
	def total_payment
		data=["",{:content => "", :align => :right},"","", {:content => "<b>Total</b>            #{format_amount @payment_vouchers.amount}", :align => :right}] #Kindly mind the whitespace after Total
		data
	end
	def payment_table_header
		data=["Voucher Number","Voucher Date","Payment Date","Payment Mode", {:content => "Amount(#{@company.currency_code})", :align => :right}]
		data
	end

	def payment_lines
		data=Array.new
			payment_voucher = @payment_vouchers
			sub_data=["#{payment_voucher.voucher_number}","#{payment_voucher.voucher_date}","#{payment_voucher.received_date}","#{payment_voucher.payment_detail.payment_mode}", {:content => "#{format_amount(payment_voucher.amount)}", :align => :right}]
			data<<sub_data
		data
	end
end
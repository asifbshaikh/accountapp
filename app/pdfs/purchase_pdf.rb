class PurchasePdf < Prawn::Document
	include PdfBase
	include ApplicationHelper
	include ActionView::Helpers::NumberHelper
	def initialize(view_context, purchase)
		super(PAGE_LAYOUT)
		@purchase=purchase
		@payment_vouchers = @purchase.purchases_payments
		@purchase_line_items = @purchase.purchase_line_items
		@tax_line_items = @purchase.tax_line_items.group(:account_id)
		@other_charge_line_items = @purchase.other_charge_line_items
		@pos_arr=[]
		@header_pos=[]
		@customer = @purchase.account.customer.blank? ? @purchase.account.vendor : @purchase.account.customer
		@company=purchase.company
		@discount=@purchase.discount
		@tds_amount = @purchase.tds_amt
		@party=purchase.vendor
		@custom_field = CustomField.find_by_company_id_and_voucher_type_and_status(@company.id, "Purchase", true)
		@gst_debit_note = @purchase.gst_debit_note
		generate_pdf
	end

	def generate_pdf
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
			text "<b>PURCHASE</b>", :align => :center, :inline_format => true, :size => 14
			stroke_horizontal_rule
		end

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
  	@pos_arr<<y

  	bounding_box([0, (@pos_arr.min.to_f-50)], :width => bounds.width) do
  		if @payment_vouchers.blank?
  			text "Payment is due for this purchase."
  		else
  			text "Payment Details."
  			self.y-=5
  			payment_details
  		end
  	end
  	self.y-=10

    unless @purchase.customer_notes.blank?
	    span(y, :position => :left) do
	    	text "<b>Customer Notes</b>", :size=>10, :inline_format=>:true
		  	text @purchase.customer_notes, :inline_format=>true, :size=>8
		  end
		end

  	self.y-=10
		unless @purchase.terms_and_conditions.blank?
	    span(y, :position => :left) do
	    	text "<b>Terms and Conditions</b>", :size=>10, :inline_format=>:true
		  	text @purchase.terms_and_conditions, :inline_format=>true, :size=>8
		  end
		end
		company_tax_info
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
		data=["","","",{:content => "Total", :align => :right}, {:content => "#{format_amount(@purchase.payment_maid)}", :align => :right}]
		data.insert(3, {:content => "", :align => :right}) if @tds_amount > 0
		data
	end
	def payment_table_header
		data=["Voucher Number","Voucher Date","Payment Date","Payment Mode", {:content => "Amount (#{format_amount(@purchase.currency)})", :align => :right}]
		data.insert(4, {:content => "TDS (#{@purchase.currency})", :align => :right}) if @tds_amount > 0
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
		n=@purchase_line_items.count
		data=Array.new
		data<<table_header
		data=data.concat(purchase_lines)
		table(data, :header=>true, :width=>bounds.width,:row_colors => ["FFFFFF","F2F7FF"] , :cell_style =>{:border_width => 0,:border_color => "70B8FF",  :size => 8}, :column_widths => {0 => 100, 1 => 120 }) do
  		row(0).font_style=:bold
      row(0).borders=[:top, :bottom]
      row(0).border_width=0.2
  		row(n).borders=[:bottom]
      row(n).border_width=0.2
    end
	end

	def purchase_lines
		line_items=Array.new

		@purchase_line_items.each do |line_item|
			line_items<<build_line_item(line_item)
		end

		line_items<<total_quantity

		@tax_line_items.each do |line_item|
			tax_account = line_item.account
     		 next if (tax_account.accountable_type=='DutiesAndTaxesAccounts' && tax_account.accountable.calculation_method==4 && tax_account.accountable.split_tax == 0)      
			line_items<<build_tax_lines(line_item)
		end

		line_items<<sub_total
		line_items<<total_tax

		@other_charge_line_items.each do |line_item|
			line_items<<build_other_charge_lines(line_item)
		end

		line_items<<total_discount unless @discount==0
		line_items<<total_calculation
		if @purchase.gst_purchase? && @purchase.reverse_charge?
			line_items<<reverse_charge
		end
		line_items<<payment_made
		line_items<<return_voucher_amount if @purchase.has_return_any?
		line_items<<allocated_debit if @purchase.has_debit_allocation_any?
		line_items<<total_tds_amount if @purchase.purchases_payments.sum(:tds_amount)>0
		line_items<<outstanding if @purchase.outstanding>0
		line_items<<gain_or_loss if @purchase.status_id == 1 && @purchase.foreign_currency?

		line_items
	end

	def gain_or_loss
		data=["","","",{:content => "#{(@purchase.gain_or_loss > 0) ? 'Gain' : 'Loss'}", :font_style => :bold, :align => :right},{:content => "#{format_amount(@purchase.gain_or_loss)}", :font_style => :bold, :align => :right}]
		data.insert(3, "") unless @discount==0
		data
	end
	def outstanding
		data=["","","",{:content => "Balance Due", :font_style => :bold, :align => :right},{:content => "#{number_with_precision (@purchase.outstanding), :precision=>2}", :font_style => :bold, :align => :right}]
		data.insert(3, "") unless @discount==0
		data
	end
	def total_tds_amount
		data=["","","",{:content => "TDS Deducted", :font_style => :bold, :align => :right},{:content => "#{format_amount(@purchase.tds_amt)}", :font_style => :bold, :align => :right}]
		data.insert(3, "") unless @discount==0
		data
	end
	def allocated_debit
		data=["","","",{:content => "Debit Note Amount", :font_style => :bold, :align => :right},{:content => "#{format_amount(@purchase.allocated_debit)}", :font_style => :bold, :align => :right}]
		data.insert(3, "") unless @discount==0
		data
	end

	def return_voucher_amount
		data=["","","",{:content => "Return voucher amount", :font_style => :bold, :align => :right},{:content => "#{format_amount(@purchase.debit_note_amount)}", :font_style => :bold, :align => :right}]
		data.insert(3, "") unless @discount==0
		data
	end

	def payment_made
		data=["","","",{:content => "Payment Made", :font_style => :bold, :align => :right},{:content => "#{number_with_precision (@purchase.payment_maid), :precision=>2}", :font_style => :bold, :align => :right}]
		data.insert(3, "") unless @discount==0
		data
	end

	def total_calculation
		data=["","","",{:content => "Total", :font_style => :bold, :align => :right},{:content => "#{number_with_precision (@purchase.total_amount), :precision=>2}", :font_style => :bold, :align => :right}]
		data.insert(3, "") unless @discount==0
		data
	end

	def reverse_charge
		data=["","","",{:content => "Reverse charge" , :font_style => :bold, :align => :right},{:content => "#{format_amount(@purchase.tax)}", :font_style => :bold, :align => :right}]
  		data.insert(3, "") unless @discount==0
		data
	end

	def total_discount
		["","","","",{:content => "Discount", :font_style => :bold, :align => :right},{:content => "#{format_amount(@discount)}", :font_style => :bold, :align => :right}]
	end

	def total_tax
   		data=["","","",{:content => @purchase.tax_inclusive? ? "Tax Inclusive" : "Tax Exclusive" , :font_style => :bold, :align => :right},{:content => "#{number_with_precision @purchase.tax, :precision=>2}", :font_style => :bold, :align => :right}]
  		data.insert(3, "") unless @discount==0
		data
  	end

	def sub_total
		data=["","","",{:content => "Sub Total", :font_style => :bold, :align => :right},{:content => "#{number_with_precision (@purchase.sub_total), :precision=>2}", :font_style => :bold, :align => :right}]
		data.insert(3, "") unless @discount==0
		data
	end
	def company_tax_info
		if !@company.pan.blank? || !@company.tin.blank? || !@company.VAT_no.blank? || !@company.CST_no.blank? || !@company.service_tax_reg_no.blank? || !@company.GSTIN.blank?
		  self.y=self.y
		  span(bounds.width-10, :position=>:center,:align=>:top) do
		    text "<b>Tax Details: </b>", :size=> 8, :inline_format => true
		    data=Array.new
		    if !@company.GSTIN.blank?
         	 data<<[{:content=>"GSTIN", :font_style=>:bold}, ": #{@company.GSTIN}"]
        	end
		    if !@company.VAT_no.blank?
		    data<<[{:content=>"VAT", :font_style=>:bold}, ": #{@company.VAT_no}"]
			end
		    if !@company.pan.blank?
		      data<<[{:content=>"PAN", :font_style=>:bold}, ": #{@company.pan}"]
		    end
		    if !@company.tin.blank?
		      data<<[{:content=>"TIN", :font_style=>:bold}, ": #{@company.tin}"]
		    end
		    if !@company.CST_no.blank?
		      data<<[{:content=>"CST", :font_style=>:bold}, ": #{@company.CST_no}"]
		    end
		    if !@company.service_tax_reg_no.blank?
		      data<<[{:content=>"Service Tax No.", :font_style=>:bold}, ": #{@company.service_tax_reg_no}"]
		    end

		    table(data, :cell_style =>{:padding_top=>2.5,:padding_bottom=>1.5, :border_width=>0, :size=>7}) do

		    end
		  end
		end
	end


	def total_quantity
		data=["",{:content => "Total Qty.", :font_style => :bold, :align => :right},{:content => " #{ number_with_precision @purchase.total_quantity, :precision=>2}", :font_style => :bold, :align => :right},"",""]
		data.insert(3, "") unless @discount==0
		data
	end

	def build_other_charge_lines(line_item)
		data=["", "", "", {:content=>line_item.account.name, :align=>:right},	{:content=>"#{format_amount(line_item.amount)}", :align=>:right} ]
		data.insert(3, "") unless @discount==0
		data
	end

	def build_tax_lines(line_item)
		data=["", "", "", {:content=>line_item.account.name, :align=>:right},	{:content=>"#{format_amount(@purchase.group_tax_amt(line_item.account_id))}", :align=>:right} ]
		data.insert(3, "") unless @discount==0
		data
	end

	def build_line_item(line_item)

if line_item.product.inventory? && line_item.purchase.gst_purchase?
            name_and_hsn ="#{line_item.item_name}\n HSN: #{line_item.product.hsn_code}"
            elsif line_item.product.inventory == false && line_item.purchase.gst_purchase?
             name_and_hsn ="#{line_item.item_name}\n SAC: #{line_item.product.hsn_code}"
            else
              name_and_hsn = "#{line_item.item_name}\n#{line_item.product.hsn_code}"
            end

		data=[{:content=>name_and_hsn, :align=>:left}, {:content=>line_item.description, :align=>:left},{:content=>"#{number_with_precision line_item.quantity, :precision=>2} #{line_item.product.unit_of_measure}", :align=>:right},
			{:content=>"#{number_with_precision line_item.unit_rate, :precision=>(line_item.unit_rate == line_item.unit_rate.round(2) ? 2 : 4)}", :align=>:right}, {:content=>"#{number_with_precision line_item.amount, :precision=>2}", :align=>:right} ]
	  {:content=>"Disc%", :align=>:right}
	  data.insert(3, {:content=>"#{number_to_percentage line_item.discount_percent, :precision=>2 }", :align=>:right}) unless @discount==0
	  data
	end

	def table_header
		data=[{:content=>'Item', :align=>:left}, {:content=>'Description', :align=>:left}, {:content=>'Qantity', :align=>:right},
					{:content=>'Unit Cost', :align=>:right}, {:content=>"Amount(#{@purchase.currency})", :align=>:right} ]
		data.insert(3, {:content=>"Disc%", :align=>:right}) unless @discount==0
		data
	end

	def voucher_details
		data=[[{:content =>"Purchase#:", :font_style => :bold, :align => :left}, {:content =>"#{@purchase.purchase_number}"}]]
		data<<[{:content =>"PO Ref.#:", :font_style => :bold, :align => :left}, {:content =>"#{@purchase.bill_reference}"}] unless @purchase.bill_reference.blank?
		data<<[{:content =>"Record Date:", :font_style => :bold, :align => :left}, {:content =>"#{@purchase.record_date}"}] unless @purchase.record_date.blank?
		data<<[{:content =>"PO Date:", :font_style => :bold, :align => :left}, {:content =>"#{@purchase.bill_date}"}] unless @purchase.bill_date.blank?
		data<<[{:content =>"Due Date:", :font_style => :bold, :align => :left}, {:content =>"#{@purchase.due_date}"}]
		data<<[{:content =>"Amount", :font_style => :bold, :align => :left}, {:content =>"#{@purchase.currency} #{number_with_precision @purchase.total_amount, :precision=>2}"}]
		data<<[{:content =>"Under Project", :font_style => :bold, :align => :left}, {:content =>"#{@purchase.project_name}"}] unless @purchase.project_id.blank?
		data<<[{:content =>"Purchase Order No.", :font_style=> :bold, :align => :left}, {:content =>"#{@purchase.purchase_order_number}"}] unless @purchase.purchase_order_id.blank?
		@gst_debit_note.each do |gst_debit_note|
		data<<[{:content =>"Gst Debit Note No.", :font_style=> :bold, :align => :left}, {:content =>"#{gst_debit_note.gst_debit_note_number}"}] unless gst_debit_note.blank?
		data<<[{:content =>"Allocated Amount", :font_style=> :bold, :align => :left}, {:content =>"#{@purchase.total_amount-@purchase.outstanding}"}] unless gst_debit_note.blank?
	end
		if @customer.gstn_id.present?
          data<<[{:content=>"GSTIN", :font_style=>:bold}, "#{@customer.gstn_id}"]
    	end
		unless @company.plan.free_plan? || @custom_field.blank?
			data<<[{:content =>"#{@custom_field.custom_label1}", :font_style => :bold, :align => :left}, {:content =>"#{@purchase.custom_field1}"}] unless @custom_field.custom_label1.blank? || @purchase.custom_field1.blank?
			data<<[{:content =>"#{@custom_field.custom_label2}", :font_style => :bold, :align => :left}, {:content =>"#{@purchase.custom_field2}"}] unless @custom_field.custom_label2.blank? || @purchase.custom_field2.blank?
			data<<[{:content =>"#{@custom_field.custom_label3}", :font_style => :bold, :align => :left}, {:content =>"#{@purchase.custom_field3}"}] unless @custom_field.custom_label3.blank? || @purchase.custom_field3.blank?
		end
		table(data, :width=>bounds.width, :row_colors => ["F2F7FF"], :cell_style =>{:align => :left, :border_width => 0, :size => 9})do
		end
	end
end
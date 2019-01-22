class PurchaseOrderPdf < Prawn::Document
  include PdfBase
  include ActionView::Helpers::NumberHelper
  def initialize(purchase_order)
    super(PAGE_LAYOUT)
    @purchase_order=purchase_order
    @purchase_order_line_items=purchase_order.purchase_order_line_items
    @tax_line_items=purchase_order.tax_line_items.group(:account_id)
    @other_charge_line_items=purchase_order.other_charge_line_items
    @pos_arr=[]
    @header_pos=[]
    @company=purchase_order.company
    @customer = @purchase_order.account.customer.blank? ? @purchase_order.account.vendor : @purchase_order.account.customer
    @party=purchase_order.vendor
    @discount=@purchase_order.discount
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
      text "<b>PURCHASE ORDER</b>", :align => :center, :inline_format => true, :size => 14
      stroke_horizontal_rule
    end

    y_pos=cursor-5
    box_width=(bounds.width-20)/3
    bounding_box([0, y_pos], :width=>box_width) do
      vendor_details
    end

    #y_pos=cursor-5
    box_width=(bounds.width-20)/3
    bounding_box([198, y_pos], :width=>box_width) do
      vendor_shipping_details
      #company_name_and_address
    end

    @pos_arr<<y

    bounding_box([(box_width*2)+20, y_pos], :width=>box_width) do
      voucher_details
    end
    @pos_arr<<y

    bounding_box([0, (@pos_arr.min.to_f-50)], :width => bounds.width) do
      voucher_line_item_and_calculation_details
    end
    # self.y-=10
    # unless @purchase_order.customer_notes.blank?
    #   span(y, :position => :left) do
    #     text "<b>Customer Notes</b>", :size=>10, :inline_format=>:true
    #     text @purchase_order.customer_notes, :inline_format=>true, :size=>8
    #   end
    # end

    # self.y-=10
    # unless @purchase_order.terms_and_conditions.blank?
    #   span(y, :position => :left) do
    #     text "<b>Terms and Conditions</b>", :size=>10, :inline_format=>:true
    #     text @purchase_order.terms_and_conditions, :inline_format=>true, :size=>8
    #   end
    # end
    customer_notes_and_terms
    company_tax_info
    signatory

    page_footer
  end

  def signatory
    draw_text "-------------------", :at =>[bounds.width-70, 40]
    draw_text "Authorised Signatory",:size => 8,:at=>[bounds.width-70, 32]
  end

  def voucher_details
    data=[[{:content =>"Purchase order#:", :font_style => :bold, :align => :left}, {:content =>"#{@purchase_order.purchase_order_number}"}]]
    data<<[{:content =>"Dated on:", :font_style => :bold, :align => :left}, {:content =>"#{@purchase_order.record_date}"}]
    data<<[{:content =>"Amount:", :font_style => :bold, :align => :right}, {:content =>"#{@purchase_order.currency} #{number_with_precision @purchase_order.amount, :precision=>2}"}]
    data<<[{:content =>"Due Date:", :font_style => :bold, :align => :left}, {:content =>"#{@purchase_order.due_date}"}]
    data<<[{:content =>"Project", :font_style => :bold, :align => :left}, {:content =>"#{@purchase_order.project.name}"}] unless @purchase_order.project.blank?
    if @customer.gstn_id.present?
          data<<[{:content=>"GSTIN", :font_style=>:bold}, "#{@customer.gstn_id}"]
    end
    table(data, :width=>bounds.width, :row_colors => ["F2F7FF"], :cell_style =>{:align => :left, :border_width => 0, :size => 9})do
  end
end

def shipping_detail
end

def voucher_line_item_and_calculation_details
  n=@purchase_order_line_items.count
  data=Array.new
  data<<table_header
  data=data.concat(order_lines)
  table(data, :header=>true, :width=>bounds.width,:row_colors => ["FFFFFF","F2F7FF"] , :cell_style =>{:border_width => 0,:border_color => "70B8FF",  :size => 8}, :column_widths => {0 => 100, 1 => 120 }) do
    row(0).font_style=:bold
    row(0).borders=[:top, :bottom]
    row(0).border_width=0.2
    row(n).borders=[:bottom]
    row(n).border_width=0.2
  end
end

def order_lines
  line_items=Array.new

  @purchase_order_line_items.each do |line_item|
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

  line_items
end

def total_calculation
  data=["","","",{:content => "Total", :font_style => :bold, :align => :right},{:content => "#{number_with_precision @purchase_order.amount, :precision=>2}", :font_style => :bold, :align => :right}]
  data.insert(3, "") unless @discount==0
  data
end

def total_discount
  ["","","","",{:content => "Discount", :font_style => :bold, :align => :right},{:content => "#{number_with_precision @purchase_order.discount, :precision=>2}", :font_style => :bold, :align => :right}]
end

def total_tax
  data=["","","",{:content => "Tax", :font_style => :bold, :align => :right},{:content => "#{number_with_precision @purchase_order.tax, :precision=>2}", :font_style => :bold, :align => :right}]
  data.insert(3, "") unless @discount==0
  data
end

def sub_total
  data=["","","",{:content => "Sub Total", :font_style => :bold, :align => :right},{:content => "#{number_with_precision @purchase_order.sub_total, :precision=>2}", :font_style => :bold, :align => :right}]
  data.insert(3, "") unless @discount==0
  data
end

def customer_notes_terms_header
    sub_data=[{:content=>"#{'Customer Notes:' unless @purchase_order.customer_notes.blank?}", :size=> 8,:align=>:left},
      {:content=>"#{'Terms & Conditions:' unless @purchase_order.customer_notes.blank? }", :size=> 8,:align=>:left}]
    sub_data
  end
  def customer_notes_terms_data
    sub_data=[{:content=>"#{@purchase_order.customer_notes unless @purchase_order.customer_notes.blank?}", :size=> 8, :align=>:left},
      {:content=>"#{@purchase_order.terms_and_conditions unless @purchase_order.customer_notes.blank?}", :size=> 8, :align=>:left}]
    sub_data 
  end
  def customer_notes_and_terms
    notes_and_terms=Array.new
    notes_and_terms<<customer_notes_terms_header
    notes_and_terms<<customer_notes_terms_data
      table(notes_and_terms, :header=>true, :width=>bounds.width, :cell_style=>{:border_width=>0}, :column_widths => bounds.width/2) do
      row(0).font_style = :bold
      end
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
  data=["",{:content => "Total Qty.", :font_style => :bold, :align => :right},{:content => " #{ number_with_precision @purchase_order.total_quantity, :precision=>2}", :font_style => :bold, :align => :right},"",""]
  data.insert(3, "") unless @discount==0
  data
end

def build_other_charge_lines(line_item)
  data=["", "", "", {:content=>line_item.account.name, :align=>:right}, {:content=>"#{number_with_precision line_item.amount, :precision=>2 }", :align=>:right} ]
  data.insert(3, "") unless @discount==0
  data
end

def build_tax_lines(line_item)
  data=["", "", "", {:content=>line_item.account.name, :align=>:right}, {:content=>"#{number_with_precision @purchase_order.group_tax_amt(line_item.account_id), :precision=>2 }", :align=>:right} ]
  data.insert(3, "") unless @discount==0
  data
end

def build_line_item(line_item)
  if line_item.product.inventory? && line_item.purchase_order.gst_purchaseorder?
            name_and_hsn ="#{line_item.item_name}\n HSN: #{line_item.product.hsn_code}"
            elsif line_item.product.inventory == false && line_item.purchase_order.gst_purchaseorder?
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
    data=[{:content=>'Item', :align=>:left}, {:content=>'Description', :align=>:left}, {:content=>'Quantity', :align=>:right},
      {:content=>'Unit Cost', :align=>:right}, {:content=>"Amount(#{@purchase_order.currency})", :align=>:right} ]
      data.insert(3, {:content=>"Disc%", :align=>:right}) unless @discount==0
      data
  end
end

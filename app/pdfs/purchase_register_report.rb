class PurchaseRegisterReport < Prawn::Document
  include PdfBase
  require 'open-uri'
  include ActionView::Helpers::NumberHelper

  def initialize(view_context, purchases, account, company, start_date, end_date, branch_id, include_line_items)
    super(PAGE_LAYOUT)
    @view_context=view_context
    @purchases=purchases
    @account=account
    @company=company
    @start_date=start_date
    @end_date=end_date
    @branch_id=branch_id
    @pos_arr=[]
    @header_pos=[]
    @include_line_items = include_line_items
    send "generate_purchase_register"
  end

  def generate_purchase_register
    y_pos=cursor
    bounding_box([0, y_pos], :width=>bounds.width) do
      company_name_and_address_in_center
      report_details
    end
    sales_register_details
    page_footer
  end

  def report_details
    text"<b><u>Purchase Register</u></b>", :align=>:center, :size=>8, :inline_format=>true
    text"#{@view_context.vendor_name(@account)}", :align=>:center, :size=>8, :inline_format=>true
    unless @branch_id.blank?
     text "#{@view_context.display_branch(@branch_id)}", :inline_format=>true, :align => :center, :size => 6 
    end 
    text"#{@start_date} to #{@end_date}", :align=>:center, :size=>8, :inline_format=>true
  end

  def sales_register_details
    data = Array.new
    data << table_header
    data = data.concat(report_data)
    table(data, :header=>true, :width=>bounds.width, :row_colors => ["FFFFFF","F2F7FF"] , :cell_style =>{:border_width => 0,:border_color => "70B8FF",  :size => 8}) do
      row(0).font_style=:bold
      row(0).borders=[:top, :bottom]
      row(0).border_width=0.2
    end
  end

  def report_data
    data=Array.new
    total_amount=0
    @purchases.each do |purchase|
      data << ["#{purchase.record_date}", purchase.purchase_number,"#{purchase.account.name}", {:content=>"#{number_with_precision (purchase_amount=@view_context.purchase_amount(purchase)), :precision=>2}", :align=>:right}]
      if @include_line_items
        purchase.purchase_line_items.each do |line_item|
          data << ["#{line_item.product.name}", line_item.unit_rate,"#{line_item.quantity}", {:content=>"#{number_with_precision line_item.amount, :precision=>2}", :align=>:right}]
        end
      end    
      total_amount += purchase_amount
    end
    data<<["", "",  {:content=>"T o t a l", :align=>:right, :font_style=>:bold}, {:content=>"#{number_with_precision total_amount, :precision=>2}", :align=>:right, :font_style=>:bold}]
    data
  end

  def table_header
    if @include_line_items
      ["Purchase Date / Product", "Purchase No / Unit rate", "Vendor / Quantity", {:content=>"Amount(#{@company.currency_code}) / Amount", :align=>:right}]
    else
      ["Purchase Date", "Purchase No", "Vendor", {:content=>"Amount(#{@company.currency_code})", :align=>:right}]      
    end  
  end
end
class PaymentVoucherPdf < Prawn::Document
  include PdfBase
  include ActionView::Helpers::NumberHelper
  include ApplicationHelper
  
  def initialize(view_context, payment_voucher)
    super(PAGE_LAYOUT)
    @payment_voucher=payment_voucher
    @pos_arr=[]
    @header_pos=[]
    @company=@payment_voucher.company
    @party=@payment_voucher.vendor
    generate_pdf
  end

  def generate_pdf
    y_pos=cursor
    bounding_box([0, cursor], :width => (bounds.width/2)-5) do 
      company_logo
      @header_pos<<y
    end

    bounding_box([(bounds.width/2), y_pos], :width => (bounds.width/2)) do
      company_name_and_address
      @header_pos<<y
    end

    bounding_box([0, (@header_pos.min.to_i-30)], :width=>bounds.width) do
      text "<b>PAYMENT VOUCHER</b>", :align => :center, :inline_format => true, :size => 14
      stroke_horizontal_rule
    end

    y_pos=cursor-5
    box_width=(bounds.width-20)/3
    bounding_box([0, y_pos], :width=>box_width) do
      if @payment_voucher.other_payment?
        account_details
      else
        vendor_details
      end
    end
    @pos_arr<<y
    bounding_box([(box_width*2)+20, y_pos], :width=>box_width) do
      voucher_details
    end
    @pos_arr<<y
    bounding_box([0, (@pos_arr.min.to_f-50)], :width => bounds.width) do
      voucher_line_item_and_calculation_details
    end
    self.y-=10

    payment_mode_details unless @payment_voucher.payment_detail.type.to_s=="CashPayment"

    self.y-=10
    unless @payment_voucher.description.blank?
      span(y, :position => :left) do
        text "<b>Description</b>", :size=>10, :inline_format=>:true
        text @payment_voucher.description, :inline_format=>true, :size=>8
      end
    end

    draw_text "-------------------", :at =>[0, 40]
    draw_text "Authorised Signatory",:size => 8,:at=>[0, 32]

    draw_text "-------------------", :at =>[bounds.width-70, 40]
    draw_text "Receiver's Signature",:size => 8,:at=>[bounds.width-70, 32]

    page_footer
  end

  def payment_mode_details
    text "#{@payment_voucher.payment_detail.payment_mode} Details:"
    data=send("#{@payment_voucher.payment_detail.type.to_s.underscore}_details")
    table(data, :header => true, :width => (bounds.width),:row_colors => ["FFFFFF","F2F7FF"] , 
         :cell_style =>{:border_width => 0,:border_color => "70B8FF",  :size => 9}) do
      row(0).font_style = :bold
      row(0).borders = [:top, :bottom]
      row(0).border_width = 0.1
      row(1).borders = [:bottom]
      row(1).border_width = 0.1 
    end
  end

  def card_payment_details
    data=Array.new
    data<<["Card number","Transaction Date","Transaction reference"]
    data<<["#{@payment_voucher.payment_detail.account_number}","#{@payment_voucher.payment_detail.payment_date}","#{@payment_voucher.payment_detail.transaction_reference}"]
    data
  end

  def internet_banking_payment_details
    data=Array.new
    data<<["Transaction Date","Bank name","Transaction reference"]
    data<<["#{@payment_voucher.payment_detail.payment_date}","#{@payment_voucher.payment_detail.bank_name}","#{@payment_voucher.payment_detail.transaction_reference}"]
    data
  end

  def cheque_payment_details
    data=Array.new
    data<<["Cheque number","Cheque Date","Bank name","Branch" ]
    data<<["#{@payment_voucher.payment_detail.account_number}","#{@payment_voucher.payment_detail.payment_date}","#{@payment_voucher.payment_detail.bank_name}","#{@payment_voucher.payment_detail.branch}"]
    data
  end

  def voucher_line_item_and_calculation_details
    data=Array.new
    data<<table_header
    data=data.concat(purchases_lines)
    data=data.concat(expenses_lines)
    data=data.concat(calculation_line)
    table(data, :header=>true, :width=>bounds.width,:row_colors => ["FFFFFF","F2F7FF"] , :cell_style =>{:border_width => 0,:border_color => "70B8FF",  :size => 8}) do
      row(0).font_style=:bold
      row(0).borders=[:top, :bottom]
      row(0).border_width=0.2
      # row(n).borders=[:bottom]
    #   row(n).border_width=0.2
    end
  end
  def calculation_line
    data=Array.new
    sub_data=[{:content=>"Total", :align=>:right}, {:content=>"#{format_amount(@payment_voucher.amount)}", :align=>:right}]
    sub_data.insert(0, "") unless @payment_voucher.tds_amount.blank? || @payment_voucher.tds_amount <=0
    data<<sub_data
  end
  def table_header
    data=["Voucher No.", {:content=>"Paid Amount (#{@payment_voucher.currency_code})", :align=>:right}]
    data.insert(1, {:content=>"TDS Deducted (#{@payment_voucher.currency_code})", :align=>:right}) unless @payment_voucher.tds_amount.blank? || @payment_voucher.tds_amount <=0
    data
  end

  def purchases_lines
    data=Array.new
    @payment_voucher.purchases_payments.each do |purchase_payment|
      sub_data=["#{purchase_payment.purchase.purchase_number}", {:content=>"#{format_amount(purchase_payment.amount)}", :align=>:right}]
      sub_data.insert(1, {:content=>"#{format_amount(purchase_payment.tds_amount)}", :align=>:right}) unless @payment_voucher.tds_amount.blank? || @payment_voucher.tds_amount <=0
      data<<sub_data
    end
    data
  end
  def expenses_lines
    data=Array.new
    @payment_voucher.expenses_payments.each do |expense_payment|
      sub_data=["#{expense_payment.expense.voucher_number}", {:content=>"#{format_amount(expense_payment.amount)}", :align=>:right}]
      sub_data.insert(1, {:content=>"#{format_amount(expense_payment.tds_amount)}", :align=>:right}) unless @payment_voucher.tds_amount.blank? || @payment_voucher.tds_amount <=0
      data<<sub_data
    end
    data
  end
  def account_details
    data=[[{:content =>"Vendor:", :font_style => :bold, :align => :left}]]
    data<<["<b>#{@payment_voucher.to_account.name}</b>"]

    table(data, :width=>bounds.width,:cell_style =>{:align => :left,:inline_format => true,:border_width =>0, :size => 9, :border_color => "70B8FF" })do
      row(0).borders = [:left, :right, :bottom, :top]
      row(0).background_color = 'F2F7FF'
      row(1..(data.size - 2)).borders = [:left, :right]
      row(data.size - 1).borders = [:left, :right, :bottom]
      row(0..(data.size - 1)).border_width = 0.2
    end
  end
  def voucher_details
    data=[[{:content =>"Payment Voucher#:", :font_style => :bold, :align => :left}, {:content =>"#{@payment_voucher.voucher_number}"}]]
    data<<[{:content =>"Voucher Date:", :font_style => :bold, :align => :left}, {:content =>"#{@payment_voucher.voucher_date}"}]
    data<<[{:content =>"Amount", :font_style => :bold, :align => :left}, {:content =>"#{@payment_voucher.currency_code} #{format_amount(@payment_voucher.amount)}"}]
    data<<[{:content =>"Paid From", :font_style => :bold, :align => :left}, {:content =>"#{@payment_voucher.from_account.name}"}]
    if !@payment_voucher.tds_account_id.blank? && !@payment_voucher.tds_amount.blank?
      data<<[{:content => "TDS Section:", :font_style => :bold, :align => :left},{:content =>
      "#{@payment_voucher.tds_account.name}"}]
      data<<[{:content => "TDS Amount:", :font_style => :bold, :align => :left},{:content =>
      "#{@payment_voucher.currency_code} #{format_amount(@payment_voucher.tds_amount)}"}]
    end
    table(data, :width=>bounds.width, :row_colors => ["F2F7FF"], :cell_style =>{:align => :left, :border_width => 0, :size => 9})do
    end
  end
end
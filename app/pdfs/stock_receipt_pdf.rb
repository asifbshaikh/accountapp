class StockReceiptPdf < Prawn::Document
require 'open-uri'
include PdfBase
include ActionView::Helpers::NumberHelper

def initialize(view_context, stock_receipt_voucher,company)
  super(PAGE_LAYOUT)
    @view_context=view_context
    @stock_receipt_voucher=stock_receipt_voucher
    @pos_arr=[]
    @header_pos=[]
    @company=company
    send "generate_stock_receipt_voucher"
  end

def generate_stock_receipt_voucher
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
      text "<b>Stock Receipt Voucher</b>", :align => :center, :inline_format => true, :size => 14
      stroke_horizontal_rule
  end

   y_pos=cursor-5
    box_width=(bounds.width-20)/3
    @pos_arr<<y
    bounding_box([(box_width*2)+20, y_pos], :width=>box_width) do
    issue_details
 end


 @pos_arr<<y
    data = [[{:content => "Product", :align => :left} ,{:content => "Quantity", :align => :right}]]
    @stock_receipt_voucher.stock_receipt_line_items.each do |line_item|
     data += [[{:content => "#{line_item.product_name}", :align => :left},{:content => "#{line_item.quantity} #{line_item.product.unit_of_measure}", :align => :right}]]
  end
  bounding_box([0, (@pos_arr.min.to_i-50)], :width => (bounds.width)) do
    n =   @stock_receipt_voucher.stock_receipt_line_items.count
   table(data, :header => true,  :width => (bounds.width-10),:row_colors => ["FFFFFF","F2F7FF"] , :cell_style =>{:border_width => 0,:border_color => "70B8FF",  :size => 9}) do
      row(0).font_style = :bold
      row(0).borders = [:top, :bottom]
      row(0).border_width = 0.1
      row(n).borders =[:bottom]
      row(n).border_width = 0.1
    end
  end
  y_position = cursor

  if !@stock_receipt_voucher.details.blank?
         bounding_box([0, y_position], :width => (bounds.width/2)) do
          table([["<b>Details</b>"],
          [" #{@stock_receipt_voucher.details}"]],
         :cell_style =>{:border_width => 0, :inline_format=> true, :size => 9})do
       end
     end
   end
 end

 def issue_details
    data=[[{:content =>"Voucher Number:", :font_style => :bold, :align => :left}, {:content =>"#{@stock_receipt_voucher.voucher_number}"}]]
    data<<[{:content =>"Voucher Date :", :font_style => :bold, :align => :left}, {:content =>"#{ @stock_receipt_voucher.voucher_date}"}]
    data<<[{:content =>"Godown:", :font_style => :bold, :align => :left}, {:content =>"#{ @stock_receipt_voucher.stock_received_warehouse}"}]
    data<<[{:content =>"Created On:", :font_style => :bold, :align => :left}, {:content =>"#{ @stock_receipt_voucher.created_at.strftime("%d-%m-%Y")} by #{@stock_receipt_voucher.created_by_user}"}]
    table(data, :width=>bounds.width, :row_colors => ["F2F7FF"], :cell_style =>{:align => :left, :border_width => 0, :size => 9})do
    end
  end
 end




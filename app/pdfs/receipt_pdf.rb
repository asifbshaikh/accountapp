class ReceiptPdf < Prawn::Document
	require 'open-uri'
	include PdfBase
  include ApplicationHelper
	def initialize(receipt_voucher, view_context, company)
		paper_size="A4"
		super(:page_layout => :portrait,:page_size=> paper_size,:top_margin=>10, :left_margin=>10, :right_margin=>20)
		@receipt_voucher=receipt_voucher
    @account=Account.find_by_id_and_company_id(@receipt_voucher.from_account_id,company.id)
		@view_context=view_context
		@company=company
    @col_cnt=0
		@pos_arr=[]
		@header_pos=[]
		generate_receipt
	end


def generate_receipt
  pos_arr=[]
  y_position = cursor
  bounding_box([0, 790], :width => (bounds.width/2) - 5) do
  company_logo
  @header_pos<<y
end

  bounding_box([370, 790], :width => (bounds.width/2)) do
    table([
	     [ "<b>#{@company.name}</b>"],
	     [ "#{@company.address.get_address unless @company.address.blank?}"],
	     ["#{@company.phone unless @company.phone.blank?}"],
	    ],
	    :width => (bounds.width/3*2), :cell_style =>{:border_width => 0,:align => :right, :inline_format => true, :size => 9})do
	  end
  end

  move_down 20
  text "<b>Receipt Acknowledgement</b>", :align => :center, :inline_format => true, :size => 14
  stroke_horizontal_rule

  move_down 10
  y_position = cursor
  bounding_box([15, y_position], :width => (bounds.width/2) - 100) do
  table([
	  [{:content =>"Received from:", :font_style => :bold, :align => :left}],
          ["<b>#{@receipt_voucher.from_account_name unless @receipt_voucher.from_account_id.blank?}</b>"],
          [ 
            if !"@account.customer.blank?" 
             "#{@account.customer.billing_address.address_line1 unless @account.customer.billing_address.blank?}"
           end
            ],
          [{:content => "This sentence will not visible to you i know", :inline_format=> true, :align => :left, :text_color => 'FFFFFF'}],
          ],
        :cell_style =>{:align => :left,:inline_format => true,:border_width =>0, :size => 9, :border_color => "70B8FF" })do
         row(0).borders = [:left, :right, :bottom, :top]
         row(0).background_color = 'F2F7FF'
         # row(1).borders = [:left, :right]
         # row(1).borders = [:left, :right, :bottom]
	       # row(0).border_width = 0.5
         # row(2).border_width = 0.5
     end
    pos_arr<<y
  end

if !@receipt_voucher.project_id.blank?
  bounding_box([430, y_position], :width => (bounds.width / 2) - 10) do
    data = [[{:content =>"Under project:", :font_style => :bold, :align => :left}, {:content =>"#{@receipt_voucher.project_name}"}]]
    data += [[{:content =>"Voucher #:", :font_style => :bold, :align => :left}, {:content =>"#{@receipt_voucher.voucher_number}"}]]
    data += [[{:content =>"Received date:", :font_style => :bold, :align => :left}, {:content =>"#{@receipt_voucher.received_date.strftime("%d-%m-%Y")}"}]]
    data += [[{:content =>"Amount", :font_style => :bold, :align => :left}, {:content =>"#{@receipt_voucher.currency_code} #{format_amount(@receipt_voucher.amount.to_s)}"}]]

if !@receipt_voucher.tds_amount.blank? && @receipt_voucher.tds_amount > 0
     data += [[{:content => "TDS Amount", :font_style => :bold, :align => :right},{:content => " #{@receipt_voucher.currency_code} #{format_amount(@receipt_voucher.tds_amount.to_s)}", :font_style => :bold, :align => :right}]]
   end
     table(data, :row_colors => ["F2F7FF"], :cell_style =>{:align => :left, :border_width => 0, :size => 9})do
   end
     pos_arr<<y
   end
else
  bounding_box([430, y_position], :width => (bounds.width / 2) - 10) do
    data = [[{:content =>"Voucher #:", :font_style => :bold, :align => :left}, {:content =>"#{@receipt_voucher.voucher_number}"}]]
    data += [[{:content =>"Received date:", :font_style => :bold, :align => :left}, {:content =>"#{@receipt_voucher.received_date.strftime("%d-%m-%Y")}"}]]
    data += [[{:content =>"Amount", :font_style => :bold, :align => :left}, {:content =>"#{@receipt_voucher.currency_code} ##{format_amount(@receipt_voucher.amount.to_s)}"}]]
if !@receipt_voucher.tds_amount.blank? && @receipt_voucher.tds_amount > 0
     data += [[{:content => "TDS Amount", :font_style => :bold, :align => :right},{:content => " #{@receipt_voucher.currency_code} #{format_amount(@receipt_voucher.tds_amount.to_s)}", :font_style => :bold, :align => :right}]]
  end
     table(data, :row_colors => ["F2F7FF"], :cell_style =>{:align => :left, :border_width => 0, :size => 9})do
  end
     pos_arr<<y
  end
end

    data = [["Transaction Mode", "" ,"Received on",{:content => "Amount", :align => :center}]]
    data += [["#{@receipt_voucher.payment_detail.payment_mode}","","#{@receipt_voucher.received_date}", {:content => " #{format_amount(@receipt_voucher.amount.to_s)}", :align => :center}]]

if @receipt_voucher.payment_detail.type == 'ChequePayment'
  data += [[{:content =>"Cheque No   : #{@receipt_voucher.payment_detail.account_number}"},"","",""]]
  data += [[{:content =>"Cheque Date : #{@receipt_voucher.payment_detail.payment_date}"},"","",""]]
  data += [[{:content =>"Bank Name   : #{@receipt_voucher.payment_detail.bank_name}"},"","",""]]
  data += [[{:content =>"Branch Name : #{@receipt_voucher.payment_detail.branch}"},"","",""]] unless @receipt_voucher.payment_detail.branch.blank?
if @receipt_voucher.payment_detail.branch.blank?
    line_count=4
  else 
    line_count=5
end

elsif @receipt_voucher.payment_detail.type == 'CardPayment'
  data += [[{:content =>"Card Number            : #{@receipt_voucher.payment_detail.account_number}"},"","",""]]
  data += [[{:content =>"Transaction Date       : #{@receipt_voucher.payment_detail.payment_date}"},"","",""]]
  data += [[{:content =>"Transaction Reference : #{@receipt_voucher.payment_detail.transaction_reference}"},"","",""]]
  line_count=4

elsif @receipt_voucher.payment_detail.type == 'InternetBankingPayment'
  data += [[{:content =>"Transaction Date : #{@receipt_voucher.payment_detail.payment_date}"},"","",""]]
  data += [[{:content =>"Bank Name         : #{@receipt_voucher.payment_detail.bank_name}"},"","",""]]
 # data += [[{:content =>"Transaction reference",:align => :left},"#{@receipt_voucher.payment_detail.transaction_reference}",""]]
  line_count=3
end
# data += [["","","",""]]
  data += [["","",{:content => "Total", :font_style => :bold, :align => :right},{:content => "  #{format_amount(@receipt_voucher.amount.to_s)}",:font_style => :bold, :align => :center}]]

bounding_box([15, (pos_arr.min.to_i-50)], :width => (bounds.width)) do
  text "Receipt Details"
  
table(data, :header => true,  :width => (bounds.width-10),:row_colors => ["FFFFFF","F2F7FF"] , :cell_style =>{:border_width => 0,:border_color => "70B8FF",  :size => 9}) do
  	row(0).font_style = :bold
    row(0).borders = [:top, :bottom]
    row(0).border_width = 0.1
    row(line_count).borders = [:bottom]
    row(line_count).border_width = 0.1
  end
  # move_down 10
  # text "Thank you for payment",:size => 10,:inline_format => true,:align => :left
end
    
   # text "Receipt Details"
  #  if @receipt_voucher.payment_detail.type == 'ChequePayment'
  #   bounding_box([15, (pos_arr.min.to_i-200)], :width => (bounds.width/2) - 60) do
  #   text "<b>Mode:</b>", :align => :left, :inline_format => true, :size => 10

  #   data = [[{:content =>"Cheque No.", :font_style => :bold, :align => :left}, {:content =>"#{@receipt_voucher.payment_detail.account_number}"}]]
  #   data += [[{:content =>"Cheque Date", :font_style => :bold, :align => :left}, {:content =>"#{@receipt_voucher.payment_detail.payment_date}"}]]
  #   data += [[{:content =>"Bank Name", :font_style => :bold, :align => :left}, {:content =>"#{@receipt_voucher.payment_detail.bank_name}"}]]
  #    data += [[{:content =>"Branch Name", :font_style => :bold, :align => :left}, {:content =>"#{@receipt_voucher.payment_detail.branch}"}]]

  #      table(data, :header => true, :width => (bounds.width),:row_colors => ["FFFFFF"] ,
  #                        :cell_style =>{:align => :left, :border_width => 0, :size => 9}) do
  #   end
  # end
 
  # elsif @receipt_voucher.payment_detail.type == 'CardPayment'
  #   bounding_box([15, (pos_arr.min.to_i-200)], :width => (bounds.width/2) - 60) do
  #     text "<b>Mode:</b>", :align => :left, :inline_format => true, :size => 10
  #       data = [[{:content =>"Card Number.", :font_style => :bold, :align => :left}, {:content =>"#{@receipt_voucher.payment_detail.account_number}"}]]
  #       data += [[{:content =>"Transaction Date", :font_style => :bold, :align => :left}, {:content =>"#{@receipt_voucher.payment_detail.payment_date}"}]]
  #       data += [[{:content =>"Transaction reference", :font_style => :bold, :align => :left}, {:content =>"#{@receipt_voucher.payment_detail.transaction_reference}"}]]
  #    # data += [[{:content =>"Branch Name", :font_style => :bold, :align => :left}, {:content =>"#{@receipt_voucher.payment_detail.branch}"}]]

  #      table(data, :header => true, :width => (bounds.width),:row_colors => ["FFFFFF"] ,
  #                        :cell_style =>{:align => :left, :border_width => 0, :size => 9}) do
  #   end
  # end

  #  elsif @receipt_voucher.payment_detail.type == 'InternetBankingPayment'
  #   bounding_box([15, (pos_arr.min.to_i-200)], :width => (bounds.width/2) - 60) do
  #     text "<b>Mode:</b>", :align => :left, :inline_format => true, :size => 10
  #       data = [[{:content =>"Transaction Date", :font_style => :bold, :align => :left}, {:content =>"#{@receipt_voucher.payment_detail.payment_date}"}]]
  #       data += [[{:content =>"Bank Name", :font_style => :bold, :align => :left}, {:content =>"#{@receipt_voucher.payment_detail.bank_name}"}]]
  #       data += [[{:content =>"Transaction reference", :font_style => :bold, :align => :left}, {:content =>"#{@receipt_voucher.payment_detail.transaction_reference}"}]]
  #    # data += [[{:content =>"Branch Name", :font_style => :bold, :align => :left}, {:content =>"#{@receipt_voucher.payment_detail.branch}"}]]

  #      table(data, :header => true, :width => (bounds.width),:row_colors => ["FFFFFF"] ,
  #                        :cell_style =>{:align => :left, :border_width => 0, :size => 9}) do
  #   end
  # end
  # end

move_down 10
y_position = cursor

if !@receipt_voucher.description.blank?
  bounding_box([10, y_position], :width => (bounds.width/2)) do
    table([["<b>Description</b>"],
		[" #{@receipt_voucher.description}"]],
	  :cell_style =>{:border_width => 0, :inline_format=> true, :size => 9})do
	 end
  end
end


   draw_text "-------------------", :at =>[bounds.width-70, 40]
   draw_text "Receiver's Signature",:size => 8,:at=>[bounds.width-70, 32]


   page_count.times do |i|
	 go_to_page(i+1)
	 fill_color "ADADAD"
	 if @footer.nil? || @footer.strip == ''
		draw_text "#{@company.watermark unless @company.watermark.blank?}", :at=>[0,-10], :size => 7
	 else
		draw_text @footer.strip, :at => [0,-10], :size => 7
	 end
	 fill_color "000000"
	 draw_text "Page : #{i+1} / #{page_count}", :at=>[bounds.width - 50,-10], :size => 9
   end
 end
end

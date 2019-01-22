class Gstr3bReportPdf < Prawn::Document
  include PdfBase
  require 'open-uri'
  include ActionView::Helpers::NumberHelper

  def initialize(view_context, company, gstr3b_report)
    super(PAGE_LAYOUT)
    @view_context=view_context
    @company=company
    @gstr3b_report=gstr3b_report
    @section3 = @gstr3b_report.generate_section3
    @section32 = @section3.section32
    @section4 = @gstr3b_report.generate_section4
    @section5 = @gstr3b_report.generate_section5
    @section6 = @gstr3b_report.generate_section61
    @pos_arr=[]
    @header_pos=[]
    send "generate_gstr3b_report"
  end

  def generate_gstr3b_report
    y_pos=cursor
    bounding_box([0, y_pos], :width=>bounds.width) do
      report_details
      company_name_and_GSTIN
    end
    text" "
    text"3.1 Details of outward supplies and inward supplies liable to reverse charge", :align => :left, :size => 9, :inline_format=>true
    details_3_1
    text" "
    text" "
    text"3.2 Of the supplies shown in 3.1(a), details of inter-state supplies made to unregistered persons, composition taxable persons and UIN holders", :align => :left, :size => 9, :inline_format=>true
    details_3_2
    text" "
    text" "
    text"4. Eligible ITC", :align => :left, :size => 9, :inline_format=>true
    details_4
    text" "
    text" "
    text"5. Values of exempt, nil-rated, and non-GST inward supplies", :align => :left, :size => 9, :inline_format=>true
    details_5
    text" "
    text" "
    text"6.1 Payment of Tax", :align => :left, :size => 9, :inline_format=>true
    details_6_1
    text" "
    text" "
    text"6.2 TDS/TCS Credit", :align => :left, :size => 9, :inline_format=>true
    details_6_2
  end

  def company_name_and_GSTIN
    text"<b>Legal name of registered person: </b>#{@company.name}", :align => :left, :size => 10, :inline_format=>true
    text"<b>GSTIN: </b>#{@company.GSTIN}", :align => :left, :size => 10, :inline_format=>true
  end

  def report_details
    text"<b><u>GSTR 3B Report</u></b>", :align=>:center, :size=>10, :inline_format=>true
    text"<b>Date: </b>#{Time.zone.now.to_date}",  :align=>:right, :size=>8, :inline_format=>true
  end

  def details_3_1
    data=Array.new
    data<<table_header_3_1
    data=data.concat(report_data_3_1)
    # data<<grand_total
    table(data, :header=>true, :width=>bounds.width,:row_colors => ["FFFFFF","F2F7FF"] , :cell_style =>{:border_width => 0,:border_color => "70B8FF",  :size => 8}) do
      row(0).font_style=:bold
      row(0).borders=[:top, :bottom]
      row(0).border_width=0.2
    end
  end

  def table_header_3_1
    ["Nature of supplies", "Total taxable value", "Integrated tax", "Central tax", "State/UT tax", "Cess"]
  end

  def report_data_3_1
    data=Array.new
      data<<["(a) Outward taxable supplies (other than zero rated, nil rated and exempted)",
        "#{@section3.outward_taxable_amount}", "#{@section3.outward_igst_tax_amt}", 
        "#{@section3.outward_cgst_tax_amt}","#{@section3.outward_sgst_tax_amt}", "#{@section3.outward_cess_amt}"]
      
      data<<["(b) Outward taxable supplies (Zero rated)","#{@section3.outward_zero_gst_taxable_amt}", 
        "#{@section3.outward_zero_igst_tax_amt}", "#{@section3.outward_zero_cgst_tax_amt}","#{@section3.outward_zero_sgst_tax_amt}", "#{@section3.outward_zero_cess_amt}"]
      
      data<<["(c) Other Outward supplies (Nil rated, exempted)","#{@section3.outward_nil_gst_taxable_amt}", 
        "#{@section3.outward_nil_igst_tax_amt}", "#{@section3.outward_nil_cgst_tax_amt}","#{@section3.outward_nil_sgst_tax_amt}","#{@section3.outward_nil_cess_amt}"]

      data<<["(d) Inward supplies(liable to reverse charge)","#{@section3.inward_reverse_taxable_amt}", "#{@section3.inward_reverse_igst_tax_amt}", 
        "#{@section3.inward_reverse_cgst_tax_amt}","#{@section3.inward_reverse_sgst_tax_amt}", "#{@section3.inward_reverse_cess_amt}"]
      
      data<<["(e) Non-GST outward supplies","", "", "","", ""]

  end

  def details_3_2
    data=Array.new
    data<<table_header_3_2
    data=data.concat(report_data_3_2)
    # data<<grand_total
    table(data, :header=>true, :width=>bounds.width,:row_colors => ["FFFFFF","F2F7FF"] , :cell_style =>{:border_width => 0,:border_color => "70B8FF",  :size => 8}) do
      row(0).font_style=:bold
      row(0).borders=[:top, :bottom]
      row(0).border_width=0.2
    end
  end

  def table_header_3_2
    ["Nature of supplies", "Place of supply", "Total taxable value", "Amount of integrated tax"]
  end

  def report_data_3_2
    data=Array.new
    data<<["Supplies made to unregistered persons","", "#{@section32.unregistered_inv_amt}", "#{@section32.unregistered_igst_tax_amt}"]
    place_of_supply = @section32.unregistered_invoices[0].place_of_supply_state if @section32.unregistered_invoices.present?
    total_inv_amt =0
    total_tax_amt = 0
    @section32.unregistered_invoices.each do |invoice|
      if invoice.place_of_supply_state == place_of_supply
        total_inv_amt += invoice.sub_total
        total_tax_amt += invoice.igst_tax_amt
      else
        data<<["", "#{place_of_supply}","#{total_inv_amt}", "#{total_tax_amt}"]
        place_of_supply = invoice.place_of_supply_state
        total_inv_amt = invoice.sub_total
        total_tax_amt = invoice.igst_tax_amt        
      end
    end
    if total_inv_amt != 0 
       data<<["", "#{place_of_supply}","#{total_inv_amt}", "#{total_tax_amt}"]
    end
      data<<["Supplies made to composition taxable persons","", "", ""]
      data<<["Supplies made to UIN holders","", "", ""]
  end

  def details_4
    data=Array.new
    data<<table_header_4
    data=data.concat(report_data_4)
    # data<<grand_total
    table(data, :header=>true, :width=>bounds.width,:row_colors => ["FFFFFF","F2F7FF"] , :cell_style =>{:border_width => 0,:border_color => "70B8FF",  :size => 8}) do
      row(0).font_style=:bold
      row(0).borders=[:top, :bottom]
      row(0).border_width=0.2
      row(2).column(0).font_style=:italic
      row(2).column(0).align=:right
      row(3).column(0).font_style=:italic
      row(3).column(0).align=:right
      row(4).column(0).font_style=:italic
      row(4).column(0).align=:right
      row(5).column(0).font_style=:italic
      row(5).column(0).align=:right
      row(6).column(0).font_style=:italic
      row(6).column(0).align=:right
      row(8).column(0).font_style=:italic
      row(8).column(0).align=:right
      row(9).column(0).font_style=:italic
      row(9).column(0).align=:right
      row(12).column(0).font_style=:italic
      row(12).column(0).align=:right
      row(13).column(0).font_style=:italic
      row(13).column(0).align=:right
    end
  end

  def table_header_4
    ["Details", "Integrated tax", "Central tax", "State/UT tax", "Cess"]
  end

  def report_data_4
    data=Array.new
      data<<["(A) ITC available (whether in full or in part)","#{@section4.total_igst_tax_amt}", "#{@section4.total_cgst_tax_amt}", "#{@section4.total_sgst_tax_amt}", "#{@section4.total_cess_amt}"]
      data<<["(1) Import of goods","", "", "",""]
      data<<["(2) Import of services","", "", "",""]
      data<<["(3) Inward supplies liabile to reverse charge","#{@section4.inward_reverse_igst_tax_amt}", "#{@section4.inward_reverse_cgst_tax_amt}", "#{@section4.inward_reverse_sgst_tax_amt}","#{@section4.inward_reverse_cess_amt}"]
      data<<["(4) Inward supplies from ISD","", "", "",""]
      data<<["(5) All other ITC","#{@section4.igst_tax_amt}", "#{@section4.cgst_tax_amt}", "#{@section4.sgst_tax_amt}","#{@section4.cess_amt}"]
      data<<["(B) ITC Reversed", "", "", "",""]
      data<<["(1) As per rules 42 & 43 of CGST rules","", "", "",""]
      data<<["(2) Others","", "", "",""]
      data<<["(C) Net ITC available (A) - (B)","#{@section4.net_igst_tax_amt}", "#{@section4.net_cgst_tax_amt}", "#{@section4.net_sgst_tax_amt}","#{@section4.net_cess_amt}"]
      data<<["(D) Ineligible ITC","", "", "",""]
      data<<["(1) As per section 17(5)","", "", "",""]
      data<<["(2) Others","", "", "",""]
  end

  def details_5
    data=Array.new
    data<<table_header_5
    data=data.concat(report_data_5)
    # data<<grand_total
    table(data, :header=>true, :width=>bounds.width,:row_colors => ["FFFFFF","F2F7FF"] , :cell_style =>{:border_width => 0,:border_color => "70B8FF",  :size => 8}) do
      row(0).font_style=:bold
      row(0).borders=[:top, :bottom]
      row(0).border_width=0.2

    end
  end

  def table_header_5
    ["Nature of supplies", "inter-state supplies", "Intra-state supplies"]
  end

  def report_data_5
    data=Array.new
      data<<["From a supplier under composition scheme, Exempt and Nil rated", "#{@section5.exempt_inter_tax_amt}", "#{@section5.exempt_intra_tax_amt}"]
      data<<["Non GST supply","#{@section5.non_gst_inter_tax_amt}", "#{@section5.non_gst_intra_tax_amt}"]
  end

  def details_6_1
    data=Array.new

    data<<table_header_1_6_1
    data<<table_header_6_1
    data=data.concat(report_data_6_1)
    # data<<grand_total
    table(data, :header=>true, :width=>bounds.width,:row_colors => ["FFFFFF","F2F7FF"] , :cell_style =>{:border_width => 0,:border_color => "70B8FF",  :size => 8}) do
      row(0).font_style=:bold
      row(1).font_style=:bold
      row(0).borders=[:top]
      row(1).borders=[:bottom,:left,:right,:top]
      row(0).border_width=0.2
      row(1).border_width=0.2
      column(0).borders=[:left,:top,:bottom]
      column(9).borders=[:right,:top,:bottom]
      column(2).borders=[:left,:top,:bottom]
      column(3).borders=[:top,:bottom]
      column(4).borders=[:top,:bottom]
      column(5).borders=[:right,:top,:bottom]
    end
  end

  def table_header_1_6_1
    [" ", " "," ", "Paid through ITC"," "," "," "," "," "," "]
  end

  def table_header_6_1
    ["Description", "Tax payable", "Integrated tax", "Central tax", "State/UT tax", "Cess", "Tax paid TDS/TCS", "Tax/Cess paid in cash", "Interest", "Late fee"]
  end

  def report_data_6_1
    data=Array.new
      data<<["Integrated tax","#{@section6.igst_payable}", "#{@section6.igst_paid_with_igst}", "#{@section6.igst_paid_with_cgst}","#{@section6.igst_paid_with_sgst}","","","#{@section6.balance_igst_paid_in_cash}","",""]
      
      cgst_payable = @section6.cgst_payable
      cgst_with_cgst = @section6.cgst_paid_with_cgst
      cgst_with_igst = @section6.cgst_paid_with_igst
      data<<["Central tax","#{cgst_payable}", "#{cgst_with_igst}", "#{cgst_with_cgst}","-","","","#{@section6.balance_cgst_paid_in_cash}","",""]
      
      sgst_payable = @section6.sgst_payable
      sgst_with_sgst = @section6.sgst_paid_with_sgst
      sgst_with_igst = @section6.sgst_paid_with_igst

      data<<["State/UT tax","#{sgst_payable}", "#{sgst_with_igst}", "-","#{sgst_with_sgst}","","","#{@section6.balance_sgst_paid_in_cash}","",""]
      data<<["Cess","#{@section3.outward_cess_amt}", "-", "-","-","","","","",""]
  end

  def details_6_2
    data=Array.new
    data<<table_header_6_2
    data=data.concat(report_data_6_2)
    # data<<grand_total
    table(data, :header=>true, :width=>bounds.width,:row_colors => ["FFFFFF","F2F7FF"] , :cell_style =>{:border_width => 0,:border_color => "70B8FF",  :size => 8}) do
      row(0).font_style=:bold
      row(0).borders=[:top, :bottom]
      row(0).border_width=0.2
    end
  end

  def table_header_6_2
    ["Details", "Integrated tax", "Central tax", "State/UT tax" ]
  end

  def report_data_6_2
    data=Array.new
      data<<["TDS","", "", ""]
      data<<["TDS","", "", ""]
  end
end
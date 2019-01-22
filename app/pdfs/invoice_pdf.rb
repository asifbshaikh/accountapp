class InvoicePdf < Prawn::Document
  require 'open-uri'
  include PdfBase
  include ApplicationHelper
  def initialize(invoice, view_context, template,margin ,custom_field, invoice_line_items, time_line_items, shipping_line_items, tax_line_items, receipt_vouchers, pdf_name)
    @template=template
    @margin = margin
    paper_size= template=='Thermal'? "B7" : "A4"
    if @template =='professional' || @template =='SMB'
      super(:page_layout => :portrait, :page_size => paper_size,:top_margin=>@margin.top_margin , :left_margin=>@margin.left_margin, :right_margin=>@margin.right_margin)
    else
      super(:page_layout => :portrait, :page_size => paper_size,:top_margin=>10 , :left_margin=>10, :right_margin=>20)
    end
    @invoice=invoice
    @company=@invoice.company
    @view_context=view_context
    @custom_field=custom_field
    @created_by_user=User.find(@invoice.created_by)
    @customer = @invoice.customer.blank? ? @invoice.vendor : @invoice.customer
    if @customer.blank?
      @customer = @invoice.account.customer.present? ? @invoice.account.customer : @invoice.account.vendor
    end  
    @time_line_items=time_line_items
    @invoice_line_items=invoice_line_items
    @shipping_line_items=shipping_line_items
    @tax_line_items=tax_line_items
    @receipt_vouchers=receipt_vouchers
    @title=pdf_name
    @col_cnt=0
    @pos_arr=[]
    @header_pos=[]
    @top_pos=[]
    send "generate_#{@template.downcase}"
  end

  def generate_modern1
    text "<b><u>#{@title}</u></b>", :align=>:center, :inline_format=>true
    bounding_box([0, 790], :width => (bounds.width/2) - 5) do
      company_logo
      @header_pos<<y
    end
    bounding_box([(bounds.width/2), 780], :width => (bounds.width/2)) do
      text "<b>#{@invoice.invoice_title.blank? ? "INVOICE" : @invoice.invoice_title}</b>", :align => :center, :inline_format => true, :size => 14
      @header_pos<<y
    end

    box_width=(bounds.width-20)/3
    bounding_box([0, @header_pos.min.to_i-40], :width=>(box_width)) do
      stroke_horizontal_rule
      self.y=y-2
      table(invoice_info, :width=>(box_width), :row_colors=>["ffffff"], :cell_style=>{:padding_top=>1.5,:padding_bottom=>1.5, :align=>:left, :border_width=>0, :size=>8})do
      end
      @pos_arr<<y
    end
    bounding_box([(box_width+10), @header_pos.min.to_i-40], :width=>(box_width)) do
      stroke_horizontal_rule
      self.y=y-2
      table(branch_address, :width=>(box_width), :row_colors=>["ffffff"], :cell_style=>{:padding_top=>1.5,:padding_bottom=>1.5, :align=>:left, :border_width=>0, :size=>8})do
      end
      @pos_arr<<y
    end

    bounding_box([(2*box_width)+20, @header_pos.min.to_i-40], :width=>(box_width)) do
      stroke_horizontal_rule
      self.y=y-2
      table(bill_to, :width=>(box_width), :row_colors=>["ffffff"], :cell_style=>{:padding_top=>1.5,:padding_bottom=>1.5, :align=>:left, :border_width=>0, :size=>8})do
      end
      @pos_arr<<y
    end

    invoice_rows

    amount_words


    company_tax_info

    unless !@company.invoice_setting.view_payment? || @invoice.cash_invoice?
      receipt_rows
    end

    customer_notes_and_terms

    invoice_footer

    page_footer
  end

  def generate_classic
    text "<b><u>#{@title}</u></b>", :align=>:center, :inline_format=>true
    bounding_box([0, 800], :width => (bounds.width/2)) do
      company_logo
      @header_pos<<y
    end
    bounding_box([360, 800], :width=>(bounds.width/2)) do
      table(branch_address, :width=>(bounds.width/2*2-60),:cell_style=>{:border_width=>0,:align=>:right, :inline_format=>true, :size=>9}) do
      end
      @header_pos<<y
    end
    bounding_box([0, (@header_pos.min.to_i-30)], :width=>bounds.width) do
      text "<b>#{@invoice.invoice_title.blank? ? "INVOICE" : @invoice.invoice_title}</b>", :align => :center, :inline_format => true, :size => 14
      stroke_horizontal_rule
    end
    box_width=(bounds.width-20)/ 3
    y_offset=cursor-5
    bounding_box([0, y_offset], :width=>box_width) do
      billing_add=bill_to
      table(billing_add,:width=>box_width,  :cell_style=>{:padding_top=>1.5,:padding_bottom=>1.5, :align =>:left,:inline_format=> true,:border_width =>0, :size => 8, :border_color => "000000" })do
        row(0).borders = [:left, :right, :bottom, :top]
        row(0).background_color = 'F2F7FF'
        row(1..(billing_add.size-2)).borders = [:left, :right]
        row(billing_add.size - 1).borders = [:left, :right, :bottom]
        row(0..(billing_add.size - 1)).border_width = 0.1
      end
      @pos_arr<<y
    end
    unless @invoice.cash_invoice?
      bounding_box([box_width+10, y_offset], :width=>box_width ) do
        shipping_add=ship_to
        table(shipping_add, :width=>box_width,   :cell_style=>{:padding_top=>1.5,:padding_bottom=>1.5,:align=>:left, :inline_format=>true, :border_width=>0, :size=>8, :border_color=>"000000" }) do
          row(0).borders = [:left, :right, :bottom, :top]
          row(0).background_color = 'F2F7FF'
          row(1..(shipping_add.size-2)).borders = [:left, :right]
          row(shipping_add.size - 1).borders = [:left, :right, :bottom]
          row(0..(shipping_add.size - 1)).border_width = 0.1
        end
        @pos_arr<<y
      end
    end
    bounding_box([2*box_width+20, y_offset], :width=>box_width) do
      table(invoice_info, :width=>box_width, :row_colors=>["F2F7FF"], :cell_style=>{:padding_top=>1.5,:padding_bottom=>1.5, :align=>:left, :border_width=>0,:size=>8}) do
      end
      @pos_arr<<y
    end
    invoice_rows

    amount_words
    company_tax_info
    unless !@company.invoice_setting.view_payment? || @invoice.cash_invoice?
      receipt_rows
    end
    customer_notes_and_terms
    invoice_footer
    page_footer
  end


  def generate_tabular
    generate_classic
  end

  def generate_thermal
    text "<b><u>#{@title}</u></b>", :align=>:center, :inline_format=>true
    bounding_box([0, cursor], :width=>bounds.width) do
      text" <b>#{@company.name}</b>", :size=> 10, :inline_format => true
      text" #{@company.address.get_address unless @company.address.blank?}", :size=> 7, :inline_format => true
      text"Phone:#{@company.phone}", :size=> 7, :inline_format => true
      text" Email:#{@company.email}", :size=> 7, :inline_format => true
    end
    bounding_box([0, cursor], :width => bounds.width) do
      text"<b>Invoice #:</b> #{@invoice.invoice_number}", :size=> 7, :inline_format => true
      text"<b>Invoice date:</b> #{@invoice.invoice_date}", :size=> 7, :inline_format => true
      if @invoice.gst_invoice?
        text"<b>Place of Supply:</b> #{@invoice.place_of_supply_state}", :size=> 7, :inline_format => true
      end  
    end
    table_width=bounds.width
    n =  @invoice_line_items.count
    n += @invoice.tax_line_items.count
    table invoice_line_items do
      self.header=true
      self.width= table_width
      self.cell_style={:border_width=>0, :size=>8, :border_color => "000000", :height=> 17}
      row(0).font_style = :bold
      columns(1..3).align=:right
      row(0).borders = [:top,:bottom]
      row(0).border_width = 0.2
      row(n).borders = [:bottom]
      row(n).border_width = 0.2
    end
    amount_words
    company_tax_info

    if !@invoice.customer_notes.blank?
      span(bounds.width, :position=>:left) do
        text"<b>#{@company.label.customer_label} Notes:</b>", :size=> 8, :inline_format => true
        text "#{(@invoice.customer_notes)}",:size => 8
      end
    end
  end

  def generate_smb
    text "<b><u>#{@title}</u></b>", :align=>:center, :inline_format=>true
    box_width=(bounds.width-20)/ 3
    y_offset=cursor-5

    bounding_box([0, y_offset], :width=>box_width+180) do
      if @margin.hide_address != 1
        text "  "+"<b>#{@invoice.invoice_title.blank? ? "INVOICE" : @invoice.invoice_title} </b> #{@invoice.invoice_number}", :align => :left, :inline_format => true, :size => 12
        stroke_horizontal_rule
      else
        bounding_box([5, @header_pos.min.to_i-70], :width=>box_width+30) do
          self.y=y-20
          text "  "+"<b>#{@invoice.invoice_title.blank? ? "INVOICE" : @invoice.invoice_title} </b> #{@invoice.invoice_number}", :align => :left, :inline_format => true, :size => 12
          @header_pos<<y
        end

      end
      @header_pos<<y

    end

    bounding_box([5, y_offset-8], :width=>box_width+180) do
      if @margin.hide_address != 1
        text "<b>\nSold By</b>",:size=>9,:inline_format=>true
      end
      @header_pos<<y
    end
    bounding_box([0, y_offset-27], :width=>box_width+80) do
      if @margin.hide_address !=1
        table(branch_address, :width=>(bounds.width/2*2),:cell_style=>{:padding_top=>1,:padding_bottom=>1,:border_width=>0,:align=>:left, :inline_format=>true, :size=>9}) do
        end
      end
      @header_pos<<y
    end

    bounding_box([2*box_width+20, y_offset], :width=>box_width) do
      if @margin.hide_logo !=1
        company_logo
        @header_pos<<y
      end
    end
    bounding_box([0, y_offset-100], :width=>box_width) do
      self.y=y-18
      billing_add=bill_to
      table(billing_add,:width=>box_width,  :cell_style=>{:padding_top=>1.5,:padding_bottom=>1.5, :align =>:left,:inline_format=> true,:border_width =>0, :size => 8, :border_color => "000000" })do
      end
      @pos_arr<<y
    end
    unless @invoice.cash_invoice?
      bounding_box([box_width+10, y_offset-100], :width=>box_width ) do
        self.y=y-18
        shipping_add=ship_to
        table(shipping_add, :width=>box_width,   :cell_style=>{:padding_top=>1.5,:padding_bottom=>1.5,:align=>:left, :inline_format=>true, :border_width=>0, :size=>8, :border_color=>"000000" }) do
        end
      end
      @pos_arr<<y
    end

    bounding_box([3, y_offset-100], :width=>box_width+380) do
      self.y=y-18
      stroke_horizontal_rule
      @pos_arr<<y
    end
    bounding_box([2*box_width, y_offset-100], :width=>box_width) do
      self.y=y-18
      table(invoice_info, :width=>box_width,  :cell_style=>{:padding_top=>1.5,:padding_bottom=>1.5, :align=>:left, :border_width=>0,:size=>8}) do
      end
      @pos_arr<<y
    end

    invoice_rows

    amount_words
    
    company_tax_info

    unless !@company.invoice_setting.view_payment? || @invoice.cash_invoice?
      receipt_rows
    end

    customer_notes_and_terms

    authorised_signatory
    invoice_footer

    page_footer
  end

  def generate_professional
    text "<b><u>#{@title}</u></b>", :align=>:center, :inline_format=>true
    box_width=(bounds.width-20)/ 3
    y_offset=cursor-5
    bounding_box([2*box_width+20, y_offset], :width=>box_width) do
      if @margin.hide_logo !=1
        company_logo
        @header_pos<<y
      end
    end
    bounding_box([0, y_offset], :width=>box_width+50) do
      if @margin.hide_address !=1
        table(branch_address,:width=>(bounds.width/2*2),:cell_style=>{:padding_top=>1,:padding_bottom=>1,:border_width=>0,:align=>:left, :inline_format=>true, :size=>9}) do
        end
      end
      @header_pos<<y
    end


    bounding_box([(box_width)-20, @header_pos.min.to_i-40], :width=>box_width+30) do
      text "  "+"<b>#{@invoice.invoice_title.blank? ? "INVOICE" : @invoice.invoice_title} </b>",:align => :center, :inline_format => true, :size => 16,:color=>"F2F7FF"
      @header_pos<<y
    end


    bounding_box([(box_width)-180, @header_pos.min.to_i-30], :width=>box_width+30) do
      stroke_horizontal_rule
    end


      box_width=(bounds.width-20)/3
      bounding_box([(box_width)-183, @header_pos.min.to_i-30], :width=>(box_width)) do
        self.y=y-2
        billing_add=bill_to
        table(billing_add, :width=>box_width,   :cell_style=>{:padding_top=>1.5,:padding_bottom=>1.5,:align=>:left, :inline_format=>true, :border_width=>0, :size=>8, :border_color=>"000000" }) do
        end
        @pos_arr<<y
      end
      
    

    box_width=(bounds.width-20)/3
    bounding_box([2*(box_width)+20, @header_pos.min.to_i-40], :width=>(box_width)) do
      self.y=y-2
      table(invoice_info, :width=>(box_width), :row_colors=>["ffffff"], :cell_style=>{:padding_top=>1.5,:padding_bottom=>1.5, :align=>:left, :border_width=>0, :size=>8})do
      end
      @pos_arr<<y
    end

    bounding_box([(box_width)+140, @header_pos.min.to_i-30], :width=>box_width+70) do
      stroke_horizontal_rule
    end

    invoice_rows
    amount_words
    company_tax_info
    unless !@company.invoice_setting.view_payment? || @invoice.cash_invoice?
      receipt_rows
    end
    customer_notes_and_terms
    authorised_signatory
    invoice_footer
    page_footer
  end

  def generate_minimalist
    text "<b><u>#{@title}</u></b>", :align=>:center, :inline_format=>true
    box_width=(bounds.width-20)/3
    bounding_box([20, 800], :width => (bounds.width/2)-5) do
      company_logo
      @header_pos<<y
    end
    bounding_box([380, @header_pos.min.to_i-5], :width=>(box_width)) do
      self.y=y-2
      table(branch_address,:width=>(bounds.width),:cell_style=>{:padding_top=>1,:padding_bottom=>1,:border_width=>0,:align=>:left, :inline_format=>true, :size=>9}) do
      end
      @header_pos<<y
    end

    bounding_box([30, @header_pos.min.to_i-40], :width=>(box_width)) do
      self.y=y-2
      table(invoice_info, :width=>(box_width), :row_colors=>["ffffff"], :cell_style=>{:padding_top=>1.5,:padding_bottom=>1.5, :align=>:left, :border_width=>0, :size=>8})do
      end
      @pos_arr<<y
    end
    bounding_box([(2*box_width)+20, @header_pos.min.to_i-35], :width=>(box_width)) do
      self.y=y-2
      table(bill_to, :width=>(box_width), :row_colors=>["ffffff"], :cell_style=>{:padding_top=>1.5,:padding_bottom=>1.5, :align=>:left, :border_width=>0, :size=>8})do
      end
      @pos_arr<<y
    end

    invoice_rows
    unless !@company.invoice_setting.view_payment? || @invoice.cash_invoice?
      receipt_rows
    end
    amount_words
    company_tax_info
    notes_terms
    page_footer
  end

  def generate_retail
    
    @top_pos<<y
    @header_pos<<y
    box_width=(bounds.width-20)/ 3
    y_offset=@header_pos.min.to_i
    repeat :all do
      bounding_box([2*box_width+20, y_offset-30], :width=>box_width) do
        if @margin.hide_logo != 1
          retail_company_logo
        end
        @header_pos<<y
      end
      text "<b><u>#{@title}</u></b>", :align=>:center, :inline_format=>true
      bounding_box([0, y_offset-30], :width=>box_width+100) do
        if @margin.hide_address != 1
          table(branch_address,:width=>(bounds.width/2*2),:cell_style=>{:padding_top=>1,:padding_bottom=>1,:border_width=>0,:align=>:left, :inline_format=>true, :size=>9}) do
          end
        end
        @header_pos<<y
      end

      bounding_box([(box_width)-180, @header_pos.min.to_i-45], :width=>box_width+395) do
        stroke_horizontal_rule
      end
      bounding_box([(box_width)-20, @header_pos.min.to_i-50], :width=>box_width+30) do
        text "  "+"<b>#{@invoice.invoice_title.blank? ? "INVOICE" : @invoice.invoice_title} </b>",:align => :center, :inline_format => true, :size => 16,:color=>"F2F7FF"
        @header_pos<<y
      end

        box_width=(bounds.width-20)/3
        bounding_box([(box_width)-183, @header_pos.min.to_i-20], :width=>(box_width)) do
          billing_add=bill_to
          table(billing_add, :width=>box_width,   :cell_style=>{:padding_top=>1.5,:padding_bottom=>1.5,:align=>:left, :inline_format=>true, :border_width=>0, :size=>8, :border_color=>"000000" }) do
          end
        end
        @pos_arr<<y

      bounding_box([(box_width)-100, @header_pos.min.to_i-32], :width=>(box_width)) do
        self.y=y-3
        company_tax_info
      end

      box_width=(bounds.width-20)/3
      bounding_box([2*(box_width)+20, @header_pos.min.to_i-30], :width=>(box_width)) do
        self.y=y-2
        table(invoice_info, :width=>(box_width), :row_colors=>["ffffff"], :cell_style=>{:padding_top=>1.5,:padding_bottom=>1.5, :align=>:left, :border_width=>0, :size=>8})do
        end
        @pos_arr<<y
      end

      bounding_box([(box_width)-180, @header_pos.min.to_i-30], :width=>box_width+395) do
        stroke_horizontal_rule
      end
    end
    retail
    retail_terms
    page_count.times do |i|
      retail_invoice_footer
      retail_sign
    end
    page_footer
  end

  def invoice_info
    invoice_info=[]
    invoice_info<<[{:content=>"Invoice #:", :font_style=>:bold, :align=>:left}, {:content=>"#{@invoice.invoice_number}"}]
    invoice_info<<[{:content=>"Invoice date:", :font_style=>:bold, :align=>:left}, {:content=>"#{@invoice.invoice_date.strftime("%d-%m-%Y")}"}]
    invoice_info<<[{:content=>"Due date:", :font_style=>:bold, :align=>:left}, {:content=>"#{@invoice.due_date.strftime("%d-%m-%Y")}"}] unless @invoice.cash_invoice?
    #invoice_info<<[{:content=>"Amount ("+"#{@invoice.currency}"+")" , :font_style=>:bold, :align=>:left}, {:content=>"#{@invoice.total_amount.to_s}"}]
    invoice_info<<[{:content=>"Amount ("+"#{@invoice.currency}"+")", :font_style=>:bold, :align=>:left}, {:content=>"#{format_amount(@invoice.total_amount)}"}]
    invoice_info<<[{:content=>"Place of supply:", :font_style=>:bold, :align=>:left}, {:content=>"#{@invoice.place_of_supply_state}"}] if (@invoice.gst_invoice? && !@invoice.export_invoice?)
    invoice_info<<[{:content=>"PO #:", :font_style=>:bold, :align=>:left}, {:content=>"#{@invoice.po_reference}"}] unless @invoice.po_reference.blank?
    invoice_info<<[{:content=>"Project:", :font_style=>:bold, :align=>:left}, {:content=>"#{@invoice.project_name}"}] unless @invoice.project.blank?
    if !@custom_field.blank? && !@company.plan.free_plan?
      if !@custom_field.custom_label1.blank? && !@invoice.custom_field1.blank?
        invoice_info<<[{:content=>"#{@custom_field.custom_label1}", :font_style=>:bold, :align=>:left},{:content=>"#{@invoice.custom_field1}"}]
      end
      if !@custom_field.custom_label2.blank? && !@invoice.custom_field2.blank?
        invoice_info<<[{:content=>"#{@custom_field.custom_label2}", :font_style=>:bold, :align=>:left},{:content=>"#{@invoice.custom_field2}"}]
      end
      if !@custom_field.custom_label3.blank? && !@invoice.custom_field3.blank?
        invoice_info<<[{:content=>"#{@custom_field.custom_label3}", :font_style=>:bold, :align=>:left},{:content=>"#{@invoice.custom_field3}"}]
      end
    end
    # invoice_info<<[{:content=>"Created by:", :font_style=>:bold, :align=>:left}, {:content=>"#{@invoice.created_by_user}"}]
    invoice_info
  end

  def branch_address
    address=Array.new

    address<<[{:content=>"From :", :font_style=>:bold}] if @template=='modern1'
    address<<[{:content=>"#{@company.name}"}]
    if !@created_by_user.branch.blank?
      address<<[{:content=> "#{@created_by_user.branch.address.get_address}"}]  unless @created_by_user.branch.address.blank?

      # address<<[{:content=> "#{@company.name+"\n"+ @created_by_user.branch.address.get_address+"\n"+"#{@created_by_user.branch.phone}"+"\nEmail:"+"#{@company.email}"}"}]  unless @created_by_user.branch.address.blank?
      address<<[{:content=> "Phone: #{@created_by_user.branch.phone}"}] unless @created_by_user.branch.phone.blank?
      address<<[{:content=>"Email: #{@company.email}"}] unless @company.email.blank?
    else
      # address<<[{:content=>"#{@company.name}", :font_style=> :bold}]
      address<<[{:content=> "#{@company.address.get_address}"}] unless @company.address.blank?
      address<<[{:content=> "Phone: #{@company.phone}"}] unless @company.phone.blank?
      address<<[{:content=>"Email: #{@company.email}"}] unless @company.email.blank?
    end
    address
  end

  def bill_to
    billing_add=[]
    if @template=='minimalist' || @template=='professional' || @template=='Retail'
      billing_add<<[{:content=>"\nINVOICE TO:", :font_style=>:bold, :align=>:left}]
    else
      billing_add<<[{:content=>"Billing Address:", :font_style=>:bold, :align=>:left}]
    end
    if @invoice.cash_invoice?
      billing_add<<[{:content=>"#{@invoice.cash_customer_name}", :font_style=>:bold, :align=>:left}] unless @invoice.cash_customer_name.blank?
      billing_add<<[{:content=>"#{@invoice.cash_customer_email}", :align=>:left}] unless @invoice.cash_customer_email.blank?
      billing_add<<[{:content=>"#{@invoice.cash_customer_mobile}", :align=>:left}] unless @invoice.cash_customer_mobile.blank?
      billing_add<<[{:content=>"#{@invoice.cash_customer_gstin}", :align=>:left}] unless @invoice.cash_customer_gstin.blank?
    else
      billing_add<<[{:content=>"#{@invoice.account.name}", :font_style=>:bold, :align=>:left}]
      if @invoice.billing_address.present?
        billing_add<<[{:content=>"#{@invoice.billing_address.address_line1}", :align=>:left}]  unless @invoice.billing_address.blank?
        billing_add<<[{:content=>"City: #{@invoice.billing_address.city}",:align=>:left}] unless @invoice.billing_address.city.blank?
        billing_add<<[{:content=>"State: #{@invoice.billing_address.state}",:align=>:left}] unless @invoice.billing_address.state.blank?
        billing_add<<[{:content=>"Country: #{@invoice.billing_address.country}",:align=>:left}] unless @invoice.billing_address.country.blank?
        billing_add<<[{:content=>"Postal Code: #{@invoice.billing_address.postal_code}",:align=>:left}] unless @invoice.billing_address.postal_code.blank?
      elsif (@invoice.customer.present? && @invoice.customer.billing_address.present?)
        billing_add<<[{:content=>"#{@invoice.customer.billing_address.address_line1}", :align=>:left}]  unless @invoice.customer.billing_address.blank?
        billing_add<<[{:content=>"City: #{@invoice.customer.billing_address.city}",:align=>:left}] unless @invoice.customer.billing_address.city.blank?
        billing_add<<[{:content=>"State: #{@invoice.customer.billing_address.state}",:align=>:left}] unless @invoice.customer.billing_address.state.blank?
        billing_add<<[{:content=>"Country: #{@invoice.customer.billing_address.country}",:align=>:left}] unless @invoice.customer.billing_address.country.blank?
        billing_add<<[{:content=>"Postal Code: #{@invoice.customer.billing_address.postal_code}",:align=>:left}] unless @invoice.customer.billing_address.postal_code.blank?
      elsif (@invoice.vendor.present? && @invoice.vendor.billing_address.present?)
        billing_add<<[{:content=>"#{@invoice.vendor.billing_address.address_line1}", :align=>:left}]  unless @invoice.vendor.billing_address.blank?
        billing_add<<[{:content=>"City: #{@invoice.vendor.billing_address.city}",:align=>:left}] unless @invoice.vendor.billing_address.city.blank?
        billing_add<<[{:content=>"State: #{@invoice.vendor.billing_address.state}",:align=>:left}] unless @invoice.vendor.billing_address.state.blank?
        billing_add<<[{:content=>"Country: #{@invoice.vendor.billing_address.country}",:align=>:left}] unless @invoice.vendor.billing_address.country.blank?        
        billing_add<<[{:content=>"Postal Code: #{@invoice.vendor.billing_address.postal_code}",:align=>:left}] unless @invoice.vendor.billing_address.postal_code.blank?
      end
      billing_add<<[{:content=>"Email: #{@customer.email}", :font_style=>:bold,:align=>:left}] unless @customer.email.blank?
      billing_add<<[{:content=>"Contact: #{@customer.contact_number}", :align=>:left}] unless @customer.contact_number.blank?
      billing_add<<[{:content=>"GSTIN: #{@customer.gstn_id}",:font_style=>:bold,:align=>:left}] unless @customer.gstn_id.blank?
      billing_add<<[{:content=>"TIN: #{@customer.vat_tin}", :align=>:left}] unless @customer.vat_tin.blank?
      billing_add<<[{:content=>"Permanent Account Number: #{@customer.pan}", :align=>:left}] unless @customer.pan.blank?
      billing_add<<[{:content=>"CST Reg.: #{@customer.cst_reg_no}", :align=>:left}] unless @customer.cst_reg_no.blank?
    end
    billing_add
  end

  def ship_to
    shipping_add=Array.new
    shipping_add<<[{:content=>"Shipping Address:", :font_style=>:bold, :align=>:left}]
    if @invoice.shipping_address.present?
      shipping_add<<[{:content=>"#{@invoice.account.name }", :font_style=>:bold, :align=>:left}]
      shipping_add<<[{:content=>"#{@invoice.shipping_address.address_line1}", :align=>:left}]  unless @invoice.shipping_address.blank?
      shipping_add<<[{:content=>"City: #{@invoice.shipping_address.city}",:align=>:left}] unless @invoice.shipping_address.city.blank?
      shipping_add<<[{:content=>"State: #{@invoice.shipping_address.state}",:align=>:left}] unless @invoice.shipping_address.state.blank?
      shipping_add<<[{:content=>"Country: #{@invoice.shipping_address.country}",:align=>:left}] unless @invoice.shipping_address.country.blank?
      shipping_add<<[{:content=>"Postal Code: #{@invoice.shipping_address.postal_code}",:align=>:left}] unless @invoice.shipping_address.postal_code.blank?

    elsif (@invoice.customer.present? && @invoice.customer.shipping_address.present?)
      shipping_add<<[{:content=>"#{@invoice.account.name }", :font_style=>:bold, :align=>:left}]
      shipping_add<<[{:content=>"#{@invoice.customer.shipping_address.address_line1}", :align=>:left}]  unless @invoice.customer.shipping_address.blank?
      shipping_add<<[{:content=>"City: #{@invoice.customer.shipping_address.city}",:align=>:left}] unless @invoice.customer.shipping_address.city.blank?
      shipping_add<<[{:content=>"State: #{@invoice.customer.shipping_address.state}",:align=>:left}] unless @invoice.customer.shipping_address.state.blank?
      shipping_add<<[{:content=>"Country: #{@invoice.customer.shipping_address.country}",:align=>:left}] unless @invoice.customer.shipping_address.country.blank?
      shipping_add<<[{:content=>"Postal Code: #{@invoice.customer.shipping_address.postal_code}",:align=>:left}] unless @invoice.customer.shipping_address.postal_code.blank?
    elsif (@invoice.vendor.present? && @invoice.vendor.shipping_address.present?)
      shipping_add<<[{:content=>"#{@invoice.account.name }", :font_style=>:bold, :align=>:left}]
      shipping_add<<[{:content=>"#{@invoice.vendor.shipping_address.address_line1}", :align=>:left}]  unless @invoice.vendor.shipping_address.blank?
      shipping_add<<[{:content=>"City: #{@invoice.vendor.shipping_address.city}",:align=>:left}] unless @invoice.vendor.shipping_address.city.blank?
      shipping_add<<[{:content=>"State: #{@invoice.vendor.shipping_address.state}",:align=>:left}] unless @invoice.vendor.shipping_address.state.blank?
      shipping_add<<[{:content=>"Country: #{@invoice.vendor.shipping_address.country}",:align=>:left}] unless @invoice.vendor.shipping_address.country.blank? 
      shipping_add<<[{:content=>"Postal Code: #{@invoice.vendor.shipping_address.postal_code}",:align=>:left}] unless @invoice.vendor.shipping_address.postal_code.blank?
    end
    shipping_add
  end


  def time_invoice_item_header
    if @template == 'Retail'
      sub_data=[{:content=>"Sr.no.",:align=>:center},{:content=>"Task",:align=>:center},{:content=>"Description",:align=>:center},{:content=>"Hours",:align=>:center},{:content=>"Rate", :align=>:center},{:content=>"Amount", :align=>:center}]
    elsif @template == 'professional'
      sub_data=[{:content=>"Sr.no.",:align=>:center},{:content=>"Task Description",:align=>:center},{:content=>"Hours",:align=>:center},{:content=>"Rate", :align=>:center},{:content=>"Amount", :align=>:center}]
      if @invoice.discount>0
        sub_data.insert(4, {:content=>"Disc%", :align=>:right})
        if @invoice.tax != 0
          sub_data.insert(5, {:content=>"Tax"})
          sub_data.insert(6, {:content=>"Tax Amount", :align=>:right})
        end
      elsif @invoice.tax != 0
        sub_data.insert(4, {:content=>"Tax"})
        sub_data.insert(5, {:content=>"Tax Amount", :align=>:right})
      end
    else
      sub_data=["Task","Description",{:content=>"Hours",:align=>:right},{:content=>"Rate", :align=>:right},{:content=>"Amount", :align=>:right}]
      if @invoice.discount>0
        sub_data.insert(4, {:content=>"Disc%", :align=>:right})
        if @invoice.tax != 0
          sub_data.insert(5, {:content=>"Tax"})
          sub_data.insert(6, {:content=>"Tax Amount", :align=>:right})
        end
      elsif @invoice.tax != 0
        sub_data.insert(4, {:content=>"Tax"})
        sub_data.insert(5, {:content=>"Tax Amount", :align=>:right})
      end
    end

    sub_data
  end

  def task_rows
    line_items=[]
    n=0
    @time_line_items.each do |line_item|
      n+=1
      if @template =='Retail'
        sub_data=[{:content=>"#{n}"},{:content=>"#{line_item.item_name}"}, {:content=>"#{line_item.description}"}, {:content=>"#{line_item.quantity}",:align=>:right}, {:content=>"#{line_item.item_cost.to_s}", :align=>:right}, {:content=>"#{line_item.amount.to_s}", :align=>:right}]

      elsif @template =='professional'
        sub_data=[{:content=>"#{n}"},{:content=>"#{line_item.item_name}"+"#{line_item.description}"}, {:content=>"#{line_item.quantity}",:align=>:right}, {:content=>"#{line_item.item_cost.to_s}", :align=>:right}, {:content=>"#{ line_item.amount.to_s}", :align=>:right}]
        if @invoice.discount>0
          sub_data.insert(4, {:content=>"#{line_item.discount_percent}", :align=>:right})
          if @invoice.tax != 0
            sub_data.insert(5, {:content=>"#{@view_context.applied_taxes(line_item)}"})
            sub_data.insert(6, {:content=>"#{line_item.tax_amount unless line_item.tax_accounts.blank?}", :align=>:right})
          end
        elsif @invoice.tax != 0 && @template !='Retail'
          sub_data.insert(4, {:content=>"#{@view_context.applied_taxes(line_item)}"})
          sub_data.insert(5, {:content=>"#{line_item.tax_amount unless line_item.tax_accounts.blank?}", :align=>:right})
        end

      else
        sub_data=[{:content=>"#{line_item.item_name}"}, {:content=>"#{line_item.description}"}, {:content=>"#{line_item.quantity}",:align=>:right}, {:content=>"#{line_item.item_cost.to_s}", :align=>:right}, {:content=>"#{  line_item.amount.to_s}", :align=>:right}]

        if @invoice.discount>0 && @template !='Retail'
          sub_data.insert(4, {:content=>"#{line_item.discount_percent}", :align=>:right})
          if @invoice.tax != 0
            sub_data.insert(5, {:content=>"#{@view_context.applied_taxes(line_item)}"})
            sub_data.insert(6, {:content=>"#{line_item.tax_amount unless line_item.tax_accounts.blank?}", :align=>:right})
          end
        elsif @invoice.tax != 0 && @template !='Retail'
          sub_data.insert(4, {:content=>"#{@view_context.applied_taxes(line_item)}"})
          sub_data.insert(5, {:content=>"#{line_item.tax_amount unless line_item.tax_accounts.blank?}", :align=>:right})
        end
      end
      line_items<<sub_data
    end
    line_items
  end

  def invoice_items_header
    if @template!='professional'&&@template!='minimalist'&& @template!='Retail'
      sub_data=[{:content=>"#{!@company.invoice_setting.item_label.blank? ? @company.invoice_setting.item_label : 'Item'}"},{:content=>"#{!@company.invoice_setting.desc_label.blank? ? @company.invoice_setting.desc_label : 'Description'}"}, {:content=>"#{!@company.invoice_setting.qty_label.blank? ? @company.invoice_setting.qty_label : 'Qty'}",:align=>:right}, {:content=>"#{!@company.invoice_setting.rate_label.blank? ? @company.invoice_setting.rate_label : 'Unit Cost'}", :align=>:right}, {:content=>"#{!@company.invoice_setting.amount_label.blank? ? @company.invoice_setting.amount_label : 'Amount ('+"#{@invoice.currency}"}"+")", :align=>:right}]
      if @invoice.discount>0
        sub_data.insert(4, {:content=>"Disc%", :align=>:right})
        if @invoice.tax != 0
          sub_data.insert(5, {:content=>"Tax"})
          sub_data.insert(6, {:content=>"Tax Amount", :align=>:right})
        end
      elsif @invoice.tax != 0
        sub_data.insert(4, {:content=>"Tax"})
        sub_data.insert(5, {:content=>"Tax Amount", :align=>:right})
      end
      sub_data
    elsif @template == 'Retail'
      sub_data=[{:content=>"Sr.No"},{:content=>"Item",:align => :center},{:content=>"Description",:align => :center}, {:content=>"Quantity",:align=>:right}, {:content=>"Rate", :align=>:center}, {:content=>"Amount("+"#{@invoice.currency}"+")", :align=>:right}]
      sub_data
    elsif @template=='professional'
      sub_data=[{:content=>"#{!@company.invoice_setting.item_label.blank? ? @company.invoice_setting.item_label : 'Sr.No'}"},{:content=>"#{!@company.invoice_setting.desc_label.blank? ? @company.invoice_setting.desc_label : 'Item '}"}, {:content=>"#{!@company.invoice_setting.qty_label.blank? ? @company.invoice_setting.qty_label : 'Qty'}",:align=>:right}, {:content=>"#{!@company.invoice_setting.rate_label.blank? ? @company.invoice_setting.rate_label : 'Rate'}", :align=>:right}, {:content=>"#{!@company.invoice_setting.amount_label.blank? ? @company.invoice_setting.amount_label : 'Amount ('+"#{@invoice.currency}"}"+")", :align=>:right}]
      if @invoice.discount>0
        sub_data.insert(4, {:content=>"Disc%", :align=>:right})
        if @invoice.tax != 0
          sub_data.insert(5, {:content=>"Tax"})
          sub_data.insert(6, {:content=>"Tax Amount", :align=>:right})
        end
      elsif @invoice.tax != 0
        sub_data.insert(4, {:content=>"Tax"})
        sub_data.insert(5, {:content=>"Tax Amount", :align=>:right})
      end
      sub_data
    elsif @template=='minimalist' && @margin.HideRateQuantity != 1
      sub_data=[{:content=>"#{!@company.invoice_setting.item_label.blank? ? @company.invoice_setting.item_label : 'Sr.No'}"},{:content=>"#{!@company.invoice_setting.desc_label.blank? ? @company.invoice_setting.desc_label : 'Item'}"}, {:content=>"#{!@company.invoice_setting.qty_label.blank? ? @company.invoice_setting.qty_label : 'Qty'}",:align=>:right}, {:content=>"#{!@company.invoice_setting.rate_label.blank? ? @company.invoice_setting.rate_label : 'Rate'}", :align=>:right}, {:content=>"#{!@company.invoice_setting.amount_label.blank? ? @company.invoice_setting.amount_label : 'Amount ('+"#{@invoice.currency}"}"+")", :align=>:right}]
      sub_data
    elsif @template=='minimalist' && @margin.HideRateQuantity ==1
      sub_data=[{:content=>"#{!@company.invoice_setting.item_label.blank? ? @company.invoice_setting.item_label : 'Sr.No'}"},{:content=>"#{!@company.invoice_setting.desc_label.blank? ? @company.invoice_setting.desc_label : 'Item'}"}, {:content=>"#{!@company.invoice_setting.amount_label.blank? ? @company.invoice_setting.amount_label : 'Amount ('+"#{@invoice.currency}"}"+")", :align=>:right}]
      sub_data
    end

  end

  def product_rows
    line_items=Array.new
    if @template!='professional' && @template!='minimalist' &&  @template != 'Retail'
      @invoice_line_items.each do |line_item|
        if line_item.product.batch_enable?
          sub_data=[{:content=>"#{line_item.item_name}"},
                    {:content=>"#{@view_context.number_with_precision line_item.quantity, :precision=>(line_item.quantity.to_i==line_item.quantity ? 0 : 2) } #{line_item.product.unit_of_measure}",:align => :right},
                    {:content=>"#{@view_context.number_with_precision line_item.item_cost, :precision=>(line_item.item_cost == line_item.item_cost.round(2) ? 2 : 4)}", :align => :right},
                    {:content=>"#{@view_context.number_with_precision line_item.amount, :precision=>2}", :align => :right}]
          if line_item.description.blank?
            sub_data.insert(1, {:content=>"Batch numbers: #{line_item.batch_number}"})
          else
            sub_data.insert(1,{:content=>"#{line_item.description}, Batch numbers: #{line_item.batch_number}"})
          end

        else
          sub_data=[
            if line_item.product.inventory? && line_item.invoice.gst_invoice? && !line_item.product.hsn_code.blank?
              {:content=>"#{line_item.item_name}\n HSN: #{line_item.product.hsn_code}"}
            elsif line_item.product.inventory == false && line_item.invoice.gst_invoice? && !line_item.product.hsn_code.blank?
              {:content=>"#{line_item.item_name}\n SAC: #{line_item.product.hsn_code}"}
            else
              {:content=>"#{line_item.item_name}\n#{line_item.product.hsn_code}"}
            end,
                    {:content=>"#{line_item.description}"},
                    {:content=>"#{@view_context.number_with_precision line_item.quantity, :precision=>(line_item.quantity.to_i==line_item.quantity ? 0 : 2)} #{line_item.product.unit_of_measure}",:align => :right},
                    {:content=>"#{@view_context.number_with_precision line_item.item_cost, :precision=>((line_item.item_cost == line_item.item_cost.round(2) ? 2 : 4))}", :align => :right},
                    {:content=>"#{@view_context.number_with_precision line_item.amount, :precision=>2}", :align => :right}]
        end

        if @invoice.discount>0
          sub_data.insert(4, {:content=>"#{line_item.discount_percent}", :align=>:right})
          if @invoice.tax != 0
            sub_data.insert(5, {:content=>"#{@view_context.applied_taxes(line_item)}"})
            sub_data.insert(6, {:content=>"#{@view_context.number_with_precision line_item.tax_amount, :precision=>2 unless line_item.tax_accounts.blank?}", :align=>:right})
          end
        elsif @invoice.tax != 0
          sub_data.insert(4, {:content=>"#{@view_context.applied_taxes(line_item)}"})
          sub_data.insert(5, {:content=>"#{@view_context.number_with_precision line_item.tax_amount, :precision=>2 unless line_item.tax_accounts.blank?}", :align=>:right})
        end
        line_items<<sub_data
      end
      sub_data=["",{:content => "Total Qty", :font_style => :bold, :align => :right},{:content => " #{ @invoice.total_quantity}", :font_style => :bold, :align => :right},"",""]
      if @invoice.discount>0
        sub_data.insert(4, "")
        if @invoice.tax != 0
          sub_data.insert(5, "")
          sub_data.insert(6, "")
        end
      elsif @invoice.tax != 0
        sub_data.insert(4, "")
        sub_data.insert(5, "")
      end
      line_items<<sub_data
      # line_items

    elsif @template == 'Retail'
      n=0;
      @invoice_line_items.each do |line_item|
        n+=1
        if line_item.product.batch_enable?
          sub_data=[{:content=>"#{n}"},
            if line_item.product.inventory? && line_item.invoice.gst_invoice? && !line_item.product.hsn_code.blank?
              {:content=>"#{line_item.item_name}\n HSN: #{line_item.product.hsn_code}"}
            elsif line_item.product.inventory == false && line_item.invoice.gst_invoice? && !line_item.product.hsn_code.blank?
              {:content=>"#{line_item.item_name}\n SAC: #{line_item.product.hsn_code}"}
            else
              {:content=>"#{line_item.item_name}\n#{line_item.product.hsn_code}"}
            end,
                    
                    {:content=>"#{@view_context.number_with_precision line_item.quantity, :precision=>(line_item.quantity.to_i==line_item.quantity ? 0 : 2) } #{line_item.product.unit_of_measure}",:align => :right},
                    {:content=>"#{@view_context.number_with_precision line_item.item_cost, :precision=>(line_item.item_cost == line_item.item_cost.round(2) ? 2 : 4)}", :align => :right},
                    {:content=>"#{@view_context.number_with_precision line_item.amount, :precision=>2}", :align => :right}]

          if line_item.description.blank?
            sub_data.insert(2, {:content=>"Batch numbers: #{line_item.batch_number}"})
          else
            sub_data.insert(2,{:content=>"#{line_item.description}, Batch numbers: #{line_item.batch_number}"})
          end

        else
          sub_data=[{:content=>"#{n}"},
                      if line_item.product.inventory? && line_item.invoice.gst_invoice? && !line_item.product.hsn_code.blank?
              {:content=>"#{line_item.item_name}\n HSN: #{line_item.product.hsn_code}"}
             elsif line_item.product.inventory == false && line_item.invoice.gst_invoice? && !line_item.product.hsn_code.blank?
              {:content=>"#{line_item.item_name}\n SAC: #{line_item.product.hsn_code}"}
            else
               {:content=>"#{line_item.item_name}\n#{line_item.product.hsn_code}"}
            end,
                   
                    {:content=>"#{line_item.description}"},
                    {:content=>"#{@view_context.number_with_precision line_item.quantity, :precision=>(line_item.quantity.to_i==line_item.quantity ? 0 : 2)} #{line_item.product.unit_of_measure}",:align => :right},
                    {:content=>"#{@view_context.number_with_precision line_item.item_cost, :precision=>((line_item.item_cost == line_item.item_cost.round(2) ? 2 : 4))}", :align => :right},
                    {:content=>"#{@view_context.number_with_precision line_item.amount, :precision=>2}", :align => :right}]
        end
        line_items<<sub_data
      end

    elsif @template=='professional'
      n=0;
      # line_items=[]
      @invoice_line_items.each do |line_item|
        n+=1
        if line_item.product.batch_enable?
          sub_data=[{:content=>"#{n}"},
                    {:content=>"#{@view_context.number_with_precision line_item.quantity, :precision=>(line_item.quantity.to_i==line_item.quantity ? 0 : 2) } #{line_item.product.unit_of_measure}",:align => :right},
                    {:content=>"#{@view_context.number_with_precision line_item.item_cost, :precision=>(line_item.item_cost == line_item.item_cost.round(2) ? 2 : 4)}", :align => :right},
                    {:content=>"#{@view_context.number_with_precision line_item.amount, :precision=>2}", :align => :right}]
          if line_item.description.blank?
            sub_data.insert(1, {:content=>"#{line_item.item_name},"+"\n"+"Batch numbers: #{line_item.batch_number}"})
          else
            sub_data.insert(1,{:content=>"#{line_item.item_name},"+"\n"+"#{line_item.description} Batch numbers: #{line_item.batch_number}"})
          end
        else
          sub_data=[{:content=>"#{n}"},
                  if line_item.product.inventory? && line_item.invoice.gst_invoice? && !line_item.product.hsn_code.blank?
                    {:content=>"#{line_item.item_name}\n HSN: #{line_item.product.hsn_code}\n#{line_item.description}"}
                  elsif line_item.product.inventory == false && line_item.invoice.gst_invoice? && !line_item.product.hsn_code.blank?
                    {:content=>"#{line_item.item_name}\n SAC: #{line_item.product.hsn_code}\n#{line_item.description}"}
                    else
                      {:content=>"#{line_item.item_name}\n#{line_item.product.hsn_code}\n#{line_item.description}"}
                  end,
                    {:content=>"#{@view_context.number_with_precision line_item.quantity, :precision=>(line_item.quantity.to_i==line_item.quantity ? 0 : 2)} #{line_item.product.unit_of_measure}",:align => :right},
                    {:content=>"#{@view_context.number_with_precision line_item.item_cost, :precision=>((line_item.item_cost == line_item.item_cost.round(2) ? 2 : 4))}", :align => :right},
                    {:content=>"#{@view_context.number_with_precision line_item.amount, :precision=>2}", :align => :right}]
        end

        if @invoice.discount>0
          sub_data.insert(4, {:content=>"#{line_item.discount_percent}", :align=>:right})
          if @invoice.tax != 0
            sub_data.insert(5, {:content=>"#{@view_context.applied_taxes(line_item)}"})
            sub_data.insert(6, {:content=>"#{@view_context.number_with_precision line_item.tax_amount, :precision=>2 unless line_item.tax_accounts.blank?}", :align=>:right})
          end
        elsif @invoice.tax != 0
          sub_data.insert(4, {:content=>"#{@view_context.applied_taxes(line_item)}"})
          sub_data.insert(5, {:content=>"#{@view_context.number_with_precision line_item.tax_amount, :precision=>2 unless line_item.tax_accounts.blank?}", :align=>:right})
        end
        line_items<<sub_data
      end
    elsif @template=='minimalist' && @margin.HideRateQuantity == 1
      n=0;
      # line_items=[]
      @invoice_line_items.each do |line_item|
        n+=1
        if line_item.product.batch_enable?
          sub_data=[{:content=>"#{n}"},
                    {:content=>"#{@view_context.number_with_precision line_item.amount, :precision=>2}", :align => :right}]

          if line_item.description.blank?
            sub_data.insert(1, {:content=>"#{line_item.item_name},"+"\n"+"Batch numbers: #{line_item.batch_number}"})
          else
            sub_data.insert(1,{:content=>"#{line_item.item_name},"+"\n"+"#{line_item.description} Batch numbers: #{line_item.batch_number}"})
          end
        else
          sub_data=[{:content=>"#{n}"},
                    if line_item.product.inventory? && line_item.invoice.gst_invoice? && !line_item.product.hsn_code.blank?
                    {:content=>"#{line_item.item_name}\n HSN: #{line_item.product.hsn_code}\n#{line_item.description}"}
                 elsif line_item.product.inventory == false && line_item.invoice.gst_invoice? && !line_item.product.hsn_code.blank?
                    {:content=>"#{line_item.item_name}\n SAC: #{line_item.product.hsn_code}\n#{line_item.description}"}
                  else
                  {:content=>"#{line_item.item_name}\n#{line_item.product.hsn_code}\n#{line_item.description}"}
                  end,
                    {:content=>"#{@view_context.number_with_precision line_item.amount, :precision=>2}", :align => :right}]
        end

        line_items<<sub_data
      end
      line_items=line_items.concat(calculation_rows)
      unless @invoice.cash_invoice?
        line_items=line_items.concat(cash_customer_info)
      end

    elsif @template=='minimalist' && @margin.HideRateQuantity != 1
      n=0;
      # line_items=[]
      @invoice_line_items.each do |line_item|
        n+=1
        if line_item.product.batch_enable?
          sub_data=[{:content=>"#{n}"},
                    {:content=>"#{@view_context.number_with_precision line_item.amount, :precision=>2}", :align => :right}]

          if line_item.description.blank?
            sub_data.insert(1, {:content=>"#{line_item.item_name},"+"\n"+"Batch numbers: #{line_item.batch_number}"})
          else
            sub_data.insert(1,{:content=>"#{line_item.item_name},"+"\n"+"#{line_item.description} Batch numbers: #{line_item.batch_number}"})
          end
        else
          sub_data=[{:content=>"#{n}"},
                    if line_item.product.inventory? && line_item.invoice.gst_invoice? && !line_item.product.hsn_code.blank?
                    {:content=>"#{line_item.item_name}\n HSN: #{line_item.product.hsn_code}\n#{line_item.description}"}
                  elsif line_item.product.inventory == false && line_item.invoice.gst_invoice? && !line_item.product.hsn_code.blank?
                    {:content=>"#{line_item.item_name}\n SAC: #{line_item.product.hsn_code}\n#{line_item.description}"}
                    else
                      {:content=>"#{line_item.item_name}\n#{line_item.product.hsn_code}\n#{line_item.description}"}
                  end,
                    
                    {:content=>"#{@view_context.number_with_precision line_item.quantity, :precision=>(line_item.quantity.to_i==line_item.quantity ? 0 : 2)} #{line_item.product.unit_of_measure}",:align => :right},
                    {:content=>"#{@view_context.number_with_precision line_item.item_cost, :precision=>((line_item.item_cost == line_item.item_cost.round(2) ? 2 : 4))}", :align => :right},
                    {:content=>"#{@view_context.number_with_precision line_item.amount, :precision=>2}", :align => :right}]
        end

        line_items<<sub_data
      end
      line_items=line_items.concat(calculation_rows)
      unless @invoice.cash_invoice?
        line_items=line_items.concat(cash_customer_info)
      end
      # sub_data=["",{:content => "Sub Total", :align => :right},{:content => " #{ @invoice.sub_total}",:align => :right}]
      # line_items<<sub_data
      # sub_data=["",{:content => "Tax",:align => :right},{:content => " #{ @invoice.tax}",:align => :right}]
      # line_items<<sub_data
      # sub_data=["",{:content => " Total", :font_style => :bold, :align => :right},{:content => " #{ @invoice.total_amount}",:align => :right}]
      # line_items<<sub_data

    end
    line_items
  end

  def tax_rows
    line_items=Array.new
    @tax_line_items.each do |line_item|
      #code to not display GST parent tax items
      tax_account = line_item.account
      next if (tax_account.accountable_type=='DutiesAndTaxesAccounts' && tax_account.accountable.calculation_method==4 && tax_account.accountable.split_tax == 0)
      sub_data=["", "", ""]
      if @template == 'minimalist' && @margin.HideRateQuantity == 1
        sub_data.insert(@col_cnt+1, {:content => "#{line_item.account.name.chomp('on sales')}", :align => :right})
        sub_data.insert((@col_cnt+2), {:content => "#{format_amount @invoice.group_tax_amt(line_item.account_id).to_s}", :align => :right})
      elsif @template == 'minimalist' && @margin.HideRateQuantity != 1
        sub_data.insert((@col_cnt+1), "")
        sub_data.insert((@col_cnt+2), "")
        sub_data.insert(@col_cnt+3, {:content => "#{line_item.account.name.chomp('on sales')}", :align => :right})
        sub_data.insert((@col_cnt+4), {:content => "#{format_amount @invoice.group_tax_amt(line_item.account_id).to_s}", :align => :right})
      else
        sub_data.insert(@col_cnt, {:content => "#{line_item.account.name.chomp('on sales')}", :align => :right})
        sub_data.insert((@col_cnt+1), "")
        sub_data.insert((@col_cnt+2), {:content => "#{format_amount @invoice.group_tax_amt(line_item.account_id).to_s}", :align => :right})
      end	
      line_items<<sub_data
    end
    line_items
  end

  def calculation_rows
    line_items=Array.new
    sub_data=["", ""]
    if @template == 'minimalist' && @margin.HideRateQuantity != 1
      sub_data.insert((@col_cnt+1), "")
      sub_data.insert((@col_cnt+2), "")
      sub_data.insert(@col_cnt+3, {:content => "Sub total", :font_style => :bold, :align => :right})
      sub_data.insert((@col_cnt+4), {:content => "#{number_with_precision @invoice.sub_total, :precision=>2}", :font_style => :bold, :align => :right})
    elsif @template == 'minimalist' && @margin.HideRateQuantity == 1
      sub_data.insert(@col_cnt+1, {:content => "Sub total", :font_style => :bold, :align => :right})
      sub_data.insert((@col_cnt+2), {:content => "#{number_with_precision @invoice.sub_total, :precision=>2}", :font_style => :bold, :align => :right})
    else	
      sub_data.insert(@col_cnt, {:content => "Sub total", :font_style => :bold, :align => :right})
      sub_data.insert((@col_cnt+1), "")
      sub_data.insert((@col_cnt+2), {:content => "#{number_with_precision @invoice.sub_total, :precision=>2}", :font_style => :bold, :align => :right})
    end	
    line_items<<sub_data
    unless @invoice.tax==0
      #if @template!='professional' 
        line_items=line_items.concat(tax_rows)
      #end
    end

    @shipping_line_items.each do |line_item|
      sub_data = ["","",""]
      if @template == 'minimalist' && @margin.HideRateQuantity == 1
        sub_data.insert(@col_cnt+1, {:content => "#{line_item.account.name}", :align => :right})
        sub_data.insert((@col_cnt+2), {:content => "#{number_with_precision line_item.amount, :precision=>2}", :align => :right})
      elsif @template == 'minimalist' && @margin.HideRateQuantity != 1
        sub_data.insert((@col_cnt+1), "")
        sub_data.insert((@col_cnt+2), "")
        sub_data.insert(@col_cnt+3, {:content => "#{line_item.account.name}", :align => :right})
        sub_data.insert((@col_cnt+4), {:content => "#{number_with_precision line_item.amount, :precision=>2}", :align => :right})
      else
        sub_data.insert(@col_cnt, {:content => "#{line_item.account.name}", :align => :right})
        sub_data.insert((@col_cnt+1), "")
        sub_data.insert((@col_cnt+2), {:content => "#{number_with_precision line_item.amount, :precision=>2}", :align => :right})
      end
      line_items<<sub_data
    end

    if !@invoice.discount.blank? && @invoice.discount != 0
      sub_data=["", "", ""]
      if @template == 'minimalist' && @margin.HideRateQuantity == 1
        sub_data.insert(@col_cnt+1, {:content => "Discount", :font_style => :bold, :align => :right})
        sub_data.insert((@col_cnt+2), {:content => "#{number_with_precision @invoice.discount, :precision=>2}", :font_style => :bold, :align => :right})
      elsif @template == 'minimalist' && @margin.HideRateQuantity != 1
        sub_data.insert(@col_cnt, {:content => "Discount", :font_style => :bold, :align => :right})
        sub_data.insert((@col_cnt+1), "")
        sub_data.insert((@col_cnt+2), {:content => "#{number_with_precision @invoice.discount, :precision=>2}", :font_style => :bold, :align => :right})

      else
        sub_data.insert(@col_cnt, {:content => "Discount", :font_style => :bold, :align => :right})
        sub_data.insert((@col_cnt+1), "")
        sub_data.insert((@col_cnt+2), {:content => "#{number_with_precision @invoice.discount, :precision=>2}", :font_style => :bold, :align => :right})
      end	
      line_items<<sub_data
    end

    if  @invoice.tax!= 0
      sub_data=["", "", ""]
      if @template == 'minimalist' && @margin.HideRateQuantity == 1
        sub_data.insert(@col_cnt+1, {:content => "Tax #{@invoice.tax_inclusive? ? 'Inclusive' : 'Exclusive' }", :font_style => :bold, :align => :right})
        sub_data.insert((@col_cnt+2), {:content => " #{number_with_precision @invoice.tax, :precision=>2}", :font_style => :bold, :align => :right})
      elsif @template == 'minimalist' && @margin.HideRateQuantity != 1
        sub_data.insert((@col_cnt+1), "")
        sub_data.insert((@col_cnt+2), "")
        sub_data.insert(@col_cnt+3, {:content => "Tax #{@invoice.tax_inclusive? ? 'Inclusive' : 'Exclusive' }", :font_style => :bold, :align => :right})
        sub_data.insert((@col_cnt+4), {:content => " #{number_with_precision @invoice.tax, :precision=>2}", :font_style => :bold, :align => :right})
      else
        sub_data.insert(@col_cnt, {:content => "Tax #{@invoice.tax_inclusive? ? 'Inclusive' : 'Exclusive' }", :font_style => :bold, :align => :right})
        sub_data.insert((@col_cnt+1), "")
        sub_data.insert((@col_cnt+2), {:content => " #{number_with_precision @invoice.tax, :precision=>2}", :font_style => :bold, :align => :right})
      end
      line_items<<sub_data
    end


    sub_data=["", "", ""]
    if @template == 'minimalist' &&  @margin.HideRateQuantity == 1
      sub_data.insert(@col_cnt+1, {:content => "Total", :font_style => :bold, :align => :right})
      sub_data.insert((@col_cnt+2), {:content => "#{number_with_precision @invoice.total_amount, :precision=>2}", :font_style => :bold, :align => :right})
    elsif @template == 'minimalist' && @margin.HideRateQuantity != 1
      sub_data.insert((@col_cnt+1), "")
      sub_data.insert((@col_cnt+2), "")

      sub_data.insert(@col_cnt+3, {:content => "Total", :font_style => :bold, :align => :right})
      sub_data.insert((@col_cnt+4), {:content => "#{number_with_precision @invoice.total_amount, :precision=>2}", :font_style => :bold, :align => :right})

    else
      sub_data.insert(@col_cnt, {:content => "Total", :font_style => :bold, :align => :right})
      sub_data.insert((@col_cnt+1), "")
      sub_data.insert((@col_cnt+2), {:content => "#{number_with_precision @invoice.total_amount, :precision=>2}", :font_style => :bold, :align => :right})
    end
    line_items<<sub_data
    line_items
  end

  def cash_customer_info
    line_items=Array.new
    if @template == 'minimalist' &&  @margin.HideRateQuantity == 1
      sub_data=[{:content=>"#{'LBT Reg.No.' unless @company.lbt_registration_number.blank?}", :font_style=>:bold, :align=>:left},{:content=>"#{@company.lbt_registration_number}", :align=>:left }]
      sub_data.insert(@col_cnt+1, {:content => "Payment received", :font_style => :bold, :align => :right})
      sub_data.insert((@col_cnt+2), {:content => " #{@invoice.currency} #{number_with_precision @invoice.received_amt, :precision=>2}", :font_style => :bold, :align => :right})
    elsif @template == 'minimalist' &&  @margin.HideRateQuantity != 1
      sub_data=[{:content=>"#{'LBT Reg.No.' unless @company.lbt_registration_number.blank?}", :font_style=>:bold, :align=>:left},{:content=>"#{@company.lbt_registration_number}", :align=>:left }]
      sub_data.insert((@col_cnt+1), "")
      sub_data.insert((@col_cnt+2), "")
      sub_data.insert(@col_cnt+3, {:content => "Payment received", :font_style => :bold, :align => :right})
      sub_data.insert((@col_cnt+4), {:content => " #{@invoice.currency} #{number_with_precision @invoice.received_amt, :precision=>2}", :font_style => :bold, :align => :right})
    else
      sub_data=[{:content=>"#{'LBT Reg.No.' unless @company.lbt_registration_number.blank?}", :font_style=>:bold, :align=>:left},{:content=>"#{@company.lbt_registration_number}", :align=>:left }]
      sub_data.insert(@col_cnt, {:content => "Payment received", :font_style => :bold, :align => :right})
      sub_data.insert((@col_cnt+1), "")
      sub_data.insert((@col_cnt+2), {:content => " #{@invoice.currency} #{number_with_precision @invoice.received_amt, :precision=>2}", :font_style => :bold, :align => :right})
    end
    line_items<<sub_data

    if @receipt_vouchers.sum(:tds_amount) > 0
      sub_data= ["","",""]
      if @template == 'minimalist'
        sub_data.insert(@col_cnt+1, {:content => "TDS Amount", :font_style => :bold, :align => :right})
        sub_data.insert((@col_cnt+2), {:content => "#{number_with_precision @invoice.tds_amt, :precision=>2}", :font_style => :bold, :align => :right})
      else
        sub_data.insert(@col_cnt, {:content => "TDS Amount", :font_style => :bold, :align => :right})
        sub_data.insert((@col_cnt+1), "")
        sub_data.insert((@col_cnt+2), {:content => "#{number_with_precision @invoice.tds_amt, :precision=>2}", :font_style => :bold, :align => :right})
      end	
      line_items<<sub_data
    end

    if @invoice.has_return_any?
      sub_data= ["","",""]
      if @template == 'minimalist'
        sub_data.insert(@col_cnt+1, {:content => "Return Voucher Amount", :font_style => :bold, :align => :right})
        sub_data.insert((@col_cnt+2), {:content => "#{number_with_precision @invoice.credit_note_amount, :precision=>2}", :font_style => :bold, :align => :right})
      else
        sub_data.insert(@col_cnt, {:content => "Return Voucher Amount", :font_style => :bold, :align => :right})
        sub_data.insert((@col_cnt+1), "")
        sub_data.insert((@col_cnt+2), {:content => "#{number_with_precision @invoice.credit_note_amount, :precision=>2}", :font_style => :bold, :align => :right})
      end	
      line_items<<sub_data
    end

    if @invoice.has_credit_allocation_any?
      sub_data= ["","",""]
      sub_data.insert(@col_cnt, {:content => "Credit Note Amount", :font_style => :bold, :align => :right})
      sub_data.insert((@col_cnt+1), "")
      sub_data.insert((@col_cnt+2), {:content => "#{number_with_precision @invoice.allocated_credit, :precision=>2}", :font_style => :bold, :align => :right})
      line_items<<sub_data
    end
    if [0, 4].include?(@invoice.invoice_status_id) && @invoice.outstanding>0
      sub_data = ["","",""]
      if @template == 'minimalist' && @margin.HideRateQuantity == 1
        sub_data.insert(@col_cnt+1, {:content => "Balance due", :font_style => :bold, :align => :right})
        sub_data.insert((@col_cnt+2), {:content => " #{@invoice.currency} #{number_with_precision @invoice.outstanding, :precision=>2 }", :font_style => :bold, :align => :right})
      elsif @template == 'minimalist' && @margin.HideRateQuantity != 1
        sub_data.insert((@col_cnt+1), "")
        sub_data.insert((@col_cnt+2), "")
        sub_data.insert(@col_cnt+3, {:content => "Balance due", :font_style => :bold, :align => :right})
        sub_data.insert((@col_cnt+4), {:content => " #{@invoice.currency} #{number_with_precision @invoice.outstanding, :precision=>2 }", :font_style => :bold, :align => :right})
      else
        sub_data.insert(@col_cnt, {:content => "Balance due", :font_style => :bold, :align => :right})
        sub_data.insert((@col_cnt+1), "")
        sub_data.insert((@col_cnt+2), {:content => " #{@invoice.currency} #{number_with_precision @invoice.outstanding, :precision=>2 }", :font_style => :bold, :align => :right})
      end	
      line_items<<sub_data
    end
    line_items
  end

  def invoice_rows
    line_items=Array.new
    if @invoice.time_invoice?
      line_items<<time_invoice_item_header
      line_items=line_items.concat(task_rows)
    else
      line_items<<invoice_items_header
      line_items=line_items.concat(product_rows)
    end
    @col_cnt=@invoice.pdf_column_count

    if @template!='minimalist' 
      line_items=line_items.concat(calculation_rows)
      unless @invoice.cash_invoice?
        line_items=line_items.concat(cash_customer_info)
      end
    end

    self.y=@pos_arr.min.to_i-5
    n = @invoice.time_invoice? ? @time_line_items.count : @invoice_line_items.count
    d_width = (bounds.width-260)/3 if @invoice.discount==0 && @invoice.tax==0
    span(bounds.width, :position=>:left) do
      if @template=='Tabular'
        n+=1
        if @invoice.time_invoice?
          table(line_items, :header=>true, :width=>bounds.width+10,:row_colors => ["FFFFFF"] , :cell_style =>{:border_width => 0,:border_color => "000000",  :size => 8}, :column_widths => {0 =>50,1=>150,2=>35}) do
            row(0).font_style = :bold
            row(0).background_color = 'F2F7FF'
            row(0).borders = [:top,:right,:bottom,:left]
            row(1..n).borders = [:right,:left]
            row(n).borders = [:top]
            row(0..n).border_width = 0.2
            row(n).border_width = 0.2
            if d_width.present? && d_width>0
              column(2).width=d_width
              column(3).width=d_width
              column(4).width=d_width
            end
          end
        else
          table(line_items, :header=>true, :width=>bounds.width+10,:row_colors => ["FFFFFF"] , 
                :cell_style =>{:border_width => 0,:border_color => "000000",  :size => 8}, :column_widths => {0=>80, 3=> 75, 4=>75}) do
            row(0).font_style = :bold
            row(0).background_color = 'F2F7FF'
            row(0).borders = [:top,:right,:bottom,:left]
            row(1..n).borders = [:right,:left]
            row(n).borders = [:top]
            row(0..n).border_width = 0.2
            row(n).border_width = 0.2
            if d_width.present? && d_width>0
              column(2).width=d_width
              column(3).width=d_width
              column(4).width=d_width
            end
          end
        end
      elsif @template=='SMB'
        if @invoice.time_invoice?
          table(line_items, :header=>true, :width=>bounds.width+10,:row_colors => ["FFFFFF"] , :cell_style =>{:border_width => 0,:border_color => "000000",  :size => 8}, :column_widths => {0 =>50,1=>150,2=>35}) do
            row(0).font_style = :bold
            row(0).background_color = 'F2F7FF'
            row(0).borders = [:top,:right,:bottom,:left]
            row(1..n).borders = [:right,:left]
            row(n).borders = [:top]
            row(0..n).border_width = 0.2
            row(n).border_width = 0.2
            if d_width.present? && d_width>0
              column(2).width=d_width
              column(3).width=d_width
              column(4).width=d_width
            end
          end
        else
          table(line_items, :header=>true, :width=>bounds.width-5,:row_colors => ["FFFFFF"] , 
                :cell_style =>{:border_width => 0,:border_color => "000000",  :size => 8}, :column_widths => {0=>80, 1=> 100}) do
            row(0).font_style = :bold
            row(0).background_color = 'F2F7FF'
            row(0).borders = [:top,:right,:bottom,:left]
            row(1..n).borders = [:right,:left]
            row(n).borders = [:right, :bottom, :left]
            row(0..n).border_width = 0.2
            row(n).border_width = 0.2
            if d_width.present? && d_width>0
              column(2).width=d_width
              column(3).width=d_width
              column(4).width=d_width
            end
          end
        end

      elsif @template=='professional' 
        if @invoice.time_invoice?
          table(line_items, :header=>true, :width=>bounds.width+10,:row_colors => ["FFFFFF"] , :cell_style =>{:border_width => 0,:border_color => "000000",  :size => 8}, :column_widths => {0 => 30,1=>220,2=>35}) do
            row(0).font_style = :bold
            row(0).background_color = 'F2F7FF'
            row(0).borders = [:top,:right,:bottom,:left]
            row(1..n).borders = [:right,:left]
            row(n).borders = [:right,:left,:bottom]
            row(0..n).border_width = 0.2
            row(n).border_width = 0.2
            if d_width.present? && d_width>0
              column(2).width=d_width
              column(3).width=d_width
              column(4).width=d_width
            end
          end
        else
          table(line_items, :header=>true, :width=>bounds.width+10,:row_colors => ["FFFFFF"] , :cell_style =>{:border_width => 0,:border_color => "000000",  :size => 8}, :column_widths => {0 => 30,1=>200,2=>40,3=>50}) do
            row(0).font_style = :bold
            row(0).background_color = 'F2F7FF'
            row(0).borders = [:top,:right,:bottom,:left]
            row(1..n).borders = [:right,:left]
            row(n).borders = [:right,:left,:bottom]
            row(0..n).border_width = 0.2
            row(n).border_width = 0.2
            if d_width.present? && d_width>0
              column(2).width=d_width
              column(3).width=d_width
              column(4).width=d_width
            end
          end
        end


      elsif @template=='minimalist' && @margin.HideRateQuantity != 1
        box_width=(bounds.width-20)/ 3
        y_offset=cursor-5
        bounding_box([box_width-150, y_offset], :width=>box_width+350) do
          table(line_items,:header=>true, :width=>bounds.width+40,:row_colors => ["FFFFFF"] , :cell_style =>{:border_width => 0,:border_color => "000000",  :size => 8},:column_widths => {0 => 50, 1 => 160, 2=>70, 3 => 120, 4 => 100}) do
            row(0).font_style = :bold
            row(0).background_color = 'F2F7FF'
            row(0).borders = [:top,:right,:bottom,:left]
            row(1..n).borders = [:right,:left,:bottom]
            row(n).borders = [:right,:left,:bottom]
            row(0..n).border_width = 0.2
            # row(n+1..n+3).borders = [:right,:bottom,:left]
            #       row(n+1..n+3).border_width = 0.2
            if d_width.present? && d_width>0
              column(2).width=d_width
              column(3).width=d_width
              column(4).width=d_width
            end
          end
        end

      elsif @template=='minimalist' && @margin.HideRateQuantity == 1
        box_width=(bounds.width-20)/ 3
        y_offset=cursor-5
        bounding_box([box_width-150, y_offset], :width=>box_width+500) do
          table(line_items,:header=>true, :width=>bounds.width,:row_colors => ["FFFFFF"] , :cell_style =>{:border_width => 0,:border_color => "000000",  :size => 8},:column_widths => {0=>20}) do
            row(0).font_style = :bold
            row(0).background_color = 'F2F7FF'
            row(0).borders = [:top,:right,:bottom,:left]
            row(1..n).borders = [:right,:left,:bottom]
            row(n).borders = [:right,:left,:bottom]
            row(0..n).border_width = 0.2
            # row(n+1..n+3).borders = [:right,:bottom,:left]
            #       row(n+1..n+3).border_width = 0.2
            if d_width.present? && d_width>0
              column(2).width=d_width
              column(3).width=d_width
              column(4).width=d_width
            end
          end
        end
      else
        #This was modified to control width of all columns for invoice line items display.
        #Now controlling width of pricing column to take care of most of the issues.
        #Author: Ashish Wadekar
        #Date: 8 March 2017
        table(line_items, :header=>true, :width=>bounds.width+10,:row_colors => ["FFFFFF"] , :cell_style =>{:border_width => 0,:border_color => "000000", :size => 8}, :column_widths => {0 => 100, 1 => 150, 3 => 50 }) do
          row(0).font_style = :bold
          row(0).background_color = 'F2F7FF'
          row(0).borders = [:top,:bottom]
          row(0).border_width = 0.2
          row(n).borders = [:bottom]
          row(n).border_width = 0.2
          if d_width.present? && d_width>0
            column(2).width=d_width
            column(3).width=d_width
            column(4).width=d_width
          end
        end
      end
    end
  end

  def amount_words
    currency_array = ['INR', 'PKR']
      if currency_array.include?(@invoice.currency)
      bounding_box([0, cursor], :width=>bounds.width/2) do
        text " <b>Amount in words:</b> ",:align => :left, :size=> 8, :inline_format => true
        text"#{amount_in_words(@invoice.total_amount)}",:align => :left, :size=> 8, :inline_format => true
        text " "
      end
    end
  end


  def company_tax_info
    if @company.pan.present? || @company.tin.present? || @company.VAT_no.present? || @company.CST_no.present? || @company.service_tax_reg_no.present? || @company.GSTIN.present?
      if @template =='Thermal'
        self.y=self.y+10
      else
        self.y=self.y
      end  	

      if @template =='minimalist'
        bound_limit = bounds.width-70
      else
        bound_limit = bounds.width-10
      end  
      span(bound_limit, :position=>:center,:align=>:top) do
        text "<b>Tax Details: </b>", :size=> 8, :inline_format => true
        data=Array.new
        # data<<[{:content=>"Tax Details :", :font_style=>:bold}]
        if @company.GSTIN.present?
          data<<[{:content=>"GSTIN", :font_style=>:bold}, ": #{@company.GSTIN}"]
        end
        if @company.pan.present?
          data<<[{:content=>"PAN", :font_style=>:bold}, ": #{@company.pan}"]
        end
        if @invoice.gst_invoice == false
          if @company.VAT_no.present?
            data<<[{:content=>"VAT", :font_style=>:bold}, ": #{@company.VAT_no}"]
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
        end
        if data.blank?
          data<<[{:content=>" ", :font_style=>:bold}, " "]
        end
        if @template == 'Retail'
          table(data, :cell_style =>{:padding_top=>1,:padding_bottom=>1, :border_width=>0, :size=>7}) do

          end
        else
          table(data, :cell_style =>{:padding_top=>2.5,:padding_bottom=>1.5, :border_width=>0, :size=>7}) do
          end
        end
      end
    end
  end

  def receipt_rows
    if @template!='minimalist' && @template !='Retail'
      receipt_info=Array.new

      sub_data=["Voucher Number","Voucher Date","Payment Received Date","Payment Mode" ,{:content => "Amount" , :align => :right}]
      sub_data.insert(4, {:content => "TDS", :align => :right}) if @receipt_vouchers.sum('tds_amount')>0
      receipt_info<<sub_data

      @receipt_vouchers.each do |invoice_receipt|
        receipt_voucher = invoice_receipt.receipt_voucher
        sub_data=["#{receipt_voucher.voucher_number}","#{receipt_voucher.voucher_date}","#{receipt_voucher.received_date}","#{receipt_voucher.payment_detail.payment_mode}",{:content => "#{@invoice.currency} #{format_amount invoice_receipt.amount.to_s}", :align => :right}]
        sub_data.insert(4, {:content => "#{@invoice.currency} #{invoice_receipt.tds_amount.to_s}", :align => :right}) if @receipt_vouchers.sum('tds_amount')>0
        receipt_info<<sub_data
      end
      if @receipt_vouchers.sum('tds_amount') > 0
        receipt_info<<["","","","",{:content => "Total", :font_style => :bold, :align => :right},{:content => " #{@invoice.currency} #{(format_amount @invoice.total_received_amt).to_s}", :font_style => :bold, :align => :right}]
      else
        receipt_info<<["","","",{:content => "Total", :font_style => :bold, :align => :right},{:content => " #{@invoice.currency} #{(format_amount @invoice.total_received_amt).to_s}", :font_style => :bold, :align => :right}]
      end
      self.y=self.y-7
      span(bounds.width, :position=>:left) do
        if @receipt_vouchers.blank?
          text "Payment is due for this invoice.",:size => 8
          move_down 5
        else
          text "Payment recieved for this invoice",:size => 8
          table(receipt_info, :header => true, :width => (bounds.width),:row_colors => ["FFFFFF"] , :cell_style =>{:height => 17, :border_width => 0,:border_color => "000000",  :size => 8}) do
            row(0).font_style = :bold
            row(0).background_color = 'F2F7FF'
            row(0).borders = [:top, :bottom]
            row(0).border_width = 0.2
            row(receipt_info.size).borders = [:bottom]
            row(receipt_info.size).border_width = 0.2
            row(receipt_info.size-1).background_color = ["70B8FF"]
            row(receipt_info.size-1).borders = [:top, :bottom]
            row(receipt_info.size-1).border_width = 0.2
          end
        end
      end
    else
      box_width=(bounds.width-20)/ 3
      y_offset=cursor-5
      bounding_box([box_width-150, y_offset], :width=>box_width+350) do
        receipt_info=Array.new

        sub_data=["Voucher Number","Voucher Date","Payment Received Date","Payment Mode" ,{:content => "Amount" , :align => :right}]
        sub_data.insert(4, {:content => "TDS", :align => :right}) if @receipt_vouchers.sum('tds_amount')>0
        receipt_info<<sub_data

        @receipt_vouchers.each do |invoice_receipt|
          receipt_voucher = invoice_receipt.receipt_voucher
          sub_data=["#{receipt_voucher.voucher_number}","#{receipt_voucher.voucher_date}","#{receipt_voucher.received_date}","#{receipt_voucher.payment_detail.payment_mode}",{:content => "#{@invoice.currency} #{invoice_receipt.amount.to_s}", :align => :right}]
          sub_data.insert(4, {:content => "#{@invoice.currency} #{invoice_receipt.tds_amount.to_s}", :align => :right}) if @receipt_vouchers.sum('tds_amount')>0
          receipt_info<<sub_data
        end
        if @receipt_vouchers.sum('tds_amount') > 0
          receipt_info<<["","","","",{:content => "Total", :font_style => :bold, :align => :right},{:content => " #{@invoice.currency} #{format_amount (@invoice.total_received_amt).to_s}", :font_style => :bold, :align => :right}]
        else
          receipt_info<<["","","",{:content => "Total", :font_style => :bold, :align => :right},{:content => " #{@invoice.currency} #{format_amount (@invoice.total_received_amt).to_s}", :font_style => :bold, :align => :right}]
        end
        self.y=self.y-7
        box_width=(bounds.width-20)/ 3
        y_offset=cursor-5
        bounding_box([box_width-173, y_offset], :width=>box_width+320) do
          if @receipt_vouchers.blank?
            text "Payment is due for this invoice.",:size => 8
            move_down 5
          else
            text "Payment recieved for this invoice",:size => 8
            table(receipt_info, :header => true, :width => (bounds.width),:row_colors => ["FFFFFF"] , :cell_style =>{:height => 17, :border_width => 0,:border_color => "70B8FF",  :size => 8}) do
              row(0).font_style = :bold
              row(0).background_color = 'F2F7FF'
              row(0).borders = [:top, :bottom,:left,:right]
              row(0).border_width = 0.2
              row(receipt_info.size).borders = [:bottom,:left,:right]
              row(receipt_info.size).border_width = 0.2
              row(receipt_info.size-1).background_color = ["70B8FF"]
              row(receipt_info.size-1).borders = [:top, :bottom]
              row(receipt_info.size-1).border_width = 0.2
            end
          end
        end
      end
    end
  end

  def page_footer
    page_count.times do |i|
      go_to_page(i+1)
      fill_color "ADADAD"
      if @footer.nil? || @footer.strip == ''
        draw_text "#{@company.watermark unless @company.watermark.blank?}", :at=>[0,-30], :size => 7
      else
        draw_text @footer.strip, :at => [0,-30], :size => 7
      end
      fill_color "000000"
      draw_text "Page : #{i+1} / #{page_count}", :at=>[bounds.width - 50,-30], :size => 8
    end
  end

  def customer_notes_and_terms

    if @template!='professional' && @template!='SMB' && @template!='minimalist'
      if !@invoice.customer_notes.blank?
        self.y=self.y-10
        span(bounds.width-250, :position=>:left) do
          text"<b>#{@company.label.customer_label} Notes:</b>", :size=> 8, :inline_format => true
          text "#{(@invoice.customer_notes)}",:size => 8
        end
      end

      if !@invoice.terms_and_conditions.blank?
        self.y=self.y-7
        span(bounds.width-220, :position=>:left) do
          text "<b>Terms & Conditions</b>",:size => 8, :inline_format => true
          text "#{(@invoice.terms_and_conditions)}",:size => 8
        end
      end
    else
      if !@invoice.customer_notes.blank?  && @template!='minimalist'
        self.y=self.y-10
        span(bounds.width-280, :position=>:left) do
          # text"<b>Notes:</b>", :size=> 8, :inline_format => true
          text "#{(@invoice.customer_notes)}",:size => 8
        end
      end
      if @template!='minimalist'
        if !@invoice.terms_and_conditions.blank?
            if @invoice.terms_and_conditions.to_s.size > 175 && self.y < 160 #This condition checks for long t&c (avg: 158) and also page area left Author: Ashish Wadekar
              start_new_page
              span(bounds.width-20, :position=>:left) do
                text "<b>Terms & Conditions</b>",:size => 8, :inline_format => true
                text "#{(@invoice.terms_and_conditions)}",:size => 8
              end
            else
              self.y=self.y-10
              span(bounds.width-280, :position=>:left) do
                text "<b>Terms & Conditions</b>",:size => 8, :inline_format => true
                text "#{(@invoice.terms_and_conditions)}",:size => 8
              end
            end
        end
      else
        if !@invoice.terms_and_conditions.blank?
          self.y=self.y-50
          span(bounds.width+100, :position=>:left) do
            text "<b>Terms & Conditions</b>",:size => 8, :inline_format => true
            text "#{(@invoice.terms_and_conditions)}",:size => 8
          end
        end
      end
    end
  end

  def retail
    box_width=(bounds.width)/2
    repeat :all do
      bounding_box([box_width-280, @top_pos.min.to_i-240], :height=>440,:width=>box_width+288) do
        stroke_bounds
      end
    end

    bounding_box([box_width-280,@top_pos.min.to_i-240], :height=>440,:width=>box_width+288) do
      stroke_bounds
      line_items=Array.new
      if @invoice.time_invoice?
        line_items<<time_invoice_item_header
        line_items=line_items.concat(task_rows)
      else
        line_items<<invoice_items_header
        line_items=line_items.concat(product_rows)
      end
      @col_cnt=@invoice.pdf_column_count
      n=10
      table(line_items, :header=>true, :width=>bounds.width-10, :cell_style =>{:border_width => -2,:border_color => "70B8FF",  :size => 10}, :column_widths => {0 => 35,1=>100,2=>220}) do
      end
      if !@invoice.time_invoice?
        repeat :all do
          bounding_box([(box_width)-282,@top_pos.min.to_i-413], :width=>box_width+287) do
            stroke_horizontal_rule
          end
          bounding_box([box_width-282,@top_pos.min.to_i-391], :height=>440,:width=>box_width-250) do
            stroke_bounds
          end
          bounding_box([box_width-282,@top_pos.min.to_i-391], :height=>440,:width=>box_width-150) do
            stroke_bounds
          end
          bounding_box([box_width +80,@top_pos.min.to_i-391], :height=>440,:width=>box_width-161) do
            stroke_bounds
          end
        end

      else
        repeat :all do
          bounding_box([(box_width)-282,@top_pos.min.to_i-413], :width=>box_width+287) do
            stroke_horizontal_rule
          end
          bounding_box([box_width-282,@top_pos.min.to_i-391], :height=>440,:width=>box_width-250) do
            stroke_bounds
          end
          bounding_box([box_width-282,@top_pos.min.to_i-391], :height=>440,:width=>box_width-150) do
            stroke_bounds
          end
          bounding_box([box_width +80,@top_pos.min.to_i-391], :height=>440,:width=>box_width-161) do
            stroke_bounds
          end
        end


      end

      bounding_box([(box_width)+80,@top_pos.min.to_i-776], :width=>box_width-161) do
        stroke_horizontal_rule
      end

      repeat 1..page_count-1 do
        bounding_box([box_width+138 ,@top_pos.min.to_i-391], :height=>440,:width=>box_width-133) do
          stroke_bounds
        end
      end


      go_to_page(page_count)
      bounding_box([box_width+138 ,@top_pos.min.to_i-391], :height=>385,:width=>box_width-133) do
        stroke_bounds
      end

    end

  end

  def retail_invoice_footer
    go_to_page(page_count)
    box_width=(bounds.width)/ 2
    y_offset=cursor-670

    bounding_box([box_width-104, y_offset-40], :height=>150,:width=>box_width-80) do
      stroke_bounds
      self.y=self.y-5
      span(box_width-80, :position=>:center) do
        if !@company.invoice_setting.invoice_footer.blank?
          text "#{@company.invoice_setting.invoice_footer[0..80]}", :inline_format=>true, :size => 8
        end
      end
    end
  end

  def retail_terms
    box_width=(bounds.width)/2
    y_offset=cursor-100

    bounding_box([box_width-280, y_offset+100], :height=>50,:width=>box_width+80) do
      stroke_bounds
    end

    # sub_data.insert(@col_cnt, {:content => "#{line_item.account.name.chomp('on sales')}", :align => :right})
    # sub_data.insert((@col_cnt+1), "")
    #     sub_data.insert((@col_cnt+2), {:content => "#{@invoice.group_tax_amt(line_item.account_id).to_s}", :align => :right})



    bounding_box([box_width +83, y_offset+100], :height=>50,:width=>box_width-162) do
      
      if @invoice.gst_invoice?
      draw_text('Discount', :at => [30, (bounds.top + 45)],:size => 10)
      draw_text('Sub Total', :at => [30, (bounds.top + 33)],:size => 10)     
      x = 21
      @tax_line_items.each do |line_item|
        tax_account = line_item.account
      next if (tax_account.accountable_type=='DutiesAndTaxesAccounts' && tax_account.accountable.calculation_method==4 && tax_account.accountable.split_tax == 0)

      draw_text("#{line_item.account.name.chomp('on sales')}", :at => [30, (bounds.top + x)],:size => 10)
      x = x - 12
      end
      else
        draw_text('Discount', :at => [30, (bounds.top + 42)],:size => 10)
        draw_text('Sub Total', :at => [30, (bounds.top + 25)],:size => 10)
        draw_text('Total Tax', :at => [30, (bounds.top + 10)],:size => 10)
      end
      draw_text(''+"", :at => [30, (bounds.top + 10)],:size => 12)
      draw_text('Grand Total', :at => [20, (bounds.bottom + 10)])
      stroke_bounds
    end

    bounding_box([box_width +204, y_offset+100], :height=>50,:width=>box_width-196) do
      
      if @invoice.gst_invoice?
      draw_text(''+"#{@invoice.discount}",:at => [20, (bounds.top + 45)],:size => 10)
      draw_text(''+"#{@invoice.sub_total}",:at => [20, (bounds.top + 33)],:size => 10)
      x = 21
      @tax_line_items.each do |line_item|
         tax_account = line_item.account
      next if (tax_account.accountable_type=='DutiesAndTaxesAccounts' && tax_account.accountable.calculation_method==4 && tax_account.accountable.split_tax == 0)

      draw_text(''+"#{@invoice.group_tax_amt(line_item.account_id).to_s}", :at => [20, (bounds.top + x)],:size => 10)
      x = x-12
      end
      else
        draw_text(''+"#{@invoice.discount}",:at => [20, (bounds.top + 42)],:size => 10)
        draw_text(''+"#{@invoice.sub_total}",:at => [20, (bounds.top + 25)],:size => 10)
        draw_text(''+"#{@invoice.tax}",:at => [20, (bounds.top + 10)],:size => 10)
      end

      draw_text(''+"#{@invoice.total_amount}", :at => [20, (bounds.bottom + 10)],:size => 12 )
      stroke_bounds
    end

    bounding_box([box_width, y_offset+100], :height=>100,:width=>box_width+290) do
      self.y=self.y-10
      span(box_width+80, :position=>:left) do
        text_box "#{@invoice.terms_and_conditions.split[0..60].join(' ')}", at: [bounds.left+5, 0],:size => 8
      end
      unless !@company.invoice_setting.view_payment? || @invoice.cash_invoice?	
        retail_receipt_rows
      end			
    end
  end

  def  retail_receipt_rows
    self.y= @top_pos.min.to_i-698
    span(bounds.width, :left=>20) do
      if @receipt_vouchers.blank?
        text "Payment is due for this invoice.",:size => 8
      else
        text "Payment recieved for this invoice"+" #{@invoice.currency} #{(@invoice.total_received_amt).to_s}",:size => 10
      end
    end
  end

  def retail_sign
    go_to_page(page_count)
    box_width=(bounds.width)/ 2
    y_offset=cursor-670

    bounding_box([box_width+115, y_offset-40], :height=>100,:width=>box_width-105) do
      stroke_horizontal_rule
      span(box_width-120, :position=>:right) do
        text_box 'For '+"#{@company.name[0..100]}", at: [bounds.left, -5],:size => 12
      end
      draw_text('Authorised Signatory', :at => [20, (bounds.bottom + 5)])
    end

    bounding_box([box_width-282, y_offset-140], :height=>100,:width=>box_width+290) do
      stroke_horizontal_rule
    end

    bounding_box([box_width-282 , y_offset-40], :height=>100,:width=>box_width+290) do
      stroke_horizontal_rule
      self.y=self.y-10
      span(box_width-110, :position=>:left) do
        text "#{@invoice.customer_notes[0..180]}", :length   => 3, :inline_format=>true, :size => 8
      end
    end
  end

  def authorised_signatory
    box_width=(bounds.width-20)/ 3
    bounding_box [bounds.left, bounds.bottom + 25], width: bounds.width do
      bounding_box([box_width+270, bounds.bottom + 18], :height=>30,:width=>box_width-80,:position=>:left) do
        stroke_bounds
      end
      bounding_box([box_width+230, bounds.bottom-5], :height=>10,:width=>box_width,:position=>:left) do
        text "[Authorised Signatory]", size: 8, align: :center
      end
    end
  end

  def notes_terms
    if !@invoice.customer_notes.blank? && @template!='Retail'
      if self.y<cursor+630
        self.y=self.y-20
        box_width=(bounds.width-20)/ 3
        y_offset=cursor-5
        bounding_box([box_width-150, y_offset], :width=>box_width+180) do
          text "<b>Terms & Conditions</b>",:size => 8, :inline_format => true
          text "#{(@invoice.terms_and_conditions)}",:align=>:left,:size => 8
        end
      else

        self.y=self.y-20
        box_width=(bounds.width-20)/ 3
        y_offset=cursor-5
        bounding_box([box_width-150, y_offset], :width=>box_width+180) do
          text "<b>Terms & Conditions</b>",:size => 8, :inline_format => true
          text "#{(@invoice.terms_and_conditions)}",:align=>:left,:size => 8
        end
      end
    end

    if !@invoice.terms_and_conditions.blank?
      if self.y<cursor+630
        self.y=self.y-20
        span(bounds.width-320, :position=>:right) do
          text "\n"+"[Authorised Signatory]" , :align => :center, :inline_format => true, :size => 8
        end
      else
        self.y=self.y+30
        span(bounds.width-320, :position=>:right) do
          text "\n"+"[Authorised Signatory]" , :align => :center, :inline_format => true, :size => 8
        end
      end
    end
  end

  def invoice_footer
    if @company.invoice_setting.footer_enabled?
      if @template=='professional'|| @template=='minimalist'|| @template=='SMB'
        bounding_box [bounds.left, bounds.bottom + 25], width: bounds.width do
          span(bounds.width-120, :position=>:left) do
            fill_color "000000"
            text "#{@company.invoice_setting.invoice_footer}", :inline_format=>true, :size => 7
          end
        end

      else
        self.y=cursor+5
        span(bounds.width, :position=>:left) do
          fill_color "000000"
          text "#{@company.invoice_setting.invoice_footer}", :inline_format=>true, :size => 7
        end
      end
    end
  end

  def invoice_line_items
    lines = [["#{!@company.invoice_setting.item_label.blank? ? @company.invoice_setting.item_label : 'Item'}",
              "#{!@company.invoice_setting.qty_label.blank? ? @company.invoice_setting.qty_label : 'Qty'}",
              "#{!@company.invoice_setting.rate_label.blank? ? @company.invoice_setting.rate_label : 'Rate'}",
              "#{!@company.invoice_setting.amount_label.blank? ? @company.invoice_setting.amount_label : 'Amount'}"]] +
        @invoice_line_items.map do |line|
          ["#{line.product.hsn_code}  #{line.item_name}", line.quantity, line.unit_rate, line.amount]
        end
              lines=lines +
                @tax_line_items.map do |line|
                ["", "", line.account.name.chomp("on sales"), @invoice.group_tax_amt(line.account_id)]
              end
              lines=lines + [["", "", "Sub total", @invoice.sub_total]]
              if @invoice.discount != 0
                lines=lines + [["","","Discount",@invoice.discount]]
              end
              if @invoice.tax!= 0
                lines=lines + [["","","Tax",@invoice.tax]]
              end
              lines= lines+[["","","Total",@invoice.total_amount]]
  end
end

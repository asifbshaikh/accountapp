class GstrAdvancePaymentPdf < Prawn::Document
  require 'open-uri'
  include ActionView::Helpers::NumberHelper
  include ApplicationHelper
  def initialize(gstr_advance_payment, view_context, gstr_advance_payment_line_items, tax_line_items, shipping_line_items)
    super(:page_layout => :portrait, :page_size => "A4", :top_margin=>10, :left_margin=>10, :right_margin=>10)
    @gstr_advance_payment=gstr_advance_payment
    @company=@gstr_advance_payment.company
    @view_context=view_context
    @created_by_user=User.find(@gstr_advance_payment.company_id)
    @customer = @gstr_advance_payment.to_account.customer.blank? ? @gstr_advance_payment.to_account.vendor : @gstr_advance_payment.to_account.customer
    @gstr_advance_payment_line_items=gstr_advance_payment_line_items

    @tax_line_items=tax_line_items
    @shipping_line_items =shipping_line_items
    @col_cnt=@view_context.gstr_advance_payment_line_count-3
    @pos_arr=[]
    @header_pos=[]
    send "generate_gstr_advance_payment"
  end

  def generate_gstr_advance_payment
    bounding_box([0, 800], :width => (bounds.width/2)-5) do 
      company_logo
      @header_pos<<y
    end
    bounding_box([380, 800], :width=>(bounds.width/2)) do
      table(branch_address, :width=>(bounds.width/3*2),:cell_style=>{:border_width=>0,:align=>:right, :inline_format=>true, :size=>9}) do
      end
      @header_pos<<y
    end
    bounding_box([0, (@header_pos.min.to_i-30)], :width=>bounds.width) do
      text "Advance Payment", :align => :center, :inline_format => true, :size => 14
      stroke_horizontal_rule  
    end
    box_width=(bounds.width-20)/ 3
    y_offset=cursor-5
    bounding_box([0, y_offset], :width=>box_width) do
      billing_add=bill_to
      table(billing_add,:width=>box_width,  :cell_style=>{:align =>:left,:inline_format=> true,:border_width =>0, :size => 8, :border_color => "70B8FF" })do
        row(0).borders = [:left, :right, :bottom, :top]
        row(0).background_color = 'F2F7FF'
        row(1..(billing_add.size-2)).borders = [:left, :right]
        row(billing_add.size - 1).borders = [:left, :right, :bottom]
        row(0..(billing_add.size - 1)).border_width = 0.1
      end
      @pos_arr<<y
    end
    unless @customer.shipping_address.blank?
      bounding_box([box_width+10, y_offset], :width=>box_width ) do
        shipping_add=ship_to
        table(shipping_add, :width=>box_width,   :cell_style=>{:align=>:left, :inline_format=>true, :border_width=>0, :size=>8, :border_color=>"70B8FF" }) do
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
      table(gstr_advance_payment_info, :width=>box_width, :row_colors=>["F2F7FF"], :cell_style=>{:align=>:left, :border_width=>0,:size=>8}) do
      end
      @pos_arr<<y
    end
    gstr_advance_payment_rows
    
    #customer_notes_and_terms
    page_footer
  end

  def company_logo
    if Rails.env.production?
      unless @company.logo_file_name.blank? 
        image open("#{@company.logo.url}"), :fit=>PageGeometry::SIZES["A8"]
        # @header_pos<<y
      end
    else
      image( "#{Rails.root}/app/assets/images/logo.png", :fit=>Prawn::Document::PageGeometry::SIZES["A10"])
    end
  end

  def gstr_advance_payment_info
    gstr_advance_payment_info=[]
    gstr_advance_payment_info<<[{:content=>"Advance Payment #:", :font_style=>:bold, :align=>:left}, {:content=>"#{@gstr_advance_payment.voucher_number}"}]
    gstr_advance_payment_info<<[{:content =>"Advance Payment Date:", :font_style => :bold, :align => :left}, {:content =>"#{@gstr_advance_payment.voucher_date.strftime("%d-%m-%Y")}"}]
    gstr_advance_payment_info<<[{:content=>"Amount:", :font_style=>:bold, :align=>:left}, {:content =>"#{@gstr_advance_payment.currency} #{format_amount(@gstr_advance_payment.amount)}"}]
    # if !@custom_field.blank? && !@company.plan.free_plan?
    #   if !@custom_field.custom_label1.blank? && !@gstr_advance_payment.custom_field1.blank?
    #     gstr_advance_payment_info<<[{:content=>"#{@custom_field.custom_label1}", :font_style=>:bold, :align=>:left},{:content=>"#{@gstr_advance_payment.custom_field1}"}]
    #   end
    #   if !@custom_field.custom_label2.blank? && !@gstr_advance_payment.custom_field2.blank?
    #     gstr_advance_payment_info<<[{:content=>"#{@custom_field.custom_label2}", :font_style=>:bold, :align=>:left},{:content=>"#{@gstr_advance_payment.custom_field2}"}]
    #   end 
    #   if !@custom_field.custom_label3.blank? && !@gstr_advance_payment.custom_field3.blank?
    #     gstr_advance_payment_info<<[{:content=>"#{@custom_field.custom_label3}", :font_style=>:bold, :align=>:left},{:content=>"#{@gstr_advance_payment.custom_field3}"}]
    #   end 
    # end
    gstr_advance_payment_info<<[{:content=>"Created by:", :font_style=>:bold, :align=>:left}, {:content=>"#{@gstr_advance_payment.created_by_user}"}]
    gstr_advance_payment_info
  end

  def branch_address
    address=Array.new
    address<<[{:content=>"#{@company.name}", :font_style=> :bold}]
    if !@created_by_user.branch.blank?
      address<<["#{@created_by_user.branch.address.get_address}"]  unless @created_by_user.branch.address.blank?
      address<<["Phone: #{@created_by_user.branch.phone}"] unless @created_by_user.branch.phone.blank?
    else
      address<<["#{@company.address.get_address}"] unless @company.address.blank?
      address<<["Phone: #{@company.phone}"] unless @company.phone.blank?
    end
    address
  end

  def bill_to
    billing_add=[]
    billing_add<<[{:content=>"Bill To:", :font_style=>:bold, :align=>:left}]
      billing_add<<[{:content=>"#{@gstr_advance_payment.to_account.name }", :font_style=>:bold, :align=>:left}]
      if !@customer.billing_address.blank? 
        billing_add<<[{:content=>"#{@customer.billing_address.address_line1}", :align=>:left}]  unless @customer.billing_address.blank?
        billing_add<<[{:content=>"City: #{@customer.billing_address.city}", :font_style=>:bold, :align=>:left}] unless @customer.billing_address.city.blank?
        billing_add<<[{:content=>"State: #{@customer.billing_address.state}", :font_style=>:bold, :align=>:left}] unless @customer.billing_address.state.blank?
      end
      billing_add<<[{:content=>"Email: #{@customer.email}", :align=>:left}] unless @customer.email.blank?
      billing_add<<[{:content=>"Contact: #{@customer.contact_number}", :align=>:left}] unless @customer.contact_number.blank?
      billing_add<<[{:content=>"GSTIN: #{@customer.gstn_id}", :align=>:left}] unless @customer.gstn_id.blank?
      billing_add<<[{:content=>"TIN: #{@customer.vat_tin}", :align=>:left}] unless @customer.vat_tin.blank?
      billing_add<<[{:content=>"PAN: #{@customer.pan}", :align=>:left}] unless @customer.pan.blank?
      billing_add<<[{:content=>"CST Reg.: #{@customer.cst_reg_no}", :align=>:left}] unless @customer.cst_reg_no.blank?
    billing_add
  end

  def ship_to
    shipping_add=Array.new
    shipping_add<<[{:content=>"Ship To:", :font_style=>:bold, :align=>:left}]
    shipping_add<<[{:content=>"#{@gstr_advance_payment.to_account.name }", :font_style=>:bold, :align=>:left}]
    shipping_add<<[{:content=>"#{@customer.shipping_address.address_line1}", :align=>:left}]  unless @customer.billing_address.blank?
    shipping_add
  end

  def gstr_advance_payment_items_header
    sub_data=[{:content=>"#{!@company.invoice_setting.item_label.blank? ? @company.invoice_setting.item_label : 'Item'}"},
      {:content=>"#{!@company.invoice_setting.desc_label.blank? ? @company.invoice_setting.desc_label : 'Description'}"},
      {:content=>"#{!@company.invoice_setting.qty_label.blank? ? @company.invoice_setting.qty_label : 'Qty'}",:align=>:right},
      {:content=>"#{!@company.invoice_setting.rate_label.blank? ? @company.invoice_setting.rate_label : 'Unit Cost'}", :align=>:right},
      {:content=>"#{!@company.invoice_setting.amount_label.blank? ? @company.invoice_setting.amount_label : 'Amt'}(#{@gstr_advance_payment.currency})", :align=>:right}]
    if @gstr_advance_payment.get_discount>0
      sub_data.insert(4, {:content=>"Disc%", :align=>:right})
    end
    if @gstr_advance_payment.has_tax_lines?
      sub_data.insert(@col_cnt, "Tax Rate")
      sub_data.insert(@col_cnt+1, {:content=> "Tax Amount", :align=>:right})
    end
    sub_data
  end

  def product_rows
    line_items=[]
    @gstr_advance_payment_line_items.each do |line_item|
        sub_data=[{:content=>"#{line_item.item_name}"},
                 {:content=>"#{line_item.description}"},
                 {:content=>"#{number_with_precision line_item.quantity, :precision=>2} #{line_item.product.unit_of_measure}",:align => :right},
                 {:content=>"#{number_with_precision line_item.item_unit_cost, :precision=>(line_item.item_unit_cost == line_item.item_unit_cost.round(2) ? 2 : 4)}", :align => :right},
                 {:content=>"#{format_amount(line_item.amount)}", :align => :right}]
      
      if @gstr_advance_payment.get_discount>0
        sub_data.insert(4, {:content=>"#{format_amount(line_item.discount) }", :align=>:right})
      end

      if @gstr_advance_payment.has_tax_lines?
        sub_data.insert(@col_cnt, "#{line_item.applied_taxes unless line_item.applied_taxes.blank? }")
        sub_data.insert(@col_cnt+1, {:content=>"#{format_amount(line_item.tax_amount) unless line_item.tax_amount.blank? }", :align=>:right})
      end
      line_items<<sub_data
    end
    sub_data=["",{:content => "Total Qty", :font_style => :bold, :align => :right},{:content => " #{ number_with_precision @gstr_advance_payment.total_quantity, :precision=>2}", :font_style => :bold, :align => :right},"",""]
    unless @gstr_advance_payment.get_discount>0
      sub_data.insert(4, "")
    end

    if @gstr_advance_payment.has_tax_lines?
      sub_data.insert(5, "")
      sub_data.insert(6, "")
    end
    line_items<<sub_data
    line_items
  end

  def tax_rows
    line_items=Array.new
    @tax_line_items.each do |line_item|
       tax_account = line_item.account
       next if (tax_account.accountable_type=='DutiesAndTaxesAccounts' && tax_account.accountable.calculation_method==4 && tax_account.accountable.split_tax == 0)
      sub_data=["", "", ""]
        sub_data.insert(@col_cnt, {:content => "#{line_item.account.name.chomp('on sales')}", :align => :right})
        sub_data.insert((@col_cnt+1), "")
        sub_data.insert((@col_cnt+2), {:content => "#{format_amount(@gstr_advance_payment.group_tax_amt(line_item.account_id))}", :align => :right})
      line_items<<sub_data
    end
    line_items
  end

  def calculation_rows
    line_items=Array.new

    sub_data=["", "", ""]
    sub_data.insert(@col_cnt, {:content => "Sub total", :font_style => :bold, :align => :right})
    sub_data.insert((@col_cnt+1), "")
    sub_data.insert((@col_cnt+2), {:content => "#{format_amount(@gstr_advance_payment.sub_total)}", :font_style => :bold, :align => :right})
    line_items<<sub_data

    if @gstr_advance_payment.get_discount != 0
      sub_data=["", "", ""]
      sub_data.insert(@col_cnt, {:content => "Discount", :font_style => :bold, :align => :right})
      sub_data.insert((@col_cnt+1), "")
      sub_data.insert((@col_cnt+2), {:content => "#{format_amount(@gstr_advance_payment.get_discount)}", :font_style => :bold, :align => :right})
      line_items<<sub_data
    end

    if  @gstr_advance_payment.has_tax_lines?
      sub_data=["", "", ""]
      sub_data.insert(@col_cnt, {:content => "Total tax ", :font_style => :bold, :align => :right})
      sub_data.insert((@col_cnt+1), "")
      sub_data.insert((@col_cnt+2), {:content => "#{ format_amount(@gstr_advance_payment.tax)}", :font_style => :bold, :align => :right})
      line_items<<sub_data
    end
    
    @shipping_line_items.each do |line_item|
      sub_data = ["","",""]
      sub_data.insert(@col_cnt, {:content => "#{line_item.account.name}", :align => :right})
      sub_data.insert((@col_cnt+1), "")
      sub_data.insert((@col_cnt+2), {:content => "#{format_amount(line_item.amount)}", :align => :right})

      line_items<<sub_data
    end

    sub_data=["", "", ""]
    sub_data.insert(@col_cnt, {:content => "Total", :font_style => :bold, :align => :right})
    sub_data.insert((@col_cnt+1), "")
    sub_data.insert((@col_cnt+2), {:content => "#{format_amount(@gstr_advance_payment.amount)}", :font_style => :bold, :align => :right}) #BUG FIX for improper total in tax inclusive scenarios Author: Ashish Wadekar
    line_items<<sub_data
    line_items
  end

  def gstr_advance_payment_rows
    line_items=Array.new
      line_items<<gstr_advance_payment_items_header
      line_items=line_items.concat(product_rows)
   
    # @col_cnt= @gstr_advance_payment.pdf_column_count
    unless @gstr_advance_payment.tax==0
      line_items=line_items.concat(tax_rows)
    end
    line_items=line_items.concat(calculation_rows)
    
    self.y=@pos_arr.min.to_i-5
    n = @gstr_advance_payment_line_items.count
    if  @gstr_advance_payment.tax == 0 && @gstr_advance_payment.get_discount==0
        column_widths = {2=>80, 3=>80, 4=>100 }
    elsif @gstr_advance_payment.get_discount ==0
        column_widths = {0 => 100, 1 => 150, 3=>80, 4=>80, 5 => 50, 6=>80 }
    else  
      column_widths = {0 => 100, 1 => 100, 4=>50, 5 => 80, 6=>60, 7=> 80 }
    end
    span(bounds.width, :position=>:left) do 
      table(line_items, :header=>true, :width=>bounds.width,:row_colors => ["FFFFFF"] , :cell_style =>{:border_width => 0,:border_color => "70B8FF",  :size => 8}, 
        :column_widths => column_widths) do
        row(0).font_style = :bold
        row(0).background_color = 'F2F7FF'
         row(0).borders = [:top,:bottom]
         row(0).border_width = 0.2
         row(n).borders = [:bottom]
         row(n).border_width = 0.2
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
  # def customer_notes_and_terms
  #   if !@gstr_advance_payment.customer_notes.blank?  
  #     self.y=cursor+5 
  #     span(bounds.width, :position=>:left) do
  #       text"<b>#{@company.label.customer_label} Notes:</b>", :size=> 8, :inline_format => true
  #       text "#{(@gstr_advance_payment.customer_notes)}",:size => 8
  #     end
  #   end

  #   if !@gstr_advance_payment.terms_and_conditions.blank?
  #     self.y=cursor+5
  #     span(bounds.width, :position=>:left) do
  #       text "<b>Terms & Conditions</b>",:size => 8, :inline_format => true
  #       text "#{(@gstr_advance_payment.terms_and_conditions)}",:size => 8
  #     end
  #   end 
  #end

  def gstr_advance_payment_line_items
    lines = [["#{!@company.gstr_advance_payment_setting.item_label.blank? ? @company.gstr_advance_payment_setting.item_label : 'Item'}",
              "#{!@company.gstr_advance_payment_setting.qty_label.blank? ? @company.gstr_advance_payment_setting.qty_label : 'Qty'}",
              "#{!@company.gstr_advance_payment_setting.rate_label.blank? ? @company.gstr_advance_payment_setting.rate_label : 'Rate'}",
              "#{!@company.gstr_advance_payment_setting.amount_label.blank? ? @company.gstr_advance_payment_setting.amount_label : 'Amount'}"]] +
        @gstr_advance_payment_line_items.map do |line|
          ["#{line.product.hsn_code}  #{line.item_name}", line.quantity, line.unit_rate, line.amount]
        end
              lines=lines +
                @tax_line_items.map do |line|
                ["", "", line.account.name.chomp("on sales"), @gstr_advance_payment.group_tax_amt(line.account_id)]
              end
              lines=lines + [["", "", "Sub total", @gstr_advance_payment.sub_total]]
              if @gstr_advance_payment.discount != 0
                lines=lines + [["","","Discount",@gstr_advance_payment.discount]]
              end
              if @gstr_advance_payment.tax!= 0
                lines=lines + [["","","Tax",@gstr_advance_payment.tax]]
              end
              lines= lines+[["","","Total",@gstr_advance_payment.total_amount]]
  end

end

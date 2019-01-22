module InvoicesHelper
  INVOICE_STATUS_BADGES = { draft: "badge", paid: "bg-primary", unpaid: "bg-warning", settled: "bg-info", returned: "bg-inverse"}.with_indifferent_access
  #[FIXME] Move ActiveRecord code
  def display_stock_quantity(swd)
    stock=Stock.find_by_warehouse_id_and_product_id(swd.warehouse_id, swd.product_id)
    result=0.0
    unless stock.blank?
      result+=stock.quantity
      # result+= swd.quantity unless swd.quantity.blank?
    end
    result
  end

  def available_quantity(invoice_line_item)
    avail_qty=invoice_line_item.product.quantity unless invoice_line_item.product.blank?
    avail_qty+=invoice_line_item.quantity unless invoice_line_item.quantity.blank? || @invoice.errors.any? || @invoice.draft?
    #  IF VALIDATION FAILS ----
    # @invoice.errors.any? is because in case validation fails, system will add invalid quantity which is entered in line item to total quantity
    # only product.quantity will return total quantity as keep_back_inventory() adds quantity back to stock before checking for validation
    # -------------------------
    avail_qty
  end

  def line_item_column_count
    columns=4
    columns+=1 if @invoice.discount>0
    columns+=2 if @invoice.tax>0
    columns
  end

 #[FIXME] Relocate this method to the address helper. We need to standardise the Address display(html.erb) and helper code for all screens
  def customer_billing_address(address)
    address_str=""
    unless address.blank?
      address_str+="<p></p><p>#{address.address_line1}</p>" unless address.address_line1.blank?
      address_str+="<p>City-#{address.city}</p>" unless address.city.blank?
      address_str+="<p>State-#{address.state}</p>" unless address.state.blank?
      address_str+="<p>Country-#{address.country}</p>" unless address.country.blank?
      address_str+="<p>Postal code-#{address.postal_code}</p>" unless address.postal_code.blank?
    end
    address_str.html_safe
  end

  def customer_details(customer)
    details = content_tag :h4, customer.name
    details = content_tag :h4, (content_tag :strong, customer.name)
    details += address(customer)

    if !customer.primary_phone_number.blank?
      details += content_tag :p do
        content_tag :i, customer.primary_phone_number, :class => 'icon-phone'
      end
    end
    details
  end

  def invoice_address_details
    customer = @invoice.account.customer.blank? ? @invoice.account.vendor : @invoice.account.customer
    details = content_tag :h4, customer.name
    details = content_tag :h4, (content_tag :strong, customer.name)
    details += address(@invoice)

    if !customer.primary_phone_number.blank?
      details += content_tag :p do
        content_tag :i, customer.primary_phone_number, :class => 'icon-phone'
      end
    end
    details
  end

  def cash_customer_details
    details = content_tag :h4, (content_tag :strong, @invoice.customer_name)

    if !@invoice.cash_customer_email.blank?
      details += content_tag :p do
          content_tag :i, @invoice.cash_customer_email, :class => 'icon-envelope-alt'
        end
    end
    if !@invoice.cash_customer_mobile.blank?
      details += content_tag :p do
          content_tag :i, @invoice.cash_customer_mobile, :class => 'icon-phone'
        end
    end
    details
  end

  def address(customer)
    content_tag :p do
      cnt = address_line1(customer).blank? ? "" : address_line1(customer)  
      cnt += '<br/>' + address_line2(customer) unless address_line2(customer).blank?
      cnt += ', ' + city(customer) unless city(customer).blank?
      cnt += ' ' + state(customer) unless state(customer).blank?
      cnt += ', ' + country(customer) unless country(customer).blank?
      cnt += ' - ' + postal_code(customer) unless postal_code(customer).blank?
      cnt
    end
  end

  def address_line1(customer)
    if !customer.billing_address.blank?
      customer.billing_address.address_line1 unless customer.billing_address.address_line1.blank?
    end
  end

  def address_line2(customer)
    if !customer.billing_address.blank?
      customer.billing_address.address_line2 unless customer.billing_address.address_line2.blank?
    end
  end

  def city(customer)
    if !customer.billing_address.blank?
      customer.billing_address.city unless customer.billing_address.city.blank?
    end
  end

  def state(customer)
    if !customer.billing_address.blank?
      customer.billing_address.state unless customer.billing_address.state.blank?
    end
  end

  def country(customer)
    if !customer.billing_address.blank?
      customer.billing_address.country unless customer.billing_address.country.blank?
    end
  end

  def postal_code(customer)
    if !customer.billing_address.blank?
      customer.billing_address.postal_code unless customer.billing_address.postal_code.blank?
    end
  end

  def invoice_status_badge(status)
    InvoicesHelper::INVOICE_STATUS_BADGES[status]
  end

  def invoice_overdue_days_in_words(due_date)
    distance_of_time_in_words(Time.zone.now.to_date, due_date)
  end


  def invoice_amount(invoice)
    format_amt_with_currency(invoice.currency, invoice.total_amount)
  end

  def copy_invoice_link
    if @invoice.cash_invoice?
      link_to raw('<i class="icon-copy"> </i> Copy into new'), {:controller => :invoices, :action => :copy_invoice, :id => @invoice.id, :cash_invoice => true}
    elsif @invoice.time_invoice?
      link_to raw('<i class="icon-copy"> </i> Copy into new'), {:controller => :invoices, :action => :copy_invoice, :id => @invoice.id, :time_invoice => true}
    else
      link_to raw('<i class="icon-copy"> </i> Copy into new'), {:controller => :invoices, :action => :copy_invoice, :id => @invoice.id}
    end
  end
 def edit_invoice_link
    if @invoice.cash_invoice?
      link_to raw('<i class="icon-edit"> </i> Edit'), {:controller => :invoices, :action => :edit, :id => @invoice.id, :cash_invoice => true},:class => 'btn btn-info btn-lg'
    elsif @invoice.time_invoice?
      link_to raw('<i class="icon-edit"> </i> Edit'), {:controller => :invoices, :action => :edit, :id => @invoice.id, :time_invoice => true},:class => 'btn btn-info btn-lg'
    else
      link_to raw('<i class="icon-edit"> </i> Edit'), {:controller => :invoices, :action => :edit, :id => @invoice.id},:class => 'btn btn-info btn-lg'
    end
  end

  def sales_amount(object)
    object.foreign_currency? ? object.total_amount*object.exchange_rate : object.total_amount
  end

  def outstanding_amount(object)
    object.foreign_currency? ? object.balance_due*object.exchange_rate : object.balance_due
  end

  def received_amount(object)
    object.foreign_currency? ? object.paid_amount*object.exchange_rate : object.paid_amount
  end
end
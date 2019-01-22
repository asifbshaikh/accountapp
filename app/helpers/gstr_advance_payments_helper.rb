module GstrAdvancePaymentsHelper
GSTR_ADVANCE_PAYMENT_STATUS_BADGES = { draft: "badge", allocated: "bg-primary", unallocated: "bg-warning", settled: "bg-info", returned: "bg-inverse"}.with_indifferent_access

	def address(customer)
    content_tag :p do
      cnt = address_line1(customer)
      cnt += '<br/>' + address_line2(customer) unless address_line2(customer).blank?
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

  def gstr_advance_payment_line_count
    columns=5
    columns+=1 if @gstr_advance_payment.get_discount>0
    columns+=2 if @gstr_advance_payment.has_tax_lines?
    columns
  end 

def gstr_advance_payment_status_badge(status)
    GstrAdvancePaymentsHelper::GSTR_ADVANCE_PAYMENT_STATUS_BADGES[status]
     end
  
end

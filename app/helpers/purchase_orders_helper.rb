module PurchaseOrdersHelper

	def vendor_details
		details = content_tag :h4, @purchase_order.vendor_name
		unless @purchase_order.account.accountable.PAN.blank?
			content_tag :p do
				content_tag :i, @purchase_order.account.accountable.PAN, :class => 'icon-credit-card'
			end
		end
		unless @purchase_order.account.accountable.address.blank?
			details += content_tag :p, @purchase_order.account.accountable.address.get_address
		end

		unless @purchase_order.account.accountable.email.blank?
			details += content_tag :p do
				content_tag :i, @purchase_order.account.accountable.email, :class => 'icon-envelope-alt'
			end
		end

		unless @purchase_order.account.accountable.contact_number.blank?
			details += content_tag :p do
				content_tag :i, @purchase_order.account.accountable.contact_number, :class => 'icon-phone'
			end
		end
		details
	end

	def vendor_shipping_details
		details = content_tag :h4, @purchase_order.vendor_name

		unless @purchase_order.account.accountable.address.blank?
			details += content_tag :p, @purchase_order.account.accountable.address.get_address
		end

		unless @purchase_order.account.accountable.email.blank?
			details += content_tag :p do
				content_tag :i, @purchase_order.account.accountable.email, :class => 'icon-envelope-alt'
			end
		end

		unless @purchase_order.account.accountable.contact_number.blank?
			details += content_tag :p do
				content_tag :i, @purchase_order.account.accountable.contact_number, :class => 'icon-phone'
			end
		end
		details
	end

	def po_status_badge
    status = @purchase_order.get_status
    if status == 'Purchased'
      "success"
    end
  end

end

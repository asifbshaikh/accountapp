module PurchasesHelper
	def purchase_outstanding(obj)
		obj.foreign_currency? ? obj.balance_due*obj.exchange_rate : obj.balance_due
	end
	def purchase_amount(obj)
		obj.foreign_currency? ? obj.total_amount*obj.exchange_rate : obj.total_amount
	end

	def vendor_details(vendor)
		details = content_tag :h4, (content_tag :strong, vendor.name)
			unless vendor.blank?
				unless vendor.pan.blank?
					content_tag :p do 
						content_tag :i, vendor.pan, :class => 'icon-credit-card'
					end
				end
				unless vendor.billing_address.blank?
					details += content_tag :p, vendor.billing_address.get_address
				end
				
				unless vendor.email.blank?
					details += content_tag :p do 
						content_tag :i, vendor.email, :class => 'icon-envelope-alt'
					end
				end
			# unless vendor.contact_no.blank?
			# 	details += content_tag :p do 
			# 		content_tag :i, vendor.contact_no, :class => 'icon-phone'
			# 	end
			# end
		end
		details
	end

	  def purchase_status_badge
    status = @purchase.get_status
    if status =='Paid'
      "success"
    elsif status == 'Settled'
      "info"
    else
    	"warning"
    end
  end

end

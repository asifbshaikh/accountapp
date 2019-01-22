class BillingLineItem < ActiveRecord::Base

  belongs_to :billing_invoice
  validates :amount, :numericality => {:greater_than_or_equal_to => 0.00}
#   validate :applicability_of_coupon

#   def applicability_of_coupon
#    coupon = Coupon.find_by_coupon_code('FEB5500')
#    if coupon.year != 12/12
#         errors.add(:base,"not applicable for this tenure")
#   end
# end

  def get_validity
  	vldt = '1 year'
  	unless validity.blank? 
	  	if validity < 1
	  		vldt = "#{(validity*30).ceil} days"
	  	else
	  		vldt = (validity/12) > 1 ? "#{validity/12} years" : "#{validity} months"
	  	end
	  end
  	vldt
  end

end
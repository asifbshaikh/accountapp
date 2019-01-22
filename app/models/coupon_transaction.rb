class CouponTransaction < ActiveRecord::Base
  belongs_to :coupon
  belongs_to :company
  belongs_to :user
end

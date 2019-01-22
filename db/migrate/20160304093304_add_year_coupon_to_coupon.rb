class AddYearCouponToCoupon < ActiveRecord::Migration
  def change
  	add_column :coupons,:year,:decimal
  end
end

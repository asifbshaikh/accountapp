class Coupon < ActiveRecord::Base
  has_many :coupon_transactions
  has_many :pbreferrals
  validates_presence_of :name, :coupon_code, :coupon_type,:discount, :date_start, :date_end
  validate :percent_or_fixed_amount
  validate :check_availability_of_coupon

  def percent_or_fixed_amount
    if !discount.blank? && coupon_type == "Percentage"
      errors.add(:discount, "can not be grater than 100%") if discount > 100
    end
  end
  def check_availability_of_coupon
    if !date_end.blank?
   coupon = Coupon.find_by_coupon_code(coupon_code)
    if !coupon.blank? && coupon.date_end > Time.zone.now.to_date
      errors.add(:coupon, "with same coupon code already exist !")
      end 
    end
  end

  def can_use?(company, order_total,validity)
    result = true
    if year != validity/12
      result = false
    elsif !order_total.blank? && order_total <= 0
      result = false
    elsif !total_amount.blank? && order_total > 0 && total_amount > order_total
      result = false
    elsif (!date_end.blank? && date_end < Time.zone.now.to_date) || status == "Disabled"
      result = false
    elsif !uses_per_coupon.blank? && coupon_transactions.count > uses_per_coupon
      result = false
    end
    result
  end

  def get_coupon_amount(order_total)
    coupon_amt = 0
    if coupon_type == 'Percentage'
      coupon_amt = order_total * (discount.to_f / 100)
    else
      coupon_amt = discount
    end
    coupon_amt
  end

  def mark_disabled
    update_attributes(:status => "Disabled")
  end

  def self.create_referral_coupon(email, count)
     coupon = Coupon.new(
      :name => "PBReferral Coupon",
      :coupon_code => "REFBY"+email,
      :coupon_type => "Referral",
      :discount => 0,
      :total_amount => 2500,
      :date_start => Time.zone.now.to_date,
      :date_end => 30.days.from_now,
      :uses_per_coupon=> count,
      :uses_per_customer => 1,
      :status => "Enabled"
      )
     coupon.save!
     coupon
  end
end

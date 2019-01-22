module DeliveryChallansHelper

  def dc_created_date(delivery_challan)
    delivery_challan.created_at.to_date.strftime("%d-%m-%Y")
  end

  def dc_created_by(delivery_challan)
    delivery_challan.created_by_user
  end

end

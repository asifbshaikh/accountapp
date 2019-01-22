class PurchaseManager
  require 'purchase_b2b_rule'
 
 

  #Purchase Classification
  RULES = [PurchaseB2BRule.new]

  def classify_purchase(purchase)
    type = nil
    RULES.each do |rule|
      type = rule.classify(purchase)
      if type.present?
        break 
      end
    end
    Rails.logger.debug "classification is #{type}"
    type
  end

end



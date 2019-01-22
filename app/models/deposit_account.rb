class DepositAccount < ActiveRecord::Base
  INTEREST_TYPES = { "1" => "Daily", "2" => "Monthly", "3" => "Quarterly", "4" => "Yearly", "5" => "Payout"}

  def compounding=(name)
      self.compounding_type = INTEREST_TYPES.index(name)
  end

  def compounding 
    INTEREST_TYPES[self.compounding_type.to_s]
  end  
end

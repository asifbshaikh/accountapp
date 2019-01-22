class LineItem < ActiveRecord::Base
  #validation
  validates :amount, :numericality => {:greater_than_or_equal_to => 0.01,
                                        :message => " should not be zero or negative ." }
end

class SaccountingToLineItem < ActiveRecord::Base
  belongs_to :saccounting
  #validation
  validates :amount, :numericality => {:greater_than_or_equal_to => 0.01,
                                        :message => " should not be zero or negative ." }
  validates :to_account_id, :uniqueness => { :scope => :saccounting_id, :message => "should once per simple account entry" }
end

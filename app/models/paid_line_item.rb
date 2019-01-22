class PaidLineItem < ActiveRecord::Base
  belongs_to :expense

  #validations
  validates_presence_of :account_id, :amount
  validates :amount, :numericality => {:greater_than_or_equal_to => 0.01,
                                        :message => " should not be zero or negative ." }
   validates :account_id, :uniqueness => { :scope => :expense_id, :message => "should once per expense entry" }

end

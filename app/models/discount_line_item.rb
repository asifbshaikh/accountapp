class DiscountLineItem < PurchaseLineItem
  belongs_to :purchase
  validates_presence_of :account_id, :amount
  validates :amount, :numericality => {:greater_than_or_equal_to => 0.00,
                                        :message => " should not be negative" }
  validates :account_id, :uniqueness => {:scope => :purchase_id, :message => "should once per purchase entry" }
end

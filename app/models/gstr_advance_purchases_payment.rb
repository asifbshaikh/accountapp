class GstrAdvancePurchasesPayment < ActiveRecord::Base
  belongs_to :gstr_advance_payment
  belongs_to :purchase
  
end

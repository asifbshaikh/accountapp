class PaymentTransaction < ActiveRecord::Base
  belongs_to :billing_invoice
end

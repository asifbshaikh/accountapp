class PaymentDetail < ActiveRecord::Base
  belongs_to :voucher, :polymorphic => true
   attr_accessible :transaction_reference, :branch, :payment_date, :bank_name, :amount, :account_number
  #validates_presence_of :payment_date 
end

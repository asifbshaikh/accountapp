class CashPayment < PaymentDetail
  attr_accessible :amount

  def payment_mode
	'Cash'
  end
end

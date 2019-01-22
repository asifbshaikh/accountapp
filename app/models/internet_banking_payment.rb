class InternetBankingPayment < PaymentDetail
  attr_accessible :transaction_reference, :branch, :payment_date, :bank_name, :amount
  validates_presence_of :payment_date, :message => "/transaction date can not be blank."
  def payment_mode
	'Internet Banking'
  end
end

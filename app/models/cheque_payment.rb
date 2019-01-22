class ChequePayment < PaymentDetail
  attr_accessible :transaction_reference, :branch, :payment_date, :bank_name, :amount,:account_number
  
  validates_presence_of :payment_date, :message => "/cheque date can not be blank."
  def payment_mode
	'Cheque'
  end
end

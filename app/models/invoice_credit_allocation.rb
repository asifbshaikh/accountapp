class InvoiceCreditAllocation < ActiveRecord::Base
	belongs_to :invoice
	belongs_to :credit_note

	validates_presence_of :invoice_id, :credit_note_id
  # validate :amount, :blank=>:allow
	validates :amount, :numericality => {:greater_than_or_equal_to => 0.00,
                                        :message => " should not be negative ." }, :allow_blank=>true

  validate :invoice_amount_on_create, :on=>:create
  validate :invoice_amount_on_update, :on=>:update

  def invoice_amount_on_create
  	if !amount.blank? && amount>(invoice.outstanding)
  		errors.add(:payment, "can't be greater than outstanding for #{invoice.invoice_number}")
  	end
  end

  def invoice_amount_on_update
  	allocation=InvoiceCreditAllocation.find_by_id id
    outstanding=invoice.outstanding
    outstanding+=allocation.amount unless allocation.blank? || allocation.amount.blank? 

  	if !amount.blank? && amount>outstanding
  		errors.add(:payment, "can't be greater than outstanding for #{invoice.invoice_number}")
  	end
  end
end

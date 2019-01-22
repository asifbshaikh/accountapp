class GstDebitAllocation < ActiveRecord::Base
	belongs_to :gst_debit_note
	belongs_to :purchase

	validates_presence_of :purchase_id, :gst_debit_note_id
	validates :amount, :numericality => {:greater_than_or_equal_to => 0.00,
                                        :message => " should not be negative ." }, :allow_blank=>true
  validate :purchase_amount_on_create, :on=>:create
  validate :purchase_amount_on_update, :on=>:update
  def purchase_amount_on_create
  	if !amount.blank? && amount>(purchase.outstanding)
  		errors.add(:payment, "can't be greater than outstanding for #{purchase.purchase_number}")
  	end
  end

  def purchase_amount_on_update
  	allocation=GstDebitAllocation.find_by_id id
  	if !amount.blank? && !allocation.amount.blank? && amount>(purchase.outstanding+allocation.amount)
  		errors.add(:payment, "can't be greater than outstanding for #{purchase.purchase_number}")
  	end
  end
end
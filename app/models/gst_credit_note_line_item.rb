class GstCreditNoteLineItem < ActiveRecord::Base
	include VoucherLineItem
	scope :by_company, lambda { |company_id| joins(:gst_credit_note).where(:"gst_credit_notes.company_id"=>company_id) }
	scope :by_product, lambda { |product_id| where(:product_id=>product_id) unless product_id.blank? }
	scope :by_branch,lambda { |branch_id| joins(:gst_credit_note).where(:"gst_credit_notes.branch_id"=> branch_id) unless branch_id.blank? }
	scope :by_voucher_date, lambda { |start_date, end_date| joins(:gst_credit_note).where(:"gst_credit_notes.record_date"=>(start_date..end_date))}

	has_many :gst_credit_note_taxes, :dependent=>:destroy
	has_many :tax_accounts, :class_name=>"Account", :through=>:gst_credit_note_taxes, :source=>:account
	belongs_to :gst_credit_note
	belongs_to :invoice_return_line_item
	belongs_to :account
	belongs_to :product
	# belongs_to :tax_account, :class_name=>"Account", :foreign_key=>:tax_account_id

	validates_presence_of :quantity, :unit_rate
	accepts_nested_attributes_for :gst_credit_note_taxes
	attr_accessible :tax, :account_id, :amount, :discount_percent, :product_id, :quantity, :line_type, :unit_rate, :invoice_return_line_item_id, :gst_credit_note_taxes_attributes


 	def gst_tax_rate
    	self.tax_accounts.first.accountable.tax_rate
  	end





end

class GstDebitNoteLineItem < ActiveRecord::Base
	include VoucherLineItem
	scope :by_company, lambda { |company_id| joins(:gst_debit_note).where(:"gst_debit_notes.company_id"=>company_id) }
	scope :by_product, lambda { |product_id| where(:product_id=>product_id) unless product_id.blank? }
	scope :by_branch,lambda { |branch_id| joins(:gst_debit_note).where(:"gst_debit_notes.branch_id"=> branch_id) unless branch_id.blank? }
	scope :by_voucher_date, lambda { |start_date, end_date| joins(:gst_debit_note).where(:"gst_debit_notes.record_date"=>(start_date..end_date))}

	belongs_to :gst_debit_note
	belongs_to :purchase_return_line_item
	belongs_to :product
	belongs_to :warehouse
	belongs_to :account
	has_many :gst_debit_note_taxes, :dependent=>:destroy
	has_many :tax_accounts, :class_name=>"Account", :through=>:gst_debit_note_taxes, :source=>:account, :autosave=>true
	accepts_nested_attributes_for :gst_debit_note_taxes
	attr_accessible  :account_id, :amount, :tax, :gst_debit_note_line_item_id, :unit_rate, :product_id, :discount_percent, :quantity, :line_type, :gst_debit_note_taxes_attributes

	def gst_tax_rate
    	self.tax_accounts.first.accountable.tax_rate
  	end
end

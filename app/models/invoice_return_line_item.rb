class InvoiceReturnLineItem < ActiveRecord::Base
	scope :by_company, lambda { |company_id| joins(:invoice_return).where(:"invoice_returns.company_id"=>company_id) }
	scope :by_product, lambda { |product_id| where(:product_id=>product_id) unless product_id.blank? }
	scope :by_branch,lambda { |branch_id| joins(:invoice_return).where(:"invoice_returns.branch_id"=> branch_id) unless branch_id.blank? }
	scope :by_voucher_date, lambda { |start_date, end_date| joins(:invoice_return).where(:"invoice_returns.record_date"=>(start_date..end_date))}

	has_many :invoice_return_taxes, :dependent=>:destroy
	has_many :tax_accounts, :class_name=>"Account", :through=>:invoice_return_taxes, :source=>:account
	belongs_to :invoice_return
	belongs_to :invoice_line_item
	belongs_to :account
	belongs_to :product
	# belongs_to :tax_account, :class_name=>"Account", :foreign_key=>:tax_account_id

	validates_presence_of :quantity, :unit_rate
	validate :returning_quantity_on_create, :on=>:create
	validate :returning_quantity_on_update, :on=>:update
	accepts_nested_attributes_for :invoice_return_taxes
	attr_accessible :tax, :account_id, :amount, :discount_percent, :product_id, :quantity, :line_type, :unit_rate, :invoice_line_item_id, :invoice_return_taxes_attributes
	before_destroy :keep_back_inventory
	def keep_back_inventory
		if line_type=="InvoiceReturnLineItem"
			Stock.reduce(invoice_return.company_id, product_id, invoice_return.warehouse_id, quantity) if product.inventory?
		end
	end
	def returning_quantity_on_update
		unless line_type.blank?
			if product.inventory? && !quantity.blank? #&& quantity>invoice_line_item.ready_to_return_quantity
				old_line=InvoiceReturnLineItem.find_by_id(id)
				ready_to_return_quantity=invoice_line_item.ready_to_return_quantity
				ready_to_return_quantity+=old_line.quantity unless old_line.blank?
				errors.add(:quantity, "can't be greater than invoiced quantity") if quantity>ready_to_return_quantity
			end
		end
	end
	def returning_quantity_on_create
		unless line_type.blank?
			if product.inventory? && !quantity.blank? && quantity>invoice_line_item.ready_to_return_quantity
				errors.add(:quantity, "can't be greater than invoiced quantity")
			end
		end
	end

	def converted_amount
		self.invoice_return.foreign_currency? ? (amount*self.invoice_return.exchange_rate).round(2) : amount
	end
end

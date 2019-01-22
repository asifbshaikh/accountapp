class PurchaseReturnLineItem < ActiveRecord::Base
	scope :by_company, lambda { |company_id| joins(:purchase_return).where(:"purchase_returns.company_id"=>company_id) }
	scope :by_product, lambda { |product_id| where(:product_id=>product_id) unless product_id.blank? }
	scope :by_branch,lambda { |branch_id| joins(:purchase_return).where(:"purchase_returns.branch_id"=> branch_id) unless branch_id.blank? }
	scope :by_voucher_date, lambda { |start_date, end_date| joins(:purchase_return).where(:"purchase_returns.record_date"=>(start_date..end_date))}

	belongs_to :purchase_line_item
	belongs_to :purchase_return
	belongs_to :product
	belongs_to :warehouse
	belongs_to :account
	# belongs_to :tax_account, :class_name=>'Account', :foreign_key=>:tax_account_id
	has_many :purchase_return_taxes, :dependent=>:destroy
	has_many :tax_accounts, :class_name=>"Account", :through=>:purchase_return_taxes, :source=>:account, :autosave=>true
	validates_presence_of :quantity, :unit_rate

	validate :returning_quantity_on_create, :on=>:create
	validate :returning_quantity_on_update, :on=>:update
	before_destroy :keep_back_inventory

	accepts_nested_attributes_for :purchase_return_taxes
	attr_accessible  :account_id, :amount, :tax, :purchase_line_item_id, :unit_rate, :product_id, :discount_percent, :quantity, :line_type, :purchase_return_taxes_attributes
	def keep_back_inventory
		if line_type=="PurchaseReturnLineItem"
			Stock.increase(purchase_return.company_id, product_id, purchase_return.warehouse_id, quantity, nil) if product.inventory?
		end
	end
	def returning_quantity_on_update
		unless line_type.blank?
			if product.inventory? && !quantity.blank? #&& quantity>purchase_line_item.ready_to_return_quantity
				old_line=PurchaseReturnLineItem.find_by_id(id)
				ready_to_return_quantity=purchase_line_item.ready_to_return_quantity
				ready_to_return_quantity+=old_line.quantity unless old_line.blank?
				errors.add(:quantity, "can't be greater than purchased quantity") if quantity>ready_to_return_quantity
			end
		end
	end
	def returning_quantity_on_create
		unless line_type.blank?
			if product.inventory? && !quantity.blank? && quantity>purchase_line_item.ready_to_return_quantity
				errors.add(:quantity, "can't be greater than purchased quantity")
			end
		end
	end

	def converted_amount
    self.purchase_return.foreign_currency? ? (amount*self.purchase_return.exchange_rate).round(2) : amount
  end
end

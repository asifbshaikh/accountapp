class PurchaseOrderLineItem < ActiveRecord::Base
 belongs_to :purchase_order
 belongs_to :product
 belongs_to :account
 has_many :purchase_order_taxes, :dependent=>:destroy
 has_many :tax_accounts, :class_name=>"Account", :through=>:purchase_order_taxes, :source=>:account
 validates :amount, :numericality => {:greater_than_or_equal_to => 0.01,
                                        :message => " should not be zero or negative ." }
  validates_presence_of :product_id, :if => lambda{|a| a.line_item_type == 'PurchaseOrderLineItem'}
  validates_presence_of :account_id, :if => lambda{|a| a.line_item_type != 'PurchaseOrderLineItem'}

  accepts_nested_attributes_for :purchase_order_taxes#, :reject_if=>lambda { |o| o[:account_id].blank? }
  attr_accessible :line_item_type, :tax_account_id, :discount_percent, :amount, :quantity, :product_id,
  :account_id, :description, :unit_rate, :purchase_order_reference, :tax, :cost_center, :deleted_by,
  :created_at, :purchase_id, :deleted, :updated_at, :approved_by, :purchase_order_taxes_attributes
  before_save :check_tax_destruction

  def check_tax_destruction
    purchase_order_taxes.each do |tax|
      tax.mark_for_destruction if tax.account_id.blank?
    end
  end
  def tax_account
    Account.find_by_id(tax_account_id)
  end

  def self.subclasses
    [TaxLineItem]
  end

  def item_name
    product_id.blank? ? Account.find(account_id).name : Product.find(product_id).name
  end
end

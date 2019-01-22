class StockReceiptLineItem < ActiveRecord::Base
  scope :by_company, lambda { |company_id| joins(:stock_receipt_voucher).where(:"stock_receipt_vouchers.company_id"=>company_id) }
  scope :by_product, lambda { |product_id| where(:product_id=>product_id) unless product_id.blank? }
  scope :by_warehouse, lambda { |warehouse_id| joins(:stock_receipt_voucher).where(:"stock_receipt_vouchers.warehouse_id"=>warehouse_id) }
  scope :by_branch,lambda { |branch_id| joins(:stock_receipt_voucher).where(:"stock_receipt_vouchers.branch_id"=> branch_id) unless branch_id.blank? }
  scope :by_voucher_date, lambda { |start_date, end_date| joins(:stock_receipt_voucher).where(:"stock_receipt_vouchers.voucher_date"=>(start_date..end_date))}
  scope :order_by_voucher_date, lambda { joins(:stock_receipt_voucher).order('stock_receipt_vouchers.voucher_date DESC') }
  has_one :product_batch, :dependent => :destroy
  belongs_to :stock_receipt_voucher
  belongs_to :product
  validates_presence_of :product_id, :quantity
  
  accepts_nested_attributes_for :product_batch
  attr_accessible :unit_rate, :product_id, :quantity, :product_batch_attributes
  validates_associated :product_batch
  before_destroy :retain_stock
  def product_name
    Product.find(product_id).name
  end

  def retain_stock
    company = stock_receipt_voucher.company
    unless product.batch_enable?
      warehouse = stock_receipt_voucher.warehouse
      stock = Stock.where(:company_id => company.id, :product_id => product_id, :warehouse_id => warehouse.id).first
       unless stock.blank?
        stock.quantity -= quantity
        stock.save
      end
    end
  end
end

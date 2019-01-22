class StockTransferLineItem < ActiveRecord::Base
  belongs_to :product
  belongs_to :warehouse
  belongs_to :product_batch
  belongs_to :stock_transfer_voucher
  validates_presence_of :product_id, :transfer_quantity, :destination_warehouse_id
  validates_presence_of :product_batch_id, :if => lambda{|e| !e.product.blank? && e.product.batch_enable? }
  before_destroy :retain_stock

  def product_name
    Product.find(product_id).name
  end
  
  def destination_warehouse_name
    Warehouse.find(destination_warehouse_id).name
  end

  def retain_stock
    product_batch.update_attributes(:warehouse_id => stock_transfer_voucher.warehouse_id) unless product_batch.blank?
    Stock.reduce(stock_transfer_voucher.company_id, product_id_was, destination_warehouse_id_was, transfer_quantity_was)
    Stock.increase(stock_transfer_voucher.company_id, product_id_was, stock_transfer_voucher.warehouse_id_was, transfer_quantity_was, 0.0)
    # company = stock_transfer_voucher.company
    # warehouse = stock_transfer_voucher.warehouse
    # product_batch.update_attributes(:warehouse_id => warehouse.id) unless product_batch.blank?
    # Stock.transfer_stock(company.id, product_id, destination_warehouse_id, warehouse.id, transfer_quantity)    
  end

end

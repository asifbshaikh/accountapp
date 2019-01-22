class SalesWarehouseDetail < ActiveRecord::Base
  scope :by_invoice_date, lambda { |fy| joins(:invoice_line_item=>:invoice).where(:invoices=>{:invoice_date=>fy.start_date..fy.end_date})  }	
  belongs_to :warehouse
  belongs_to :invoice_line_item
  belongs_to :product_batch
  belongs_to :product
  validates_presence_of :warehouse_id, :quantity
  validates_presence_of :product_batch_id, :if=>lambda { |a| a.product.batch_enable? }
  validate :available_batch_quantity, :if=>lambda { |a| a.product.batch_enable? }
  before_destroy :retain_stock

  def available_batch_quantity
    if !product_batch.blank? && !quantity.blank? 
      available_quantity=product_batch.quantity
      existing_swd=SalesWarehouseDetail.find_by_id id
      available_quantity+=existing_swd.quantity unless existing_swd.blank? || existing_swd.quantity.blank?
      errors.add(:base, "Low stock in Batch: #{product_batch.batch_number}") if quantity> available_quantity
    end
  end

  def available_batches
    stock=Stock.find_by_product_id_and_warehouse_id(product_id, warehouse_id)
    stock.blank? ? [] : stock.get_batches 
  end

  def retain_stock
    unless draft?
      if product.batch_enable? 
        product_batch.update_attributes(:quantity => (product_batch.quantity + quantity))
      else
        Stock.increase(product.company_id, product_id, warehouse_id, quantity, 0)
      end
    end
  end

  def self.create_default_swd(line_item, warehouse, qty, batch)
     swd = SalesWarehouseDetail.new(:invoice_line_item_id => line_item.id,
        :warehouse_id => warehouse.id,
        :quantity => qty,
        :product_batch_id => batch.id
      )
      swd.save
  end
end

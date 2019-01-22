class DeliveryChallanLineItem < ActiveRecord::Base
  belongs_to :delivery_challan
  belongs_to :product
  belongs_to :product_batch
  belongs_to :sales_order_line_item
  #validation
  validates_presence_of :product_id
  # validates_presence_of :quantity
  validates :quantity, :numericality => {:greater_than_or_equal_to => 0.00,
                                        :message => " should not be zero." }
  attr_accessible :product_id, :description, :quantity , :product_batch_id ,:sales_order_line_item_id

  def item_name
     Product.find(product_id).name  unless product_id.blank?
  end

 def inventoriable?
    product = Product.find(product_id)
    product.inventoriable?
  end


  def self.sales_order_qty(sales_order)
    sales_order = SalesOrder.find_by_id(sales_order.id)
    qty = 0
    if !sales_order.blank?
      sales_order.sales_order_line_items.each do |line_item|
        qty = line_item.quantity
      end
    end
    return qty
  end

end

class PurchaseWarehouseDetail < ActiveRecord::Base
	scope :order_by_record_date, lambda { joins(:purchase_line_item=>:purchase).order("purchases.record_date DESC")  }
	scope :by_record_date, lambda {|fy| joins(:purchase_line_item=>:purchase).where(:purchases=>{:record_date=>fy.start_date..fy.end_date})  }
	belongs_to :product
	belongs_to :company
	belongs_to :warehouse
	belongs_to :purchase_line_item
	belongs_to :product_batch#, :dependent => :destroy
  before_destroy :retain_stock
  
  validates_presence_of :quantity, :warehouse_id
  def mark_deleted
  	update_attribute("deleted", true)	
  end

  def fully_returned?
  	purchase_return_line_items = purchase_line_item.purchase_return_line_items.where(:warehouse_id=>warehouse_id)
  	purchase_return_line_items.sum(:quantity)>=quantity
  end

  def retain_stock
  	# company = purchase_line_item.purchase.company
  # 	if company.inventory_setting.purchase_effects_inventory?
	 #    stock = Stock.where(:company_id => purchase_line_item.purchase.company_id, :product_id => purchase_line_item.product.id, :warehouse_id => warehouse_id).first
	 #    unless stock.blank?
	 #    	unless batch_is_not_yet_received?
		#       stock.quantity -= quantity unless quantity.blank?
		#       stock.save
		#     end
	 #    end
		# end
		if company.inventory_setting.purchase_effects_inventory?
		  if product.batch_enable?
	    	product_batch.update_attributes(:quantity => (product_batch.quantity - quantity)) unless batch_is_not_yet_received?
		  else
		    Stock.reduce(company_id, product_id, warehouse_id, quantity)
		  end
		end
  end

  def batch_is_not_yet_received?
  	!status_id?
  end
  class << self
	  # def deleted_purchase_warehouse_details(purchase_line_item_id)
	  # self.where(:purchase_line_item_id=>purchase_line_item_id, :deleted=>true)	
	  # end
	  def get_batch_hold_records(company, product, warehouse)
  		purchase_warehouse_details = PurchaseWarehouseDetail.where(:company_id=>company, :status_id=>false).includes(:purchase_line_item).where(:"purchase_line_items.product_id"=>product,:warehouse =>warehouse)	
	  end
	  
	  def get_hold_product_batches(company, product)
    	purchase_warehouse_details = PurchaseWarehouseDetail.where(:company_id=>company, :status_id=>false, :product_id=>product)
    end
	end
end

class ProductBatch < ActiveRecord::Base
  belongs_to :company
  has_one :stock_transfer_line_item
  has_one :stock_issue_line_item
  has_one :stock_receipt_line_item
  has_one :purchase_warehouse_detail
  has_one :stock_wastage_line_item
  has_many :sales_warehouse_details
  has_one :delivery_challan_line_item
	belongs_to :product
  belongs_to :warehouse
	before_update :update_inventory
	before_destroy :delete_inventory
	after_create :add_inventory
  validates :batch_number, :presence => true, :length => {:maximum => 30}, :uniqueness => {:scope => [:company_id, :product_id]}
  validates :quantity, :presence => true, :numericality => {:greater_than => 0.00,
              :message => " must be greater than zero." }, :on => :create
  validate :batch_dates
  def batch_dates
    unless manufacture_date.blank? || expiry_date.blank?
      errors.add(:manufacture_date, " must be before expiry date") if manufacture_date > expiry_date
    end
  end
  def transfer_stock

  end
	def update_inventory
		product_batch = ProductBatch.find id
    stock = Stock.where(:company_id => product.company_id, :product_id => product.id, :warehouse_id => product_batch.warehouse_id).first
    stock.update_attributes(:quantity => ((stock.quantity - product_batch.quantity ) + quantity))
  end

  def delete_inventory
    stock = Stock.where(:company_id => product.company_id, :product_id => product.id, :warehouse_id => warehouse_id).first
    stock.update_attributes(:quantity => (stock.quantity - quantity))
  end

  def add_inventory
  	stock = Stock.where(:company_id => product.company_id, :product_id => product.id, :warehouse_id => warehouse_id).first
  	if stock.blank?
  	  Stock.create!(:company_id => product.company_id, :product_id => product.id, :warehouse_id => warehouse_id,
  	    :quantity => quantity )
  	else
  	  stock.update_attributes(:quantity => (stock.quantity + quantity))
  	end
  end
  class << self
    def get_warehouse_batches(warehouse, product)
      ProductBatch.where(:warehouse_id=>warehouse, :product_id=>product)
    end
    def record_batch(params, stock_receipt_voucher)
      warehouse = stock_receipt_voucher.warehouse_id
      unless params[:batch_index].blank?
        params[:batch_index].each do |index|
          product = params[:stock_receipt_voucher][:stock_receipt_line_items_attributes][index][:product_id]
          quantity = params[:stock_receipt_voucher][:stock_receipt_line_items_attributes][index][:quantity]
          batch_number = params[:batch][index][:batch_number]
          manufacture_date = params[:batch][index][:manufacture_date]
          expiry_date = params[:batch][index][:expiry_date]
          line_item = StockReceiptLineItem.where(:product_id => product, :product_batch_id => nil,
            :stock_receipt_voucher_id => stock_receipt_voucher.id, :quantity => quantity).first
          batch = new(:product_id => product, :warehouse_id => warehouse,
            :batch_number => batch_number, :quantity => line_item.quantity,
            :manufacture_date => manufacture_date, :expiry_date => expiry_date,
            :company_id => stock_receipt_voucher.company_id,
            :reference => stock_receipt_voucher.voucher_number)
          if batch.save
            batch.reload
            line_item.update_attributes(:product_batch_id => batch.id)
          end
        end
      end
    end
  end
end

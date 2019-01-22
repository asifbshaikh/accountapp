class StockWastageLineItem < ActiveRecord::Base
  scope :by_company, lambda { |company_id| joins(:stock_wastage_voucher).where(:"stock_wastage_vouchers.company_id"=>company_id) }
  scope :by_product, lambda { |product_id| where(:product_id=>product_id) unless product_id.blank? }
  scope :by_branch,lambda { |branch_id| joins(:stock_wastage_voucher).where(:"stock_wastage_vouchers.branch_id"=> branch_id) unless branch_id.blank? }
  scope :by_voucher_date, lambda { |start_date, end_date| joins(:stock_wastage_voucher).where(:"stock_wastage_vouchers.voucher_date"=>(start_date..end_date))}
  belongs_to :stock_wastage_voucher
  belongs_to :product
  belongs_to :product_batch
  validates_presence_of :product_id, :quantity
  validates_presence_of :product_batch_id, :if => lambda{|e| !e.product.blank? && e.product.batch_enable? }
  # before_destroy :retain_stock
  # validate do |line_item|
  #   line_item.errors.add_to_base("Select product") if product_id.blank?
  #   line_item.errors.add_to_base("Quantity can't be blank") if quantity.blank?
  #   line_item.errors.add_to_base("Quantity can't be negative") if !quantity.blank? && quantity < 0
  # end
end

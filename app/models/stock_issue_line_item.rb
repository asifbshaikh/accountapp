class StockIssueLineItem < ActiveRecord::Base
  scope :by_company, lambda { |company_id| joins(:stock_issue_voucher).where(:"stock_issue_vouchers.company_id"=>company_id) }
  scope :by_product, lambda { |product_id| where(:product_id=>product_id) unless product_id.blank? }
  scope :by_branch,lambda { |branch_id| joins(:stock_issue_voucher).where(:"stock_issue_vouchers.branch_id"=> branch_id) unless branch_id.blank? }
  scope :by_voucher_date, lambda { |start_date, end_date| joins(:stock_issue_voucher).where(:"stock_issue_vouchers.voucher_date"=>(start_date..end_date))}
  belongs_to :stock_issue_voucher
  belongs_to :product
  belongs_to :product_batch
  validates_presence_of :product_id, :quantity
  validate :available_quantity
  validates_presence_of :product_batch_id , :if => lambda{|e| !e.product.blank? && e.product.batch_enable? }

  # validate :available_batch_quantity_on_create, :on => :create
  # validate :available_batch_quantity_on_update, :on => :update
  before_destroy :retain_stock
  
  def available_batch_quantity_on_update
    # if product.batch_enable? && product_batch.quantity < quantity
    #   errors.add_to_base("Quantity not available in selected batch.")
    # end
  end

  def available_batch_quantity_on_create
    if !product.blank? && product.batch_enable? && product_batch.quantity < quantity
      errors.add(:product_batch_id, "Quantity not available in selected batch.")
    end
  end
  def product_name
    Product.find(product_id).name
  end

 def available_quantity
   unless product.blank? || quantity.blank?
     if product.batch_enable? && !product_batch.blank? && product_batch.quantity < quantity
       errors.add(:product_batch_id, "quantity not available in selected batch.")
     elsif quantity > product.quantity
      errors.add(:quantity, " not in stock. Available quantity is #{product.quantity}")
     end
   end
 end

 def retain_stock
    company = stock_issue_voucher.company
    if product.batch_enable?
      product_batch.update_attributes(:quantity => (product_batch.quantity + quantity)) unless product_batch.blank?
    else
      Stock.increase(stock_issue_voucher.company_id, product_id_was, stock_issue_voucher.warehouse_id_was, quantity_was, 0.0)
    end
    # unless product.blank? || product.batch_enable?
    #   warehouse = stock_issue_voucher.warehouse
    #   stock = Stock.where(:company_id => company.id, :product_id => product_id, :warehouse_id => warehouse.id).first
    #    unless stock.blank?
    #     stock.quantity += quantity
    #     stock.save
    #   end
    # end
 end

end

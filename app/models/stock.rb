class Stock < ActiveRecord::Base
  scope :by_branch_id, lambda {|id| where(:branch_id => id) unless id.blank? }
  belongs_to :product
  belongs_to :warehouse
  belongs_to :company
  has_many :stock_histories

  before_save :ensure_stock_is_available

  def warehouse_name
    warehouse.name
  end
  
  def get_closing_quantity(financial_year)
    quantity=0
    purchased_quantity=PurchaseWarehouseDetail.where(:warehouse_id=>warehouse_id, :company_id=>company_id, :product_id=> product_id).by_record_date(financial_year).sum(:quantity)
    stock_received_quantity=StockReceiptLineItem.by_company(company_id).by_product(product_id).by_voucher_date(financial_year.start_date, financial_year.end_date).sum(:quantity)

    invoiced_quntity=SalesWarehouseDetail.where(:warehouse_id=>warehouse_id, :product_id=>product_id).by_invoice_date(financial_year).sum(:quantity)
    wasted_quantity=StockWastageLineItem.by_company(company_id).by_product(product_id).by_voucher_date(financial_year.start_date, financial_year.end_date).sum(:quantity)
    issued_quantity=StockIssueLineItem.by_company(company_id).by_product(product_id).by_voucher_date(financial_year.start_date, financial_year.end_date).sum(:quantity)
    old_opening_stock= opening_stock.blank? ? 0 : opening_stock
    quantity=(purchased_quantity+stock_received_quantity+old_opening_stock)-(invoiced_quntity+wasted_quantity+issued_quantity)
  end
  def get_closing_valuation(financial_year, qty)
    amount=0
    stock_quantity=qty
    purchase_warehouse_details=PurchaseWarehouseDetail.where(:warehouse_id=>warehouse_id, :company_id=>company_id, :product_id=> product_id).by_record_date(financial_year).order_by_record_date
    stock_receipt_line_items=StockReceiptLineItem.by_company(company_id).by_product(product_id).by_warehouse(warehouse_id).by_voucher_date(financial_year.start_date, financial_year.end_date).order_by_voucher_date

    unless stock_quantity<=0
      purchase_warehouse_details.each do |pwd|
        if pwd.quantity == stock_quantity
          amount += pwd.quantity * pwd.purchase_line_item.unit_rate
          stock_quantity = 0
        elsif pwd.quantity > stock_quantity
          amount += stock_quantity * pwd.purchase_line_item.unit_rate
          stock_quantity = 0
        elsif pwd.quantity < stock_quantity
          amount += pwd.quantity * pwd.purchase_line_item.unit_rate
          stock_quantity -= pwd.quantity
        end
      end
    end
    unless quantity <= 0
      stock_receipt_line_items.each do |line_item|
        if line_item.quantity == stock_quantity
          amount += line_item.quantity * line_item.unit_rate
          stock_quantity = 0
        elsif line_item.quantity > stock_quantity
          amount += stock_quantity * line_item.unit_rate
          stock_quantity = 0
        elsif line_item.quantity < stock_quantity
          amount += line_item.quantity * line_item.unit_rate
          stock_quantity -= line_item.quantity
        end
      end
    end
    amount
  end
  def get_batches
    ProductBatch.where("company_id=? and warehouse_id=? and product_id=? and quantity > ?", company_id, warehouse_id, product_id, 0)
  end
  def get_all_batches
    ProductBatch.where("company_id=? and warehouse_id=? and product_id=?", company_id, warehouse_id, product_id)
  end
  class << self
  def group_stock(product, company)
    stocks = Stock.where(:company_id=>company, :product_id=>product)
    hash = Hash.new
    stocks.each do |stock|
      hash[stock.warehouse_id]=stock.quantity
    end
    hash.to_json
  end
  def available_in_warehouse(product, warehouse)
    stock = find_by_product_id_and_warehouse_id(product, warehouse)
    stock.quantity
  end

  def reduce(company_id, product_id, warehouse_id, quantity)
    stock = Stock.where(:company_id => company_id, :product_id => product_id, :warehouse_id => warehouse_id).first
    if stock.blank?
       new_stock_entry = Stock.new(:company_id => company_id, :product_id => product_id,
                                   :warehouse_id => warehouse_id, :quantity => 0)
       new_stock_entry.save
    else
      stock.quantity -= quantity
      stock.save
    end
  end

  def increase(company_id, product_id, warehouse_id, quantity, new_cost)
    stock = Stock.where(:company_id => company_id, :product_id => product_id, :warehouse_id => warehouse_id).first
    if stock.blank?
       new_stock_entry = Stock.new(:company_id => company_id, :product_id => product_id,
                                   :warehouse_id => warehouse_id, :quantity => quantity)
       new_stock_entry.save
     else
  	  stock.quantity += quantity
  	  stock.save
    end
  end

  def update_inventory(params, company_id, product_id, warehouse_id, quantity)
    if params[:warehouse].include?(warehouse_id.to_s)
      stock = Stock.where(:company_id => company_id.to_i, :product_id => product_id.to_i, :warehouse_id => warehouse_id.to_i).first
      unit_rate=params["product_price_at_#{warehouse_id.to_s}"].to_d unless params["product_price_at_#{warehouse_id.to_s}"].blank?
      quantity=quantity.to_d unless quantity.blank?
      unless stock.blank?
        stock.quantity -= stock.opening_stock
        stock.opening_stock = 0
        stock.save
      end
      if stock.blank?
        new_stock_entry = Stock.new(:company_id => company_id, :product_id => product_id,
         :warehouse_id => warehouse_id, :quantity => quantity, :opening_stock => quantity, :opening_stock_unit_price=>unit_rate)
        new_stock_entry.save
      else
        stock.opening_stock = quantity
        stock.opening_stock_unit_price=unit_rate
        stock.quantity += quantity
        stock.save
      end
    end
  end

  def reduce_wastage(company_id, product_id, warehouse_id, quantity)
    stock = Stock.where(:company_id => company_id, :product_id => product_id, :warehouse_id => warehouse_id).first
    unless stock.blank?
      stock.quantity -= quantity
      stock.save!
    end
  end

  def increase_wastage(company_id, product_id, warehouse_id, quantity)
    stock = Stock.where(:company_id => company_id, :product_id => product_id, :warehouse_id => warehouse_id).first
    unless stock.blank?
      stock.quantity += quantity
      stock.save!
    end
  end

   # def transfer_stock(company_id, product_id, warehouse_id, destination_warehouse_id, quantity)
   #   stock1 = Stock.find_by_company_id_and_product_id_and_warehouse_id(company_id, product_id, warehouse_id)
   #   stock2 = Stock.find_by_company_id_and_product_id_and_warehouse_id(company_id, product_id, destination_warehouse_id)
   #   if !stock1.blank?
   #      if stock1.quantity >= quantity
   #         stock1.quantity -= quantity
   #         stock1.save!
   #       if !stock2.blank?
   #        stock2.quantity += quantity
   #        stock2.save!
   #       else
   #        stock2 = Stock.new(:company_id => company_id, :product_id => product_id,
   #                 :warehouse_id => destination_warehouse_id, :quantity => quantity)
   #         stock2.save!
   #       end
   #      else
   #         stock1.errors.add(:base, "Available stock is less than transfer stock")
   #      end
   #    else
   #       errors.add(:base, "#{Product.find(product_id).name} is not in stock")
   #    end
   # end

  def get_warehouse_specific(warehouse)
    self.where(:company_id => warehouse.company_id, :warehouse_id => warehouse.id)
  end

  ##
  # This method get the stocks grouped by warehouse.
  # Warehouse wise stock report
  #
  def get_warehouse_wise_stock(params, company, user, branch_id)
      if params[:warehouse_id].blank?
        stocks = Stock.where(:company_id => company.id).includes(:product).includes(:warehouse).group(:warehouse_id, :product_id)
      else
        warehouse_id = params[:warehouse_id].to_i
        stocks = Stock.where(:company_id => company.id, :warehouse_id => warehouse_id).includes(:product).includes(:warehouse).group(:product_id)
      end
    end
end
# total inward stock
 def inward_stock(params, company, user ,fyr)
    start_date = start_date = params[:start_date].blank? ? fyr.start_date : params[:start_date].to_date
    end_date = params[:end_date].blank? ? Time.zone.now.to_date : params[:end_date].to_date
    branch_id = params[:branch_id].blank? ? user.branch_id : params[:branch_id].to_i
    inward_stock = 0
    stocks = Stock.by_branch_id(branch_id).where(:company_id => company.id, :created_at=> start_date..end_date)
    stocks.each do |stock|
     if !stock.blank?
        inward_stock = stock.product.total_inward_quantity(params, company, fyr)
     end
    end
     inward_stock
 end
# total outward stock
def outward_stock(params, company, user, fyr)
    start_date = start_date = params[:start_date].blank? ? fyr.start_date : params[:start_date].to_date
    end_date = params[:end_date].blank? ? Time.zone.now.to_date : params[:end_date].to_date
    branch_id = params[:branch_id].blank? ? user.branch_id : params[:branch_id].to_i
    outward_stock = 0
    stocks = Stock.by_branch_id(branch_id).where(:company_id => company.id, :created_at=> start_date..end_date)
    stocks.each do |stock|
     if !stock.blank?
        outward_stock = stock.product.total_outward_quantity(params, company, fyr)
     end
    end
    outward_stock
 end
 def closing_stock
   inward_stock - outward_stock
 end

  def product_name
    product.name
  end

  protected
  def ensure_stock_is_available
    self.quantity < 0 ? false : true
  end
end

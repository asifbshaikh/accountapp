class StockReceiptVoucher < ActiveRecord::Base
  scope :by_branch_id, lambda {|id| where(:branch_id => id) unless id.blank? }
  scope :by_deleted, lambda {|del| where(:deleted => del)}
  scope :by_date, lambda{|fin_year| where(:voucher_date => fin_year.start_date..fin_year.end_date) unless fin_year.blank?}
  scope :by_custom_field, lambda{|custom_field| where("custom_field1 = ? or custom_field2 =? or custom_field3=? ",custom_field, custom_field, custom_field) unless custom_field.blank?}

  belongs_to :purchase
  belongs_to :company
  belongs_to :warehouse
  has_many :stock_receipt_line_items, :dependent => :destroy
  accepts_nested_attributes_for :stock_receipt_line_items, :allow_destroy => true

  validates_presence_of :warehouse_id, :voucher_number
  validates_uniqueness_of :voucher_number, :scope => :company_id
  validates :custom_field1, :custom_field2, :custom_field3, :length => { :maximum => 30, :too_long => "%{count} characters is the maximum allowed" }
  # validate :save_only_in_current_year
  attr_accessor :fin_year
  before_update :update_inventory

  validate :stock_to_be_enter, :on => :create
  validate :stock_to_be_update, :on => :update
  validate :save_in_frozen_fy
  def voucher_setting
    VoucherSetting.by_voucher_type(16, company_id).first
  end
  def save_in_frozen_fy
    if !voucher_date.blank? && in_frozen_year?
      errors.add(:voucher_date, "can't be in frozen financial year")
    end
  end
  def in_frozen_year?
    FinancialYear.check_if_frozen(company_id, voucher_date)
  end

  def record_batch
    transaction do
      stock_receipt_line_items.each do |line_item|
        if line_item.product.batch_enable?
          line_item.product_batch.product_id = line_item.product_id
          line_item.product_batch.company_id = company_id
          line_item.product_batch.warehouse_id = warehouse_id
          line_item.product_batch.quantity = line_item.quantity
          line_item.product_batch.reference = voucher_number
        end
      end
    end
  end
  def stock_to_be_enter
    unless purchase_id.blank?
      purchase = Purchase.find purchase_id
      stock_receipt_line_items.each do |line|
        purchase_line = PurchaseLineItem.find_by_purchase_id_and_product_id(purchase.id, line.product_id )
        purchase_warehouse_detail = PurchaseWarehouseDetail.find_by_purchase_line_item_id_and_warehouse_id(purchase_line.id, warehouse_id) unless purchase_line.blank?
        quantity = purchase_warehouse_detail.quantity unless purchase_warehouse_detail.blank?
        ids = []
        purchase.stock_receipt_vouchers.each do |srv|
          ids<<srv.id if srv.warehouse_id == warehouse_id
        end
        prev_stock_receipt_line_items = StockReceiptLineItem.where(:stock_receipt_voucher_id => ids, :product_id => line.product_id)
        if purchase_line.blank?
          errors.add(:purchase_id, "products are not matching with selected product")
        elsif quantity.blank?
          errors.add(:base, "Either selected warehouse or product is wrong combination")
        elsif quantity < (prev_stock_receipt_line_items.sum(:quantity) + line.quantity)
          errors.add(:base, "Quantity can't be greater than purchase quantity")
        end
      end
    end
  end
  def stock_to_be_update
    unless purchase_id.blank?
      stock_receipt_voucher = StockReceiptVoucher.find id
      purchase = Purchase.find purchase_id
      stock_receipt_line_items.each do |line|
        purchase_line = PurchaseLineItem.find_by_purchase_id_and_product_id(purchase.id, line.product_id )
        purchase_warehouse_detail = PurchaseWarehouseDetail.find_by_purchase_line_item_id_and_warehouse_id(purchase_line.id, warehouse_id) unless purchase_line.blank?
        quantity = purchase_warehouse_detail.quantity unless purchase_warehouse_detail.blank?
        ids = []
        purchase.stock_receipt_vouchers.each do |srv|
          ids<<srv.id if srv.warehouse_id == warehouse_id && srv.id != id
        end
        prev_stock_receipt_line_items = StockReceiptLineItem.where(:stock_receipt_voucher_id => ids, :product_id => line.product_id)
        if purchase_line.blank?
          errors.add(:purchase_id, "products are not matching with selected product")
        elsif quantity.blank?
          errors.add(:base, "Either selected warehouse or product is wrong combination")
        elsif quantity < (prev_stock_receipt_line_items.sum(:quantity) + line.quantity)
          errors.add(:base, "Quantity can't be greater than purchase quantity")
        end
      end
    end
  end
  # def save_only_in_current_year
  #   year = Year.find_by_name(fin_year)
  #   f_year = FinancialYear.find_by_company_id_and_year_id(company_id, year.id)
  #   if !voucher_date.blank? && (voucher_date < f_year.start_date || voucher_date > f_year.end_date)
  #     errors.add(:voucher_date, " must be in current financial year")
  #   end
  # end
  def created_by_user
    User.find(created_by).first_name
  end

  def stock_received_warehouse
    Warehouse.find(warehouse_id).name
  end

  def save_inventory
    save_result = false
		transaction do
		  if save
				stock_receipt_line_items.each do |line_item|
          Stock.increase(self.company_id, line_item.product_id, warehouse_id, line_item.quantity, 0) unless line_item.product.batch_enable?
        end
        unless company.inventory_setting.purchase_effects_inventory? || purchase_id.blank?
          purchase.fin_year = fin_year
          purchase.manage_stock_status
        end
        save_result = true
			end
		end
		save_result
  end

  def update_inventory
    stock_receipt_voucher = StockReceiptVoucher.find id
    stock_receipt_voucher.stock_receipt_line_items.each do |line_item|
      Stock.reduce(company_id, line_item.product_id, stock_receipt_voucher.warehouse_id, line_item.quantity) unless line_item.product.batch_enable?
    end
    stock_receipt_line_items.each do |line_item|
      Stock.increase(company_id, line_item.product_id, warehouse_id, line_item.quantity, 0) unless line_item.product.batch_enable?
    end
  end
  
  class << self
    def new_stock_receipt(company)
      stock_receipt_voucher = StockReceiptVoucher.new
      stock_receipt_voucher.company_id=company.id
      stock_receipt_voucher.voucher_date = Time.zone.now.to_date
      stock_receipt_voucher.voucher_number = VoucherSetting.next_stock_receipt_voucher_number(company)
      stock_receipt_voucher.stock_receipt_line_items.build
      stock_receipt_voucher
    end

    def create_stock_receipt(params, company, user, fyr)
      stock_receipt_voucher = StockReceiptVoucher.new(params[:stock_receipt_voucher])
      stock_receipt_voucher.created_by = user.id
      stock_receipt_voucher.company_id = company
      stock_receipt_voucher.received_by = user.id
      stock_receipt_voucher.branch_id = user.branch_id unless user.branch_id.blank?
      stock_receipt_voucher.fin_year = fyr
      stock_receipt_voucher.stock_receipt_line_items.each do |line_item|
        if !line_item.product.blank? && line_item.product.batch_enable?
          line_item.product_batch.product_id = line_item.product_id
          line_item.product_batch.company_id = stock_receipt_voucher.company_id
          line_item.product_batch.warehouse_id = stock_receipt_voucher.warehouse_id
          line_item.product_batch.quantity = line_item.quantity
          line_item.product_batch.reference = stock_receipt_voucher.voucher_number
        end
      end
      stock_receipt_voucher
    end

    def update_stock_receipt(params, user, fyr)
      stock_receipt_voucher = StockReceiptVoucher.find(params[:id])
      stock_receipt_voucher.branch_id = user.branch_id unless user.branch_id.blank?
      stock_receipt_voucher.fin_year = fyr
      stock_receipt_voucher
    end
    def get_record_with_custom_field(params, company, current_financial_year)
      start_date = params[:start_date].blank? ? current_financial_year.start_date : params[:start_date].to_date
      end_date = params[:end_date].blank? ? Time.zone.now.to_date : params[:end_date].to_date
      voucher_type = params[:voucher_type]
      val = params[:custom_field] unless params[:custom_field].blank?
      stock = StockReceiptVoucher.where(:company_id=>company.id, :voucher_date => start_date..end_date).by_custom_field(val)
    end
  end

  def register_user_action(remote_ip, action)
    Workstream.register_user_action(company_id, created_by, remote_ip, " #{voucher_number} #{action} by #{created_by_user} at #{stock_received_warehouse}", action, branch_id)
  end

  def register_delete_action(remote_ip, user, action)
    Workstream.register_user_action(company_id, user.id, remote_ip, " #{voucher_number} #{action} by #{created_by_user} at #{stock_received_warehouse}", action, branch_id)
  end

end

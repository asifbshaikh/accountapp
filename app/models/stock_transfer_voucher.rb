class StockTransferVoucher < ActiveRecord::Base
  scope :by_branch_id, lambda {|id| where(:branch_id => id) unless id.blank? }
  scope :by_date, lambda{|fin_year| where(:transfer_date => fin_year.start_date..fin_year.end_date) unless fin_year.blank?}

  belongs_to :company
  belongs_to :warehouse
  has_many :stock_transfer_line_items, :dependent => :destroy
  accepts_nested_attributes_for :stock_transfer_line_items, :allow_destroy => true
  validates_presence_of  :warehouse_id, :company_id, :created_by, :transfer_date,:voucher_date,:voucher_number
  validates_uniqueness_of :voucher_number, :scope => :company_id
  # validate :save_only_in_current_year
  validate :validate_warehouse
  validate :save_in_frozen_fy
  validate :stock_availability_on_create, :on=>:create
  validate :stock_availability_on_update, :on=>:update
  attr_accessor :fin_year
  
  def save_and_manage_stock(remote_ip)
    result=false
    transaction do 
      if valid?
        manage_stock
        save(validate: false)
        register_user_action(remote_ip, 'updated')
        result=true
      else
        raise ActiveRecord::Rollback
      end
    end
    result
  end

  def manage_stock
    stock_transfer_line_items.each do |line_item|
      if line_item.changed? && !line_item.transfer_quantity.blank? && !line_item.marked_for_destruction?
        quantity=0
        if line_item.product_batch.blank?
          transfer_quantity_was=line_item.transfer_quantity_was.blank? ? 0 : line_item.transfer_quantity_was
          transfer_quantity=line_item.transfer_quantity
          quantity = transfer_quantity - transfer_quantity_was
        else
          # quantity = line_item.transfer_quantity
          # line_item.product_batch_was.update_attribute("warehouse_id", warehouse_id)
          # Stock.reduce(company_id, line_item.product_id, line_item.destination_warehouse_id, quantity)
          # Stock.increase(company_id, line_item.product_id, warehouse_id, quantity, 0.0)
          # line_item.product_batch.update_attribute("warehouse_id", line_item.destination_warehouse_id)
          line_item.product_batch.update_attributes!(:warehouse_id => line_item.destination_warehouse_id)
          quantity=line_item.transfer_quantity
        end
        Stock.increase(company_id, line_item.product_id, line_item.destination_warehouse_id, quantity, 0.0)
        Stock.reduce(company_id, line_item.product_id, warehouse_id, quantity)
      end
    end
  end

  def stock_availability_on_create
    stock_transfer_line_items.each do |line_item| 
      source_stock = Stock.find_by_company_id_and_product_id_and_warehouse_id(company_id, line_item.product_id, warehouse_id)
      unless source_stock.blank? || line_item.transfer_quantity.blank?
        if source_stock.quantity<line_item.transfer_quantity
          errors.add(:base, "No enough quantity to transfer.")
        end
      end
    end
  end

  def stock_availability_on_update
    stock_transfer_line_items.each do |line_item|
      source_stock = Stock.find_by_company_id_and_product_id_and_warehouse_id(company_id, line_item.product_id, warehouse_id)
      destination_stock = Stock.find_by_company_id_and_product_id_and_warehouse_id(company_id, line_item.product_id, line_item.destination_warehouse_id)
      transfer_quantity_was=line_item.transfer_quantity_was.blank? ? 0 : line_item.transfer_quantity_was
      unless source_stock.blank? || line_item.transfer_quantity.blank?
        if (source_stock.quantity+transfer_quantity_was)<line_item.transfer_quantity
          errors.add(:base, "No enough quantity to transfer.")
        end
      end
      unless destination_stock.blank? || line_item.transfer_quantity.blank? || line_item.new_record?
        if destination_stock.quantity<(line_item.transfer_quantity_was-line_item.transfer_quantity)
          errors.add(:base, "Stock underflow.")
        end
      end
    end
  end

  def voucher_setting
    VoucherSetting.by_voucher_type(17, company_id).first
  end

  def save_in_frozen_fy
    if !transfer_date.blank? && in_frozen_year?
      errors.add(:transfer_date, "can't be in frozen financial year")
    end
  end

  def in_frozen_year?
    FinancialYear.check_if_frozen(company_id, transfer_date)
  end

  def validate_warehouse
    self.stock_transfer_line_items.each do |line_item|
     if warehouse_id == line_item.destination_warehouse_id
      errors.add(:base, "Both warehouse should not be same")
    end
  end
  end
 def warehouse_name
   Warehouse.find(warehouse_id).name
 end

  def created_by_user
    User.find(created_by).first_name
  end
  class << self
    def new_stock_transfer(company)
      stock_transfer_voucher = StockTransferVoucher.new
      stock_transfer_voucher.company_id=company.id
      stock_transfer_voucher.voucher_date = Time.zone.now.to_date
      stock_transfer_voucher.voucher_number = VoucherSetting.next_stock_transfer_voucher_number(company)
      stock_transfer_voucher.stock_transfer_line_items.build
      stock_transfer_voucher
    end

    def create_stock_transfer(params, company, user, fyr)
      stock_transfer_voucher = StockTransferVoucher.new(params[:stock_transfer_voucher])
      stock_transfer_voucher.created_by = user.id
      stock_transfer_voucher.company_id = company
      stock_transfer_voucher.branch_id = user.branch_id unless user.branch_id.blank?
      stock_transfer_voucher.fin_year = fyr
      stock_transfer_voucher
    end

    def update_stock_transfer(params, user, fyr)
      stock_transfer_voucher = StockTransferVoucher.find(params[:id])
      stock_transfer_voucher.assign_attributes(params[:stock_transfer_voucher])
      stock_transfer_voucher.branch_id = user.branch_id unless user.branch_id.blank?
      # stock_transfer_voucher.fin_year = fyr
      stock_transfer_voucher
    end
  end
  # to save voucher and update inventory with
  def save_inventory
    save_result = false
    transaction do
       if save
         stock_transfer_line_items.each do |line_item|
          line_item.product_batch.update_attributes!(:warehouse_id => line_item.destination_warehouse_id) unless line_item.product_batch.blank?
          Stock.increase(company_id, line_item.product_id, line_item.destination_warehouse_id, line_item.transfer_quantity, 0.0)
          Stock.reduce(company_id, line_item.product_id, warehouse_id, line_item.transfer_quantity)
          # Stock.transfer_stock(company_id, line_item.product_id, warehouse_id, line_item.destination_warehouse_id, line_item.transfer_quantity)
         end
       save_result = true
      end
    end
   save_result
  end
  
  # to update voucher and inventory
  # before_update :update_inventory

  # def update_inventory
  #   stock_transfer_voucher = StockTransferVoucher.find id
  #   stock_transfer_voucher.stock_transfer_line_items.each do |line_item|
  #    stock = Stock.find_by_company_id_and_product_id_and_warehouse_id(company_id, line_item.product_id, line_item.destination_warehouse_id)
  #   if stock.quantity > line_item.transfer_quantity
  #     # stock.quantity -= line_item.transfer_quantity
  #      Stock.transfer_stock(company_id, line_item.product_id, warehouse_id, line_item.destination_warehouse_id, line_item.transfer_quantity)
  #   else
  #     Stock.transfer_stock(company_id, line_item.product_id, line_item.destination_warehouse_id, warehouse_id, line_item.transfer_quantity)
  #     # stock.quantity += line_item.transfer_quantity
  #   end
  #  end
  # end

  def register_user_action(remote_ip, action)
    Workstream.register_user_action(company_id, created_by, remote_ip,"Stock transfer voucher #{voucher_number} #{action} by #{created_by_user} ", action, branch_id)
  end

  def register_delete_action(remote_ip, user, action)
    Workstream.register_user_action(company_id, user.id, remote_ip,"Stock transfer voucher #{voucher_number} #{action} by #{created_by_user} ", action, branch_id)
  end

end

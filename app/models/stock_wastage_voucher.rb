class StockWastageVoucher < ActiveRecord::Base
  scope :by_branch_id, lambda {|id| where(:branch_id => id) unless id.blank? }
  scope :by_deleted, lambda {|del| where(:deleted => del)}
  scope :by_date, lambda{|fin_year| where(:voucher_date => fin_year.start_date..fin_year.end_date) unless fin_year.blank?}
  scope :by_custom_field, lambda{|custom_field| where("custom_field1 = ? or custom_field2 =? or custom_field3=? ",custom_field, custom_field, custom_field) unless custom_field.blank?}

  belongs_to :company
  belongs_to :warehouse
  has_many :stock_wastage_line_items
  accepts_nested_attributes_for :stock_wastage_line_items, :allow_destroy => true
 # attr_accessible :stock_wastage_line_items_attributes , :details, :warehouse_id, :voucher_number, :voucher_date
  validates_presence_of  :warehouse_id, :voucher_date, :voucher_number
  validates_uniqueness_of :voucher_number, :scope => :company_id
  validates :custom_field1, :custom_field2, :custom_field3, :length => { :maximum => 30, :too_long => "%{count} characters is the maximum allowed" }
  # validate :save_only_in_current_year
  validate :save_in_frozen_fy
  attr_accessor :fin_year

  def voucher_setting
    VoucherSetting.by_voucher_type(18, company_id).first
  end

  def save_in_frozen_fy
    if !voucher_date.blank? && in_frozen_year?
      errors.add(:voucher_date, "can't be in frozen financial year")
    end
  end

  def in_frozen_year?
    FinancialYear.check_if_frozen(company_id, voucher_date.to_date)
  end

  # def save_only_in_current_year
  #   year = Year.find_by_name(fin_year)
  #   f_year = FinancialYear.find_by_company_id_and_year_id(company_id, year.id)
  #   if !voucher_date.blank? && (voucher_date < f_year.start_date || voucher_date > f_year.end_date)
  #     errors.add(:voucher_date, " must be in current financial year")
  #   end
  # end

  validate :available_quantity
  def available_quantity
    stock_wastage_line_items.each do |line_item|
      unless line_item.product.blank? || warehouse.blank? || line_item.quantity.blank?
        stock = Stock.find_by_company_id_and_product_id_and_warehouse_id(company_id, line_item.product.id, warehouse_id)
        if line_item.product.batch_enable? && !line_item.product_batch.blank? && line_item.product_batch.quantity < line_item.quantity
          errors.add(:base, "quantity not available in selected batch.")
        elsif stock.blank?
          str = ""
          str += " for #{line_item.product.name}" unless line_item.product.blank?
          errors.add(:base, "No stock available in selected warehouse"+str)
        elsif !stock.quantity.blank? && !line_item.quantity.blank? && stock.quantity < line_item.quantity
          errors.add(:base, "No quantity available in selected warehouse")
        end
      end
    end
  end

  before_update :update_inventory
  def update_inventory
    wastage_voucher = StockWastageVoucher.find id
    wastage_voucher.stock_wastage_line_items.each do |line_item|
      if line_item.product.batch_enable?
        product_batch = line_item.product_batch
        product_batch.update_attributes(:quantity => (product_batch.quantity + line_item.quantity)) unless product_batch.blank?
      else
        Stock.increase_wastage(company_id, line_item.product_id, warehouse_id, line_item.quantity)
      end
    end
    stock_wastage_line_items.each do |line_item|
      if line_item.product.batch_enable?
        product_batch = ProductBatch.find_by_id line_item.product_batch_id
        product_batch.update_attributes(:quantity => (product_batch.quantity - line_item.quantity)) unless product_batch.blank?
      else
        Stock.reduce_wastage(company_id, line_item.product_id, warehouse_id, line_item.quantity)
      end
    end
  end

  before_destroy :retain_inventory
  def retain_inventory
    stock_wastage_line_items.each do |line_item|
      if line_item.product.batch_enable?
        line_item.product_batch.update_attributes(:quantity => (line_item.product_batch.quantity + line_item.quantity)) unless line_item.product_batch.blank?
      else
        Stock.increase_wastage(company_id, line_item.product_id, warehouse_id, line_item.quantity)
      end
    end
  end

  class << self
    def new_stock_wastage(company)
      stock_wastage_voucher = StockWastageVoucher.new
      stock_wastage_voucher.company_id=company.id
      stock_wastage_voucher.voucher_date = Time.zone.now.to_date
      stock_wastage_voucher.voucher_number = VoucherSetting.next_stock_wastage_voucher_number(company)
      stock_wastage_voucher.stock_wastage_line_items.build
      stock_wastage_voucher
    end

    def create_stock_wastage(params, company, user, fyr)
      stock_wastage_voucher = StockWastageVoucher.new(params[:stock_wastage_voucher])
      stock_wastage_voucher.created_by = user.id
      stock_wastage_voucher.company_id = company
      stock_wastage_voucher.fin_year = fyr
      stock_wastage_voucher.branch_id = user.branch_id unless user.branch_id.blank?
      stock_wastage_voucher
    end

    def update_stock_wastage(params, user, fyr)
      stock_wastage_voucher = StockWastageVoucher.find(params[:id])
      stock_wastage_voucher.branch_id = user.branch_id unless user.branch_id.blank?
      stock_wastage_voucher.fin_year = fyr
      stock_wastage_voucher
    end

  def total_quantity
    quantity = self.stock_wastage_line_items.sum(:quantity)
    total = quantity
    total
   end

   def get_wastage_record(params, company, user, current_financial_year)
      start_date = params[:start_date].blank? ? current_financial_year.start_date : params[:start_date].to_date
      end_date = params[:end_date].blank? ? current_financial_year.end_date : params[:end_date].to_date
      branch_id = params[:branch_id].blank? ? user.branch_id : params[:branch_id].to_i
      stock_wastage_vouchers = StockWastageVoucher.by_branch_id(branch_id).where(:company_id => company, :voucher_date => start_date..end_date)
    end
    def get_record_with_custom_field(params, company, current_financial_year)
      start_date = params[:start_date].blank? ? current_financial_year.start_date : params[:start_date].to_date
      end_date = params[:end_date].blank? ? Time.zone.now.to_date : params[:end_date].to_date
      voucher_type = params[:voucher_type]
      val = params[:custom_field] unless params[:custom_field].blank?
      stock = StockWastageVoucher.where(:company_id=>company.id, :voucher_date => start_date..end_date).by_custom_field(val)
    end

  end
  def created_by_user
    User.find_by_id(created_by).full_name
  end

  def set_inventory
    stock_wastage_line_items.each do |line_item|
      if line_item.product.batch_enable?
        line_item.product_batch.update_attributes(:quantity => (line_item.product_batch.quantity - line_item.quantity)) unless line_item.product_batch.blank?
      else
        Stock.reduce(company_id, line_item.product_id, warehouse.id, line_item.quantity)
      end
    end
  end

  def register_user_action(remote_ip, action)
    Workstream.register_user_action(company_id, created_by, remote_ip," #{voucher_number} #{action} by #{created_by_user} from #{warehouse.name}", action, branch_id)
  end

  def register_delete_action(remote_ip, user, action)
    Workstream.register_user_action(company_id, user.id, remote_ip," #{voucher_number} #{action} by #{created_by_user} from #{warehouse.name}", action, branch_id)
  end

end

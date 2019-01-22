class DeliveryChallan < ActiveRecord::Base
  scope :by_date, lambda{|fin_year| where(:voucher_date => fin_year.start_date..fin_year.end_date) unless fin_year.blank?}
  scope :by_customer, lambda{|customer| where(:customer_id=> customer) unless customer.blank? }
  scope :by_voucher, lambda{|voucher_no| where("voucher_number like ?", "%#{voucher_no}%")}
  scope :by_date_range, lambda{|start_date, end_date| where(:voucher_date=> start_date..end_date) unless start_date.blank? || end_date.blank? }
  scope :by_sales_order, lambda{|sales_order| where(:sales_order_id => sales_order) unless sales_order.blank?}
  scope :by_sales_order_id, lambda{|sales_order| where(:sales_order_id => sales_order_id) unless sales_order_id.blank?}


  belongs_to :account
  belongs_to :customer
  belongs_to :company
  belongs_to :warehouse
  belongs_to :sales_order
  has_many :delivery_challan_line_items,  :dependent => :destroy
  accepts_nested_attributes_for :delivery_challan_line_items, :reject_if => lambda{|a| a[:quantity].blank? }, :allow_destroy => true
  attr_accessible :voucher_number, :voucher_date, :terms_and_conditions, :customer_notes, :delivery_challan_line_items_attributes,
  :warehouse_id,:account_id,:sales_order_id, :customer_id


  #validations
  validates_presence_of :voucher_date, :customer_id, :voucher_number, :warehouse_id
  validates_uniqueness_of :voucher_number, :scope => :company_id
  validates_presence_of :delivery_challan_line_items
  validates_associated :delivery_challan_line_items, :message => "fields with * are mandatory"
  # validate :save_only_in_current_year
  # validate :validate_account_type, :if => :account_id
  validate :validate_stock
  validate :save_in_frozen_fy
  attr_accessor :fin_year

  def delete(remote_ip, user)
    transaction do
      delivery_challan_line_items.each do |line_item|
       if line_item.product.inventory?
         if line_item.product.batch_enable?
           product_batch = line_item.product_batch
           product_batch.update_attributes(:quantity => (product_batch.quantity + line_item.quantity)) unless product_batch.blank?
         else
           Stock.increase(self.company_id, line_item.product_id, warehouse_id, line_item.quantity, 0.00)
         end
       end
      end
      destroy
      sales_order.update_status
      register_user_action(remote_ip, 'deleted', user.branch_id)
    end
  end
  def voucher_setting
    VoucherSetting.by_voucher_type(20, company_id).first
  end

  def save_in_frozen_fy
    if !voucher_date.blank? && in_frozen_year?
      errors.add(:voucher_date, "can't be in frozen financial year")
    end
  end

  def in_frozen_year?
    FinancialYear.check_if_frozen(company_id, voucher_date)
  end
  def validate_account_type
     if !["SundryDebtor","SundryCreditor"].include?(Account.find(account_id).accountable_type)
      errors.add(:account_id,"you entered is not a customer, please select right account")
     end
  end

  # def save_only_in_current_year
  #   year = Year.find_by_name(fin_year)
  #   f_year = FinancialYear.find_by_company_id_and_year_id(company_id, year.id)
  #   if !voucher_date.blank? && (voucher_date < f_year.start_date || voucher_date > f_year.end_date)
  #     errors.add(:voucher_date, " must be in current financial year")
  #   end
  # end

 def validate_stock
  self.delivery_challan_line_items.each do |line_item|
    product=line_item.product
    stock = Stock.find_by_product_id_and_warehouse_id(line_item.product_id, self.warehouse_id)
     if !line_item.quantity.blank?
      if !stock.blank? && stock.quantity < line_item.quantity
       errors.add(:base, "#{self.warehouse_name} only has #{stock.quantity} for #{line_item.product.name}")
      elsif product.inventory? && stock.blank? #|| stock.quantity == 0
       errors.add(:base, "Stock for #{line_item.product.name} not available in #{self.warehouse_name}")
      end
     end
  end
 end

  def customer_name
    customer = Customer.find_by_id_and_company_id(customer_id, company_id)
    if !customer.blank?
      customer.name
    else
      Vendor.find(customer_id).name
    end
  end
  def warehouse_name
  	warehouse.name if warehouse
  end
 def total_quantity
   qty_total = self.delivery_challan_line_items.sum(:quantity)
   qty_total
  end

  def get_available_stock
   prd_arr = []
    self.delivery_challan_line_items.each do |line_item|
      if line_item.product.inventoriable?
        stocks = Stock.where(:product_id=> line_item.product_id)
        qty = stocks.sum(:quantity)
        if qty < line_item.quantity
          prd_arr << "#{line_item.product.name}"
        end
     end
    end
    prd_arr
  end

 class << self
  def get_customer_delivery_challan(company, account)
    where(:company_id => company, :account_id => account)
  end

  def new_delivery_challan(company, sales_order)
    delivery_challan = DeliveryChallan.new
    delivery_challan.company_id=company.id
    delivery_challan.sales_order_id = sales_order.id
    delivery_challan.customer_id = sales_order.customer_id
    delivery_challan.voucher_number = VoucherSetting.next_delivery_challan_number(company)

    sales_order.sales_order_line_items.each do |line_item|
      if line_item.remaining_quantity != 0
       delivery_challan_line_item = DeliveryChallanLineItem.new(
        :product_id => line_item.product_id,
        :description => line_item.description,
        :quantity => line_item.remaining_quantity,
        :sales_order_line_item_id => line_item.id
        )
        delivery_challan.delivery_challan_line_items << delivery_challan_line_item
      end
    end
    delivery_challan
  end
  def create_delivery_challan(params, company, fyr, user, sales_order)
    delivery_challan = DeliveryChallan.new(params[:delivery_challan])
    delivery_challan.company_id = company.id
    delivery_challan.created_by = user.id
    delivery_challan.customer_id = sales_order.customer_id
    delivery_challan.fin_year = fyr
    delivery_challan
  end

 end

  def created_by_user
    User.find(created_by).full_name
  end


  def register_user_action(remote_ip, action, branch_id)
    Workstream.register_user_action(company_id, created_by, remote_ip,
    " #{voucher_number} #{action} for customer #{customer_name} for warehouse #{warehouse_name}.", action, branch_id)
  end

  def save_with_inventory
    save_result = false
    transaction do
       if save
         delivery_challan_line_items.each do |line_item|
          if line_item.product.inventory?
            if line_item.product.batch_enable?
              product_batch = line_item.product_batch
              product_batch.update_attributes(:quantity => (product_batch.quantity - line_item.quantity)) unless product_batch.blank?
            else
              Stock.reduce(self.company_id, line_item.product_id, warehouse_id, line_item.quantity)
            end
          end
         end
       save_result = true
       self.sales_order.update_status
      end
    end
   save_result
  end

  def save_with_invoice
    save_result = false
    transaction do
       if save
         Invoice.create_with_delivery_challan(self.sales_order, self, self.created_by, self.company)
         save_result = true
         self.sales_order.update_status
      end
    end
   save_result
  end

end

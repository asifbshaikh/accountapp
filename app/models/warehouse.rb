class Warehouse < ActiveRecord::Base
  scope :by_branch_id, lambda {|id| where(:branch_id => id) unless id.blank? }
  scope :by_product , lambda { |product_id| where(product_id: product_id)  }
  has_many :purchase_return_line_items
  has_many :purchase_warehouse_details
  has_many :sales_warehouse_details
  has_many :product_batches
  has_many :stock_receipt_vouchers
  has_many :stock_issue_vouchers
  has_many :stocks,:dependent => :destroy
  has_many :products, :through => :stocks
  has_many :stock_wastage_vouchers
  has_many :delivery_challans, :dependent => :destroy
  has_many :stock_transfer_vouchers
  has_many :stock_transfer_line_items, :foreign_key => :destination_warehouse_id  
belongs_to :company

  accepts_nested_attributes_for :product_batches
  attr_accessible  :created_by, :company_id, :address, :pincode, :name, :phone, :city, :manager_id, :product_batches_attributes
  DEFAULT_WAREHOUSE_NAME = 'default warehouse'

  validates_presence_of :name
  def manager
    User.find(manager_id).username unless manager_id.blank?
  end
  class << self
    def find_by_company(company)
      self.find_all_by_company_id(company.id)
    end

    def default_warehouse(company_id)
      Warehouse.where(:company_id=>company_id).first
    end

    def create_default_warehouse( company_id, created_by_user_id)
      warehouse = Warehouse.new(:company_id=> company_id,
        :created_by => created_by_user_id,
        :name => DEFAULT_WAREHOUSE_NAME,
        :manager_id => created_by_user_id
      )
      warehouse.save
    end  

    def create_warehouse(params, company, user)
      warehouse = Warehouse.new(params[:warehouse])
      warehouse.company_id = company
      warehouse.created_by = user
      warehouse
    end
    
  end
    
  def has_stock_vouchers?
   !stock_receipt_vouchers.blank? || !stock_issue_vouchers.blank? || !stock_transfer_vouchers.blank? || !stock_wastage_vouchers.blank? || !stock_transfer_line_items.blank?
  end
  def has_inventory_vouchers?
    !product_batches.blank? || !purchase_warehouse_details.blank? || !sales_warehouse_details.blank? || !delivery_challans.blank?
  end

  def register_user_action(remote_ip, action)
    Workstream.register_user_action(company_id, created_by, remote_ip," warehouse #{name} at location #{city}", action, nil)
  end
end
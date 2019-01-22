class PurchaseLineItem < ActiveRecord::Base
  include VoucherLineItem
  scope :by_company, lambda { |company_id| includes(:purchase).where(:"purchases.company_id"=>company_id) }
  scope :by_product, lambda { |product_id| where(:product_id=>product_id) unless product_id.blank? }
  scope :by_branch,lambda { |branch_id| joins(:purchase).where(:"purchases.branch_id"=> branch_id) unless branch_id.blank? }
  scope :by_record_date, lambda { |start_date, end_date| joins(:purchase).where(:"purchases.record_date"=>(start_date..end_date))}
  scope :non_draft, lambda { joins(:purchase).where("purchases.status_id<>2")}
  has_many :purchase_taxes, :dependent=>:destroy
  has_many :tax_accounts, :class_name=>"Account", :through=> :purchase_taxes, :source=>:account, :autosave=>true
  belongs_to :purchase
  belongs_to :product
  belongs_to :account
  has_many :purchase_warehouse_details, :dependent=>:destroy, :conditions=>{:deleted=>false}
  has_many :deleted_purchase_warehouse_details, :class_name=>"PurchaseWarehouseDetail", :conditions=>{:deleted=>true}, :dependent=>:destroy
  has_many :purchase_return_line_items
  #validations
  validates_presence_of :quantity, :amount, :message => "can not be blank"
  validates_presence_of :unit_rate, :if => lambda{|a| a[:type] == 'PurchaseLineItem'}
  validates_presence_of :product_id, :if => lambda{|a| a[:type] == 'PurchaseLineItem'}
  validates_presence_of :account_id, :if => lambda{|a| a[:type] != 'PurchaseLineItem'}
  validates :amount, :numericality => {:greater_than_or_equal_to => 0.00,
                                        :message => " should not be zero or negative ." }, :if => lambda{|a| a[:type] != 'OtherChargeLineItem'}
  # validates :account_id, :uniqueness => {:scope => :purchase_id, :message => "should once per purchase entry" }
  accepts_nested_attributes_for :purchase_warehouse_details, :allow_destroy => true
  accepts_nested_attributes_for :purchase_taxes, :allow_destroy => true#, :reject_if=>lambda { |o| o[:account_id].blank?  }
  attr_accessible :amount, :quantity, :discount_percent, :tax_account_id, :product_id, :account_id,:type, :description, :unit_rate, :purchase_order_reference, :tax, :warehouse_id, 
  :cost_center, :deleted_by, :created_at, :purchase_id, :deleted, :updated_at, :approved_by, :purchase_warehouse_details_attributes, :purchase_taxes_attributes, :eligibility, :igst, :cgst, :sgst
 
  validates_presence_of :purchase_warehouse_details, :message=>"please select warehouse", :if => lambda{|e| e.current_step=="last" && !e.product.blank? && e.inventoriable? && e.product.company.plan.is_inventoriable? && !e.marked_for_destruction?}
  validates_associated :purchase_warehouse_details,:if =>  lambda{|e| e.current_step=="last" && !e.product.blank? && e.inventoriable? && e.product.company.plan.is_inventoriable? && !e.marked_for_destruction?}
  validate :ensure_quantity_is_equal_to_sum_of_purchase_warehouse_details, :if =>  lambda{|e| e.current_step=="last" && !e.product.blank? && e.inventoriable? && e.product.company.plan.is_inventoriable? && !e.marked_for_destruction?}

  attr_accessor :current_step
  before_save :check_tax_destruction

    TAX_TYPE={true=>'inclusive', false=>'exclusive'}
 
 def gst_tax_rate
    self.tax_accounts.first.accountable.tax_rate
  end

  def discount_amount
    line_discount_amount = (quantity*unit_rate)*(discount_percent/100.0) unless quantity.blank? || unit_rate.blank?

    self.purchase.foreign_currency? ? (line_discount_amount*self.purchase.exchange_rate).round(2) : line_discount_amount
  end
  
  def check_tax_destruction
    purchase_taxes.each do |tax|
      tax.mark_for_destruction if tax.account_id.blank?  
    end
  end

  def self.by_product_and_date_range(product, start_date, end_date, branch_id)
    # where(:product_id=>product).includes(:purchase).where(:purchases=>{:record_date=>start_date..end_date, :branch_id=>branch_id})
    # where(:product_id=>product).by_record_date(start_date, end_date).by_branch(branch_id)
    where(:product_id=>product).includes(:purchase).where(purchases: {:status_id=>[0,1,3], :record_date => start_date..end_date, :branch_id=>branch_id})
  end
  
  def purchase_class?
   self.class.to_s == "PurchaseLineItem"
  end
  
  def tax_inclusive_unit_cost
    # unit_rate-(tax_amount/quantity) unless quantity==0
    discount=discount_percent.blank? ? 0.0 : discount_percent
    (unit_rate*(1-(discount/100.0)))/(1+(tax_rate/100.0))
  end
  
  def tax_rate
    tax_rate=0
    tax_accounts.each do |account|
      tax_rate+=account.tax_rate
    end
    tax_rate
  end

  def ensure_quantity_is_equal_to_sum_of_purchase_warehouse_details
    quantity_in_warehouse=0
    purchase_warehouse_details.each do |pwd|
      quantity_in_warehouse+=pwd.quantity unless pwd.quantity.blank?
    end
    unless quantity==quantity_in_warehouse
      errors.add(:quantity, "must be equal to purchased quantity for #{product.name}.")
    end
  end

  # def deleted_purchase_warehouse_details
  #   PurchaseWarehouseDetail.deleted_purchase_warehouse_details(id)
  # end

  def ready_to_return_quantity
    quantity-purchase_return_line_items.sum(:quantity)
  end
  
  def fully_returned?
    purchase_return_line_items.sum(:quantity) >= quantity  
  end

  def reallocate_inventory
    if product.batch_enable? 
      purchase_warehouse_details.each do |pwd|
        product_batch = ProductBatch.find_by_id pwd.product_batch_id
        pwd.update_attribute('status_id', false) if product_batch.blank?
        stock=Stock.where(company_id: pwd.company_id, product_id: pwd.product_id, warehouse_id: pwd.warehouse_id)
        Stock.reduce(pwd.company_id, pwd.product_id, pwd.warehouse_id, 0) if stock.blank?
        product_batch.update_attributes(:warehouse_id=>pwd.warehouse_id, :quantity => (product_batch.quantity + pwd.quantity)) unless product_batch.blank?
      end
    else
      purchase_warehouse_details.each do |pwd|
        Stock.increase(purchase.company_id, product.id, pwd.warehouse_id, pwd.quantity, nil)
      end
    end
  end
  def tax_account
    Account.find_by_id(tax_account_id)
  end
  def self.subclasses
    [TaxLineItem]
  end

  def delete_with_ledger
    purchase = self.purchase
    
    to_ledger_entry = purchase.ledgers.find_by_account_id(account_id)
    from_ledger_entry = nil
    from_ledger_entry = purchase.ledgers.find(:first, :conditions => "voucher_number='#{purchase.purchase_number}' and account_id='#{purchase.account_id}' and debit=#{to_ledger_entry.credit}") unless to_ledger_entry.blank?
    transaction do
      to_ledger_entry.destroy unless to_ledger_entry.blank?
      from_ledger_entry.destroy unless from_ledger_entry.blank?
      destroy
    end
  end
                  
  def inventoriable?
    if type == "PurchaseLineItem"
     product.blank? ? false : product.inventoriable? 
    else
      false
    end
  end                  
  def item_name
    product_id.blank? ? Account.find(account_id).name : Product.find(product_id).name                            
  end

  def converted_amount
    if self.type.to_s=="PurchaseLineItem"
      line_amount = quantity * item_cost unless quantity.blank? || item_cost.blank?
    else
      line_amount = amount.abs
    end
    self.purchase.foreign_currency? ? (line_amount*self.purchase.exchange_rate).round(2) : line_amount
  end

# item cost for inclusive purchase
  def item_cost
    send("tax_#{TAX_TYPE[purchase.tax_inclusive?]}_item_cost")
  end
  
   def tax_inclusive_item_cost
    discount=discount_percent.blank? ? 0.0 : discount_percent
    (unit_rate*(1-(discount/100.0)))/(1+(tax_rate/100.0))
  end

  def tax_exclusive_item_cost
    unit_rate
  end

  def it_igst
    igst_amount = 0
    # purchase_line_items.each do |line_item|
      igst_amount = line_item.params[:igst]
    # end
    igst_amount
  end

  def it_cgst
    cgst_amount = 0
    # purchase_line_items.each do |line_item|
      cgst_amount = line_item.params[:cgst]
    # end
    cgst_amount
  end

  def it_sgst
    sgst_amount = 0
    # purchase_line_items.each do |line_item|
      sgst_amount = line_item.params[:sgst]
    # end
    sgst_amount
  end 


  # def item_cost
  #     tax_amt = 0.0
  #     product_amt = 0.0
  #     account = self.tax_account
  #     unless account.blank? || self.unit_rate.blank?
  #       parent_tax_amount=0.0
  #       account.parent_child_accounts.reverse.each do |acc|
  #           if acc.parent_id.blank?
  #             product_amt = self.unit_rate
  #             discount_amt = 0.0
  #             discount_amt = product_amt*(self.discount_percent/100) unless self.discount_percent.blank?
  #             product_amt = product_amt - discount_amt
  #             tax_amt = acc.tax_inclusive_amt(product_amt)
  #             parent_tax_amount = tax_amt
  #             product_amt = product_amt
  #           else
  #             tax_amt += tax_amt = acc.tax_inclusive_amt(parent_tax_amount)
  #             product_amt += product_amt
  #           end
  #       end
  #       product_amt
  #       tax_amt
  #     end
  #  self.purchase.tax_inclusive? ? (product_amt - tax_amt).round(2) : unit_rate.round(2)
  # end


end

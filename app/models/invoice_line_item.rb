class InvoiceLineItem < ActiveRecord::Base
  include VoucherLineItem
  scope :by_company, lambda { |company_id| joins(:invoice).where(:"invoices.company_id"=>company_id) }
  scope :by_product, lambda { |product_id| where(:product_id=>product_id) unless product_id.blank? }
  scope :by_branch,lambda { |branch_id| joins(:invoice).where(:"invoices.branch_id"=> branch_id) unless branch_id.blank? }
  scope :by_invoice_date, lambda { |start_date, end_date| joins(:invoice).where(:"invoices.invoice_date"=>(start_date..end_date))}
  scope :non_draft, lambda { joins(:invoice).where("invoices.invoice_status_id<>2")}
  belongs_to :invoice
  has_many :sales_warehouse_details, :dependent => :destroy
  belongs_to :product
  belongs_to :account
  has_many :invoice_return_line_items, :dependent=>:destroy
  has_many :invoice_taxes, :dependent=>:destroy
  has_many :tax_accounts, :class_name=>"Account", :through=>:invoice_taxes, :source=> :account
  #validation
  validates :unit_rate, :quantity, :presence => true, :if => lambda{|e| e.type ==  'InvoiceLineItem'}
  validates :amount, :numericality => {:greater_than_or_equal_to => 0.00,
                                        :message => "should not be negative." }, :if =>  lambda{|e| e.type !=  'ShippingLineItem'}
  validates :product_id,:presence =>true, :if =>  lambda{|e| e.type ==  'InvoiceLineItem'}
  validates :account_id,:presence =>true, :if =>  lambda{|e| e.type ==  nil}
  

  accepts_nested_attributes_for :invoice_taxes, :allow_destroy=>true #, :reject_if=>lambda { |o| o[:account_id].blank?  }
  accepts_nested_attributes_for :sales_warehouse_details, :allow_destroy => true #, :reject_if => lambda{|e| e[:warehouse_id].blank? || e[:quantity].blank?}
  attr_accessible :current_step, :updated_at, :cost_center, :created_at, :invoice_id, :tax_account_id, :type, :discount_percent, :product_id, :account_id, :description,
                     :quantity, :unit_rate, :amount, :tax , :warehouse_id, :sales_warehouse_details_attributes, :task_id, :invoice_taxes_attributes
  validates_presence_of :sales_warehouse_details, :message=>"Please enter sales warehouse details", :if => lambda{|e| e.current_step=="last" && !e.invoice.so_invoice? && !e.product.blank? && e.inventoriable? && e.product.company.plan.is_inventoriable? && !e.marked_for_destruction?}
  validates_associated :sales_warehouse_details,:if =>  lambda{|e| e.current_step=="last" && !e.invoice.so_invoice? && !e.product.blank? && e.inventoriable? && e.product.company.plan.is_inventoriable? && !e.marked_for_destruction?}
  validate :ensure_quantity_is_equal_to_sum_of_sales_warehouse_details, :if =>  lambda{|e| e.current_step=="last" && !e.invoice.so_invoice? && !e.product.blank? && e.inventoriable? && e.product.company.plan.is_inventoriable? && !e.marked_for_destruction?}
  TAX_TYPE={true=>'inclusive', false=>'exclusive'}
  before_save :check_tax_destruction
  attr_accessor :current_step

  #Naveen 5 Sep 2017 Returns the applied GST tax rate for this line item
  def gst_tax_rate
    if !self.tax_accounts.blank?
      self.tax_accounts.first.accountable.tax_rate
    end
  end

  def ensure_quantity_is_equal_to_sum_of_sales_warehouse_details
    quantity_in_warehouse=0
    sales_warehouse_details.each do |swd|
      quantity_in_warehouse+=swd.quantity unless swd.quantity.blank?
    end
    unless quantity==quantity_in_warehouse
      errors.add(:quantity, "must be equal to sold quantity for #{product.name}.")
    end
  end

  def is_igst_tax_line_item?
    result =false
    if (account.present?) && (account.accountable_type =='DutiesAndTaxesAccounts') && (account.name.include? "IGST" )
      result =true
    end
    result
  end
  
  def is_zero_gst_tax_line_item?
    result =false
    if (account.present?) && (account.accountable_type =='DutiesAndTaxesAccounts') && (account.name.include? "@Zero" )
      result =true
    end
    result
  end

  def is_nil_gst_tax_line_item?
    result =false
    if (account.present?) && (account.accountable_type =='DutiesAndTaxesAccounts') && (account.name.include? "@Nil" )
      result =true
    end
    result
  end

  def check_tax_destruction
    invoice_taxes.each do |tax|
      tax.mark_for_destruction if tax.account_id.blank?
    end
  end

  def discount_amount
    line_discount_amount = (quantity*unit_rate)*(discount_percent/100.0) unless quantity.blank? || unit_rate.blank?
    invoice.foreign_currency? ? line_discount_amount*invoice.exchange_rate : line_discount_amount
  end

  # Naveen
  # [FIXME] This method is no longer required and it performing a complex query. Need to remove this
  # if not called from any other code than the stock summary report
  def self.by_product_and_date_range(product, start_date, end_date, branch_id)
    if branch_id.present?
      where(:product_id=>product).includes(:invoice).where(invoices: {:invoice_status_id=>[0,2,3], :invoice_date => start_date..end_date, :branch_id=>branch_id})
    else  
      where(:product_id=>product).joins(:invoice).where(invoices: {:invoice_status_id=>[0,2,3], :invoice_date => start_date..end_date})
    end  
  end
  
  def fully_returned?
    invoice_return_line_items.sum(:quantity) >= quantity
  end

  def ready_to_return_quantity
    quantity-invoice_return_line_items.sum(:quantity)
  end

  def set_sales_warehouse_detail_status
    sales_warehouse_details.update_all(:draft=> invoice.draft? ? true : false)
  end

  def amount_with_exchange_rate
    line_amount=0
    if ["InvoiceLineItem", "TimeLineItem"].include?(self.type.to_s)
      line_amount = quantity * item_cost unless quantity.blank? || item_cost.blank?
    else
      line_amount = amount.abs
    end
    invoice.foreign_currency? ? line_amount*invoice.exchange_rate : line_amount
  end

  def get_invoiced_tax_amount
    invoice.tax_line_items.where(:account_id=>account_id).sum(:amount)
  end

  def tax_account
    Account.find(tax_account_id) unless tax_account_id.blank?
  end

  def tax_rate
    tax_rate=0
    tax_accounts.each do |account|
      tax_rate+=account.tax_rate
    end
    tax_rate
  end

  def item_cost
    send("tax_#{TAX_TYPE[invoice.tax_inclusive?]}_item_cost")
  end

  def tax_inclusive_item_cost
    discount=discount_percent.blank? ? 0.0 : discount_percent
    #(unit_rate*invoice.exchange_rate*(1-(discount/100.0)))/(1+(tax_rate/100.0))
    (unit_rate*(1-(discount/100.0)))/(1+(tax_rate/100.0))
  end

  def tax_exclusive_item_cost
    unit_rate
    #(unit_rate*invoice.exchange_rate)
  end

  def reallocate_inventory
    if product.batch_enable?
      sales_warehouse_details.each do |swd|
        product_batch = ProductBatch.find_by_id swd.product_batch_id
        product_batch.update_attributes(:quantity => (product_batch.quantity - swd.quantity)) unless product_batch.blank?
      end
    else
      sales_warehouse_details.each do |swd|
        Stock.reduce(invoice.company_id, product.id, swd.warehouse_id, swd.quantity) #if swd.id.blank?
      end
    end
  end

  def invoice_class?
   self.class.to_s == "InvoiceLineItem"
  end

  def self.subclasses
    [TaxLineItem]
  end

  def delete_with_ledger
    invoice = self.invoice

    to_ledger_entry = invoice.ledgers.find_by_account_id(account_id)
    from_ledger_entry = nil
    from_ledger_entry = invoice.ledgers.find(:first, :conditions => "voucher_number='#{invoice.invoice_number}' and account_id='#{invoice.account_id}' and debit=#{to_ledger_entry.credit}") unless to_ledger_entry.blank?
    transaction do
      to_ledger_entry.destroy unless to_ledger_entry.blank?
      from_ledger_entry.destroy unless from_ledger_entry.blank?
      destroy
    end
  end

  def inventoriable?
    product = Product.find(product_id)
    if type == "InvoiceLineItem"
     product.inventoriable?
    else
      false
    end
  end

  def item_name
    product_id.blank? ? account.name : product.name
  end

 def batch_number
  if self.product.batch_enable?
    @batch_num = []
    for swd in self.sales_warehouse_details
    if !swd.product_batch.manufacture_date.blank?
      mfg_date= "/ Mfg.On. #{swd.product_batch.manufacture_date}"
    else
      mfg_date= ""
    end

    if !swd.product_batch.expiry_date.blank?
      exp_date= "/ Exp.On. #{swd.product_batch.expiry_date}"
    else
      exp_date= ""
    end

    @batch_num << "#{swd.product_batch.batch_number}#{mfg_date}#{exp_date}"
    end
    @batch_num.join(',')
   end
 end



 def line_item_igst
 

 end
end

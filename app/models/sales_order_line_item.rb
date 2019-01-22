class SalesOrderLineItem < ActiveRecord::Base
  include VoucherLineItem
  belongs_to :sales_order
  belongs_to :product
  belongs_to :account
  has_many :delivery_challan_line_items
  has_many :sales_order_taxes, :dependent=>:destroy
  has_many :tax_accounts, :class_name=>"Account", :through=>:sales_order_taxes, :source=>:account
  #validation

  validates :amount, :numericality => {:greater_than_or_equal_to => 0.01,
                                        :message => " should not be zero or negative ." }, :if => lambda{|a| a.line_item_type == "SalesOrderLineItem" }

  #Added validation for to allow negative & positive values in Other Charges
  #Author: Ashish Wadekar
  #Date: 27th March 2017
  validates :amount, :numericality => {:allow_nil => false, :message => " cannot be blank."}, :if => lambda{|a| a.line_item_type == "ShippingLineItem" }

  #Added validation for bug fix
  #Author: Ashish Wadekar
  #Date: 13th August 2016
  validates :quantity, :numericality => {:greater_than_or_equal_to => 0.01, :message => " should not be zero or negative ." }, :if => lambda{|a| a.line_item_type == "SalesOrderLineItem" }
    validates_presence_of :product_id, :if => lambda{|a| a.line_item_type == "SalesOrderLineItem" }
    validates_presence_of :account_id, :if => lambda{|a| a.line_item_type != "SalesOrderLineItem" }
  accepts_nested_attributes_for :sales_order_taxes, :reject_if=> lambda { |o| o[:account_id].blank? }
  attr_accessible :tax_account_id, :line_item_type, :discount, :product_id, :account_id, :description, :quantity, :unit_rate, :amount, :sales_order_taxes_attributes


  # def tax_amount
  #   tax_amt = 0
  #   unless self.quantity.blank? || self.unit_rate.blank?
  #     sales_order_taxes.each do |tax|
  #       account = tax.account
  #       unless account.blank?
  #         parent_tax_amount=0
  #         account.parent_child_accounts.reverse.each do |acc|
  #           if acc.parent_id.blank?
  #             tmp_tax_amount = acc.get_tax_amount(amount)
  #             tax_amt+=tmp_tax_amount
  #             parent_tax_amount = tmp_tax_amount
  #           else
  #             tax_amt += acc.get_tax_amount(parent_tax_amount)
  #           end
  #         end
  #       end
  #     end
  #   end
  #   tax_amt
  # end

  def discount_percent
    discount
  end

  # def tax_account
  #   Account.find_by_id(tax_account_id)
  # end
  def self.subclasses
    [TaxLineItem]
  end

  def item_name
    product_id.blank? ? (Account.find(account_id).name unless account_id.blank?) : Product.find(product_id).name
  end

  def delivered_quantity
    DeliveryChallanLineItem.where(:sales_order_line_item_id => self.id).sum(:quantity)
    # qty = 0
    #   line_items = DeliveryChallanLineItem.where(:sales_order_line_item_id => self.id)
    #   line_items.each do |line_item|
    #     qty += line_item.quantity
    #   end
    # return  qty
  end

  def invoiced_qty
    qty=0
    sales_order = SalesOrder.find_by_id(self.sales_order_id)
    invoices = sales_order.invoices
   if !invoices.blank?
    invoices.each do |invoice|
      line_items = InvoiceLineItem.where(:product_id => self.product_id, :invoice_id=> invoice.id)
     if !line_items.blank?
      line_items.each do |line_item|
        qty += line_item.quantity
      end
     end
    end
   end
   return qty
  end

 def ready_to_invoice
   qty = 0
   qty = delivered_quantity - invoiced_qty
   return qty
 end

 def remaining_quantity
    line_items = DeliveryChallanLineItem.where(:sales_order_line_item_id => self.id)
    self.quantity- line_items.sum(:quantity)
  end

 def self.soqty(id)
  line_item = SalesOrderLineItem.find_by_id(id)
  if !line_item.blank?
    dline_items = DeliveryChallanLineItem.where(:sales_order_line_item_id => line_item.id)
    line_item.quantity - dline_items.sum(:quantity)
  end
 end

  def dlqty_amount
     amt = 0
     disc = 0
     total_amt = 0
        if !discount.blank?
         amt = (self.ready_to_invoice*unit_rate)
         disc = amt*(discount/100)
         total_amt = amt - disc
         else
          total_amt = (self.ready_to_invoice*unit_rate)
        end
    return  total_amt
  end

  def dlqty_tax
     tax =0
      unless tax_account_id.blank?
        account = Account.find_by_id(tax_account_id)
        tax = account.get_tax_amount(dlqty_amount)
      end
    return tax
  end

#for single dc to invoice

  def dc_quantity
    line_item = DeliveryChallanLineItem.find_by_sales_order_line_item_id(self.id)
    qty = line_item.quantity
  end

  def dcamt
    amt = 0
     disc = 0
     total_amt = 0
        unless discount.blank?
         amt = (self.dc_quantity*unit_rate)
         disc = amt*(discount/100)
         total_amt = amt - disc
         else
          total_amt = (self.dc_quantity*unit_rate)
        end
    return  total_amt
  end

####################################
  def product_batch_id
      delivery_challan_line_items = DeliveryChallanLineItem.where(:sales_order_line_item_id => self.id)
      batch_id = nil
      delivery_challan_line_items.each do |line_item|
        batch_id = line_item.product_batch_id
      end
        return batch_id

  end
end

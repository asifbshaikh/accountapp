class SalesOrder < ActiveRecord::Base
  include VoucherBase
  scope :this_year_and_previous_unbilled, lambda { |start_date, end_date| where("voucher_date between ? and ? or billing_status in(0,1) or status in(0,1)", start_date, end_date) }
  scope :by_date, lambda{|fin_year| where(:voucher_date => fin_year.start_date..fin_year.end_date) unless fin_year.blank?}
  scope :by_customer, lambda{|customer| where(:customer_id=> customer) unless customer.blank? }
  scope :by_voucher, lambda{|voucher_no| where("voucher_number like ?", "%#{voucher_no}%")}
  scope :by_date_range, lambda{|start_date, end_date| where(:voucher_date=> start_date..end_date)  unless start_date.blank? || end_date.blank? }
  scope :by_amount_range, lambda{|min_amt, max_amt| where(:total_amount=> min_amt..max_amt)}
  scope :by_status, lambda{|status| where(:status => status) unless status.blank?}
  scope :by_billing_status, lambda{|billing_status| where(:billing_status => billing_status) unless billing_status.blank?}
  scope :by_branch_id, lambda {|id| where(:branch_id => id) unless id.blank? }
  scope :by_project, lambda {|project| where(:project_id => project) unless project.blank? }

  belongs_to :account
  belongs_to :company
  belongs_to :customer
  belongs_to :estimate
  belongs_to :project
  has_many :delivery_challans#, :dependent => :destroy
  has_many :invoice_sales_orders, :dependent => :destroy
  has_many :invoices, :through => :invoice_sales_orders
  has_many :sales_order_line_items, :conditions => {:line_item_type => "SalesOrderLineItem"}, :dependent => :destroy
  has_many :tax_line_items, :class_name => "SalesOrderLineItem", :conditions=> {:line_item_type=> nil}, :dependent => :destroy, :autosave=>true
  has_many :shipping_line_items, :class_name => "SalesOrderLineItem", :conditions=> {:line_item_type=> "ShippingLineItem"}, :dependent => :destroy
  accepts_nested_attributes_for :sales_order_line_items, :reject_if => true , :allow_destroy => true
  accepts_nested_attributes_for :tax_line_items, :reject_if => true , :allow_destroy => true
  accepts_nested_attributes_for :shipping_line_items, :reject_if => lambda {|a| a[:account_id].blank? && a[:amount].blank? }, :allow_destroy => true
  attr_accessible :po_reference, :po_date, :project_id, :total_amount, :voucher_number, :voucher_date, :terms_and_conditions, :customer_notes, :sales_order_line_items_attributes, :tax_line_items_attributes,
                   :shipping_line_items_attributes, :estimate_id, :currency_id, :exchange_rate, :customer_id, :gst_salesorder, :place_of_supply

  STATUS = {'1' => "Open", '2' => "Partially Executed", '3' => "Executed", '4' => "Draft", '5' => "Cancelled"}
  BillingStatus = {'0' => "Unbilled", '1' => "Partially Billed", '2' => "Billed"}
  #validations
  validates_presence_of :voucher_date,  :voucher_number
  # validates_presence_of :account_id, :on =>:update
  validates_presence_of :customer_id, :on =>:update
  validates_uniqueness_of :voucher_number, :scope =>:company_id
  validates_presence_of :sales_order_line_items
  validates_presence_of :place_of_supply, :if => lambda{|e| (e.gst_salesorder?)}
  validate :check_sales_order_line_items
  validates_associated :sales_order_line_items, :message => "fields with * are mandatory"
  validates_associated :tax_line_items, :message => "fields with * are mandatory. You can remove the Tax line item if you don't want to enter the Tax amount."
  validates_associated :shipping_line_items, :message => "account and amount both are mandatory"
  # validate :save_only_in_current_year, :on => :update
  # validate :validate_account_type, :on => :update
  validate :validate_exchange_rate, :if => :exchange_rate
  attr_accessor :fin_year
  validate :customer_effective_date


    def place_of_supply_state
    state =  State.find_by_state_code(self.place_of_supply)
    unless state.blank?
      state.name
    end
    end


  def voucher_setting
    VoucherSetting.by_voucher_type(19, company_id).first
  end
  def customer_effective_date
    if !customer.blank? && !voucher_date.blank? && voucher_date < customer.account.start_date
      errors.add(:voucher_date, "must be after customer activation, #{customer.name} is activated since #{customer.account.start_date}")
    end
  end
  def has_tax_lines?
    !tax_line_items.blank?
  end
  def get_party
    customer.blank? ? Vendor.find_by_id(customer_id) : customer
  end
  def account_id
    get_party.account.id unless get_party.blank?
  end

  def validate_exchange_rate
    customer = Customer.find_by_id(customer_id)
    unless customer.blank?
     if !customer.currency.blank?
      if exchange_rate <= 0
        errors.add(:exchange_rate, "should not be zero or negative")
      end
     end
    end
  end

  def validate_account_type
     if !account_id.blank? && !["SundryDebtor","SundryCreditor"].include?(Account.find(account_id).accountable_type)
      errors.add(:account_id,"you entered is not a customer, please select right account")
     end
  end

  def get_discount
    discount = 0
    sales_order_line_items.each do |line|
      discount += (line.unit_rate*line.quantity)*(line.discount/100.0) unless line.discount.blank? || line.amount.blank?
    end
    discount
  end

  # def build_tax
  #   sales_order_line_items.each do |line|
  #     unless line.marked_for_destruction?
  #       line.sales_order_taxes.each do |tax|
  #         account = tax.account
  #         unless account.blank? || line.quantity.blank? || line.product_id.blank? || line.unit_rate.blank?
  #           parent_tax_amount=0
  #           account.parent_child_accounts.reverse.each do |acc|
  #             if acc.parent_id.blank?
  #               product_amt = line.quantity * line.unit_rate
  #               discount_amt = 0
  #               discount_amt = product_amt*(line.discount/100) unless line.discount.blank?
  #               product_amt = product_amt - discount_amt
  #               tax_amount = acc.get_tax_amount(product_amt)
  #               parent_tax_amount = tax_amount
  #             else
  #               tax_amount = acc.get_tax_amount(parent_tax_amount)
  #             end
  #             tax_line_items << SalesOrderLineItem.new(:account_id => acc.id, :amount => tax_amount)
  #           end
  #         end
  #       end
  #     end
  #   end
  # end

  def currency
    if currency_id.blank?
      self.company.currency_code
    else
      Currency.find(currency_id).currency_code
    end
  end

  def customer_name
    customer = Customer.find_by_id_and_company_id(self.customer_id, self.company_id)
    if !customer.blank?
      customer.name
    else
      Vendor.find(self.customer_id).name unless self.customer_id.blank?
    end
  end

  def total_quantity
   qty_total = self.sales_order_line_items.sum(:quantity)
   qty_total
  end

  def total_delivered_qty
    qty = 0
    line_items = self.sales_order_line_items
    line_items.each do |line_item|
      qty += line_item.delivered_quantity
    end
    return qty
  end
  def total_invoiced_qty
    qty = 0
    invoices = self.invoices
    invoices.each do |invoice|
      qty += invoice.total_quantity
    end
    return qty
  end

  def amount
    sales_order_total = self.sales_order_line_items.sum(:amount)
     tax_total =  0 
            tax_line_items.each do |line_item|
              tax_account = line_item.account
              next if (tax_account.accountable_type=='DutiesAndTaxesAccounts' && tax_account.accountable.calculation_method==4 && tax_account.accountable.split_tax == 0)      
              tax_total += line_item.amount
            end

    ship_charge = self.shipping_line_items.sum(:amount)
    total = sales_order_total + tax_total + ship_charge
    total
  end

  def unbilled_amount
    line_items = self.sales_order_line_items
    line_amt = 0
    tax_amt = 0
    line_items.each do |line_item|
      line_amt += line_item.dlqty_amount
      tax_amt += line_item.dlqty_tax
    end
    total = line_amt + tax_amt
  end

  def sub_total_invoiced
    total = 0
    line_items = self.sales_order_line_items
    line_items.each do |line_item|
      total += line_item.dlqty_amount
    end
    return total
  end

  def invoiced_total
    sub_total = self.sub_total_invoiced
    tax = self.invoiced_tax
    total = sub_total + tax
  end

  def invoiced_discount
    amt = 0
    disc = 0
    line_items = self.sales_order_line_items
    line_items.each do |line_item|
     unless line_item.discount.blank?
      amt = line_item.ready_to_invoice*line_item.unit_rate
      disc += amt*(line_item.discount/100)
     end
    end
    return disc
  end

  def invoiced_tax
    tax =0
    line_items = self.sales_order_line_items
    line_items.each do |line_item|
      unless line_item.tax_account_id.blank?
        account = Account.find_by_id(line_item.tax_account_id)
        tax_rate = account.accountable.tax_rate
        tax += line_item.dlqty_amount*(tax_rate/100)
      end
    end
    return tax
  end

  def ship_charge
    self.shipping_line_items.sum(:amount)
  end

  def tax
  amt=0
    self.tax_line_items.each do |line_item|
       tax_account = line_item.account
       next if (tax_account.accountable_type=='DutiesAndTaxesAccounts' && tax_account.accountable.calculation_method==4 && tax_account.accountable.split_tax == 0)
       amt+= line_item.amount
    end  
    amt
  end
  def group_tax_amt(account_id)
    amt = 0
    tax_items = self.tax_line_items.where(:account_id => account_id)
    tax_items.each do |item|
      amt += item.amount
    end
    amt
  end

  def get_available_stock
   prd_arr = []
    self.sales_order_line_items.each do |line_item|
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


  def created_by_user
    User.find(created_by).full_name
  end

  def calculate_total_amount
    sales_order_total =0
    sales_order_line_items.each do |line_item|
      sales_order_total += line_item.amount
    end
    tax_total=0
    tax_line_items.each do |line_item|
      tax_account = line_item.account
      next if (tax_account.accountable_type=='DutiesAndTaxesAccounts' && tax_account.accountable.calculation_method==4 && tax_account.accountable.split_tax == 0)
      tax_total +=line_item.amount unless line_item.marked_for_destruction?
    end

    ship_charge=0
    shipping_line_items.each do |line_item|
      ship_charge += line_item.amount unless line_item.amount.blank?
    end

    total = sales_order_total + tax_total + ship_charge
  end

  class << self

    def get_customer_sales_order(company, account)
      where(:company_id => company, :account_id => account)
    end
    
    def new_sales_order(company, user, fyr, remote_ip)
      sales_order = SalesOrder.new
      sales_order.company_id = company.id
      sales_order.created_by = user.id
      if company.currency_code == 'INR'
        sales_order.gst_salesorder = true
      end
      sales_order.branch_id = user.branch_id
      sales_order.voucher_date = Time.zone.now.to_date
      sales_order.voucher_number = VoucherSetting.next_sales_order_number(company)
      sales_order.sales_order_line_items.build
      sales_order.fin_year = fyr
      sales_order.save(:validate=>false)
      sales_order.register_user_action(remote_ip, 'created', user.branch_id)
      sales_order
    end

    def create_sales_order(params, company, user, fyr)
      sales_order = SalesOrder.new(params[:sales_order])
      sales_order.company_id = company
      sales_order.created_by = user.id
      sales_order.branch_id = user.branch_id
      sales_order.account_id = Account.get_account_id(params[:account_id], company)
      sales_order.currency_id = sales_order.customer.currency_id #unless sales_order.customer.blank?
      if sales_order.currency_id.blank? || sales_order.customer.currency == sales_order.company.currency_code
        sales_order.exchange_rate = 0
      end
      sales_order.fin_year = fyr
      sales_order_total =0
      sales_order.sales_order_line_items.each do |line_item|
        sales_order_total += line_item.amount
      end
      sales_order.build_tax
      tax_total=0
      sales_order.tax_line_items.each do |line_item|
        tax_total +=line_item.amount
      end

      ship_charge=0
      sales_order.shipping_line_items.each do |line_item|
        ship_charge += line_item.amount unless line_item.amount.blank?
      end

      total = sales_order_total + tax_total + ship_charge
      sales_order.total_amount=total
      sales_order
    end

    def update_sales_order(params, company, user, fyr)
      sales_order = SalesOrder.find(params[:id])
      # SalesOrderLineItem.delete(sales_order.tax_line_items)
      # sales_order.reload
      sales_order.tax_line_items.each do |line_item|
        line_item.mark_for_destruction
      end
      sales_order.assign_attributes(params[:sales_order])
      sales_order.customer_id=nil if sales_order.customer.blank?
      sales_order.currency_id = sales_order.customer.currency_id unless sales_order.customer.blank?
      if sales_order.currency_id.blank? || sales_order.customer.currency == sales_order.company.currency_code
        sales_order.exchange_rate=0
      end
      sales_order.build_tax
      sales_order.total_amount=sales_order.calculate_total_amount
      sales_order
    end

    def get_status_id(index)
        string = index
      if /open|Open/i.match(string)
        value = "Open"
      elsif /partially executed|Partially Executed/i.match(string)
        value = "Partially Executed"
      elsif /executed|Executed/i.match(string)
        value = "Executed"
      elsif /cancelled|Cancelled/i.match(string)
        value = "Cancelled"
      else
        value = "Draft"
      end
      STATUS.index(value.to_s)
    end
    def get_billing_status(index)
        string = index
      if /unbilled|Unbilled/i.match(string)
        value = "Unbilled"
      elsif /partially billed|Partially Billed/i.match(string)
        value = "Partially Billed"
      else
        value = "Billed"
      end
      BillingStatus.index(value.to_s)
    end

    #Method to create SO from an estimate
    def create_from_estimate(estimate, company ,remote_ip, fyr)
      sales_order = SalesOrder.new
      sales_order.estimate_id = estimate.id
      sales_order.company_id = estimate.company.id
      if estimate.gst_estimate?
        sales_order.gst_salesorder =true
      end
      sales_order.customer_id = estimate.account.customer.blank? ? "" : estimate.account.customer_id
      sales_order.created_by = estimate.created_by
      sales_order.branch_id = estimate.branch_id
      sales_order.voucher_date = Time.zone.now.to_date
      sales_order.voucher_number = VoucherSetting.next_sales_order_number(company)
      sales_order.total_amount = estimate.total_amount
      sales_order.customer_notes = estimate.customer_notes
      sales_order.terms_and_conditions = estimate.terms_and_conditions
      sales_order.status = estimate.account.customer.blank? ? 4 : 1
      sales_order.fin_year = fyr
      if estimate.foreign_currency?
       sales_order.currency_id = estimate.currency_id
       sales_order.exchange_rate = estimate.exchange_rate
      end

   # product line items
      estimate.estimate_line_items.each do |line_item|
        # if line_item.product.inventoriable? ## Removed for converting quotation with  non-inventorable items to sales order. Check for depedencies
          sales_order_line_item = SalesOrderLineItem.new(
            :product_id => line_item.product_id,
            :quantity => line_item.quantity,
            :unit_rate => line_item.unit_rate,
            :discount => line_item.discount,
            :amount => line_item.amount,
            :description => line_item.description,
            :line_item_type=>"SalesOrderLineItem"
            )
          line_item.tax_accounts.each do |account|
            sales_order_line_item.sales_order_taxes<<SalesOrderTax.new(:account_id=>account.id)
          end
          sales_order.sales_order_line_items << sales_order_line_item
        # end
      end
      #tax line items
      sales_order.build_tax
      #other chagrs line item
      estimate.shipping_line_items.each do |line_item|
       shipping_line_item = SalesOrderLineItem.new(
        :account_id => line_item.account_id,
        :amount => line_item.amount,
        :line_item_type => "ShippingLineItem"
        )
        sales_order.shipping_line_items << shipping_line_item
      end
      sales_order.save(:validate => false)
      sales_order.register_user_action(remote_ip, 'created', estimate.branch_id)
      sales_order
    end

  end

  def register_user_action(remote_ip, action, branch_id)
    Workstream.register_user_action(company_id, created_by, remote_ip,
    " #{voucher_number} #{action} for customer #{customer_name} for amount #{amount}.", action, branch_id)
  end

  def register_delete_action(remote_ip, user, action, branch_id)
    Workstream.register_user_action(company_id, user.id, remote_ip,
    " #{voucher_number} #{action} for customer #{customer_name} for amount #{amount}.", action, branch_id)
  end

  def update_status
    if self.total_delivered_qty == self.total_quantity
      self.update_attribute(:status, 3)
    elsif self.total_delivered_qty==0
        self.update_attribute(:status, 1)
    elsif self.total_delivered_qty < self.total_quantity
      self.update_attribute(:status, 2)
    end
  end

  def foreign_currency?
    !currency_id.blank? && !exchange_rate.blank? && exchange_rate != 0 && company.currency_code != currency
  end

  def update_billing_status
    if self.total_invoiced_qty == self.total_quantity
      self.update_attribute(:billing_status, 2)
    elsif self.total_invoiced_qty==0
      self.update_attribute(:billing_status, 0)
    elsif self.total_invoiced_qty < self.total_quantity
      self.update_attribute(:billing_status, 1)
    end
  end

 def get_status
    if status == 1
          "Open"
    elsif status == 2
         "Partially Executed"
    elsif status == 3
          "Executed"
    elsif status == 4
        "Draft"
    elsif status == 5
       "Cancelled"
    end
  end
def get_billing_status
  if billing_status == 0
    "Unbilled"
  elsif billing_status == 1
    "Partially Billed"
  elsif billing_status == 2
    "Billed"
  end
end

private
##This method has been added to check atleast one line item is present when line items are marked for deletion via JavaScript
#Author: Ashish Wadekar
#Date: 16th July 2016
def check_sales_order_line_items
  if self.sales_order_line_items.size < 1 || self.sales_order_line_items.all?{|sales_order_line_item| sales_order_line_item.marked_for_destruction?}
    errors[:base] << " Atleast one line item is required in a Sales Order."
  end
end

end

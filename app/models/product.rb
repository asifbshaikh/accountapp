class Product < ActiveRecord::Base
  acts_as_taggable

  has_many :purchase_warehouse_details
  has_many :sales_warehouse_details
  has_many :product_batches, :dependent => :destroy
  has_many :stock_receipt_line_items
  has_many :stocks, :dependent => :destroy
  has_many :warehouses, :through => :stocks
  has_many :invoice_line_items
  has_many :invoice_return_line_items
  has_many :gst_credit_note_line_items
  has_many :purchase_line_items
  has_many :purchase_return_line_items
  has_many :estimate_line_items
  has_many :gstr_advance_receipt_line_items
has_many :gstr_advance_payment_line_items
  has_many :purchase_order_line_items
  has_many :stock_wastage_line_items
  has_many :stock_issue_line_items
  has_many :stock_transfer_line_items
  has_many :sales_order_line_items
  has_many :delivery_challan_line_items
  # belongs_to :account
  belongs_to :income_account, :class_name=>"Account", :foreign_key=>:income_account_id
  belongs_to :expense_account, :class_name=>"Account", :foreign_key=>:expense_account_id

  validates_presence_of :name # [FIXME] Name is allowing only special characters like ...
  validates :name, :uniqueness => {:scope => :company_id,  :case_sensitive => false}
  validates_presence_of :income_account_id, :if => lambda {|a| a.type == "SalesItem" || a.type == "ResellerItem" }
  validates_presence_of :expense_account_id, :if => lambda {|a| a.type == "PurchaseItem" || a.type == "ResellerItem" }
  validate do |product|
    product.errors.add(:base, 'Please select either Sales or Purchase checkbox') if product.type.blank?
  end

  accepts_nested_attributes_for :product_batches, :reject_if => lambda {|a| a[:warehouse_id].blank? || a[:quantity].blank? || a[:batch_number].blank? }, :allow_destroy => true
  attr_accessible :product_code, :batch_enable, :company_id, :account_id, :created_by, :name, :unit_of_measure, :average_price,
  :branch_id, :description, :type, :purchase_price, :sales_price, :expense_account_id, :income_account_id,
  :reorder_level, :inventory, :product_batches_attributes, :tag_list,:hsn_code
  validates_associated :product_batches, :if => :batch_enable

  before_update :update_previous_transactions

  INVENTORY_STATUS={true=>'product_view', false=>'service_view'}

  def available_stocks
    stocks.includes(:warehouse)
  end

  def product_type
    if self.inventoriable?
      "Product"
    else
      "Service"
    end
  end

  def purchased_stock_in_date_range(start_date, end_date, branch_id)
    purchase_line_items.includes(:purchase).where(purchases: {:status_id=>[0,1], :record_date => start_date..end_date, :branch_id=>branch_id}).sum(:quantity)
    #line_items = PurchaseLineItem.by_product_and_date_range(self.id, start_date, end_date, branch_id)
    #line_items.sum(:quantity)
  end

  def sold_stock_in_date_range(start_date, end_date, branch_id)
    invoice_line_items.includes(:invoice).where(invoices: {:invoice_status_id=>[0,2,3], :invoice_date => start_date..end_date, :branch_id=>branch_id}).sum(:quantity)
    # line_items = InvoiceLineItem.by_product_and_date_range(self.id, start_date, end_date, branch_id)
    # line_items.sum(:quantity)
  end

  def group_stock
    Stock.group_stock(id, company_id)
  end


  #method to get top selling products in a financial year
  def quantity_sold(fin_year)
    invoice_line_items.where(:type=>"InvoiceLineItem", :created_at=> fin_year.start_date..fin_year.end_date).sum(:quantity)
  end

  def created_by_user
    User.find(created_by).full_name
  end

  def opening_product_batches
    ProductBatch.where(:product_id => id, :opening_batch => true)
  end

  #indicates if the product is nearing reorder levels.
  #How to determine if product is reaching reorder level. If existing stock -reorder level ASC order
  def reorder_level?
  end


  def get_opening_stock_quantity
    stocks.sum(:opening_stock)
  end

  def get_opening_stock_amount
    result = stocks.sum("opening_stock * opening_stock_unit_price")
    result.blank? ? 0 : result.to_d
  end

  def has_expired_batch?
    result=false
    product_batches.each do |batch|
      if !batch.expiry_date.blank? && batch.expiry_date <= Time.zone.now.to_date
        result=true
      end
    end
    result
  end

  def get_batches_from(warehouse)
    ProductBatch.where(:warehouse_id => warehouse, :product_id => id)
  end

  def update_previous_transactions
    product = Product.find id
    # Find all the invoice vouchers
    invoice_ledgers = Ledger.where(:account_id => product.income_account_id, :company_id => company_id, :voucher_type => "Invoice")
    invoice_ledgers.update_all(:account_id => income_account_id) unless invoice_ledgers.blank?
    # Find all purchase vouchers
    purchase_ledgers = Ledger.where(:company_id => company_id, :account_id => product.expense_account_id, :voucher_type => "Purchase")
    purchase_ledgers.update_all(:account_id => expense_account_id) unless purchase_ledgers.blank?
  end

  def has_vouchers?
    !invoice_line_items.blank? || !purchase_line_items.blank? || !estimate_line_items.blank? || !purchase_order_line_items.blank?
  end

  #Author: Naveen
  #Date : 17 Jul 2016
  #to fix issues in Stock Summary Report
  def opening_stock_on_date(given_date, branch_id)
    quantity=0
    purchased_qty = purchase_line_items.joins(:purchase)
      .where(:purchases =>{:company_id => self.company_id, :status_id => [0,1,3], :branch_id => branch_id})
      .where("purchases.record_date < ?", given_date)
      .sum(:quantity)

    received_qty = stock_receipt_line_items.joins(:stock_receipt_voucher)
      .where(:stock_receipt_vouchers =>{:company_id => self.company_id, :branch_id => branch_id})
      .where("stock_receipt_vouchers.voucher_date < ?",given_date)
      .sum(:quantity)

    invoice_returns = invoice_return_line_items.
      select(" sum(quantity * unit_rate) as total_stk_retrn_amount, sum(quantity) as total_stk_retrn_qty").
      joins(:invoice_return).
      where(:invoice_returns => {:company_id=> self.company_id}).
      where("invoice_returns.record_date < ?", given_date)
    total_stk_retrn_amount = invoice_returns[0].total_stk_retrn_amount.blank? ? 0 : invoice_returns[0].total_stk_retrn_amount
    invoice_retrn_qty = invoice_returns[0].total_stk_retrn_qty.blank? ? 0 : invoice_returns[0].total_stk_retrn_qty


    invoiced_qty = invoice_line_items.joins(:invoice)
      .where(:invoices =>{:company_id => self.company_id, :invoice_status_id => [0,2,3,4], :branch_id => branch_id})
      .where("invoices.invoice_date < ?", given_date)
      .sum(:quantity)
    issued_qty = stock_issue_line_items.joins(:stock_issue_voucher)
      .where(:stock_issue_vouchers => {:company_id => self.company_id, :branch_id => branch_id})
      .where("stock_issue_vouchers.voucher_date < ?",given_date)
      .sum(:quantity)

    wastage_qty = stock_wastage_line_items.joins(:stock_wastage_voucher)
      .where(:stock_wastage_vouchers => {:company_id => company_id})
      .where("stock_wastage_vouchers.voucher_date < ?", given_date).sum(:quantity)

    purchase_retrn_qty = purchase_return_line_items.joins(:purchase_return)
      .where(:purchase_returns => {:company_id => company_id})
      .where("purchase_returns.record_date < ?", given_date)
      .sum(:quantity)

    quantity = (get_opening_stock_quantity + purchased_qty + received_qty + invoice_retrn_qty)-(invoiced_qty + issued_qty + wastage_qty + purchase_retrn_qty)
    quantity
  end

  #Author: Naveen
  #Date: 10 Aug 2017
  #Method to fetch closing balance
  def closing_stock
    closing_stock_on_date(Time.zone.now.to_date, nil)
  end

  #Author: Naveen
  #Date: 10 Aug 2017
  #Method to fetch closing balance
  def closing_stock_on_date(given_date, branch_id)
    opening_stock_on_date(given_date.tomorrow, branch_id)
  end

  #[TODO]Remove this method
  #Author: Naveen
  #Date : 26 Oct 2015
  #to fix issues in Stock Summary Report
  def opening_stock_amount_on_date(given_date, branch_id)
    quantity=0
    purchases = purchase_line_items.joins(:purchase)
      .where(:purchases =>{:status_id => [0,1,3], :branch_id => branch_id})
      .where("purchases.record_date < ?", given_date)
      .sum(:amount)

     #we need the below call to compute average purchase price of stock issue
    purchases_qty = purchase_line_items.joins(:purchase)
      .where(:purchases =>{:status_id => [0,1,3], :branch_id => branch_id})
      .where("purchases.record_date < ?", given_date)
      .sum(:quantity)
    if purchases_qty.present? && purchases_qty != 0
      average_purchase_price = (purchases/purchases_qty)
    else
      average_purchase_price = 0
    end

    sold= invoice_line_items.joins(:invoice)
      .where(:invoices =>{:invoice_status_id => [0,2,3,4], :branch_id => branch_id})
      .where("invoices.invoice_date < ?", given_date)
      .sum(:amount)
    issued = stock_issue_line_items.joins(:stock_issue_voucher)
      .where(:stock_issue_vouchers => {:branch_id => branch_id})
      .where("stock_issue_vouchers.voucher_date < ?",given_date)
      .sum(:quantity)
    issued_amount = issued * average_purchase_price
    received= stock_receipt_line_items.select(" sum(stock_receipt_line_items.quantity * stock_receipt_line_items.unit_rate) as amount ").joins(:stock_receipt_voucher)
      .where(:stock_receipt_vouchers =>{:branch_id => branch_id})
      .where("stock_receipt_vouchers.voucher_date < ?",given_date)
    received_amount = received[0].amount.blank? ? 0 : received[0].amount

    transaction_amount = (purchases + received_amount)-(sold + issued_amount)
    amount = get_opening_stock_amount.to_f + transaction_amount
  end

  #Author: Naveen
  #Date : 17 July 2016
  #Gives inventory valuation as on date using the weighted average cost inventory valuation method
  def inventory_valuation(valuation_date)
    quantity=0
    purchases = purchase_line_items.
      select(" sum(quantity * unit_rate) as total_purchase_price, sum(quantity) as total_purchase_qty").joins(:purchase).
      where(:purchases =>{:company_id => self.company_id, :status_id => [0,1,3]}).
      where("purchases.record_date <= ?", valuation_date)
    total_purchased_price = purchases[0].total_purchase_price.blank? ? 0 : purchases[0].total_purchase_price
    total_purchased_qty = purchases[0].total_purchase_qty.blank? ? 0 : purchases[0].total_purchase_qty


    received= stock_receipt_line_items.
      select("sum(quantity * unit_rate) as total_stk_recv_amount, sum(quantity) as total_stk_recv_qty").
      joins(:stock_receipt_voucher).
      where(:stock_receipt_vouchers => {:company_id=> self.company_id}).
      where("stock_receipt_vouchers.voucher_date <= ?",valuation_date)
    total_stk_recv_amount = received[0].total_stk_recv_amount.blank? ? 0 : received[0].total_stk_recv_amount
    total_stk_recv_qty = received[0].total_stk_recv_qty.blank? ? 0 : received[0].total_stk_recv_qty

    invoice_returns = invoice_return_line_items.
      select(" sum(quantity * unit_rate) as total_stk_retrn_amount, sum(quantity) as total_stk_retrn_qty").
      joins(:invoice_return).
      where(:invoice_returns => {:company_id=> self.company_id}).
      where("invoice_returns.record_date <= ?", valuation_date)
    total_stk_retrn_amount = invoice_returns[0].total_stk_retrn_amount.blank? ? 0 : invoice_returns[0].total_stk_retrn_amount
    total_stk_retrn_qty = invoice_returns[0].total_stk_retrn_qty.blank? ? 0 : invoice_returns[0].total_stk_retrn_qty

    total_opening_stk_qty = get_opening_stock_quantity #stocks.sum(:opening_stock)
    total_opening_stk_amount = stocks.sum("opening_stock * opening_stock_unit_price").to_d


    total_purchase_qty = total_opening_stk_qty + total_purchased_qty + total_stk_recv_qty #+ total_stk_retrn_qty
    total_purchase_amount = total_opening_stk_amount + total_purchased_price +total_stk_recv_amount #+total_stk_retrn_amount
    
    weighted_avg_cost_per_unit_price = 0
    if total_purchase_qty >0
      weighted_avg_cost_per_unit_price = total_purchase_amount / total_purchase_qty
    end

    #we add the returns qty and amounts after calculating the weighted average price. Else it will be accounted twice
    total_purchase_qty +=total_stk_retrn_qty
    total_purchase_amount +=total_stk_retrn_amount


    invoiced_qty = invoice_line_items.joins(:invoice)
      .where(:invoices =>{:invoice_status_id => [0,2,3,4], :company_id=> company_id})
      .where("invoices.invoice_date <= ?", valuation_date)
      .sum(:quantity)

    issued_qty = stock_issue_line_items.joins(:stock_issue_voucher)
      .where(:stock_issue_vouchers => {:company_id => company_id})
      .where("stock_issue_vouchers.voucher_date <= ?", valuation_date)
      .sum(:quantity)

    wastage_qty = stock_wastage_line_items.joins(:stock_wastage_voucher)
      .where(:stock_wastage_vouchers => {:company_id => company_id})
      .where("stock_wastage_vouchers.voucher_date <= ?", valuation_date).sum(:quantity)

    purchase_retrn_qty = purchase_return_line_items.joins(:purchase_return)
      .where(:purchase_returns => {:company_id => company_id})
      .where("purchase_returns.record_date <= ?", valuation_date)
      .sum(:quantity)


    total_sold_qty = invoiced_qty + issued_qty + wastage_qty + purchase_retrn_qty
    outstanding_inventory_qty = total_purchase_qty - total_sold_qty
    weighted_avg_inventory_valuation = weighted_avg_cost_per_unit_price * outstanding_inventory_qty
    weighted_avg_inventory_valuation
  end


  #Author: Naveen
  #Date : 26 Oct 2015
  #to fix issues in Stock Summary Report
  # This method returns the purchased quantity and amount of a product during the given period.
  # ==== Attributes
  # * +start_date+ - The start date of the period
  # * +end_date+ - The end date of the period
  def purchase_quantity_amount_in_period(start_date, end_date, branch_id)
    if branch_id.present?
      purchases = purchase_line_items.select("sum(quantity) as purchase_quantity, sum(amount) as purchase_amount").joins(:purchase)
        .where(:purchases =>{:company_id=> company_id, :status_id => [0,1,3], :record_date => start_date..end_date, :branch_id => branch_id})
    else
      purchases = purchase_line_items.select("sum(quantity) as purchase_quantity, sum(amount) as purchase_amount").joins(:purchase)
        .where(:purchases =>{:company_id=> company_id, :status_id => [0,1,3], :record_date => start_date..end_date})
    end    
  end

  #Author: Naveen
  #Date : 17 July 2016
  #to fix issues in Stock Summary Report
  # This method returns the purchased return quantity and amount of a product during the given period.
  # ==== Attributes
  # * +start_date+ - The start date of the period
  # * +end_date+ - The end date of the period
  def purchase_return_quantity_amount_in_period(start_date, end_date, branch_id)
    if branch_id.present?
      purchase_retrn_qty = purchase_return_line_items.select("sum(quantity) as purchase_return_quantity, sum(amount) as purchase_return_amount").joins(:purchase_return)
        .where(:purchase_returns => {:company_id => company_id, :record_date => start_date..end_date, :branch_id => branch_id})
    else
      purchase_retrn_qty = purchase_return_line_items.select("sum(quantity) as purchase_return_quantity, sum(amount) as purchase_return_amount").joins(:purchase_return)
        .where(:purchase_returns => {:company_id => company_id, :record_date => start_date..end_date, :branch_id => branch_id})      
    end
  end


  #Author: Naveen
  #Date : 29 Nov 2015
  #to fix issues in Stock Summary Report
  # This method returns the prodution stock received quantity and amount of a product during the given period.
  # ==== Attributes
  # * +start_date+ - The start date of the period
  # * +end_date+ - The end date of the period
  def production_stock_received_qty_amt_in_period(start_date, end_date, branch_id)
    if branch_id.present?
      stock_receipt_vouchers = stock_receipt_line_items.select("sum(quantity) as received_quantity, sum(unit_rate*quantity) as received_amount").joins(:stock_receipt_voucher)
        .where(:stock_receipt_vouchers =>{:company_id=> company_id, :voucher_date => start_date..end_date, :branch_id => branch_id})
    else
      stock_receipt_vouchers = stock_receipt_line_items.select("sum(quantity) as received_quantity, sum(unit_rate*quantity) as received_amount").joins(:stock_receipt_voucher)
        .where(:stock_receipt_vouchers =>{:company_id=> company_id, :voucher_date => start_date..end_date})      
    end    
  end

  def production_stock_wasted_qty_amt_in_period(start_date, end_date, branch_id)
    if branch_id.present?
      stock_wastage_vouchers = stock_wastage_line_items.select("sum(quantity) as wasted_quantity").joins(:stock_wastage_voucher)
        .where(:stock_wastage_vouchers =>{:company_id=> company_id, :voucher_date => start_date..end_date, :branch_id => branch_id})
    else
      stock_wastage_vouchers = stock_wastage_line_items.select("sum(quantity) as wasted_quantity").joins(:stock_wastage_voucher)
        .where(:stock_wastage_vouchers =>{:company_id=> company_id, :voucher_date => start_date..end_date})
    end    
  end

  #Author: Naveen
  #Date : 29 Nov 2015
  #to fix issues in Stock Summary Report
  # This method returns the stock issued to production quantity and amount of a product during the given period.
  # ==== Attributes
  # * +start_date+ - The start date of the period
  # * +end_date+ - The end date of the period
  def production_stock_issued_qty_in_period(start_date, end_date, branch_id)
    if branch_id.present?
      stock_issue_vouchers = stock_issue_line_items.select("sum(quantity) as issued_quantity").joins(:stock_issue_voucher)
        .where(:stock_issue_vouchers =>{:company_id=> company_id, :voucher_date => start_date..end_date, :branch_id => branch_id})
    else
      stock_issue_vouchers = stock_issue_line_items.select("sum(quantity) as issued_quantity").joins(:stock_issue_voucher)
        .where(:stock_issue_vouchers =>{:company_id=> company_id, :voucher_date => start_date..end_date})
    end    
  end

  #Author: Naveen
  #Date : 26 Oct 2015
  #to fix issues in Stock Summary Report
  # This method returns the sold quantity and amount of a product during the given period.
  # ==== Attributes
  # * +start_date+ - The start date of the period
  # * +end_date+ - The end date of the period
  def sales_quantity_amount_in_period(start_date, end_date, branch_id)
    if branch_id.present?
      sales = invoice_line_items.select("sum(quantity) as invoice_quantity, sum(amount) as invoice_amount").joins(:invoice)
        .where(:invoices =>{:company_id=> company_id, :deleted => false, :invoice_status_id => [0,2,3,4], :invoice_date => start_date..end_date, :branch_id => branch_id})
    else
      sales = invoice_line_items.select("sum(quantity) as invoice_quantity, sum(amount) as invoice_amount").joins(:invoice)
        .where(:invoices =>{:company_id=> company_id, :deleted => false, :invoice_status_id => [0,2,3,4], :invoice_date => start_date..end_date})
    end    
  end

  #Author: Naveen
  #Date : 26 Oct 2015
  #to fix issues in Stock Summary Report
  # This method returns the sales returns quantity and amount of a product during the given period.
  # ==== Attributes
  # * +start_date+ - The start date of the period
  # * +end_date+ - The end date of the period
  def sales_return_quantity_amount_in_period(start_date, end_date, branch_id)
    if branch_id.present?
      invoice_returns = invoice_return_line_items.
        select(" sum(quantity * unit_rate) as total_stk_retrn_amount, sum(quantity) as total_stk_retrn_qty").
        joins(:invoice_return).
        where(:invoice_returns => {:company_id=> self.company_id, :record_date => start_date..end_date, :branch_id => branch_id})
    else
      invoice_returns = invoice_return_line_items.
        select(" sum(quantity * unit_rate) as total_stk_retrn_amount, sum(quantity) as total_stk_retrn_qty").
        joins(:invoice_return).
        where(:invoice_returns => {:company_id=> self.company_id, :record_date => start_date..end_date})
    end
  end


  class << self

    def products_near_reorder(company_id)
      Product.select("products.name,products.reorder_level, sum(stocks.quantity) as sum_quantity").
        where(:company_id => company_id, :type => ['SalesItem', 'PurchaseItem', 'ResellerItem']).
        joins(:stocks).group("name").order("sum(stocks.quantity) DESC").limit(15)
    end

    #method to get top selling products
    #This method returns the top 15 selling products of a company for the given financial year
    def top_15_products(company_id, fin_year)
      # Product.where(:company_id => company_id).joins(:invoice_line_items).
      #   where(:invoice_line_items => {:type=>"InvoiceLineItem", :created_at=> fin_year.start_date..fin_year.end_date}).
      #   group("name").order("sum_quantity DESC").limit(15).sum(:quantity)
      Product.where(:company_id => company_id).joins(:invoice_line_items).
        where(:invoice_line_items => {:type=>"InvoiceLineItem"}).
        group("name").order("sum_quantity DESC").limit(15).sum(:quantity)
    end

    #02-May-2016 Naveen
    #This method returns the total opening inventory valuation of all products for a given date.
    #This is used in Profit and Loss calculation.
    def total_opening_inventory_valuation(company, as_on_date, branch_id)
      products = company.products.where(:inventory=> true)
      valuation_amount =0
      products.each do |product|
        valuation_amount += product.opening_stock_amount_on_date(as_on_date, branch_id)
      end
      return valuation_amount
    end

    #10-Apr-2016 Naveen
    #This method returns the total inventory valuation of all products for a given date.
    #This is used in Profit and Loss calculation as well as balance sheet.
    def total_inventory_valuation(company, as_on_date)
      products = company.products.where(:inventory=> true)
      valuation_amount =0
      products.each do |product|
        valuation_amount += product.inventory_valuation(as_on_date)
      end
      return valuation_amount
    end

    #10-Apr-2016 Naveen
    #This method returns the total opening inventory valuation of all products for a given date.
    #This is used in Profit and Loss calculation as well as balance sheet.
    def opening_inventory_valuation(company)
      products = company.products.where(:inventory=> true)
      opening_valuation_amount =0
      products.each do |product|
        opening_valuation_amount += product.get_opening_stock_amount
      end
      return opening_valuation_amount
    end

    # INVENTORY VALUATION CODE START
    def stock_in_hand(company, current_financial_year, as_on, branch_id)
      total_valuation=0
      if as_on.blank?
        total_valuation=Product.closing_balance(company, current_financial_year, branch_id)
      else
        as_on=as_on.to_date
        if as_on<current_financial_year.start_date
          previous_financial_year=current_financial_year.get_previous_year
          if previous_financial_year.blank?
            return total_valuation=0
          else
            total_valuation=Product.stock_in_hand(company, previous_financial_year, as_on, branch_id)
          end
        else
          # total_valuation=Product.opening_balance(company, current_financial_year, branch_id)
          total_valuation+=Product.current_year_transactions(company, current_financial_year, as_on, branch_id)
        end
      end
      total_valuation
    end

    # Naveen 01 May 2016
    # This method may not be required. It is no longer called from profit and loss report
    # def opening_balance_as_on(company, current_financial_year, as_on, branch_id)
    #   amount=0
    #   if as_on.blank?
    #     amount=Product.opening_balance(company, current_financial_year, branch_id)
    #   else
    #     as_on=as_on.to_date
    #     if as_on<current_financial_year.start_date
    #       previous_financial_year = current_financial_year.get_previous_year
    #       if previous_financial_year.blank?
    #         return amount=0
    #       else
    #         amount=Product.opening_balance_as_on(company, previous_financial_year, as_on, branch_id)
    #       end
    #     else
    #       # amount=Product.opening_balance(company, current_financial_year, branch_id)
    #       amount=Product.current_year_transactions(company, current_financial_year, as_on-1.days, branch_id)
    #     end
    #   end
    #   amount
    # end

    # def opening_balance(company, current_financial_year, branch_id)
    #   total_valuation=0
    #     if current_financial_year.freeze?
    #       total_valuation=current_financial_year.opening_stock_valuation
    #     else
    #       previous_financial_year = current_financial_year.get_previous_year
    #       if previous_financial_year.blank?
    #         total_valuation=Product.get_opening_balance(company, current_financial_year, branch_id)
    #       else
    #         total_valuation=Product.closing_balance(company, previous_financial_year, branch_id)
    #       end
    #     end
    #   total_valuation
    # end

    # def get_opening_balance(company, current_financial_year, branch_id)
    #   products = Product.where(:company_id => company, :inventory => true)
    #   amount=0
    #   products.each do |product|
    #     amount+= product.get_opening_stock_amount
    #   end
    #   amount
    # end

    # def current_year_transactions(company, current_financial_year, as_on, branch_id)
    #   products = Product.where(:company_id => company, :inventory => true)
    #   amount=0
    #   products.each do |product|
    #     quantity = product.closing_stock_quantity(current_financial_year, as_on, branch_id)
    #     amount+=product.closing_stock_amount(current_financial_year, as_on, quantity, branch_id)
    #   end
    #   amount
    # end

    # def closing_balance(company, current_financial_year, branch_id)
    #   # opening_balance=Product.opening_balance(company, current_financial_year, branch_id)
    #   closing_balance=Product.current_year_transactions(company, current_financial_year, current_financial_year.end_date, branch_id)
    #   # opening_balance+closing_balance
    # end
    # INVENTORY VALUATION CODE END

    #[FIXME] I have checked that this method is not used anywhere
    # def openining_stock_differenct(company, financial_year)
    #   amount=0
    #   products=Product.where(:company_id=>company, :inventory=>true,:type => ['SalesItem', 'PurchaseItem', 'ResellerItem'], :created_at=>financial_year.start_date..financial_year.end_date)
    #   products.each do |product|
    #     amount += product.get_opening_stock_amount
    #   end
    #   amount
    # end

    def create_default_products(company, user, income_account_id, expense_account_id)
      # Creating sales product
      sales_product = create!(:company_id => company, :created_by => user, :name => "Consultation",
        :description => "This is system generated default non-inventory product for sales",
        :type => "SalesItem", :sales_price => 150, :income_account_id => income_account_id, :inventory => 0 )
      # Creating purchase product
      purchase_product = create!(:company_id => company, :created_by => user, :name => "Purchase product",
        :description => "This is system generated default product for purchase",
        :type => "PurchaseItem", :purchase_price => 90, :expense_account_id => expense_account_id, :inventory => 1)
      # Creating reseller product
      reseller_product = create!(:company_id => company, :created_by => user, :name => "iPhone5 (demo)",
        :description => "This is system generated default product for trading",
        :type => "ResellerItem", :sales_price => 46000, :income_account_id => income_account_id,
        :purchase_price => 45000, :expense_account_id => expense_account_id, :inventory => 1)
      warehouse = Warehouse.default_warehouse(company)
      unless warehouse.blank?
        Stock.create!(:company_id => company, :product_id => purchase_product.id,
          :warehouse_id => warehouse.id, :quantity => 10)
        Stock.create!(:company_id => company, :product_id => reseller_product.id,
          :warehouse_id => warehouse.id, :quantity => 10)
      end
    end
    def create_product(params, company, user)
      product = Product.new(params[:product])
      product.batch_enable = false unless product.inventory?
      product.company_id = company
      product.created_by = user.id
      product.branch_id = user.branch_id unless user.branch_id.blank?
      if !params[:sales].blank? && !params[:purchase].blank?
        product.type = "ResellerItem"
      elsif !params[:sales].blank?
        product.type = "SalesItem"
        product.expense_account_id = nil
        product.purchase_price = nil
      elsif !params[:purchase].blank?
        product.type = "PurchaseItem"
        product.income_account_id = nil
        product.sales_price = nil
      else
        product.type = nil
      end
      product
    end

    def new_product(product_id,company_id,current_user)
      imported_product = ProductImport.find(product_id)
      product = Product.new
      product.company_id = company_id
      product.created_by = current_user
      product.name = imported_product.name
      product.unit_of_measure = imported_product.unit_of_measure
      product.description = imported_product.description
      product.reorder_level = imported_product.reorder_level
      if !imported_product.quantity.blank?
        product.inventory = true
      else
        product.inventory = false
      end
      if !imported_product.batch_no.blank?
        product.batch_enable = true
      else
        product.batch_enable = false
      end

      if !imported_product.income_account.blank? && !imported_product.expense_account.blank?
        product.type = "ResellerItem"
      elsif !imported_product.income_account.blank?
        product.type = "SalesItem"
        product.expense_account_id = nil
      elsif !imported_product.expense_account.blank?
        product.type = "PurchaseItem"
        product.income_account_id = nil
      else
        product.type = nil
      end

      product.sales_price = imported_product.sales_price
      product.purchase_price = imported_product.purchase_price
      if !imported_product.warehouse.blank?
            warehouse_name = imported_product.warehouse.strip
            warehouse = Warehouse.find_by_name_and_company_id(warehouse_name,company_id)
            if !warehouse.blank?
                warehouse_id = warehouse.id
            else
              created_warehouse = Warehouse.create!(:name => warehouse_name, :company_id => company_id, :created_by => current_user)
              warehouse_id = created_warehouse.id
            end
          end
      if !imported_product.income_account.blank?
        sales_account_name = imported_product.income_account.strip
        sales_account = Account.find_by_name_and_company_id(sales_account_name,company_id)
        if !sales_account.blank?
            product.income_account_id = sales_account.id
        else
          account_head = AccountHead.find_by_name_and_company_id("Direct Income",company_id)
          new_income_account = Account.new(:company_id => company_id, :account_head_id => account_head.id,
          :name => sales_account_name, :created_by => current_user)
          sub_account = DirectIncomeAccount.new()
          new_income_account.accountable = sub_account
          new_income_account.save
          product.income_account_id = new_income_account.id
        end
      end
      if !imported_product.expense_account.blank?
        expense_account_name = imported_product.expense_account.strip
        expense_account = Account.find_by_name_and_company_id(expense_account_name,company_id)
        if !expense_account.blank?
          product.expense_account_id = expense_account.id
        else
          account_head = AccountHead.find_by_name_and_company_id("Direct Expenses",company_id)
          new_expense_account = Account.new(:company_id => company_id, :account_head_id => account_head.id,
          :name => expense_account_name, :created_by => current_user)
          sub_account = DirectExpenseAccount.new(:inventoriable => false)
          new_expense_account.accountable = sub_account
          new_expense_account.save
          product.expense_account_id = new_expense_account.id
        end
      end
      product_batches = ProductBatch.new
      product_batches.product_id = product.id
      product_batches.warehouse_id = warehouse_id
      product_batches.batch_number = imported_product.batch_no
      product_batches.quantity = imported_product.quantity
      product_batches.company_id = company_id
      product_batches.opening_stock_unit_price = imported_product.unit_price
      product.product_batches << product_batches
      product
    end

    def update_product(params, company, user)
      product = Product.find(params[:id])
      product.branch_id = user.branch_id unless user.branch_id.blank?
      if !params[:sales].blank? && !params[:purchase].blank?
        product.type = "ResellerItem"
      elsif !params[:sales].blank?
        product.type = "SalesItem"
        product.expense_account_id = nil
        product.purchase_price = nil
      elsif !params[:purchase].blank?
        product.type = "PurchaseItem"
        product.income_account_id = nil
        product.sales_price = nil
      else
        product.type = nil
      end
      product
    end

    def get_sales_order_products(company)
      products = Product.where("company_id =? and inventory =? and (type ='SalesItem' or type = 'ResellerItem')", company, 1)
    end

    def get_sales_products(company)
      products = Product.where("company_id =? and (type ='SalesItem' or type = 'ResellerItem')", company)
    end

    def get_purchase_products(company)
      products = Product.where("company_id =? and (type ='PurchaseItem' or type = 'ResellerItem')", company)
    end

    def find_by_company(company)
      Product.find_all_by_company_id(company.id)
    end

    def get_low_stock(params, company)
      products = Product.where(:company_id => company.id, :type => ['SalesItem', 'PurchaseItem', 'ResellerItem'])
    end

    #[FIXME] Reorder level is minimum level the stock cannot fall down
    def reorder_level_products(company)
      products = Product.where(:company_id => company.id)
      @reorder_level = []
      products.each do |p|
        unless !p.blank?
         @reorder_level << p if p.quantity <= p.reorder_level
        end
      end
      @reorder_level
    end

    def expired_products(company)
      ProductBatch.where(:company_id => company.id, :expiry_date => Time.zone.now.to_date.end_of_month)
    end
  end

  def quantity
    self.stocks.sum(:quantity)
  end

  def update_average_price(price)
   update_attributes(:average_price => price)
  end

   def update_corresponding_product(name)
     update_attribute("name", name)
   end

  def has_stock_vouchers?
    !stock_receipt_line_items.blank? || !stock_issue_line_items.blank? || !stock_wastage_line_items.blank? || !stock_transfer_line_items.blank? || !sales_order_line_items.blank? || !delivery_challan_line_items.blank?
  end

  def get_stock_receipt_vouchers_count
    StockReceiptLineItem.joins("product").where("product_id = ?", id).count
  end

  def get_stock_issue_vouchers_count
    StockIssueLineItem.joins("product").where("product_id = ?", id).count
  end

  def register_user_action(remote_ip, action)
    Workstream.register_user_action(company_id, created_by, remote_ip," product '#{name}'", action, branch_id)
  end

  def register_delete_action(remote_ip, user, action)
    Workstream.register_user_action(company_id, user.id, remote_ip," product '#{name}'", action, branch_id)
  end

  def current_balance
    account.current_balance
  end

  def account
    account_id = type=='PurchaseItem' ? expense_account_id : income_account_id
    Account.find_by_id(account_id)
  end

  # def income_account
  #   Account.find_by_id(income_account_id)
  # end

  # def expense_account
  #   Account.find_by_id(expense_account_id)
  # end

  def inventoriable?
    inventory?
  end

  def enter_opening_stock(params)
    #ENTERING OPENING STOCK IN CASE WITHOUT BATCH
    unless params[:warehouse].blank? || !inventoriable?
      params[:warehouse].each do |w|
      stock = Stock.create!(:company_id => company_id, :product_id => id, :warehouse_id => w,
          :quantity => params['quantity_at_'+w], :opening_stock => params['quantity_at_'+w],
          :opening_stock_unit_price => params['product_price_at_'+w] )
      end
    end
    #ENTERING OPENING STOCK IN CASE BATCH NUMBERS PRESENT
    self.reload
    unless product_batches.blank?
      product_batches.each do |product_batch|
        #STOCK ENTRY IS ALREADY PASSED FROM ProductBatch MODEL ON AFTER CREATE CALLBACK
        stock = Stock.where(:company_id => company_id, :product_id => id, :warehouse_id => product_batch.warehouse_id).first
        if !stock.blank?
          past_value=0
          past_value = stock.opening_stock*stock.opening_stock_unit_price unless stock.opening_stock.blank? || stock.opening_stock_unit_price.blank?
          current_value=0
          current_value = product_batch.quantity*product_batch.opening_stock_unit_price unless product_batch.quantity.blank? || product_batch.opening_stock_unit_price.blank?
          past_quantity=0
          past_quantity = stock.opening_stock unless stock.opening_stock.blank?
          current_quantity=0
          current_quantity=product_batch.quantity unless product_batch.quantity.blank?
          avg_price = (past_value+current_value)/(past_quantity+current_quantity)
          stock.update_attributes(:opening_stock => (stock.opening_stock + product_batch.quantity), :opening_stock_unit_price=>avg_price)
        end
      end
    end
  end

  def manage_batchwise_opening_stock
    unless product_batches.blank?
      product_batches.each do |product_batch|
        old_batch = ProductBatch.find_by_id product_batch.id
        #STOCK ENTRY IS ALREADY PASSED FROM ProductBatch MODEL ON AFTER UPDATE CALLBACK
        stock = Stock.where(:company_id => company_id, :product_id => id, :warehouse_id => product_batch.warehouse_id).first
        if !stock.blank?
          stock.update_attributes(:opening_stock => ((stock.opening_stock - product_batch.quantity ) + quantity))
        end
      end
    end
  end

  # stock receipt quantity
  def get_stock_receipt_vouchers_quantity(params, company, fyr)
    start_date = start_date = params[:start_date].blank? ? fyr.start_date : params[:start_date].to_date
    end_date = params[:end_date].blank? ? ((Time.zone.now.to_date > fyr.end_date)? fyr.end_date : Time.zone.now.to_date) : params[:end_date].to_date
    qty = 0
    products = Product.where(:company_id => company.id, :inventory => true)
    products.each do |product|
      if !product.blank?
        stock_receipt_line_items = StockReceiptLineItem.where(:product_id =>product.id, :created_at=> start_date..end_date)
        qty = stock_receipt_line_items.sum(:quantity)
      end
    end
    qty
  end

  # stock issue quantity
  def get_stock_issue_vouchers_quantity(params, company, fyr)
    start_date = start_date = params[:start_date].blank? ? fyr.start_date : params[:start_date].to_date
    end_date = params[:end_date].blank? ? ((Time.zone.now.to_date > fyr.end_date)? fyr.end_date : Time.zone.now.to_date) : params[:end_date].to_date
    qty = 0
    products = Product.where(:company_id => company.id, :inventory => true)
    products.each do |product|
      if !product.blank?
        stock_issue_line_items = StockIssueLineItem.where(:product_id =>product.id, :created_at=> start_date..end_date)
        qty = stock_receipt_line_items.sum(:quantity)
      end
    end
    qty
  end

  # stock wastage quantity
  def get_stock_wastage_vouchers_quantity(params, company, fyr)
    start_date = start_date = params[:start_date].blank? ? fyr.start_date : params[:start_date].to_date
    end_date = params[:end_date].blank? ? ((Time.zone.now.to_date > fyr.end_date)? fyr.end_date : Time.zone.now.to_date) : params[:end_date].to_date
    qty = 0
    products = Product.where(:company_id => company.id, :inventory => true)
    products.each do |product|
      if !product.blank?
        stock_wastage_line_items = StockWastageLineItem.where(:product_id =>product.id, :created_at=> start_date..end_date)
        qty = stock_receipt_line_items.sum(:quantity)
      end
    end
    qty
  end

  #sales product quantity
  def get_sales_quantity(params, company, fyr)
    start_date = start_date = params[:start_date].blank? ? fyr.start_date : params[:start_date].to_date
    end_date = params[:end_date].blank? ? ((Time.zone.now.to_date > fyr.end_date) ? fyr.end_date : Time.zone.now.to_date): params[:end_date].to_date
    qty = 0
    products = Product.where(:company_id => company.id, :type=>["SalesItem", "ResellerItem"], :inventory=> true)
    products.each do |product|
      if !product.blank?
        invoice_line_items = InvoiceLineItem.where(:product_id => product.id, :type=>"InvoiceLineItem", :created_at=> start_date..end_date)
        qty = invoice_line_items.sum(:quantity)
      end
    end
    qty
  end

  #purchase product quantity
  def get_purchase_quantity(params, company, fyr)
    start_date = start_date = params[:start_date].blank? ? fyr.start_date : params[:start_date].to_date
    end_date = params[:end_date].blank? ? ((Time.zone.now.to_date > fyr.end_date)? fyr.end_date : Time.zone.now.to_date) : params[:end_date].to_date
    qty = 0
    products = Product.where(:comapny_id=> company.id, :type=>["PurchaseItem", "ResellerItem"], :inventory => true)
    products.each do |product|
      if !product.blank?
        purchase_line_items = PurchaseLineItem.where(:product_id => product.id, :type=>"PurchaseLineItem", :created_at=> start_date..end_date)
        qty = purchase_line_items.sum(:quantity)
      end
    end
   qty
  end

  # total inward stock
  def total_inward_quantity(params, company, fyr)
    total = 0
    products = Product.where(:company_id=> company.id, :inventory=> true)
    products.each do |product|
      if !product.blank?
        total_purchases = product.get_purchase_qunatity(params, company, fyr) unless product.type == 'SalesItem'
        total_receipt_voucher_quantity = product.get_stock_receipt_vouchers_quantity(params, company, fyr)
        if !total_purchases.blank? && !total_receipt_voucher_quantity.blank?
          total = total_purchases + total_receipt_voucher_quantity
        end
      end
    end
    total
  end

  # total outward stock
  def total_outward_quantity(params, company, fyr)
    total = 0
    products = Product.where(:company_id=> company.id, :inventory => true)
    products.each do |product|
      if !product.blank?
        total_sales = product.get_sales_qunatity(params, company, fyr) unless product.type == 'PurchaseItem'
        total_issue_voucher_quantity = product.get_stock_issue_vouchers_quantity(params, fyr)
        total_wastage_voucher_quantity = product.get_stock_wastage_vouchers_quantity(params,  fyr)
        total = total_sales + total_issue_voucher_quantity + total_wastage_voucher_quantity
      end
    end
    total
  end

##################################################
#Added for stock_summary from Inventory_helper
# on 28th September,2015

#################################################
# [FIXME] This method can be removed as its no longer used.Need to confirm
# Naveen : 31-Oct-2015. No longer using this method in Stock Summary report
def closing_ason_stock_quantity(start_date, end_date, branch_id)
    quantity=0
    purchase_line_items = PurchaseLineItem.by_company(company_id).non_draft.by_product(id).by_record_date(start_date, end_date).by_branch(branch_id).order("purchases.record_date DESC")
    purchased_quantity = purchase_line_items.sum(:quantity)

    stock_receipt_line_items = StockReceiptLineItem.by_company(company_id).by_product(id).by_voucher_date(start_date, end_date).by_branch(branch_id)
    receipt_quantity = stock_receipt_line_items.sum(:quantity)

    invoice_line_items = InvoiceLineItem.by_company(company_id).by_product(id).by_invoice_date(start_date, end_date).by_branch(branch_id)
    invoiced_quantity = invoice_line_items.sum(:quantity)

    stock_wastage_line_items = StockWastageLineItem.by_company(company_id).by_product(id).by_voucher_date(start_date, end_date).by_branch(branch_id)
    wastage_quantity = stock_wastage_line_items.sum(:quantity)

    stock_issue_line_items = StockIssueLineItem.by_company(company_id).by_product(id).by_voucher_date(start_date, end_date).by_branch(branch_id)
    issued_quantity = stock_issue_line_items.sum(:quantity)

    purchase_return_line_items=PurchaseReturnLineItem.by_company(company_id).by_product(id).by_voucher_date(start_date, end_date).by_branch(branch_id)
    invoice_return_line_items=InvoiceReturnLineItem.by_company(company_id).by_product(id).by_voucher_date(start_date, end_date).by_branch(branch_id)
    purchase_return_quantity=purchase_return_line_items.sum(:quantity)
    invoice_return_quantity=invoice_return_line_items.sum(:quantity)
    quantity = (receipt_quantity + purchased_quantity + invoice_return_quantity) - (invoiced_quantity + wastage_quantity + issued_quantity + purchase_return_quantity)
  end


# [FIXME] This method can be removed as its no longer used.Need to confirm
# Naveen : 31-Oct-2015. No longer using this method in Stock Summary report
  def self.opening_ason_quantity(fy,start_date,product,branch_id)
    quantity=0
    purchases = PurchaseLineItem.joins(:purchase).where("purchases.status_id in (0,1,3) and purchases.record_date < ? and  purchases.branch_id = ?", start_date, branch_id).sum(:quantity)
    sold=InvoiceLineItem.includes(:invoice).where("invoices.invoice_status_id in (0,2,3) and invoices.invoice_date < ? and invoices.branch_id=?",start_date,branch_id).sum(:quantity)
    in_out = purchases-sold
    quantity =product.get_opening_stock_quantity+in_out
    quantity
  end


  # [FIXME] This method can be removed as its no longer used.Need to confirm
  # Naveen : 31-Oct-2015. No longer using this method in Stock Summary report
  def self.purchase_quantity(product,start_date,end_date,branch_id)
     # ["ResellerItem", "PurchaseItem"].include?(product.type) ? (number_with_precision product.purchased_stock_in_date_range(@start_date, @end_date, @branch_id), :precision=>2) : raw("-")
    ["ResellerItem", "PurchaseItem"].include?(product.type) ? product.purchased_stock_in_date_range(start_date, end_date, branch_id) : "-"
  end

  # [FIXME] This method can be removed as its no longer used.Need to confirm
  # Naveen : 31-Oct-2015. No longer using this method in Stock Summary report
  def self.purchase_total(product,start_date,end_date,branch_id)
    line_items=PurchaseLineItem.by_product_and_date_range(product, start_date, end_date, branch_id)
    # ["ResellerItem", "PurchaseItem"].include?(product.type) ? (number_with_precision line_items.sum(:amount), :precision=>2) : 0
    ["ResellerItem", "PurchaseItem"].include?(product.type) ? line_items.sum(:amount): "-"
  end

  # [FIXME] This method can be removed as its no longer used.Need to confirm
  # Naveen : 31-Oct-2015. No longer using this method in Stock Summary report
  def self.purchase_average_price(product,start_date,end_date,branch_id)
    if ["ResellerItem", "PurchaseItem"].include?(product.type)
      quantity = product.purchased_stock_in_date_range(start_date, end_date, branch_id)
      total = PurchaseLineItem.by_product_and_date_range(product, start_date, end_date, branch_id).sum(:amount)
      # number_with_precision (total==0 || quantity==0) ? 0.00 : (total/quantity), :precision=>2
      (total==0 || quantity==0) ? 0.00 : (total/quantity)
    else
      "-"
    end
  end

  # [FIXME] This method can be removed as its no longer used.Need to confirm
  # Naveen : 31-Oct-2015. No longer using this method in Stock Summary report
  def self.sales_quantity(product,start_date,end_date,branch_id)
    # ["ResellerItem", "SalesItem"].include?(product.type) ? (number_with_precision product.sold_stock_in_date_range(@start_date, @end_date, @branch_id), :precision=>2) : 0
    ["ResellerItem", "SalesItem"].include?(product.type) ? product.sold_stock_in_date_range(start_date, end_date, branch_id ): "-"
  end

  def self.sales_total(product,start_date,end_date,branch_id)
    line_items=InvoiceLineItem.by_product_and_date_range(product, start_date, end_date, branch_id)
    # ["ResellerItem", "SalesItem"].include?(product.type) ? (number_with_precision line_items_amount(line_items), :precision=>2) : 0
    ["ResellerItem", "SalesItem"].include?(product.type) ? line_items_amount(line_items) : "-"
  end

  def self.line_items_amount(line_items)
    amount=0
    line_items.each do |line_item|
      amount += line_item.item_cost * line_item.quantity unless line_item.item_cost.blank? || line_item.quantity.blank?
    end
    amount
  end

  def self.sales_average_price(product,start_date,end_date,branch_id)
    if ["ResellerItem", "SalesItem"].include?(product.type)
      quantity = product.sold_stock_in_date_range(start_date, end_date, branch_id)
      line_items = InvoiceLineItem.by_product_and_date_range(product, start_date, end_date, branch_id)
      total = line_items_amount(line_items)
      # number_with_precision (total==0 || quantity==0) ? 0.00 : (total/quantity), :precision=>2
    (total==0 || quantity==0) ? 0.00 : (total/quantity)
    else
      "-"
    end
  end


  #[FIXME] Delete this method is no longer required or called from any place other than stock summary
  # Naveen 01-Nov-2015
  def self.net_quantity(product,financial_year,start_date,end_date,branch_id)
    in_out_quantity= product.closing_ason_stock_quantity(start_date, end_date, branch_id)
    quantity= opening_ason_quantity(financial_year,start_date,product,branch_id)+in_out_quantity
    # number_with_precision quantity, :precision=>2
    quantity
  end

  #[FIXME] Delete this method is no longer required or called from any place other than stock summary
  # Naveen 01-Nov-2015
  def self.net_total(product,start_date,end_date,branch_id)
    purchase_total = PurchaseLineItem.by_product_and_date_range(product, start_date, end_date, branch_id).sum(:amount)
    line_items = InvoiceLineItem.by_product_and_date_range(product, start_date, end_date, branch_id)
    sales_total=line_items_amount(line_items)
    if product.type=="ResellerItem"
      total=sales_total - purchase_total
    elsif product.type=="SalesItem"
      total=sales_total
    elsif product.type=="PurchaseItem"
      total=purchase_total
    end
    # number_with_precision total, :precision=>2
    total

  end


end

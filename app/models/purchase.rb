class Purchase < ActiveRecord::Base
  include VoucherBase
  scope :this_year_and_previous_unpaid, lambda { |start_date, end_date| where("due_date between ? and ? or status_id=0", start_date, end_date) }
  scope :by_branch_id, lambda {|id| where(:branch_id => id) unless id.blank? }
  scope :by_deleted, lambda {|del| where(:deleted => del) }
  scope :by_date, lambda {|fin_year| where(:record_date => fin_year.start_date..fin_year.end_date) unless fin_year.blank?}
  scope :by_due_date, lambda{|date| where(:due_date => date) unless date.blank?}
  scope :by_status, lambda{|status| where(:status_id => status) unless status.blank?}
  scope :by_day,lambda{|day| where(:record_date => day) unless day.blank?}
  scope :by_vendor, lambda{|vendor| where(:account_id=>vendor) unless vendor.blank?}
  scope :by_voucher, lambda{|voucher| where("purchase_number like ?", "%#{voucher}%") unless voucher.blank?}
  scope :by_project, lambda{|project| where(:project_id=>project.to_i) unless project.blank? }
  scope :by_date_range, lambda{|start_date, end_date| where(:due_date=> start_date..end_date) unless start_date.blank? || end_date.blank? }
  scope :by_record_date_range, lambda{|start_date, end_date| where(:record_date=> start_date..end_date) unless start_date.blank? || end_date.blank? }
  scope :by_amount_range, lambda{|min_amt, max_amt| where(:total_amount=> min_amt..max_amt)}
  scope :by_month, lambda{|month| where(:record_date => month.beginning_of_month..month.end_of_month) unless month.blank?}
  scope :by_custom_field, lambda{|custom_field| where("custom_field1 = ? or custom_field2 =? or custom_field3=? ",custom_field, custom_field, custom_field) unless custom_field.blank?}
  scope :not_in, lambda { |purchases| where("id not in(?)", purchases.map { |e| e.id }) unless purchases.blank?}
  scope :by_currency, lambda {|currency| where(:currency_id => currency) unless currency.blank?}
  scope :by_settlement_date_range, lambda{|start_date, end_date| where(:updated_at=> start_date..end_date)}

  before_save :destroy_uploaded_file?
  # after_save :utilized_storage
  attr_accessor :old_file_size
  has_many :purchase_debit_allocations
  has_many :gst_debit_note, :through => :gst_debit_allocations
  has_many :gst_debit_allocations
  has_many :purchase_returns, :dependent=>:destroy
  has_many :stock_receipt_vouchers
  has_many :purchase_attachments
  has_many :gstr_advance_payments
  has_many :gstr_advance_payment_line_items
  belongs_to :company
  belongs_to :account
  belongs_to :settlement_account, :class_name => "Account",:foreign_key => :settlement_account_id
  belongs_to :project
  belongs_to :purchase_order
  has_many :purchases_payments, :conditions=>{:deleted=>[false, nil]}, :dependent=>:destroy
  has_many :payment_vouchers, :through=>:purchases_payments
  has_many :gstr_advance_purchases_payments, :conditions=>{:deleted=>[false, nil]}, :dependent=>:destroy
  has_many :gstr_advance_payments, :through=>:gstr_advance_purchases_payments
  has_many :ledgers, :as => :voucher, :dependent => :destroy
  has_many :purchase_line_items, :conditions => {:type => "PurchaseLineItem"}, :dependent => :destroy
  has_many :tax_line_items, :class_name => "PurchaseLineItem", :conditions => {:type => nil}, :dependent => :destroy
  has_many :discount_line_items, :class_name => "PurchaseLineItem", :conditions => {:type => "DiscountLineItem"}, :dependent => :destroy
  has_many :other_charge_line_items, :dependent => :destroy

  accepts_nested_attributes_for :purchase_line_items, :reject_if => lambda {|a| a[:product_id].blank? && a[:amount].blank? }, :allow_destroy => true
  accepts_nested_attributes_for :tax_line_items, :reject_if => lambda {|a| a[:account_id].blank? && a[:amount].blank? }, :allow_destroy => true
  accepts_nested_attributes_for :discount_line_items, :reject_if => lambda {|a| a[:account_id].blank? && a[:amount].blank? }, :allow_destroy => true
  accepts_nested_attributes_for :other_charge_line_items, :reject_if => lambda {|a| a[:account_id].blank? && a[:amount].blank? }, :allow_destroy => true
  attr_accessible :settled_amount, :settlement_exchange_rate, :settlement_account_id, :created_by, :project_id, :current_step, :branch_id, :company_id, :total_amount,:stock_receipt,:status_id, :terms_and_conditions, :record_date,
  :bill_date, :customer_notes, :bill_reference, :purchase_number, :due_date, :purchase_line_items_attributes, :tax_line_items_attributes, :discount_line_items_attributes, :uploaded_file,
   :custom_field3, :custom_field2, :custom_field1, :other_charge_line_items_attributes,:currency_id, :exchange_rate, :purchase_order_id, :tax_inclusive, :account_id, :import_purchase, :boe_date, :boe_num, :boe_value, :reverse_charge
  #validations
  validates_presence_of :account_id, :purchase_number, :record_date, :due_date
  #This validation & changes on line nos. 434,568 & 619 were added to fix the issue of Purchase voucher number auto increment
  #Author: Ashish Wadekar
  #Date: 25th August 2016
  validates_uniqueness_of :purchase_number, :scope => :company_id
  validate :check_voucher_number
  validates_presence_of :purchase_line_items
  validates_associated :purchase_line_items, :message => "fields with * are mandatory"
  validates_associated :tax_line_items, :message => "fields with * are mandatory. You can remove the Tax line item if you don't want to enter the Tax amount."
  validates_associated :discount_line_items, :message => "fields are mandatory. You can remove the Discount line item if you don't want to enter the discount amount."
  validates_associated :other_charge_line_items, :message => "account and amount both are mandatory"
  validate :record_date_and_due_date
  # validate :is_account_id
  has_attached_file :uploaded_file,
                    :storage=>:s3,
                    :s3_credentials=>"#{Rails.root}/config/s3.yml",
                    :url => ":s3_domain_url",
                    :path => "/uploaded_data/:class/:id/:basename.:extension"
  validates_attachment_size :uploaded_file, :less_than => 5.megabytes
  validates_attachment_content_type :uploaded_file, :content_type => ['image/jpeg','image/png','image /jpg','image/gif', 'application/pdf'],
                                    :message=>" must be of .jpeg,'.jpg', '.gif', .png or .pdf type",
                                    :allow_nil => true
  validate :storage_limit
  # validate :availble_balance

  # validate if balance is available or not in paid account
  # validate :save_only_in_current_year
  validate :validate_account_type, :if => :account_id
  validate :save_in_frozen_fy
  validates_presence_of :exchange_rate, :if => lambda{|e| !e.account.blank? && !e.account.get_currency_id.blank?}
  validate :validate_exchange_rate, :if => :exchange_rate
  # validate :validate_tax_account, :if => lambda{|e| e.tax_inclusive? }
  validate :validate_po_quantity, :if => lambda{|e| !e.purchase_order_id.blank?}
  validate :account_effective_date
  validates_presence_of :settlement_account_id, :if=>lambda{|e| e.settled? }
  attr_accessor :fin_year
  attr_writer :current_step
  STATUS = {'0' => "Unpaid", '1' => "Paid", '2' => "Draft", '3'=>"Settled"}
  RETURN_STATUS={true=>'returned', false=>'non_returned'}

 def itc_item
  item = Hash.new
  item[:igst] = 0
  item[:cgst] = 0
  item[:sgst] = 0
  self.purchase_line_items.each do |itc|
  item[:eligibility] = itc.eligibility
  item[:igst] = itc.igst
  item[:cgst] = itc.cgst
  item[:sgst] = itc.sgst
    end
    item
 end


 def  nil_rated_account(purchase)
    
        nil_account= false
        
        if purchase.tax_line_items.blank?
               nil_account = true
        else
          purchase.tax_line_items.each do |line_item|
             nil_account = true if line_item.account.name.include?("@Nil") || line_item.account.name.include?("@Zero") 
           end
         end
          
          nil_account
   end


def customer_GSTIN
    gstin = nil
    if vendor.present?  
       gstin = vendor.GSTIN
    else
      gstin = customer.GSTIN 
    end
    gstin
  end

  def customer_state
    if vendor.present?
      state = vendor.get_state
    else
      state = customer.get_state
    end
  end

 def gst_line_items
    #create a hash with key as tax rate 
    #get the line item rate, check if the rate is present in hash
    #if not add a new gst_line_item_object to it
    #if present get the gst_line_item and add required fields to them
    items = Hash.new
    self.purchase_line_items.each do |line_item|
      rate = line_item.gst_tax_rate
      if items.has_key? rate
        gst_tax_item = items[rate]
        gst_tax_item.add_txn_value(line_item.amount)
        gst_tax_item.add_igst_amt(line_item.igst_amt)
        gst_tax_item.add_cgst_amt(line_item.cgst_amt)
        gst_tax_item.add_sgst_amt(line_item.sgst_amt)
      else
        items[rate] = GstPurchaseLineItem.new(rate, line_item.amount, line_item.igst_amt, line_item.cgst_amt, line_item.sgst_amt)
      end
    end
    items.values
  end

  def igst_tax_amt
    @igst_tax_amt ||= calc_igst_tax_amt
  end

  def cgst_tax_amt
    @cgst_tax_amt ||= calc_cgst_tax_amt
  end

  def sgst_tax_amt
    @sgst_tax_amt ||= calc_sgst_tax_amt
  end


  def calc_igst_tax_amt
    igst_tax_amt = 0
    tax_line_items.each do |line_item|
      act_name = line_item.account.name
      if act_name.include? "IGST"
        #Rails.logger.debug "Purchase==========#{line_item.account.name} #{line_item.amount}======"
        igst_tax_amt += line_item.amount
      end
    end
    igst_tax_amt
  end

  def calc_cgst_tax_amt
    cgst_tax_amt = 0
    tax_line_items.each do |line_item|
      act_name = line_item.account.name
      if act_name.include? "CGST"
        #Rails.logger.debug "Purchase==========#{line_item.account.name} #{line_item.amount}======"
        cgst_tax_amt += line_item.amount
      end  
    end
    cgst_tax_amt
  end

  def calc_sgst_tax_amt
    sgst_tax_amt = 0
    tax_line_items.each do |line_item|
      act_name = line_item.account.name
      if act_name.include? "SGST"
        #Rails.logger.debug "Purchase==========#{line_item.account.name} #{line_item.amount}======"
        sgst_tax_amt += line_item.amount
      end  
    end
    sgst_tax_amt
  end

  def get_product_wise_summary

    items = Hash.new
    self.purchase_line_items.each_with_index do |line_item,index|
       rate = line_item.gst_tax_rate
       item = line_item.product
  
        items[item.hsn_code] = ProductWiseSummary.new(item.hsn_code, item.description[0..29], item.unit_of_measure,
          line_item.quantity, line_item.amount, line_item.igst_amt, line_item.cgst_amt, line_item.sgst_amt)
    
    end
    items.values



  end
 def customer_GSTIN
    gstin = nil
    if vendor.present?   
      gstin = vendor.GSTIN
    else
      gstin = customer.GSTIN
    end
    gstin
  end


  def voucher_setting
    VoucherSetting.by_voucher_type(5, company_id).first
  end
  
  def by_product_and_date_range(product, start_date, end_date, branch_id)

  end
  def account_effective_date
    if !account.blank? && !record_date.blank? && record_date < account.start_date
      errors.add(:record_date, "must be after account activation, #{account.name} is activated since #{account.start_date}")
    end
  end
  # -------For multi step form---------------
  def steps
    %w[first last]
  end

  def current_step
    @current_step || steps.first
  end

  def has_tax_lines?
    !tax_line_items.blank?
  end

  def first_step
    self.current_step=steps.first
  end

  def last_step
    self.current_step=steps.last
  end

  def first_step?
    current_step==steps.first
  end
  def last_step?
    current_step == steps.last
  end
  # --------End------------

  def batch_sold_out?
    result=false
    purchase_line_items.each do |line_item|
      if !line_item.product.blank? && line_item.product.batch_enable?
        line_item.purchase_warehouse_details.each do |pwd|
          sales_warehouse_details=SalesWarehouseDetail.where(:product_batch_id=>pwd.product_batch_id)
          result=true unless sales_warehouse_details.blank?
        end
      end
    end
    result
  end

  def delete_and_set_po_opened_if_present
    result=false
    transaction do
      if batch_sold_out?
        result=false
      else
        payment_vouchers.update_all(:voucher_type=>1, :allocated=>false, :advanced=>true)
        destroy
        purchase_order.set_opened unless purchase_order.blank?
        result=true
      end
    end
    result
  end

  def has_atleast_one_inventoriable_item?
    result=false
    purchase_line_items.each do |line_item|
      result=true if line_item.inventoriable? && !line_item.marked_for_destruction?
    end
    result
  end

  def original_purchase
    Purchase.find id
  end

  def draft?
    status_id==2
  end

  def settled?
    status_id==3
  end

  def fully_returned?
    result=true
    purchase_line_items.each do |line_item|
      if result
        result=line_item.quantity==line_item.purchase_return_line_items.sum(:quantity)
      end
    end
    result
  end
  def debit_note_amount
    purchase_returns.sum(:total_amount)
  end

  def has_debit_allocation_any?
    !purchase_debit_allocations.blank?
  end

  def has_gst_debit_allocation_any?
    !gst_debit_allocations.blank?
  end

  def has_return_any?
    !purchase_returns.blank?
  end
  def converted_from_po?
    !purchase_order.blank?
  end

  def validate_po_quantity
    self.purchase_line_items.each do |line_item|
      if !self.purchase_order_id.blank?
        po_item = PurchaseOrderLineItem.find_by_purchase_order_id_and_product_id_and_quantity(self.purchase_order_id, line_item.product_id, line_item.quantity)
       if po_item.blank?
        errors.add(:base,"#{line_item.product.name} quantity (#{line_item.quantity}) should be same as in purchase order (#{po_item.quantity})")
       end
      end
    end
  end

  # def validate_tax_account
  #   self.purchase_line_items.each do |line_item|
  #     if line_item.tax_account_id.blank?
  #       errors.add(:base,"Tax can not be blank for tax inclusive purchase.")
  #     end
  #   end
  # end

  def validate_exchange_rate
    account = Account.find_by_id(account_id)
    unless account.blank?
    customer_currency = account.get_currency
     if !customer_currency.blank? && company.currency_code != customer_currency
      if exchange_rate <= 0
        errors.add(:exchange_rate, "should not be zero or negative")
      end
     end
    end
  end
  def update_inventory
    # This method will refresh the inventory after purchase update(By Manjeet)
    purchase_line_items.each do |line_item|
      if line_item.inventoriable? && company.plan.is_inventoriable?
        line_item.reallocate_inventory
      end
    end
  end

  def keep_back_old_and_ensure_positive_inventory
    purchase_line_items.each do |line_item|
      line_item.deleted_purchase_warehouse_details.each do |pwd|
        stock=Stock.find_by_warehouse_id_and_product_id(pwd.warehouse_id, pwd.product_id)
        if stock.blank? || pwd.quantity<=stock.quantity || pwd.batch_is_not_yet_received?
          pwd.destroy
        else
          if !line_item.product.batch_enable? || !pwd.batch_is_not_yet_received?
            errors.add(:base, "Some of the inventory has been already sold for #{line_item.product.name}. Please check available quantity before update")
            raise ActiveRecord::Rollback
          end
        end
      end
    end
  end

  def mark_old_warehouse_details_deleted
    # Method will mark purchase warehouse details as deleted (By Manjeet)
    purchase = Purchase.find_by_id id
    unless purchase.blank?
      purchase.purchase_line_items.each do |line_item|
        if !line_item.product.blank? && line_item.inventoriable?
          line_item.purchase_warehouse_details.each do |pwd|
            pwd.mark_deleted
          end
        end
      end
    end
  end

  def save_in_frozen_fy
    if !record_date.blank? && in_frozen_year?
      errors.add(:record_date, "can't be in frozen financial year")
    end
  end

  def in_frozen_year?
    FinancialYear.check_if_frozen(company_id, record_date)
  end

  def balance_due
   total =  total_amount - (purchases_payments.sum(:amount))
   total
  end
  def vendor
    account.vendor.blank? ? account.customer : account.vendor
  end
  def total_purchased(product)
    purchase_line_items.where(:product_id => product).sum(:quantity)
  end
  
  def batch_purchased?
    result = false
    purchase_line_items.each do |line_item|
      result=true if line_item.product.batch_enable?
    end
    result
  end

  def validate_account_type
     if !["SundryDebtor","SundryCreditor"].include?(Account.find(account_id).accountable_type)
      errors.add(:account_id,"you entered is not a vendor, please select right account")
     end
  end

def manage_stock_status
    result = true
    if stock_receipt_vouchers.blank?
      result = false
    end
    ids = []
    stock_receipt_vouchers.each do |srv|
      ids<<srv.id
    end
    purchase_line_items.each do |line_item|
      aquired_stock = StockReceiptLineItem.where(:stock_receipt_voucher_id => ids, :product_id => line_item.product_id).sum(:quantity)
      result = false if aquired_stock.blank? || aquired_stock < line_item.quantity
    end
    if result
      update_attributes(:stock_receipt => true)
    elsif stock_receipt?
      update_attributes(:stock_receipt => false)
    end
  end


  def get_product(tax_id)
    caccount = Account.find_by_id(tax_id)
    paccount = Account.find_by_id(caccount.parent_id)
    line = purchase_line_items.includes(:purchase_taxes).where(:purchase_taxes=>{:account_id => paccount.blank? ? caccount.id : paccount.id}).first
    line.product
  end

  def total_quantity
   qty_total = self.purchase_line_items.sum(:quantity)
   qty_total
  end

  def discount
    discount = 0
    purchase_line_items.each do |line|
      discount += (line.unit_rate*line.quantity)*(line.discount_percent/100.0) unless line.amount.blank? || line.discount_percent.blank?
    end
    discount
  end

  def paid?
    status_id == 1
  end

  def unpaid?
    status_id==0
  end
  def return_substracted_outstanding
    if gst_purchase?
      outstanding_amt = total_amount - (payment_maid + total_returned + allocated_gst_debit) 
      outstanding_amt -= settled_amount if settled?
      outstanding_amt 
    else
      outstanding_amt = total_amount - (payment_maid + total_returned + allocated_debit)
      outstanding_amt -= settled_amount if settled?
      outstanding_amt
    end
    
  end

  def allocated_debit
    purchase_debit_allocations.sum(:amount)
  end

  def allocated_gst_debit
    gst_debit_allocations.sum(:amount)
  end

  def outstanding
    amount=return_substracted_outstanding
    amount<0? 0 : amount
  end

  def total_paid
    if gst_purchase?
      paid_amt = payment_maid + total_returned + allocated_gst_debit
      paid_amt+=settled_amount if settled?
      paid_amt
    else
      paid_amt = payment_maid + total_returned + allocated_debit
      paid_amt+=settled_amount if settled?
      paid_amt
    end
  end

  def total_returned
    purchase_returns.sum(:total_amount)
  end

  # def build_tax
  #   purchase_line_items.each do |line|
  #     unless line.marked_for_destruction? || line.quantity.blank? || line.unit_rate.blank?
  #       line.purchase_taxes.each do |tax|
  #         account = tax.account
  #         unless account.blank?
  #           parent_tax_amount=0
  #           account.parent_child_accounts.reverse.each do |acc|
  #             if acc.parent_id.blank?
  #               tax_amount = acc.get_tax_amount(line.amount)
  #               parent_tax_amount = tax_amount
  #             else
  #               tax_amount = acc.get_tax_amount(parent_tax_amount)
  #             end
  #             tax_line_items << PurchaseLineItem.new(:account_id => acc.id, :tax => 1, :amount => tax_amount)
  #           end
  #         end
  #       end
  #     end
  #   end
  # end

  def update_status_and_create_adjustment_ledger_entries
    transaction do
      if save
        if STATUS[status_id.to_s]=="Settled"
          settlement_amount= foreign_currency? ? settled_amount*settlement_exchange_rate : settled_amount
          random_str=Ledger.generate_secure_random
          debit_ledger_entry=Ledger.new_debit_ledger(account_id, company_id, record_date,
            settlement_amount, purchase_number, created_by, "", branch_id, random_str, settlement_account_id)

          credit_ledger_entry=Ledger.new_credit_ledger(settlement_account_id, company_id, record_date,
            settlement_amount, purchase_number, created_by, "", branch_id, random_str, account_id)

          ledgers << debit_ledger_entry
          ledgers << credit_ledger_entry
        end
      end
    end
  end

  class << self
    
    def purchase_register_records(current_financial_year, user, account, company, start_date, end_date, branch_id)
      begin
        if account.blank?
          purchases = company.purchases.by_record_date_range(start_date, end_date).order(:record_date)
        else
          purchases=company.purchases.by_record_date_range(start_date, end_date).by_vendor(account.id).order(:record_date)
        end
        purchases=purchases.by_branch_id(branch_id) unless user.owner? && branch_id.blank?
      rescue Exception => e
        purchases = nil
      end
      purchases
    end

    def copy_into_new(purchase_order, user, company, financial_year, remote_ip)
      purchase=Purchase.new
      purchase.company_id = purchase_order.company_id
      purchase.purchase_order_id = purchase_order.id
      purchase.account_id = purchase_order.account_id
      purchase.record_date = purchase_order.record_date
      purchase.due_date = purchase_order.due_date.present? ? purchase_order.due_date : purchase_order.record_date.advance(:weeks =>1)
      purchase.purchase_number = VoucherSetting.next_purchase_number(company)
      purchase.customer_notes = purchase_order.customer_notes
      purchase.terms_and_conditions = purchase_order.terms_and_conditions
      purchase.branch_id = purchase_order.branch_id
      purchase.project_id = purchase_order.project_id


      purchase.created_by=user.id

      if purchase_order.foreign_currency?
       purchase.currency_id = purchase_order.currency_id
       purchase.exchange_rate = purchase_order.exchange_rate
      end
      purchase.uploaded_file_file_name = purchase_order.uploaded_file_file_name
      purchase.uploaded_file_file_size = purchase_order.uploaded_file_file_size
      purchase.uploaded_file_content_type = purchase_order.uploaded_file_content_type
      purchase.uploaded_file_updated_at = purchase_order.uploaded_file_updated_at

      purchase_order.purchase_order_line_items.each do |line_item|
        purchase_line_item = PurchaseLineItem.new(
          :product_id => line_item.product_id,
          :quantity => line_item.quantity,
          :unit_rate => line_item.unit_rate,
          :discount_percent => line_item.discount_percent,
          :amount => line_item.amount,
          :description => line_item.description,
          :type=>"PurchaseLineItem"
        )
        line_item.tax_accounts.each do |account|
          purchase_line_item.purchase_taxes<<PurchaseTax.new(:account_id=>account.id)
        end
        purchase.purchase_line_items << purchase_line_item
      end

      purchase_order.other_charge_line_items.each do |line_item|
       other_charge_line_item = OtherChargeLineItem.new(
        :account_id => line_item.account_id,
        :amount => line_item.amount
        )
        purchase.other_charge_line_items << other_charge_line_item
      end
      purchase.build_tax
      purchase.total_amount=purchase.calculate_total_amount
      transaction do
        if purchase_order.has_atleast_one_inventoriable_item? && company.has_more_than_one_warehouses?
          purchase.status_id=2
          purchase.save(:validate=>false)
        else
          purchase.status_id=0
          purchase.save_and_manage_inventory #purchase.valid?
          purchase.update_and_post_ledgers
          purchase.register_user_action(remote_ip, "created")
        end
        po=PurchaseOrder.find purchase_order.id
        po.mark_converted_to_purchase
      end
      purchase
    end

    def this_month
      Purchase.where("record_date between ? and ?", Time.zone.now.to_date.beginning_of_month, Time.zone.now.to_date.end_of_month).order("record_date ASC")
    end
    def get_status_id(index)
          string = index
        if /unpaid|Unpaid/i.match(string)
          value = 0
        elsif /paid|Paid/i.match(string)
          value = 1
        elsif /draft|Draft/i.match(string)
          value=2
        end
        value
    end


    # Returns top 5 unpaid purchases by total purchase amounts. The outstanding
    # amounts are not calculated. Its just overdue purchases that company needs to pay.
    def top_5_unpaid_purchases(company, user)
      #company.invoices.by_date(year).by_date_range(year.start_date, Time.zone.now.to_date).by_status(0).by_branch_id(user.branch_id).order("due_date DESC").limit(5)
      company.purchases.includes(:account).where("due_date <= ?", Time.zone.now.to_date)
        .by_status(0).by_branch_id(user.branch_id).order("total_amount DESC, due_date ASC").limit(5)
    end

    #[FIXME] This method may become obsolete after implementation of top_5_unpaid_purchases
    def overdue_expences(company, user)
      # purchases = Purchase.where("company_id=? and due_date <= ? and status_id= ?", company.id,Time.zone.now.to_date,0).order("due_date DESC").by_branch_id(user.branch_id)
      company.purchases.where("due_date<=?", Time.zone.now.to_date).by_status(0).by_branch_id(user.branch_id).sort_by{|purchase| purchase.outstanding }
    end


    def today_expences(company, user)
      expences = Purchase.where(:company_id => company.id, :due_date => Time.zone.now.to_date).by_branch_id(user.branch_id)
    end

    def paid_expences(company, user)
      expences = Purchase.where(:company_id => company.id, :status_id => 1).by_branch_id(user.branch_id)
    end

    def unpaid_expences(company, user)
      expences = Purchase.where(:company_id => company.id, :status_id => 0).by_branch_id(user.branch_id)
    end

    def yearly_expenses(company, financial_year, user)
      amount_arr=[]
      month_begin = financial_year.start_date
      while month_begin <= Time.zone.now.beginning_of_month.to_date
        purchases = company.purchases.where(:record_date => month_begin..month_begin.end_of_month).by_branch_id(user.branch_id)
        expenses = company.expenses.where(:expense_date=>month_begin..month_begin.end_of_month).by_branch_id(user.branch_id)
        amount_arr<<purchases.sum(:total_amount)+expenses.sum(:total_amount)
        month_begin = month_begin + 1.month
      end
      amount_arr
    end

    # def monthly_expenses(company, user)
    #   amount_arr=[]
    #   (Time.zone.now.beginning_of_month.to_date..Time.zone.now.to_date).each do |day|
    #     purchases = company.purchases.where(:record_date => day).by_branch_id(user.branch_id)
    #     expenses = company.expenses.where(:expense_date=>day).by_branch_id(user.branch_id)
    #     amount_arr<<purchases.sum(:total_amount)+expenses.sum(:total_amount)
    #   end
    #   amount_arr
    # end

    def get_hold_purchases(company)
      where(:company_id => company, :deleted => false, :stock_receipt => false )
    end

    def converted_from_po(purchase_order, user, company)
      purchase = Purchase.new
      purchase.company_id = purchase_order.company_id
      purchase.account_id = purchase_order.account_id
      purchase.record_date = purchase_order.record_date
      purchase.due_date = purchase_order.record_date.advance(:weeks =>1)
      purchase.purchase_number = VoucherSetting.next_purchase_number(company)
      purchase.customer_notes = purchase_order.customer_notes
      purchase.terms_and_conditions = purchase_order.terms_and_conditions
      purchase.branch_id = purchase_order.branch_id
      purchase.currency_id = purchase_order.currency_id
      purchase.exchange_rate = purchase_order.exchange_rate
      purchase.purchase_order_id = purchase_order.id
      purchase.uploaded_file_file_name = purchase_order.uploaded_file_file_name
      purchase.uploaded_file_file_size = purchase_order.uploaded_file_file_size
      purchase.uploaded_file_content_type = purchase_order.uploaded_file_content_type
      purchase.uploaded_file_updated_at = purchase_order.uploaded_file_updated_at
      purchase.bill_reference=purchase_order.purchase_order_number

      purchase_order.purchase_order_line_items.each do |line_item|
       purchase_line_item = PurchaseLineItem.new(
        :product_id => line_item.product_id,
        :quantity => line_item.quantity,
        :unit_rate => line_item.unit_rate,
        :discount_percent => line_item.discount_percent,
        :amount => line_item.amount,
        :tax_account_id => line_item.tax_account_id,
        :description => line_item.description
        )
        purchase.purchase_line_items << purchase_line_item
      end

      purchase_order.tax_line_items.each do |line_item|
       tax_line_item = PurchaseLineItem.new(
        :account_id => line_item.account_id,
        :amount => line_item.amount,
        :tax => 1
        )
        purchase.tax_line_items << tax_line_item
      end

      purchase_order.other_charge_line_items.each do |line_item|
       other_charge_line_item = OtherChargeLineItem.new(
        :account_id => line_item.account_id,
        :amount => line_item.amount
        )
        purchase.other_charge_line_items << other_charge_line_item
      end
    end

    def new_purchase(params, company, user, remote_ip)
      purchase = Purchase.new
      purchase.company_id = company.id
      purchase.created_by=user.id
      if company.currency_code == 'INR'
        purchase.gst_purchase = true
      end  
      purchase.account_id = params[:account_id] unless params[:account_id].blank?
      purchase.project_id=params[:project_id] if params[:project_id].present?
      purchase.purchase_line_items.build
      purchase.purchase_number = VoucherSetting.next_purchase_number(company)
      purchase.old_file_size = 0
      purchase.status_id=2
      purchase.save(:validate=>false)
      purchase.register_user_action(remote_ip, 'created')
      purchase
    end

    def create_purchase(params, company, user, fyr)
      purchase = Purchase.new(params[:purchase])
       purchase.reverse_charge= params[:reverseCharge].present? ? params[:reverseCharge] : 0
      if company.currency_code == 'INR'
      purchase.gst_expense = true
      end
      purchase.account_id=nil if purchase.account.blank?
      purchase.created_by = user.id
      purchase.company_id = company
      purchase_total = 0

      purchase.build_tax

      purchase.purchase_line_items.each do |line_item|
        purchase_total += line_item.amount unless line_item.amount.blank?
      end
      purchase.total_amount= purchase.calculate_total_amount

      # purchase.project_id = Project.get_project_id(params[:project_id], company)
      purchase.branch_id = user.branch_id unless user.branch_id.blank?
      purchase.currency_id = purchase.account.get_currency_id unless purchase.account_id.blank?
      if purchase.currency_id.blank? || purchase.account.get_currency == purchase.company.currency_code
        purchase.exchange_rate = 0
      end
      purchase.old_file_size = 0
      purchase.fin_year = fyr
      purchase
    end

    def update_purchase(params, company, user, fyr)
      purchase = Purchase.find(params[:id])
      purchase.reverse_charge =  params[:reverseCharge].present? ? params[:reverseCharge] : params[:purchase][:reverse_charge]
      if company.currency_code == 'INR'
        purchase.gst_purchase = true
      end
      purchase.assign_attributes(params[:purchase])
      purchase.account_id= nil if purchase.account.blank?
      if params[:purchase][:current_step]=='last'
        purchase.current_step=purchase.last_step
        purchase.purchase_line_items.each do |line_item|
          line_item.current_step=purchase.current_step
        end
      end
      purchase.status_id=0 if !params[:draft].present?
      # purchase.project_id = Project.get_project_id(params[:project_id], company.id)
      purchase.branch_id = user.branch_id unless user.branch_id.blank?
      purchase.currency_id = (purchase.account.customer.blank? ? purchase.account.vendor.currency_id : purchase.account.customer.currency_id) unless purchase.account_id.blank?
      purchase.old_file_size = params[:old_file_size]
      purchase.build_tax
      purchase.total_amount=purchase.calculate_total_amount
      purchase.build_tax
      if purchase.gst_purchase?
        PurchaseFilerWorker.perform_async(company.id, purchase.id)
      end
      purchase
    end

    def get_record_with_custom_field(params, company, current_financial_year)
      start_date = params[:start_date].blank? ? current_financial_year.start_date : params[:start_date].to_date
      end_date = params[:end_date].blank? ? Time.zone.now.to_date : params[:end_date].to_date
      voucher_type = params[:voucher_type]
      val = params[:custom_field] unless params[:custom_field].blank?
      purchase = Purchase.where(:company_id=> company.id, :record_date => start_date..end_date).by_custom_field(val)
    end
  end
 def add_tax_line(line)
    unless line.marked_for_destruction?
      line.purchase_taxes.each do |tax|
        account = tax.account
        unless account.blank? || (line.has_attribute?(:quantity) && line.quantity.blank?) || (line.has_attribute?(:unit_rate) && line.unit_rate.blank?)
          tax_lines=account.add_purchase_tax_lines(self, line)
          tax_lines.each { |tax_line| self.tax_line_items<<tax_line}
        end
      end
    end
  end
  def register_user_action(remote_ip, action)
    Workstream.register_user_action(company_id, created_by, remote_ip,
    " #{purchase_number} for vendor #{vendor_name} for amount #{amount}", action, branch_id)
  end

  def register_delete_action(remote_ip, user, action)
    Workstream.register_user_action(company_id, user.id, remote_ip,
    " #{purchase_number} for vendor #{vendor_name} for amount #{amount}", action, branch_id)
  end

  def availble_balance
    purchase_line_items.each do |line_item|
      account = Account.find(line_item.account_id) unless line_item.account_id.blank?
      if !account.blank? && line_item.amount > account.closing_balance
        errors.add(:base, "No enough balance in #{account.name}")
      else
        true
      end
    end
  end

    def file_name
      uploaded_file_file_name
    end
    def file_size
      uploaded_file_file_size
    end

  def is_account_id
    if account_id.nil? || account_id.blank?
      errors.add(:account_id, "should be there")
    else
      account_id = Account.find_by_name(account_id)
    end
  end

   def record_date_and_due_date
      if !(record_date.nil? || due_date.nil?) && due_date < record_date
        errors.add(:due_date, " should be greater than or equal to record date " )
      end
   end

  def currency
    if currency_id.blank?
      self.company.currency_code
    else
      Currency.find(currency_id).currency_code
    end
  end

  def amount
    purchase_total = self.purchase_line_items.sum(:amount)
    tax_total = self.tax_inclusive? ? 0 : self.tax_line_items.sum(:amount)
    discount_total = discount_line_items.sum(:amount)
    other_charge = self.other_charge_line_items.sum(:amount)
    total = purchase_total + tax_total - discount_total + other_charge
    total
  end

  def sub_total
   self.purchase_line_items.sum(:amount)
  end

  def payment_maid
    if gst_purchase?
      self.gstr_advance_purchases_payments.sum(:amount) + self.purchases_payments.sum(:amount)
    
    else
      self.purchases_payments.sum(:amount)
    end
  end

  def gain_or_loss
    if foreign_currency? && status_id == 1
      payment = 0
     payment_vouchers = self.purchases_payments
     payment_vouchers.each do |purchase_payment|
      payment += purchase_payment.amount
     end
     payment
     gl = (amount*exchange_rate).round(2) - payment
     (gl/exchange_rate).round(2)
    end
  end

  def tds_amt
    purchases_payments.sum('tds_amount')
  end

  # def total_payment_maid
  #   self.purchases_payments.sum(:amount) + self.purchases_payments.sum(:tds_amount)
  # end

  def other_charge
    self.other_charge_line_items.sum(:amount)
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

  def vendor_name
    Account.find(account_id).name
  end



  def voucher_date
    record_date
  end

  def to_account_name
    Account.find(to_account_id).name
  end
  # TODO: Tax inclusive removed from throught purchase voucher

  def purchase_line_total_amount
    purchase_total =0
    purchase_line_items.each do |line_item|
      purchase_total += line_item.amount unless line_item.amount.blank?
    end
    purchase_total
  end

  def tax_total_amount
    tax_total=0  
    if reverse_charge?
        tax_total= 0 
    else
        tax_line_items.each do |line_item|
           tax_account = line_item.account
           next if (tax_account.accountable_type=='DutiesAndTaxesAccounts' && tax_account.accountable.calculation_method==4 && tax_account.accountable.split_tax == 0)      
          tax_total += line_item.amount unless line_item.amount.blank?
        end
    end
    tax_total
  end

  def cgst
     amt=0
    self.tax_line_items.each do |line_item|
       tax_account = line_item.account
       next if (tax_account.accountable_type=='DutiesAndTaxesAccounts' && tax_account.accountable.calculation_method==4 && tax_account.accountable.split_tax == 0 && !tax_account.name.include?("CGST"))
       if tax_account.name.include?("CGST")
            amt+= line_item.amount
       end
    end   
    amt
  end


  def sgst
     amt=0
    self.tax_line_items.each do |line_item|
       tax_account = line_item.account
       next if (tax_account.accountable_type=='DutiesAndTaxesAccounts' && tax_account.accountable.calculation_method==4 && tax_account.accountable.split_tax == 0)
       if tax_account.name.include?("SGST")
          amt+= line_item.amount
        end
    end   
    amt
  end

  def igst
     amt=0
    self.tax_line_items.each do |line_item|
       tax_account = line_item.account
       next if (tax_account.accountable_type=='DutiesAndTaxesAccounts' && tax_account.accountable.calculation_method==4 && tax_account.accountable.split_tax == 0)
       if tax_account.name.include?("IGST")
        amt+= line_item.amount
        end
    end   
    amt
  end

  def calculate_total_amount
    purchase_total=purchase_line_total_amount
    tax_total=tax_total_amount
    other_charge=0
    other_charge_line_items.each do |line_item|
      other_charge += line_item.amount unless line_item.amount.blank?
    end
    total = purchase_total + (tax_inclusive? ? 0 : tax_total) + other_charge
  end

  def foreign_currency?
    !currency_id.blank? && !exchange_rate.blank? && exchange_rate!=0
  end

  def create_fresh_warehouse_details
    if company.warehouses.count==1 && !draft?
      purchase_line_items.each do |line_item|
        if line_item.inventoriable?
          purchase_warehouse_detail=PurchaseWarehouseDetail.new(:warehouse_id=>company.default_warehouse.id,
            :quantity=>line_item.quantity, :company_id=> company.id, :product_id=> line_item.product_id)

          if line_item.product.batch_enable?
            old_purchase_warehouse_detail=line_item.deleted_purchase_warehouse_details.first
            unless old_purchase_warehouse_detail.blank?
              purchase_warehouse_detail.product_batch_id=old_purchase_warehouse_detail.product_batch_id
              purchase_warehouse_detail.status_id=old_purchase_warehouse_detail.status_id
            end
          end
          line_item.purchase_warehouse_details<<purchase_warehouse_detail
        end
      end
    end
  end

  def save_and_manage_inventory
    result=false
    transaction do
      mark_old_warehouse_details_deleted if company.plan.is_inventoriable? # will update old purchase warehouse details as deleted=true so that system will able to delete them after adding new details
      if valid?
        #This method is added to fix the issue of Purchase numbering auto increment
        #This method is called to assign unique number to purchase before posting changes realted to accounts
        #Author: Ashish Wadekar
        #Date: 31st August 2016
        assign_voucher_number
        save
        reload
        if company.plan.is_inventoriable?
          create_fresh_warehouse_details # will create purchase warehouse details with deleted=false
          update_inventory #this will add new inventory to stock table
          keep_back_old_and_ensure_positive_inventory #this will destroy marked as deleted sales warehouse details and inventory will retain to respective warehouse
        end
        result=true
      else
        raise ActiveRecord::Rollback
      end
    end
    result
  end

  def save_with_ledgers
    save_result = false
    transaction do
      if save
        purchase_line_items.each do |line_item|
          random_str=Ledger.generate_secure_random
          credit_ledger_entry = Ledger.new_credit_ledger(account_id, company_id, record_date, line_item.converted_amount, purchase_number, created_by, line_item.description, branch_id, random_str, line_item.product.expense_account_id )
          debit_ledger_entry = Ledger.new_debit_ledger(line_item.product.expense_account_id , company_id, record_date, line_item.converted_amount, purchase_number, created_by, line_item.description, branch_id, random_str, account_id )
          #build relationship between invoice and ledgers
          ledgers << credit_ledger_entry
          ledgers << debit_ledger_entry
          if !line_item.discount_percent.blank? && line_item.discount_percent>0.0
            discount_account=Account.find_by_name_and_accountable_type_and_company_id("Discount on Purchase Account", "IndirectIncomeAccount", company_id)
            random_str=Ledger.generate_secure_random
            credit_ledger_entry = Ledger.new_credit_ledger(discount_account.id, company_id, record_date,
              line_item.discount_amount, purchase_number, created_by, line_item.description, branch_id, random_str, account_id)

            debit_ledger_entry = Ledger.new_debit_ledger(account_id, company_id, record_date,
              line_item.discount_amount, purchase_number, created_by, line_item.description, branch_id, random_str, discount_account.id)
            ledgers << credit_ledger_entry
            ledgers << debit_ledger_entry
          end
        end

        tax_line_items.each do |line_item|
          random_str=Ledger.generate_secure_random
          credit_ledger_entry = Ledger.new_credit_ledger(account_id, company_id, record_date, line_item.converted_amount, purchase_number, created_by, line_item.description, branch_id, random_str, line_item.account_id )
          debit_ledger_entry = Ledger.new_debit_ledger(line_item.account_id, company_id, record_date, line_item.converted_amount, purchase_number, created_by, line_item.description, branch_id, random_str, account_id )
          #build relationship between expense and ledgers
          ledgers << credit_ledger_entry
          ledgers << debit_ledger_entry
        end

        other_charge_line_items.each do |line_item|
          credit_account= line_item.amount<0 ? line_item.account_id : account_id
          debit_account= line_item.amount<0 ? account_id : line_item.account_id
          random_str=Ledger.generate_secure_random
          credit_ledger_entry = Ledger.new_credit_ledger(credit_account, company_id, record_date, line_item.converted_amount.abs, purchase_number, created_by, line_item.description, branch_id, random_str, debit_account )
          debit_ledger_entry = Ledger.new_debit_ledger(debit_account, company_id, record_date, line_item.converted_amount.abs, purchase_number, created_by, line_item.description, branch_id, random_str, credit_account )
          #build relationship between expense and ledgers
          ledgers << credit_ledger_entry
          ledgers << debit_ledger_entry
        end
        PurchaseFilerWorker.perform_async(company_id, id)
        save_result = true
        Subscription.increase_storage(company_id, uploaded_file_file_size, old_file_size)
      end
    end
    save_result
  end

def update_and_post_ledgers
  update_result = false
  transaction do
    Ledger.delete(ledgers)
    purchase_line_items.reload
    purchase_line_items.each do |line_item|
      random_str=Ledger.generate_secure_random
      credit_ledger_entry = Ledger.new_credit_ledger(account_id, company_id, record_date, line_item.converted_amount, purchase_number, created_by, line_item.description, branch_id, random_str, line_item.product.expense_account_id )
      debit_ledger_entry = Ledger.new_debit_ledger(line_item.product.expense_account_id, company_id, record_date, line_item.converted_amount, purchase_number, created_by, line_item.description, branch_id, random_str, account_id )
      #build relationship between invoice and ledgers
      ledgers << credit_ledger_entry
      ledgers << debit_ledger_entry
      if !line_item.discount_percent.blank? && line_item.discount_percent>0.0
        discount_account=Account.find_by_name_and_accountable_type_and_company_id("Discount on Purchase Account", "IndirectIncomeAccount", company_id)
        random_str=Ledger.generate_secure_random
        credit_ledger_entry = Ledger.new_credit_ledger(discount_account.id, company_id, record_date,
          line_item.discount_amount, purchase_number, created_by, line_item.description, branch_id, random_str, account_id)

        debit_ledger_entry = Ledger.new_debit_ledger(account_id, company_id, record_date,
          line_item.discount_amount, purchase_number, created_by, line_item.description, branch_id, random_str, discount_account.id)
        ledgers << credit_ledger_entry
        ledgers << debit_ledger_entry
      end
    end
    PurchaseLineItem.delete(tax_line_items)
    build_tax
    tax_line_items.reload
    tax_line_items.each do |line_item|
      #write code to allow entry if gst invoice and parent id present
      tax_account = line_item.account
        next if (tax_account.accountable_type=='DutiesAndTaxesAccounts' && tax_account.accountable.calculation_method==4 && tax_account.accountable.split_tax == 0)
        if self.gst_purchase? && self.reverse_charge?
          #Retrieve account of this company with sales for e.g if CSGT@9 for purchase then retrieve CGST@9 for sales
          expense_account_name = line_item.account.name.chomp('on purchases')
          account_name = "#{expense_account_name}".concat("on sales")
          random_str=Ledger.generate_secure_random
          reverse_account = company.accounts.find_by_name(account_name)
          debit_ledger_entry = Ledger.new_debit_ledger(line_item.account_id, company_id, record_date, line_item.converted_amount, purchase_number, created_by, line_item.description, branch_id, random_str, reverse_account.id )
          credit_ledger_entry = Ledger.new_credit_ledger(reverse_account.id, company_id, record_date, line_item.converted_amount, purchase_number, created_by, line_item.description, branch_id, random_str, line_item.account_id )
          logger.debug  debit_ledger_entry.inspect
          ledgers << debit_ledger_entry
          ledgers << credit_ledger_entry
        else
        random_str=Ledger.generate_secure_random
        debit_ledger_entry = Ledger.new_debit_ledger(line_item.account_id, company_id, record_date, line_item.converted_amount, purchase_number, created_by, line_item.description, branch_id, random_str, account_id )
        credit_ledger_entry = Ledger.new_credit_ledger(account_id, company_id, record_date, line_item.converted_amount, purchase_number, created_by, line_item.description, branch_id, random_str, line_item.account_id )
        #build relationship between expense and ledgers
        ledgers << debit_ledger_entry
        ledgers << credit_ledger_entry
          end
    end

    other_charge_line_items.reload
    other_charge_line_items.each do |line_item|
      credit_account= line_item.amount<0 ? line_item.account_id : account_id
      debit_account= line_item.amount<0 ? account_id : line_item.account_id

      random_str=Ledger.generate_secure_random
      credit_ledger_entry = Ledger.new_credit_ledger(credit_account, company_id, record_date, line_item.converted_amount.abs, purchase_number, created_by, line_item.description, branch_id, random_str, debit_account )
      debit_ledger_entry = Ledger.new_debit_ledger(debit_account, company_id, record_date, line_item.converted_amount.abs, purchase_number, created_by, line_item.description, branch_id, random_str, credit_account )
      #build relationship between expense and ledgers
      ledgers << credit_ledger_entry
      ledgers << debit_ledger_entry
    end

    update_result = true
    Subscription.increase_storage(company_id, uploaded_file_file_size, old_file_size)
  end
  update_attribute("total_amount", calculate_total_amount)
  update_result
end
  def customer_name
     account.name
  end

  def cash_in_hand
     account.accountable_type.include?("CashAccount")
  end

  #soft delete method
  def delete(deleted_by_user)
    result = false
    transaction do
    if update_attributes(:deleted_by => deleted_by_user, :deleted => true, :deleted_datetime => Time.zone.now)
      ledgers.update_all(:deleted_by => deleted_by_user, :deleted => true, :deleted_datetime => Time.zone.now)
      payment_vouchers.each do |pv|
      pv.fin_year = fin_year
      pv.delete(deleted_by_user)
      end
      result = true
    end
    end
    result
  end
#restore method
  def restore(restored_by_user)
    result = false
    transaction do
    if update_attributes(:restored_by => restored_by_user, :deleted => false, :restored_datetime => Time.zone.now)
      ledgers.update_all(:restored_by => restored_by_user, :deleted => false, :restored_datetime => Time.zone.now)
      payment_vouchers.each do |pv|
        pv.fin_year = fin_year
        pv.restore(restored_by_user)
      end
      result = true
    end
    end
    result
  end

  def delete_uploaded_file
    @file_delete ||= "0"
  end

  def delete_uploaded_file=(value)
    @file_delete = value
   end

  def self.get_vendor_purchases(company, account)
    where(:company_id => company, :account_id => account, :deleted => false)
  end
 def project_name
    Project.find(project_id).name
  end
def created_by_user
  User.find(created_by).full_name
end
def vendor_name
  account=Account.find_by_id(account_id)
  account.name unless account.blank?
end

  def get_status
    # if status_id == 0
    #   "Unpaid"
    # elsif status_id == 1
    #   "Paid"
    # elsif status_id==2
    #   "Draft"
    # elsif status_id==3
    #   "Settled"
    # end
    STATUS[status_id.to_s]
  end

def update_purchase_status
  if outstanding==0
    update_attribute("status_id", 1)
  else
    update_attribute("status_id", 0)
  end
end

#This method was added to fix the issue of Purchase voucher number auto increment with changes
#This method checks for uniqueness of purchase number
#Author: Ashish Wadekar
#Date: 31st August 2016
def unique_purchase_number
  Purchase.where(:purchase_number => self.purchase_number, :company_id => self.company_id, :status_id => [0,1,3]).count == 0
end

#This method was added to fix the issue of Purchase voucher number auto increment with changes
#This method is invoked to check uniqueness of Purchase when custom numbering sequence is used 
#Author: Ashish Wadekar
#Date: 31st August 2016
def check_voucher_number
  if self.voucher_setting.custom_sequence?
    if self.status_id == 2
      if !self.unique_purchase_number
        errors.add(:purchase_number, " #{self.purchase_number} is already been taken.")
      end
      if Ledger.where(:company_id => company_id, :voucher_id => self.id, :deleted => 0).count == 0
        if !self.unique_purchase_number
          errors.add(:purchase_number, " #{self.purchase_number} is already been taken.")
        end
      end
    end

    if self.status_id != 2
      if Purchase.find(self.id).purchase_number != self.purchase_number
        if !self.unique_purchase_number
          errors.add(:purchase_number, " #{self.purchase_number} is already been taken.")
        end
      end
      if Ledger.where(:company_id => company_id, :voucher_id => self.id, :deleted => 0).count == 0
        if !self.unique_purchase_number
          errors.add(:purchase_number, " #{self.purchase_number} is already been taken.")
        end
      end
    end
  end
end

#This method was added to fix the issue of Purchase voucher number auto increment with changes
#This method is invoked to check uniqueness of Purchase when sequential numbering is used 
# This method is called from save_and_manage_inventory after all the validations to assign correct unique purchase number
#Author: Ashish Wadekar
#Date: 31st August 2016
def assign_voucher_number
  if VoucherSetting.find_by_company_id_and_voucher_type(company_id, 5).voucher_number_strategy == 1    
    if Ledger.where(:company_id => company_id, :voucher_number => self.purchase_number, :deleted => 0).count == 0
      self.update_attribute(:purchase_number, VoucherSetting.next_purchase_number(company))
      VoucherSetting.next_purchase_write(company)
    elsif Purchase.where(:company_id => company_id, :purchase_number => self.purchase_number, :status_id => 2).count > 0
      if Purchase.where(:company_id => company_id, :purchase_number => self.purchase_number, :status_id => [0,1,3]).count > 0
        self.update_attribute(:purchase_number, VoucherSetting.next_purchase_number(company))
        VoucherSetting.next_purchase_write(company)
      else
        VoucherSetting.next_purchase_write(company)
      end
    end
  end
end

def purchase_order_number
  purchase_order.purchase_order_number
end

 private

  def storage_limit
    errors[:base] << "Storage limit reached, your plan does not allow storing any more files." if Subscription.storage_limit?(company_id, uploaded_file_file_size, old_file_size)
  end

  def destroy_uploaded_file?
    self.uploaded_file.clear if @file_delete == "1" and !uploaded_file.dirty?
  end


end

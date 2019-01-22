class GstrAdvancePayment < ActiveRecord::Base
  include GstrAdvancePaymentsHelper #[FIXME] what is the need to include helper in a model
  
  scope :by_deleted, lambda {|del| where(:deleted => del)}
  scope :by_date, lambda{|fin_year| where(:received_date => fin_year.start_date..fin_year.end_date) unless fin_year.blank?}
  scope :by_customer, lambda{|customer| where(:from_account_id=> customer) unless customer.blank? }
  scope :by_voucher, lambda{|voucher_no| where("voucher_number like ?", "%#{voucher_no}%")}
  scope :by_date_range, lambda{|start_date, end_date| where(:received_date=> start_date..end_date) unless start_date.blank? || end_date.blank? }
  scope :by_amount_range, lambda{|min_amt, max_amt| where(:amount=> min_amt..max_amt)}
  scope :by_project, lambda{|project| where(:project_id=>project) unless project.blank? }
  scope :by_company_id, lambda {|id| where(:company_id => id) unless id.blank? }
  scope :not_in, lambda { |purchases| where("id not in(?)", purchases.map { |e| e.id }) unless purchases.blank?}
  scope :by_status, lambda{|status| where(:status => status) unless status.blank?}
  scope :by_vendor, lambda{|vendor| where(:to_account_id=>vendor) unless vendor.blank?}
  scope :by_currency, lambda {|currency| where(:currency_id => currency) unless currency.blank?}

  
  belongs_to :company
  #belongs_to :account
  belongs_to :to_account, :class_name=>"Account", :foreign_key=>:to_account_id
  belongs_to :from_account, :class_name=>"Account", :foreign_key=>:from_account_id
  belongs_to :user, :foreign_key=> :to_account_id
  belongs_to :currency
  belongs_to :customer
  belongs_to :vendor
  # has_one :payment_detail, :as => :voucher, :dependent => :destroy
  has_one :billing_address, :class_name=>'Address', :as=>:addressable, :conditions=>{:address_type=>1}
  has_one :shipping_address, :class_name=>'Address', :as=>:addressable, :conditions=>{:address_type=>0}
  # has_many :time_line_items, :dependent => :destroy

  has_many :gstr_advance_purchases_payments
  has_many :purchases, :through=>:gstr_advance_purchases_payments, :dependent=>:destroy
  
  has_many :ledgers, :as => :voucher, :dependent => :destroy
  has_many :gstr_advance_payment_history

  has_many :gstr_advance_payment_line_items, :conditions => {:line_item_type => "GstrAdvancePaymentLineItem"}, :dependent => :destroy
  has_many :shipping_line_items, :class_name => "GstrAdvancePaymentLineItem", :conditions=> {:line_item_type=> "ShippingLineItem"}, :dependent => :destroy
  accepts_nested_attributes_for :shipping_line_items, :reject_if => lambda {|a| a[:account_id].blank? && a[:amount].blank? }, :allow_destroy => true
  #accepts_nested_attributes_for :time_line_items, :reject_if => lambda {|a| a[:account_id].blank? && a[:amount].blank? }, :allow_destroy => true
  accepts_nested_attributes_for :billing_address, :shipping_address
  accepts_nested_attributes_for :gstr_advance_purchases_payments, :reject_if=>lambda { |o| o[:amount].blank? || o[:amount].to_f==0 }
  
  attr_accessible :deleted_by, :deleted, :deleted_datetime, :voucher_number, :voucher_date, :amount, :from_account_id, 
  				  :to_account_id ,:restored_by, :restored_datetime,:currency_id, :exchange_rate, :project_id, :product_batches_attributes, :gstr_advance_payment_number,
            :gstr_advance_payment_line_items_attributes, :shipping_line_items_attributes, :billing_address_attributes, :status,:received_date,
  :shipping_address_attributes, :tax_line_items_attributes, :account_id, :gstr_advance_purchases_payments_attributes, :place_of_supply

  has_many :tax_line_items, :class_name => "GstrAdvancePaymentLineItem", :conditions=> {:line_item_type=> nil}, :dependent => :destroy

  accepts_nested_attributes_for :tax_line_items, :reject_if => true , :allow_destroy => true

  validates_associated :tax_line_items, :message => "fields with * are mandatory. You can remove the Tax line item if you don't want to enter the Tax amount."

  accepts_nested_attributes_for :gstr_advance_payment_line_items, :reject_if => true , :allow_destroy => true
  validates_presence_of  :voucher_number, :received_date, :amount, :from_account_id, :to_account_id
  validates_presence_of :voucher_date#, inclusion: { in: (Date.new(2017,7,1)..Time.now) }
  validates_presence_of :place_of_supply
  validates_uniqueness_of :voucher_number, :scope => :company_id
  validates :amount, :numericality => {:greater_than_or_equal_to => 0.01,
                                        :message => " should not be zero or negative ." }
  # validates_presence_of :time_line_items, :if =>  lambda{|e| e.gstr_advance_payment_status_id != 1 && e.time_gstr_advance_payment == true}
  # validates_associated :time_line_items, :message => "fields with * are mandatory", :if =>  lambda{|e| e.gstr_advance_payment_status_id != 1 && e.time_gstr_advance_payment == 1 }
  validates_presence_of :gstr_advance_payment_line_items
  # validate :check_gstr_advance_payment_line_items
  validates_associated :gstr_advance_payment_line_items, :message => "fields with * are mandatory"
  # validate :validate_from_account_and_to_account
  # validate :check_amount_on_create, :on => :create
  # validate :check_amount_on_update, :on => :update
  # validate :validate_from_account_type, :if => :from_account_id
  # validate :validate_to_account_type, :if => :to_account_id
  validates_presence_of :exchange_rate, :if => lambda{|e| !e.from_account.blank? && !e.from_account.get_currency_id.blank?}
  # validate :validate_exchange_rate, :if => :exchange_rate

  attr_accessor :fin_year

  STATUS = {'0' => "Unallocated", '1' => "Allocated", '2' => "Partially Allocated"}
  
  def get_party
    to_account.customer.blank? ? to_account.vendor : to_account.customer
  end

  def place_of_supply_state
    State.find_by_state_code(self.place_of_supply).name
  end
  

  def gst_line_items
    #create a hash with key as tax rate 
    #get the line item rate, check if the rate is present in hash
    #if not add a new gst_line_item_object to it
    #if present get the gst_line_item and add required fields to them
    items = Hash.new
    self.gstr_advance_payment_line_items.each do |line_item|
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

  def get_status
    if status == 1
      "Allocated"
    elsif status == 2
      "Partially Allocated"
    elsif status == 0
      "Unallocated"  
    end
  end

  def get_discount
    discount = 0
    gstr_advance_payment_line_items.each do |line|
      discount += (line.unit_rate*line.quantity)*(line.discount_percentage/100.0) unless line.discount_percentage.blank? || line.amount.blank?
    end
    discount
  end 

  def to_account_name
    to_account.name
  end 

  def customer
    customer = nil
    if to_account.customer.blank?
      customer = to_account.vendor
    else
      customer = to_account.customer
    end
    customer
  end


  def tax_total_amount
    tax_total=0  
        tax_line_items.each do |line_item|
           tax_account = line_item.account
           next if (tax_account.accountable_type=='DutiesAndTaxesAccounts' && tax_account.accountable.calculation_method==4 && tax_account.accountable.split_tax == 0)      
          tax_total += line_item.amount unless line_item.amount.blank?
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



  def total_amount
    amount
  end



  def update_status(id, status)
      result = false
      gstr_advance_payment = GstrAdvancePayment.find(id)
      if !gstr_advance_payment.blank? && gstr_advance_payment.update_attribute(:status, status)
        result = true
      end
    end

  def group_tax_amt(account_id)
    amt = 0
    tax_items = self.tax_line_items.where(:account_id => account_id)
    tax_items.each do |item|
      amt += item.amount
    end
    amt
  end

  def unallocated_amount
    amt=0
    amt=amount-(gstr_advance_purchases_payments.sum(:amount)) unless amount.blank?
    amt
  end

  def currency_code
    if currency.blank?
      company.currency_code
    else
      currency
    end
  end

  def vendor_name
     to_account.name
  end

  def date
    voucher_date
  end


  def customer_name
    to_account.name
  end

  def has_tax_lines?
    !tax_line_items.blank?
  end

  def build_gstr_advance_payment_tax
    gstr_advance_payment_line_items.each do |line|
      logger.debug "==================================line============================"
        logger.debug line.inspect
      add_tax_line(line)
    end
  end

  #  def add_tax_line(line)
  #   unless line.marked_for_destruction?
  #     line.gstr_advance_payment_taxes.each do |tax|
  #       account = tax.account_id
  #       logger.debug "==================================account====================="
  #       logger.debug tax.inspect
  #       unless account.blank? || (line.has_attribute?(:quantity) && line.quantity.blank?) || (line.has_attribute?(:unit_rate) && line.unit_rate.blank?)
  #         tax_lines=account.add_gstr_advance_payment_tax_lines(self, line)
  #         tax_lines.each { |tax_line| self.tax_line_items<<tax_line}
  #       end
  #     end
  #   end
  # end

  def sub_total
    self.gstr_advance_payment_line_items.sum(:amount)
  end

  def get_total_amount
    gstr_advance_payment_total =0
    gstr_advance_payment_line_items.each do |line_item|
      if line_item.marked_for_destruction? 
        next
      end
      gstr_advance_payment_total += line_item.amount
    end
    tax_total=0
    tax_line_items.each do |line_item|
      tax_account = line_item.account
      next if (tax_account.accountable_type=='DutiesAndTaxesAccounts' && tax_account.accountable.calculation_method==4 && tax_account.accountable.split_tax == 0)
      tax_total +=line_item.amount
    end

    ship_charge=0
    shipping_line_items.each do |line_item|
      ship_charge += line_item.amount unless line_item.amount.blank?
    end

    total = gstr_advance_payment_total + tax_total + ship_charge
  end

  def voucher_setting
    VoucherSetting.by_voucher_type(26, company_id).first
  end
def save_with_ledgers
    save_result = false
    transaction do
      if save
        gstr_advance_payment_line_items.each do |line_item|

          credit_account_id = Product.find_by_id(line_item.product_id).income_account_id
          random_str=Ledger.generate_secure_random

          debit_ledger_entry = Ledger.new_debit_ledger(to_account_id, company_id, voucher_date,
            line_item.amount_with_exchange_rate, voucher_number, created_by, line_item.description,nil, random_str, from_account_id)

          credit_ledger_entry = Ledger.new_credit_ledger(from_account_id, company_id, voucher_date,
            line_item.amount_with_exchange_rate, voucher_number, created_by, line_item.description,nil, random_str, to_account_id)

          #build and save relationship between gstr_advance_payment and ledgers
          ledgers << debit_ledger_entry
          ledgers << credit_ledger_entry
          # if !line_item.discount_percentage.blank? && line_item.discount_percentage>0.0
          #   discount_account=Account.find_by_name_and_accountable_type_and_company_id("Discount on Sales Account", "IndirectExpenseAccount", company_id)
          #   random_str=Ledger.generate_secure_random
          #   debit_ledger_entry = Ledger.new_debit_ledger(discount_account.id, company_id, voucher_date,
          #     line_item.discount_amount, voucher_number, created_by, line_item.description, nil, random_str, discount_account.id)

            # credit_account_id = Product.find_by_id(line_item.product_id).income_account_id
          #   credit_ledger_entry = Ledger.new_credit_ledger(to_account_id, company_id, voucher_date,
          #     line_item.discount_amount, voucher_number, created_by, line_item.description, nil, random_str, discount_account.id)
          #   ledgers << debit_ledger_entry
          #   ledgers << credit_ledger_entry
          # end
        end

        tax_line_items.each do |line_item|
          tax_account = line_item.account
       next if (tax_account.accountable_type=='DutiesAndTaxesAccounts' && tax_account.accountable.calculation_method==4 && tax_account.accountable.split_tax == 0)
          random_str=Ledger.generate_secure_random
          debit_ledger_entry = Ledger.new_debit_ledger(line_item.account_id, company_id, voucher_date,line_item.amount_with_exchange_rate, voucher_number,created_by , nil, nil, random_str, from_account_id)

          credit_ledger_entry = Ledger.new_credit_ledger(from_account_id, company_id, voucher_date,line_item.amount_with_exchange_rate, voucher_number, created_by, nil, nil, random_str,line_item.account_id)

          ledgers << debit_ledger_entry
          ledgers << credit_ledger_entry
        end

        # time_line_items.each do |line_item|
        #   random_str=Ledger.generate_secure_random
        #   time_account_id = Task.find(line_item.task_id).sales_account_id
        #   debit_ledger_entry = Ledger.new_debit_ledger(from_account_id, company_id, voucher_date,
        #     line_item.amount_with_exchange_rate, voucher_number, to_account_id, nil, nil, random_str, time_account_id)

        #   credit_ledger_entry = Ledger.new_credit_ledger(time_account_id, company_id, voucher_date,
        #     line_item.amount_with_exchange_rate, voucher_number, to_account_id, nil, nil, random_str, account_id)

        #   ledgers << debit_ledger_entry
        #   ledgers << credit_ledger_entry
        # end

        shipping_line_items.each do |line_item|
          debit_account= line_item.amount<0 ? line_item.account_id : account_id
          credit_account= line_item.amount<0 ? account_id : line_item.account_id
          random_str=Ledger.generate_secure_random
          debit_ledger_entry = Ledger.new_debit_ledger(debit_account, company_id, voucher_date,
            line_item.amount_with_exchange_rate, voucher_number, from_account_id, nil, nil, random_str, credit_account)

          credit_ledger_entry = Ledger.new_credit_ledger(credit_account, company_id, voucher_date,
            line_item.amount_with_exchange_rate, voucher_number, to_account_id, nil, nil, random_str, debit_account)

          ledgers << debit_ledger_entry
          ledgers << credit_ledger_entry
        end
        save_result = true
      end
    end
    save_result
  end

  def update_and_post_ledgers
  update_result = false
    transaction do
      Ledger.delete(ledgers)
      GstrAdvancePaymentLineItem.delete(tax_line_items)
      gstr_advance_payment_line_items.reload
      
      #if update
        gstr_advance_payment_line_items.each do |line_item|

          credit_account_id = Product.find_by_id(line_item.product_id).income_account_id
          random_str=Ledger.generate_secure_random

          debit_ledger_entry = Ledger.new_debit_ledger(to_account_id, company_id, voucher_date,
            line_item.amount_with_exchange_rate, voucher_number, created_by, line_item.description,nil, random_str, from_account_id)

          credit_ledger_entry = Ledger.new_credit_ledger(from_account_id, company_id, voucher_date,
            line_item.amount_with_exchange_rate, voucher_number, created_by, line_item.description,nil, random_str, to_account_id)

          #build and update relationship between gstr_advance_payment and ledgers
          ledgers << debit_ledger_entry
          ledgers << credit_ledger_entry
          # if line_item.discount_percentage.present? && line_item.discount_percentage>0.0
          #   discount_account=Account.find_by_name_and_accountable_type_and_company_id("Discount on Sales Account", "IndirectExpenseAccount", company_id)
          #   random_str=Ledger.generate_secure_random
          #   debit_ledger_entry = Ledger.new_debit_ledger(discount_account.id, company_id, voucher_date,
          #     line_item.discount_amount, voucher_number, created_by, line_item.description, nil, random_str, discount_account.id)

          #   # credit_account_id = Product.find_by_id(line_item.product_id).income_account_id
          #   credit_ledger_entry = Ledger.new_credit_ledger(to_account_id, company_id, voucher_date,
          #     line_item.discount_amount, voucher_number, created_by, line_item.description, nil, random_str, discount_account.id)
          #   ledgers << debit_ledger_entry
          #   ledgers << credit_ledger_entry
          # end
        end

        build_gstr_advance_payment_tax
        tax_line_items.reload
        tax_line_items.each do |line_item|
          tax_account = line_item.account
       next if (tax_account.accountable_type=='DutiesAndTaxesAccounts' && tax_account.accountable.calculation_method==4 && tax_account.accountable.split_tax == 0)
          random_str=Ledger.generate_secure_random
          debit_ledger_entry = Ledger.new_debit_ledger(line_item.account_id, company_id, voucher_date,line_item.amount_with_exchange_rate, voucher_number,created_by , nil, nil, random_str, from_account_id)

          credit_ledger_entry = Ledger.new_credit_ledger(from_account_id, company_id, voucher_date,line_item.amount_with_exchange_rate, voucher_number, created_by, nil, nil, random_str,line_item.account_id)

          ledgers << debit_ledger_entry
          ledgers << credit_ledger_entry
        end

        # time_line_items.each do |line_item|
        #   random_str=Ledger.generate_secure_random
        #   time_account_id = Task.find(line_item.task_id).sales_account_id
        #   debit_ledger_entry = Ledger.new_debit_ledger(from_account_id, company_id, voucher_date,
        #     line_item.amount_with_exchange_rate, voucher_number, to_account_id, nil, nil, random_str, time_account_id)

        #   credit_ledger_entry = Ledger.new_credit_ledger(time_account_id, company_id, voucher_date,
        #     line_item.amount_with_exchange_rate, voucher_number, to_account_id, nil, nil, random_str, account_id)

        #   ledgers << debit_ledger_entry
        #   ledgers << credit_ledger_entry
        # end
        shipping_line_items.reload
        shipping_line_items.each do |line_item|
          debit_account= line_item.amount<0 ? line_item.account_id : account_id
          credit_account= line_item.amount<0 ? account_id : line_item.account_id
          random_str=Ledger.generate_secure_random
           debit_ledger_entry = Ledger.new_debit_ledger(debit_account, company_id, voucher_date,
            line_item.amount_with_exchange_rate, voucher_number, from_account_id, nil, nil, random_str, credit_account)

          credit_ledger_entry = Ledger.new_credit_ledger(credit_account, company_id, voucher_date,
            line_item.amount_with_exchange_rate, voucher_number, to_account_id, nil, nil, random_str, debit_account)

          ledgers << debit_ledger_entry
          ledgers << credit_ledger_entry
        end
        update_result = true
      end

    update_attribute("amount", calculate_total_amount)
    update_result
end

  def foreign_currency?
      !currency_id.blank? && !exchange_rate.blank? && exchange_rate != 0 && company.currency_code != currency
    end

    def created_by_user
    User.find(created_by).full_name
  end

  def total_quantity
   qty_total = self.gstr_advance_payment_line_items.sum(:quantity)
   qty_total
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

  def add_tax_line(line)
    unless line.marked_for_destruction?
      line.gstr_advance_payment_taxes.each do |tax|
        account = tax.account
        logger.debug "==================================account====================="
        logger.debug tax.inspect
        unless account.blank? || (line.has_attribute?(:quantity) && line.quantity.blank?) || (line.has_attribute?(:unit_rate) && line.unit_rate.blank?)
          tax_lines=account.add_gstr_advance_payment_tax_lines(self, line)
          tax_lines.each { |tax_line| self.tax_line_items<<tax_line}
        end
      end
    end
  end


  def update_exist_receipts_with_ledger
    receipt_vouchers.each do |receipt_voucher|
      if receipt_voucher.advanced?
        receipt_voucher.update_attribute("allocated", false) if receipt_voucher.allocated?
        receipt_voucher.update_and_post_ledgers
      else
        receipts = receipt_voucher.invoices_receipts.where(:deleted=>false)
        receipt = ReceiptVoucher.find receipt_voucher.id
        receipt.amount=0
        receipt.tds_amount=0
        receipts.each do |ir|
          receipt.amount += ir.amount unless ir.amount.blank?
          receipt.tds_amount += ir.tds_amount unless ir.tds_amount.blank?
        end
        receipt.payment_detail.amount = receipt_voucher.amount
        receipt.save
        receipt.update_and_post_ledgers
      end
    end
  end

  def update_and_manage_status(remote_ip,id)
  transaction do
    save!
    update_and_post_ledgers
    purchases.each do |purchase|
      purchase.update_purchase_status

    end
    gstr_advance_payment = GstrAdvancePayment.find(id)
    gstr_advance_payment.update_gstr_advance_payment_status
   
    register_user_action(remote_ip, 'updated')
  end
end

def calculate_total_amount
    adv_payment_total =0
    gstr_advance_payment_line_items.each do |line_item|
      adv_payment_total += line_item.amount
    end

    tax_total=0
    tax_line_items.each do |line_item|
      tax_account = line_item.account
      next if (tax_account.accountable_type=='DutiesAndTaxesAccounts' && tax_account.accountable.calculation_method==4 && tax_account.accountable.split_tax == 0)      
      tax_total += line_item.amount
    end

    ship_charge=0
    shipping_line_items.each do |line_item|
      ship_charge += line_item.amount
    end
    total = adv_payment_total + ship_charge + tax_total 
end

def register_user_action(remote_ip, action)
    Workstream.register_user_action(company_id, created_by, remote_ip,
      " #{voucher_number} for customer #{customer_name} for amount #{amount}", action, nil)
  end

  def register_delete_action(remote_ip,user, action)
    Workstream.register_user_action(company_id, user.id, remote_ip,
      " #{voucher_number} for customer #{customer_name} for amount #{amount}", action, nil)
  end

def currency
    if currency_id.blank?
      self.company.currency_code
    else
      Currency.find(currency_id).currency_code
    end
  end

  def get_available_stock
   prd_arr = []
    self.gstr_advance_payment_line_items.each do |line_item|
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

  def update_gstr_advance_payment_status
    if outstanding>0
      self.update_attribute(:status, 0)
    else
      self.update_attribute(:status, 1)
    end
  end

  def outstanding
    amount=return_substracted_outstanding
    amount<0? 0 : amount
  end

  def return_substracted_outstanding
     amount - (paid_amount)
  end

  def paid_amount
    self.gstr_advance_purchases_payments.sum(:amount)
  end

  def intra_state_supply
    company.gstn_state_code == place_of_supply.rjust(2, '0')
  end

  def delete_gstr_two_entry
    @gstr_two_adv_pay = GstrTwoItem.find_by_voucher_id_and_voucher_type(id,"GstrAdvancePayment")
    if @gstr_two_adv_pay.present?
      @gstr_two_adv_pay.destroy
    end
  end

  class << self

  def create_allocation(params, company)
    gstr_advance_payment = company.gstr_advance_payments.find(params[:id])
    logger.debug "=================================================="
    gstr_advance_payment.assign_attributes(params[:gstr_advance_payment])
    logger.debug "================================================"
    gstr_advance_payment
  end

  def new_gstr_advance_payment(params, company, user)
      gstr_advance_payment = GstrAdvancePayment.new
      voucher_setting = VoucherSetting.find_by_company_id_and_voucher_type(company.id,26)
      gstr_advance_payment.company_id = company.id
      gstr_advance_payment.project_id=params[:project_id] if params[:project_id].present?
      unless params[:to_account_id].blank?
        #gstr_advance_payment.account_id = params[:account_id]
        gstr_advance_payment.billing_address=Address.new(gstr_advance_payment.get_party.billing_address.attributes) unless gstr_advance_payment.get_party.blank? || gstr_advance_payment.get_party.billing_address.blank?
        gstr_advance_payment.shipping_address=Address.new(gstr_advance_payment.get_party.shipping_address.attributes) unless gstr_advance_payment.get_party.blank? || gstr_advance_payment.get_party.shipping_address.blank?
      end
      gstr_advance_payment.gstr_advance_payment_line_items.build
      gstr_advance_payment.voucher_number = voucher_setting.gstr_advance_payment_voucher_number(company)
      logger.debug "8888888888888"
      logger.debug gstr_advance_payment.inspect
      gstr_advance_payment
  end  

  def amount
    gstr_advance_payment_total = self.gstr_advance_payment_line_items.sum(:amount)
    tax_total =  self.tax_line_items.sum(:amount)
    puts "-----tax_total--------- #{tax_total}"
    ship_charge = self.shipping_line_items.sum(:amount)
    gstr_advance_payment_total + tax_total + ship_charge
  end

  def delete
    transaction do
      if paid_amount > 0
       # save_received_amount_as_advance
        # update_exist_receipts_with_ledger
      end
      destroy
      # sales_orders.first.update_billing_status unless sales_orders.blank?
    end
  end

  
  # def sub_total
  #   self.gstr_advance_payment_line_items.sum(:amount)
  # end

  
   def create_gstr_advance_payment(params, company, user, fyr)
    advance_payment = GstrAdvancePayment.new(params[:gstr_advance_payment])
    logger.debug "==================================advance_payment==============="
        logger.debug advance_payment.inspect
      #advance_payment.account_id=nil if advance_payment.account.blank?
      advance_payment.company_id = company.id
      voucher_setting = VoucherSetting.find_by_company_id_and_voucher_type(advance_payment.company_id,26)
      #advance_payment.from_account_id=nil if advance_payment.account.blank?
      # advance_payment.to_account_id = user.id
      advance_payment.created_by = user.id
      advance_payment.branch_id = user.branch_id unless user.branch_id.blank?
      advance_payment.currency_id = advance_payment.to_account.get_currency_id unless advance_payment.to_account.blank?
      advance_payment.voucher_date = params[:voucher_date].blank? ? Time.zone.now.to_date : params[:voucher_date]
      advance_payment.received_date = Time.zone.now.to_date
      advance_payment.status = 0


      
      # advance_payment.voucher_number = voucher_setting.gstr_advance_payment_voucher_number(company)
      if advance_payment.currency_id.blank? || advance_payment.to_account.get_currency == advance_payment.company.currency_code
        advance_payment.exchange_rate = 0
      end
      advance_payment.fin_year = fyr
      advance_payment.build_gstr_advance_payment_tax
      advance_payment.amount= advance_payment.get_total_amount
      # create_advance_payment_history(advance_payment.id,company, user.id, "created")
      logger.debug "-----------------------"
      logger.debug advance_payment.attributes.inspect
      advance_payment
  end

  def create_gstr_advance_payment_history(gstr_advance_payment,company,user,action)
      gstr_advance_payment_history = GstrAdvancePaymentHistory.new
      gstr_advance_payment_history.gstr_advance_payment_id = gstr_advance_payment
      gstr_advance_payment_history.company_id = company
      gstr_advance_payment_history.description = action
      gstr_advance_payment_history.created_by = user
      gstr_advance_payment_history.payment_date = Time.zone.now
      gstr_advance_payment_history.save
    end

  def to_account_id_user
    User.find(to_account_id).full_name
  end

  def update_gstr_advance_payment(params, company, user, fyr)
      gstr_advance_payment = GstrAdvancePayment.find(params[:id])
      GstrAdvancePaymentLineItem.delete(gstr_advance_payment.tax_line_items)
      gstr_advance_payment.reload
      gstr_advance_payment.assign_attributes(params[:gstr_advance_payment])
      gstr_advance_payment.to_account_id=nil if gstr_advance_payment.customer.blank?
      
      #gstr_advance_payment.branch_id = user.branch_id unless user.branch_id.blank?
      #gstr_advance_payment.currency_id = gstr_advance_payment.account.get_currency_id unless gstr_advance_payment.account.blank?
      # if gstr_advance_payment.currency_id.blank? || gstr_advance_payment.account.get_currency == gstr_advance_payment.company.currency_code
      #   gstr_advance_payment.exchange_rate = 0
      # end
      # gstr_advance_payment.amount=0
      # gstr_advance_payment.gstr_advance_purchases_payments.each do |purchase_payment|
      #   gstr_advance_payment.amount +=purchase_payment.amount
      # end

      gstr_advance_payment.build_gstr_advance_payment_tax
      gstr_advance_payment.amount=gstr_advance_payment.get_total_amount
      create_gstr_advance_payment_history(gstr_advance_payment.id,company, user.id, "updated")
      gstr_advance_payment
    end



  def assign_voucher_number
  if VoucherSetting.find_by_company_id_and_voucher_type(company_id, 26).voucher_number_strategy == 1    
    if Ledger.where(:company_id => company_id, :voucher_number => self.voucher_number, :deleted => 0).count == 0
      self.update_attribute(:voucher_number, VoucherSetting.next_voucher_number(company))
      VoucherSetting.next_purchase_write(company)
    elsif GstrAdvancePayment.where(:company_id => company_id, :voucher_number => self.voucher_number, :status_id => 2).count > 0
      if GstrAdvancePayment.where(:company_id => company_id, :voucher_number => self.voucher_number, :status_id => [0,1,3]).count > 0
        self.update_attribute(:voucher_number, VoucherSetting.next_voucher_number(company))
        VoucherSetting.next_purchase_write(company)
      else
        VoucherSetting.next_purchase_write(company)
      end
    end
  end
end

end

end

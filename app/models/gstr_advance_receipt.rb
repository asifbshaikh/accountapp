class GstrAdvanceReceipt < ActiveRecord::Base

  # include GstrAdvanceReceiptsHelper
  include VoucherBase

  scope :by_deleted, lambda {|del| where(:deleted => del)}
  scope :by_date, lambda{|fin_year| where(:received_date => fin_year.start_date..fin_year.end_date) unless fin_year.blank?}
  scope :by_customer, lambda{|customer| where(:from_account_id=> customer) unless customer.blank? }
  scope :by_voucher, lambda{|voucher_no| where("voucher_number like ?", "%#{voucher_no}%")}
  scope :by_date_range, lambda{|start_date, end_date| where(:received_date=> start_date..end_date) unless start_date.blank? || end_date.blank? }
  scope :by_amount_range, lambda{|min_amt, max_amt| where(:amount=> min_amt..max_amt)}
  scope :by_project, lambda{|project| where(:project_id=>project) unless project.blank? }

  #belongs_to :account
  belongs_to :company
  belongs_to :customer
  belongs_to :to_account, :class_name=>"Account", :foreign_key=>:to_account_id
  belongs_to :from_account, :class_name=>"Account", :foreign_key=>:from_account_id
  belongs_to :user, :foreign_key=> :created_by
  belongs_to :currency
  belongs_to :vendor
  has_many :receipt_advances
  has_many :gstr_one_items
  has_many :gstr_advance_receipt_voucher_sequences
  has_many :invoices, :through=>:gstr_advance_receipt_invoices, :dependent=> :destroy
  has_many :gstr_advance_receipt_invoices, :conditions => {:deleted => false}
  has_many :gstr_advance_receipt_history
  #has_many :gstr_advance_receipt_taxes, :dependent=>:destroy
  has_one :payment_detail, :as => :voucher, :dependent => :destroy
  has_many :ledgers, :as =>:voucher, :dependent =>:destroy  
  has_many :tax_line_items, :class_name=>"GstrAdvanceReceiptLineItem" , :conditions=> {:line_item_type=> nil} , :dependent => :destroy
  has_one :shipping_address, :class_name=>'Address', :as=>:addressable, :conditions=>{:address_type=>1} 
  has_one :billing_address, :class_name=>'Address', :as=>:addressable, :conditions=>{:address_type=>1} 
  has_many :gstr_advance_receipt_line_items, :conditions => {:line_item_type =>"GstrAdvanceReceiptLineItem"},:dependent => :destroy  
  has_many :shipping_line_items, :class_name=>"GstrAdvanceReceiptLineItem"  ,:conditions => {:line_item_type =>"ShippingLineItems"},:dependent => :destroy 
  accepts_nested_attributes_for :receipt_advances, :reject_if => lambda {|a| a[:amount].blank? } 
  accepts_nested_attributes_for :shipping_line_items, :reject_if => lambda {|a| a[:account_id].blank? && a[:amount].blank?}, :allow_destroy => true  
  accepts_nested_attributes_for :gstr_advance_receipt_line_items, :reject_if => true , :allow_destroy => true  
  accepts_nested_attributes_for :billing_address, :shipping_address
  accepts_nested_attributes_for :tax_line_items, :reject_if => true ,:allow_destroy=>true
  accepts_nested_attributes_for :gstr_advance_receipt_invoices, :reject_if=>lambda{|o| o[:amount].blank? || o[:amount].to_f==0}
  attr_accessible  :deleted_by, :deleted, :deleted_datetime, :voucher_number, :received_date, :voucher_date, :amount, :from_account_id, :to_account_id ,:payment_details,
  :restored_by, :restored_datetime,:currency_id, :exchange_rate,
  :project_id, :product_batches_attributes,:gstr_advance_receipt_line_items_attributes, :billing_address_attributes, :shipping_address_attributes, :shipping_line_items_attributes, 
  :tax_line_items_attributes, :discount_percentage, :gstr_advance_receipt_number, :gstr_advance_receipt_invoices_attributes, :invoice_id, :gstr_advance_receipt_taxes_attributes,
  :place_of_supply
  
  #accepts_nested_attributes_for :gstr_advance_receipt_taxes, :reject_if => true ,:allow_destroy=>true
  #accepts_nested_attributes_for :tax_line_items, :reject_if => true , :allow_destroy => true
  #accepts_nested_attributes_for :shipping_line_items, :reject_if => lambda {|a| a[:account_id].blank? && a[:amount].blank? }, :allow_destroy => true
  validates_associated :tax_line_items , :message=>"fields with * are mandatory"
  validates_associated :payment_detail 
  validates_associated :gstr_advance_receipt_line_items, :message =>"fields with * are mandatory"
  validates_presence_of  :voucher_number, :voucher_date, :received_date, :amount, :to_account_id, :from_account_id, :gstr_advance_receipt_line_items
  validates_uniqueness_of :voucher_number, :scope => :company_id
  validates :amount, :numericality => {:greater_than_or_equal_to => 0.01,
    :message => " should not be zero or negative ." }

 #validate :validate_from_account_and_to_account
  # validate :check_amount_on_create, :on => :create
  # validate :check_amount_on_update, :on => :update            
  # validate :validate_from_account_type, :if => :from_account_id
  # validate :validate_to_account_type, :if => :to_account_id
  validates_presence_of :place_of_supply
  validates_presence_of :exchange_rate, :if => lambda{|e| !e.from_account.blank? && !e.from_account.get_currency_id.blank?}
  # validate :validate_exchange_rate, :if => :exchange_rate    

  attr_accessor :fin_year

  STATUS = {'0' => 'UNALLOCATED' , '1' => ' PARTIALLY ALLOCATED' , '2' => 'ALLOCATED'}


  def get_party
    account.customer.blank? ? account.vendor : account.customer
  end


  def get_status
    
    if status == 0
      "Unallocated"
    elsif status == 1
     "Partially Allocated"
    elsif status ==2
    "Allocated"
    end    
  end

  def intra_state_supply
  company.gstn_state_code == place_of_supply.rjust(2,'0')
  end


def gst_line_items
    #create a hash with key as tax rate 
    #get the line item rate, check if the rate is present in hash
    #if not add a new gst_line_item_object to it
    #if present get the gst_line_item and add required fields to them
    items = Hash.new
    self.gstr_advance_receipt_line_items.each do |line_item|
      rate = line_item.gst_tax_rate
      if items.has_key? rate
        gst_tax_item = items[rate]
        gst_tax_item.add_txn_value(line_item.amount)
        gst_tax_item.add_igst_amt(line_item.igst_amt)
        gst_tax_item.add_cgst_amt(line_item.cgst_amt)
        gst_tax_item.add_sgst_amt(line_item.sgst_amt)
      else
        items[rate] = GstInvoiceLineItem.new(rate, line_item.amount,line_item.igst_amt,line_item.cgst_amt, line_item.sgst_amt, place_of_supply)
      end
    end
    items.values
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

def set_amount_allocation
  allocated_amount = gstr_advance_receipt_invoices.sum(:amount)
  
  if allocated_amount==amount
    self.update_attribute(:status, 2)
  else allocated_amount<amount
    self.update_attribute(:status, 0)
  end
end


def place_of_supply_state
  State.find_by_state_code(self.place_of_supply).name
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


def customer_name
 account=Account.find_by_id(from_account_id).name
end  

def currency
  if currency_id.blank?
    company.currency_code
  else
    Currency.find(currency_id).currency_code
  end
end


def email
  if cash_invoice?
    cash_customer_email if !cash_customer_email.blank?
  elsif customer.present?
    customer.email
  elsif vendor.present?
    vendor.email
  else
    ""  
  end
end

def voucher_setting
  VoucherSetting.by_voucher_type(25,company_id).first
end

def get_discount
  discount = 0
  gstr_advance_receipt_line_items.each do |line|
    discount += (line.unit_rate*line.quantity)*(line.discount_percentage/100.0) unless line.discount_percentage.blank? || line.amount.blank?
  end
  discount
end

def total_quantity
 qty_total = self.gstr_advance_receipt_line_items.sum(:quantity)
 qty_total
end

def has_tax_lines?

  !tax_line_items.blank?

end 


def create_allocation(params, company)
  gstr_advance_receipt = company.gstr_advance_receipts.find(params[:id])
  gstr_advance_receipt.assign_attributes(params[:gstr_advance_receipt])
  gstr_advance_receipt
end

def from_account
 Account.find_by_id(from_account_id) unless from_account_id.blank?
end

def customer
  customer=nil
  if from_account.customer.blank?
    customer = from_account.vendor
  else
    customer= from_account.customer
  end
  customer

end 



def return_substracted_outstanding

 amount - (paid_amount)
end


def paid_amount
 self.gstr_advance_receipt_invoices.sum(:amount)
end  

def update_included_invoice_status
  
  invoices.each do |invoice|
    invoice.update_invoice_status
  end
end

def update_invoice_status
  if outstanding>0
    
    self.update_attribute(:invoice_status_id, 0)
  else
    self.update_attribute(:invoice_status_id, 2)
  end
end


def outstanding

  amount=return_substracted_outstanding
  amount<0? 0 : amount
end


def from_account_name
  from_account.name
end


def build_gstr_advance_receipt_tax
  gstr_advance_receipt_line_items.each do |line|
  add_tax_line(line)
  end
end


def allocated_credit
  invoice_credit_allocations.sum(:amount)
end


def add_tax_line(line)
  unless line.marked_for_destruction?
    line.gstr_advance_receipt_taxes.each do |tax|
      account =tax.account
      
      unless account.blank? || (line.has_attribute?(:quantity) && line.quantity.blank?) || (line.has_attribute?(:unit_rate) && line.unit_rate.blank?)
        tax_lines=account.add_gstr_advance_receipt_tax_lines(self, line)
        tax_lines.each {|tax_line| self.tax_line_items<<tax_line}
      end
    end
  end
end
def group_tax_amt(account_id)
  amt=0
  tax_items = self.tax_line_items.where(:account_id =>account_id)
  tax_items.each do |item|
    amt +=item.amount
  end 
  amt
end

def delete_gstr_one_entry
  @adv_receipt=GstrOneItem.find_by_voucher_id_and_voucher_type(id,'GstrAdvanceReceipt')
  if @adv_receipt.present?
    @adv_receipt.destroy
  end
end


def delete
  transaction do
    if paid_amount > 0

      update_exist_receipts_with_ledger
    end
    destroy
  end  


def register_user_action(remote_ip, action)
    Workstream.register_user_action(company_id, created_by, remote_ip,
      " #{voucher_number} for customer #{from_account_name} for amount #{amount}", action, nil)
end

def register_delete_action(remote_ip, user, action)
    Workstream.register_user_action(company_id, user.id, remote_ip,
      " #{voucher_number} for customer #{from_account_name} for amount #{amount}", action, nil)
end




  def get_available_stock
   prd_arr = []
   self.gstr_advance_receipt_line_items.each do |line_item|
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
end



def save_with_ledgers
  save_result = false
  transaction do
    if save

      gstr_advance_receipt_line_items.each do |line_item|

        #credit_account_id = Product.find_by_id(line_item.product_id).income_account_id
        random_str=Ledger.generate_secure_random


         debit_ledger_entry = Ledger.new_debit_ledger(to_account_id, company_id, voucher_date,
          line_item.amount_with_exchange_rate, voucher_number, created_by, line_item.description, nil, random_str, from_account_id)

        credit_ledger_entry = Ledger.new_credit_ledger(from_account_id, company_id, voucher_date,
          line_item.amount_with_exchange_rate, voucher_number, created_by, line_item.description, nil, random_str, to_account_id)

       
          #build and save relationship between invoice and ledgers
          ledgers << debit_ledger_entry
          ledgers << credit_ledger_entry


          # if !line_item.discount_percentage.blank? && line_item.discount_percentage>0.0
          #   discount_account=Account.find_by_name_and_accountable_type_and_company_id("Discount on Sales Account", "IndirectExpenseAccount", company_id)
          #   random_str=Ledger.generate_secure_random
            
          #   # credit_account_id = Product.find_by_id(line_item.product_id).income_account_id
          #   debit_ledger_entry = Ledger.new_debit_ledger(from_account_id, company_id, voucher_date,
          #     line_item.discount_amount, voucher_number,created_by, line_item.description, nil, random_str, discount_account.id)

          #   credit_ledger_entry = Ledger.new_credit_ledger(discount_account.id, company_id, voucher_date,
          #     line_item.discount_amount, voucher_number, created_by, line_item.description, nil, random_str, from_account_id)

          #   ledgers << debit_ledger_entry
          #   ledgers << credit_ledger_entry
          # end
        end

        tax_line_items.each do |line_item|
        tax_account = line_item.account
          next if (tax_account.accountable_type=='DutiesAndTaxesAccounts' && tax_account.accountable.calculation_method==4 && tax_account.accountable.split_tax == 0)
          random_str=Ledger.generate_secure_random
            debit_ledger_entry = Ledger.new_debit_ledger(to_account_id, company_id, voucher_date,
          line_item.amount_with_exchange_rate, voucher_number, created_by, nil, nil, random_str,line_item.account_id)

          credit_ledger_entry = Ledger.new_credit_ledger(line_item.account_id, company_id, voucher_date,
            line_item.amount_with_exchange_rate, voucher_number, created_by, nil, nil, random_str,to_account_id)

          ledgers << debit_ledger_entry
          ledgers << credit_ledger_entry
        end

        # time_line_items.each do |line_item|
        #  random_str=Ledger.generate_secure_random
        #   time_account_id = Task.find(line_item.task_id).sales_account_id
        #   ebit_ledger_entry = Ledger.new_debit_ledger(account_id, company_id, invoice_date,
        #     line_item.amount_with_exchange_rate, invoice_number, created_by, nil, branch_id, random_str, time_account_id)

        #   credit_ledger_entry = Ledger.new_credit_ledger(time_account_id, company_id, invoice_date,
        #     line_item.amount_with_exchange_rate, invoice_number, created_by, nil, branch_id, random_str, account_id)

        #   ledgers << debit_ledger_entry
        #   ledgers << credit_ledger_entry
        # end

        shipping_line_items.each do |line_item|
         debit_account= line_item.amount<0 ? line_item.account_id : account_id
         credit_account= line_item.amount<0 ? to_account_id : line_item.account_id
         random_str=Ledger.generate_secure_random
         credit_ledger_entry = Ledger.new_credit_ledger(debit_account, company_id, voucher_date,
           line_item.amount_with_exchange_rate, voucher_number, from_account_id, nil, nil, random_str, credit_account)

         debit_ledger_entry = Ledger.new_debit_ledger(credit_account, company_id, voucher_date,
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
    GstrAdvanceReceiptLineItem.delete(tax_line_items)
    

    gstr_advance_receipt_line_items.reload
    gstr_advance_receipt_line_items.each do |line_item|

      #credit_account_id = Product.find_by_id(line_item.product_id).income_account_id
      random_str=Ledger.generate_secure_random

    
         debit_ledger_entry = Ledger.new_debit_ledger(to_account_id, company_id, voucher_date,
          line_item.amount_with_exchange_rate, voucher_number, created_by, line_item.description, nil, random_str, from_account_id)

        credit_ledger_entry = Ledger.new_credit_ledger(from_account_id, company_id, voucher_date,
          line_item.amount_with_exchange_rate, voucher_number, created_by, line_item.description, nil, random_str, to_account_id)

        #build and save relationship between invoice and ledgers
          ledgers << debit_ledger_entry
          ledgers << credit_ledger_entry
         
        #   if !line_item.discount_percentage.blank? && line_item.discount_percentage>0.0
        #     discount_account=Account.find_by_name_and_accountable_type_and_company_id("Discount on Sales Account", "IndirectExpenseAccount", company_id)
        #     random_str=Ledger.generate_secure_random
            
        #     # credit_account_id = Product.find_by_id(line_item.product_id).income_account_id
        #     debit_ledger_entry = Ledger.new_debit_ledger(from_account_id, company_id, voucher_date,
        #       line_item.discount_amount, voucher_number,created_by, line_item.description, nil, random_str, discount_account.id)

        #     credit_ledger_entry = Ledger.new_credit_ledger(discount_account.id, company_id, voucher_date,
        #       line_item.discount_amount, voucher_number, created_by, line_item.description, nil, random_str, from_account_id)

        #     ledgers << debit_ledger_entry
        #     ledgers << credit_ledger_entry
        #   end
        end


        build_gstr_advance_receipt_tax
        tax_line_items.reload
        tax_line_items.each do |line_item|
        tax_account = line_item.account
          next if (tax_account.accountable_type=='DutiesAndTaxesAccounts' && tax_account.accountable.calculation_method==4 && tax_account.accountable.split_tax == 0)
          random_str=Ledger.generate_secure_random
          debit_ledger_entry = Ledger.new_debit_ledger(to_account_id, company_id, voucher_date,
          line_item.amount_with_exchange_rate, voucher_number, created_by, nil, nil, random_str,line_item.account_id)

          credit_ledger_entry = Ledger.new_credit_ledger(line_item.account_id, company_id, voucher_date,
            line_item.amount_with_exchange_rate, voucher_number, created_by, nil, nil, random_str,to_account_id)

         ledgers << debit_ledger_entry
          ledgers << credit_ledger_entry
        end


        # time_line_items.each do |line_item|
        #  random_str=Ledger.generate_secure_random
        #   time_account_id = Task.find(line_item.task_id).sales_account_id
        #   ebit_ledger_entry = Ledger.new_debit_ledger(account_id, company_id, invoice_date,
        #     line_item.amount_with_exchange_rate, invoice_number, created_by, nil, branch_id, random_str, time_account_id)

        #   credit_ledger_entry = Ledger.new_credit_ledger(time_account_id, company_id, invoice_date,
        #     line_item.amount_with_exchange_rate, invoice_number, created_by, nil, branch_id, random_str, account_id)

        #   ledgers << debit_ledger_entry
        #   ledgers << credit_ledger_entry
        # end
        shipping_line_items.each do |line_item|
         debit_account= line_item.amount<0 ? line_item.account_id : account_id
         credit_account= line_item.amount<0 ? to_account_id : line_item.account_id
         random_str=Ledger.generate_secure_random
         credit_ledger_entry = Ledger.new_credit_ledger(debit_account, company_id, voucher_date,
           line_item.amount_with_exchange_rate, voucher_number, from_account_id, nil, nil, random_str, credit_account)

         debit_ledger_entry = Ledger.new_debit_ledger(credit_account, company_id, voucher_date,
           line_item.amount_with_exchange_rate, voucher_number, to_account_id, nil, nil, random_str, debit_account)

         ledgers << debit_ledger_entry
         ledgers << credit_ledger_entry
       end
       update_result = true
     end
     update_attribute("amount", calculate_total_amount)
     update_result
   end
   


   def calculate_total_amount
    gstr_advance_receipt_total=0
    gstr_advance_receipt_line_items.each do |line_item|
      gstr_advance_receipt_total +=line_item.amount 
    end
    
    tax_total=0
    tax_line_items.each do |line_item|
      tax_account = line_item.account
      next if (tax_account.accountable_type=='DutiesAndTaxesAccounts' && tax_account.accountable.calculation_method==4 && tax_account.accountable.split_tax == 0)      
      tax_total += line_item.amount

    end

    ship_charge = 0
    shipping_line_items.each do |line_item|
      ship_charge += line_item.amount
    end

    total = gstr_advance_receipt_total + tax_total + ship_charge
  end





  def foreign_currency?
    !currency_id.blank? && !exchange_rate.blank? && exchange_rate != 0 && company.currency_code != currency
  end 


  def get_total_amount
    gstr_advance_receipt_total = 0
    gstr_advance_receipt_line_items.each do |line_item|
      if line_item.marked_for_destruction? 
        next
      end
      gstr_advance_receipt_total += line_item.amount
    end
    tax_total = 0
    tax_line_items.each do |line_item|
     tax_account = line_item.account
     next if (tax_account.accountable_type=='DutiesAndTaxesAccounts' && tax_account.accountable.calculation_method==4 && tax_account.accountable.split_tax == 0)
     tax_total +=line_item.amount
   end
   ship_charge=0
   shipping_line_items.each do |line_item|
    ship_charge += line_item.amount unless line_item.amount.blank?
  end

  total = gstr_advance_receipt_total + tax_total 
end


def created_by_user
  User.find(created_by).full_name
end


def unallocated_amount
  amt=0
  
  amt=amount-gstr_advance_receipt_invoices.sum(:amount) unless amount.blank?
  
  amt
end   



def currency_code
  if currency.blank?
    company.currency_code
  else
    currency
  end
end


def sub_total
  self.gstr_advance_receipt_line_items.sum(:amount)
end

class << self


  def new_gstr_advance_receipt(params, company, user)
    gstr_advance_receipt = GstrAdvanceReceipt.new
    voucher_setting = VoucherSetting.find_by_company_id_and_voucher_type(company.id, 25)
    
    gstr_advance_receipt.voucher_number = voucher_setting.gstr_advance_receipt_voucher_number(company)
    gstr_advance_receipt.company_id = company.id
    gstr_advance_receipt.project_id=params[:project_id] if params[:project_id].present?
    unless params[:from_account_id].blank?
    #gstr_advance_receipt.account_id = params[:from_account_id] 
    gstr_advance_receipt.billing_address=Address.new(gstr_advance_receipt.billing_address.attributes) unless gstr_advance_receipt.get_party.blank? || gstr_advance_receipt.get_party.billing_address.blank?
    gstr_advance_receipt.shipping_address=Address.new(gstr_advance_receipt.shipping_address.attributes) unless gstr_advance_receipt.get_party.blank? || gstr_advance_receipt.get_party.shipping_address.blank?
  end
  gstr_advance_receipt.gstr_advance_receipt_line_items.build
    #gstr_advance_receipt.gstr_advance_receipt_line_items.each {|line_item| 2.times{ line_item.gstr_advance_receipt_taxes.build}}
    #gstr_advance_receipt.gstr_advance_receipt_number = VoucherSetting.next_gstr_advance_receipt_number(company)
    #gstr_advance_payment.old_file_size = 0
    #gstr_advance_payment.status_id=2
    #gstr_advance_payment.save(:validate=>false)
    #gstr_advance_payment.register_user_action(remote_ip, 'created')
    
    gstr_advance_receipt
  end



  


  def create_gstr_advance_receipt(params, company, user, fyr)
    gstr_advance_receipt =GstrAdvanceReceipt.new(params[:gstr_advance_receipt])
    
    gstr_advance_receipt.company_id = company.id
    voucher_setting = VoucherSetting.find_by_company_id_and_voucher_type(gstr_advance_receipt.company_id,25) 
    gstr_advance_receipt.created_by = user.id
    gstr_advance_receipt.voucher_date = params[:voucher_date].blank? ? Time.zone.now.to_date : params[:voucher_date]
    gstr_advance_receipt.received_date = Time.zone.now.to_date
      #gstr_advance_receipt.branch_id = user.branch_id unless user.branch_id.blank?
      gstr_advance_receipt.currency_id = gstr_advance_receipt.to_account.get_currency_id unless gstr_advance_receipt.to_account.blank?
      if gstr_advance_receipt.currency_id.blank? || gstr_advance_receipt.to_account.get_currency == gstr_advance_receipt.company.currency_code
        gstr_advance_receipt.exchange_rate = 0
      end
      gstr_advance_receipt.fin_year = fyr
      gstr_advance_receipt.build_gstr_advance_receipt_tax
      
      gstr_advance_receipt.amount = gstr_advance_receipt.get_total_amount
      gstr_advance_receipt.status= 0
      # create_gstr_advance_receipt_history(gstr_advance_receipt.id,company, user.id, "created")
      # if !gstr_advance_receipt.valid? && gstr_advance_receipt.errors[:voucher_number]
      #   if !gstr_advance_receipt.voucher_setting.custom_sequence?
      #      gstr_advance_receipt.voucher_number= VoucherSetting.gstr_advance_receipt_voucher_number(company)
      #   end
      # end
      gstr_advance_receipt
    end



    def update_gstr_advance_receipt(params, company, user, fyr)
      gstr_advance_receipt = GstrAdvanceReceipt.find(params[:id])
      GstrAdvanceReceiptLineItem.delete(gstr_advance_receipt.tax_line_items)
      gstr_advance_receipt.reload
      gstr_advance_receipt.assign_attributes(params[:gstr_advance_receipt])
      gstr_advance_receipt.from_account_id=nil if gstr_advance_receipt.customer.blank?
      #gstr_advance_receipt.company_id = company
      #evoucher_setting = VoucherSetting.find_by_company_id_and_voucher_type(gstr_advance_receipt.company_id,25) 
      #gstr_advance_receipt.created_by = user.id
      #gstr_advance_receipt.voucher_date = params[:voucher_date].blank? ? Time.zone.now.to_date : params[:voucher_date]
      #gstr_advance_receipt.received_date = Time.zone.now.to_date
     #
      #gstr_advance_receipt.currency_id = gstr_advance_receipt.account.get_currency_id unless gstr_advance_receipt.account.blank?
      #if gstr_advance_receipt.currency_id.blank? || gstr_advance_receipt.account.get_currency == gstr_advance_receipt.company.currency_code
        #gstr_advance_receipt.exchange_rate = 0
      #end
      #gstr_advance_receipt.fin_year = fyr
      gstr_advance_receipt.build_gstr_advance_receipt_tax
      gstr_advance_receipt.amount = gstr_advance_receipt.get_total_amount
      create_gstr_advance_receipt_history(gstr_advance_receipt.id,company, user.id, "updated")
      gstr_advance_receipt
    end


    def total quantity
      qty_total = self.gstr_advance_receipt_line_items.sum(:quantity)
      qty_total
    end

    def create_gstr_advance_receipt_history(gstr_advance_receipt,company,user,action)
     gstr_advance_receipt_history = GstrAdvanceReceiptHistory.new
     gstr_advance_receipt_history.gstr_advance_receipt_id = gstr_advance_receipt
     gstr_advance_receipt_history.company_id = company
     gstr_advance_receipt_history.description =action
     gstr_advance_receipt_history.to_account_id =user
     gstr_advance_receipt_history.received_date = Time.zone.now
     gstr_advance_receipt_history.save
     
   end 






   def assign_voucher_number
    if VoucherSetting.find_by_company_id_and_voucher_type(company.id ,25).voucher_number_strategy ==1
      if Ledger.where(:company_id=> company_id, :voucher_number=> self.voucher_number, :deleted=> 0).count ==0
        self.update_attribute(:voucher_number,VoucherSetting.next_voucher_number(company))
        VoucherSetting.next_receipt_write(company)
      elsif GstrAdvanceReceipt.where(:company_id=> company_id, :voucher_number=>self.voucher_number, :status_id=>2).count >0
        if GstrAdvanceReceipt.where(:company_id=> company_id, :voucher_number=>self.voucher_number, :status_id=>[0,1,3]).count >0
          self.update_attribute(:voucher_number, VoucherSetting.next_voucher_number(company))
          VoucherSetting.next_receipt_write(company)
        else
          VoucherSetting.next_receipt_write(company)
        end
      end
    end
  end

  def to_account_id_user
    User.find(to_account_id).full_name
  end 


end
end

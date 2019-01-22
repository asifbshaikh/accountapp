class PurchaseOrder < ActiveRecord::Base
  include VoucherBase
  scope :by_branch_id, lambda {|id| where(:branch_id => id) unless id.blank? }
  scope :by_deleted, lambda {|del| where(:deleted => del)}
  scope :by_date, lambda{|fin_year| where(:record_date => fin_year.start_date..fin_year.end_date) unless fin_year.blank?}
  scope :by_project, lambda { |project| where(:project_id=>project.to_i) unless project.blank? }

  before_save :destroy_uploaded_file?
  attr_accessor :old_file_size
  belongs_to :company
  belongs_to :account
  has_one :purchase
  belongs_to :project
  has_many :purchase_order_line_items, :conditions => {:line_item_type => "PurchaseOrderLineItem"}, :dependent => :destroy, :include => :product
  has_many :tax_line_items, :class_name => "PurchaseOrderLineItem", :conditions => {:line_item_type => nil}, :dependent => :destroy
  has_many :other_charge_line_items, :class_name => "PurchaseOrderLineItem", :conditions=> {:line_item_type=> "OtherChargeLineItem"}, :dependent => :destroy
  accepts_nested_attributes_for :purchase_order_line_items, :reject_if => lambda {|a| a[:product_id].blank? && a[:amount].blank? }, :allow_destroy => true
  accepts_nested_attributes_for :tax_line_items, :reject_if => lambda {|a| a[:account_id].blank? && a[:amount].blank?}, :allow_destroy => true
  accepts_nested_attributes_for :other_charge_line_items, :reject_if => lambda {|a| a[:account_id].blank? && a[:amount].blank? }, :allow_destroy => true
  attr_accessible :gst_purchaseorder,:purchase_order_number, :account_id, :exchange_rate, :record_date, :project_id, :purchase_order_line_items_attributes, 
    :customer_notes, :terms_and_conditions, :type, :due_date
  #validations
  validates_presence_of :account_id, :record_date, :purchase_order_number
  validates_uniqueness_of :purchase_order_number, :scope=>:company_id
  validates_presence_of :purchase_order_line_items
  validates_associated :purchase_order_line_items, :message => "fields with * are mandatory"
  validates_associated :tax_line_items, :message => "fields with * are mandatory. You can remove the Tax line item if you don't want to enter the Tax amount."
  validates_associated :other_charge_line_items, :message => "account and amount both are mandatory"

  has_attached_file :uploaded_file,
                    :storage=>:s3,
                    :s3_credentials=>"#{Rails.root}/config/s3.yml",
                    :url => ":s3_domain_url",
                    :path => "/uploaded_data/:class/:id/:basename.:extension"
  validates_attachment_size :uploaded_file, :less_than => 5.megabytes
  validates_attachment_content_type :uploaded_file, :content_type => ['image/jpeg','image/png','image /jpg','image/gif', 'application/pdf'],
                                    :message=>" must be of .jpeg,'.jpg', '.gif', .png or .pdf type",
                                    :allow_nil => true
  # validate :save_only_in_current_year
  attr_accessor :fin_year
  validate :storage_limit
  validate :validate_account_type, :if=>:account_id
  validate :save_in_frozen_fy
  validates_presence_of :exchange_rate, :if => lambda{|e| !e.account.blank? && !e.account.get_currency_id.blank?}
  validate :exchange_rate, :if => :exchange_rate
  validate :account_effective_date

  def account_effective_date
    if !account.blank? && !record_date.blank? && record_date < account.start_date
      errors.add(:record_date, "must be after account activation, #{account.name} is activated since #{account.start_date}")
    end
  end

  def has_atleast_one_inventoriable_item?
    result=false
    purchase_order_line_items.each do |line_item|
      result=true if line_item.product.inventory?
    end
    result
  end

  def mark_converted_to_purchase
    update_attribute("status", 1)
  end
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

  def save_in_frozen_fy
    if !record_date.blank? && in_frozen_year?
      errors.add(:record_date, "can't be in frozen financial year")
    end
  end
  def in_frozen_year?
    FinancialYear.check_if_frozen(company_id, record_date)
  end

  def discount
    discount = 0
    purchase_order_line_items.each do |line|
      discount += (line.unit_rate*line.quantity)*(line.discount_percent/100.0) unless line.amount.blank? || line.discount_percent.blank?
    end
    (self.exchange_rate != 0) ? (discount/exchange_rate).round(2) : discount
  end

  def vendor
    account.vendor.blank? ? account.customer : account.vendor
  end

  def created_by_user
    User.find(created_by).full_name
  end
  def vendor_name
    Account.find(account_id).name
  end
  def validate_account_type
     if !["SundryDebtor","SundryCreditor"].include?(Account.find(account_id).accountable_type)
      errors.add(:account_id,"you entered is not a vendor, please select right account")
     end
  end

  # def build_tax
  #   purchase_order_line_items.each do |line|
  #     unless line.marked_for_destruction? || line.unit_rate.blank? || line.quantity.blank?
  #       line.purchase_order_taxes.each do |tax|
  #         account = tax.account
  #         unless account.blank?
  #           parent_tax_amount=0
  #           account.parent_child_accounts.reverse.each do |acc|
  #             if acc.parent_id.blank?
  #               product_amt = line.quantity * line.unit_rate
  #               discount_amt = 0
  #               discount_amt = product_amt*(line.discount_percent/100) unless line.discount_percent.blank?
  #               product_amt = product_amt - discount_amt
  #               tax_amount = acc.get_tax_amount(product_amt)
  #               parent_tax_amount = tax_amount
  #             else
  #               tax_amount = acc.get_tax_amount(parent_tax_amount)
  #             end
  #             tax_line_items << PurchaseOrderLineItem.new(:account_id => acc.id, :tax => 1, :amount => tax_amount)
  #           end
  #         end
  #       end
  #     end
  #   end
  # end

  def total_quantity
   qty_total = self.purchase_order_line_items.sum(:quantity)
   qty_total
  end

   def currency
    if currency_id.blank?
      self.company.currency_code
    else
      Currency.find(currency_id).currency_code
    end
  end


  def amount
    purchase_order_total = self.purchase_order_line_items.sum(:amount)
      tax_total =  0 
            tax_line_items.each do |line_item|
              tax_account = line_item.account
              next if (tax_account.accountable_type=='DutiesAndTaxesAccounts' && tax_account.accountable.calculation_method==4 && tax_account.accountable.split_tax == 0)      
              tax_total += line_item.amount
            end
    other_charge = self.other_charge_line_items.sum(:amount)
    total = purchase_order_total.to_f + tax_total.to_f + other_charge.to_f
  end

  def calculate_total_amount
    purchase_order_total = 0
    purchase_order_line_items.each do |line_item|
      purchase_order_total+=line_item.amount unless line_item.amount.blank?
    end
    tax_total=0
    tax_line_items.each do |line_item|
       tax_account = line_item.account
       next if (tax_account.accountable_type=='DutiesAndTaxesAccounts' && tax_account.accountable.calculation_method==4 && tax_account.accountable.split_tax == 0)
      tax_total+=line_item.amount unless line_item.amount.blank?
    end
    other_charge=0
    other_charge_line_items.each do |line_item|
      other_charge+=line_item.amount unless line_item.amount.blank?
    end
    total = purchase_order_total.to_f + tax_total.to_f + other_charge.to_f
  end

  def sub_total
    self.purchase_order_line_items.sum(:amount)
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
  def other_charge
    self.other_charge_line_items.sum(:amount)
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

  def file_name
    uploaded_file_file_name
  end

  def file_size
    uploaded_file_file_size
  end

  def self.this_month
    Purchase.where("record_date between ? and ?", Time.zone.now.to_date.beginning_of_month, Time.zone.now.to_date.end_of_month).order("record_date ASC")
  end

 #soft delete method
 def delete(deleted_by_user)
    result = false
    result = update_attributes(:deleted_by => deleted_by_user, :deleted => true, :deleted_datetime => Time.zone.now)
    puts " Purchase order is #{deleted}"
    result
  end
#restore method
  def restore(restored_by_user)
    result = false
    result = update_attributes(:restored_by => restored_by_user, :deleted => false, :restored_datetime => Time.zone.now)
    puts "Purchase order is #{deleted}"
    result
  end

  def delete_uploaded_file
    @file_delete ||= "0"
  end

  def delete_uploaded_file=(value)
    @file_delete = value
   end

  class << self
    def get_vendor_purchase_orders(company, account)
      where(:company_id => company, :account_id => account, :deleted => false)
    end
    def new_order(params, company)
      purchase_order = PurchaseOrder.new
      if company.currency_code == 'INR'
        purchase_order.gst_purchaseorder = true
      end
      purchase_order.company_id = company.id
      purchase_order.account_id = params[:account_id] unless params[:account_id].blank?
      purchase_order.purchase_order_number = VoucherSetting.next_purchase_order_number(company)
      purchase_order.old_file_size = 0
      purchase_order.project_id=params[:project_id].to_i
      purchase_order.purchase_order_line_items.build
      purchase_order
    end

    def create_order(params, company, user, fyr)
      purchase_order = PurchaseOrder.new(params[:purchase_order])
      purchase_order.account_id=nil if purchase_order.account.blank?
      purchase_order.created_by = user.id
      purchase_order.company_id = company
      if purchase_order.company.currency_code == 'INR'
        purchase_order.gst_purchaseorder = true
      end
      purchase_order.status = 0
      purchase_order.branch_id = user.branch_id unless user.branch_id.blank?
      purchase_order.currency_id =  purchase_order.account.get_currency_id unless purchase_order.account_id.blank?
      if purchase_order.currency_id.blank? || purchase_order.account.get_currency == purchase_order.company.currency_code
        purchase_order.exchange_rate = 0
      end
      purchase_order.old_file_size = 0
      purchase_order.fin_year = fyr
      purchase_order.build_tax

      purchase_order.total_amount=purchase_order.calculate_total_amount

      purchase_order
    end

    def update_order(params, company, user, fyr)
      purchase_order = PurchaseOrder.find(params[:id])
      PurchaseOrderLineItem.delete(purchase_order.tax_line_items)
      if purchase_order.company.currency_code == 'INR'
        purchase_order.gst_purchaseorder = true
      end
      purchase_order.reload
      purchase_order.assign_attributes(params[:purchase_order])
      purchase_order.account_id=nil if purchase_order.account.blank?
      purchase_order.old_file_size = params[:old_file_size]
      # purchase_order.branch_id = user.branch_id unless user.branch_id.blank?
      purchase_order.currency_id =  purchase_order.account.get_currency_id unless purchase_order.account_id.blank?
      if purchase_order.currency_id.blank? || purchase_order.account.get_currency == purchase_order.company.currency_code
        purchase_order.exchange_rate = 0
      end
      purchase_order.build_tax
      purchase_order.total_amount=purchase_order.calculate_total_amount
      purchase_order
    end

    def update_status(id, status)
      result = false
      purchase_order = PurchaseOrder.find(id)
      if !purchase_order.blank? && purchase_order.update_attribute(:status, status)
        result = true
      end
    end
  end
  def set_opened
    update_attribute("status", 0)
  end
  def get_status
    if status == 1
      "Purchased"
    end
  end
  def purchased?
    status == 1
  end

  def foreign_currency?
    !currency_id.blank? && !exchange_rate.blank? && exchange_rate != 0 && company.currency_code != currency
  end

  def register_user_action(remote_ip, action)
    Subscription.increase_storage(company_id, uploaded_file_file_size, old_file_size)
    Workstream.register_user_action(company_id, created_by, remote_ip,
    " #{purchase_order_number} #{action} for vendor #{vendor_name} for amount #{amount}.", action, branch_id)
  end

  def register_delete_action(remote_ip, user, action)
    Workstream.register_user_action(company_id, user.id, remote_ip,
    " #{purchase_order_number} #{action} for vendor #{vendor_name} for amount #{amount}.", action, branch_id)
  end

  private

    def storage_limit
      errors[:base] << "Storage limit reached, your plan does not allow storing any more files." if Subscription.storage_limit?(company_id, uploaded_file_file_size, old_file_size)
    end

    def destroy_uploaded_file?
      self.uploaded_file.clear if @file_delete == "1" and !uploaded_file.dirty?
    end

end

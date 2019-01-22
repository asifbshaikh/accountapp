class Estimate < ActiveRecord::Base
  include VoucherBase
  scope :by_branch_id, lambda {|id| where(:branch_id => id) unless id.blank? }
  scope :by_deleted, lambda {|del| where(:deleted => del)}
  scope :by_date, lambda{|fin_year| where(:estimate_date => fin_year.start_date..fin_year.end_date) unless fin_year.blank?}
  scope :by_customer, lambda{|customer| where(:account_id=> customer) unless customer.blank? }
  scope :by_voucher, lambda{|voucher_no| where("estimate_number like ?", "%#{voucher_no}%")}
  scope :by_date_range, lambda{|start_date, end_date| where(:estimate_date=> start_date..end_date) unless start_date.blank? || end_date.blank? }
  scope :by_amount_range, lambda{|min_amt, max_amt| where(:total_amount=> min_amt..max_amt)}
  scope :by_status, lambda{|status| where(:status => status) unless status.blank?}
  scope :by_custom_field, lambda{|custom_field| where("custom_field1 = ? or custom_field2 =? or custom_field3=? ",custom_field, custom_field, custom_field) unless custom_field.blank?}

  before_save :destroy_attachment?
  attr_accessor :old_file_size
  belongs_to :account
  belongs_to :company
  has_one :sales_order
  has_one :invoice
  has_many :estimate_history
  has_many :estimate_line_items, :conditions => {:line_item_type => "EstimateLineItem"}, :dependent => :destroy
  has_many :tax_line_items, :class_name => "EstimateLineItem", :conditions=> {:line_item_type=> nil}, :dependent => :destroy
  has_many :shipping_line_items, :class_name => "EstimateLineItem", :conditions=> {:line_item_type=> "ShippingLineItem"}, :dependent => :destroy
  accepts_nested_attributes_for :estimate_line_items, :reject_if => true , :allow_destroy => true
  accepts_nested_attributes_for :tax_line_items, :reject_if => true , :allow_destroy => true
  accepts_nested_attributes_for :shipping_line_items, :reject_if => lambda {|a| a[:account_id].blank? && a[:amount].blank? }, :allow_destroy => true
  attr_accessible :tax_inclusive, :delete_attachment, :attachment, :total_amount, :estimate_number, :estimate_date, :terms_and_conditions, :customer_notes,:deleted, :deleted_datetime, :deleted_by, :account_id,
                  :restored_by, :restored_datetime, :gst_estimate, :estimate_line_items_attributes, :tax_line_items_attributes, :shipping_line_items_attributes,:custom_field1, :custom_field2, :custom_field3, :currency_id, :exchange_rate,:export_estimate,:place_of_supply


  #validations
  validates_presence_of :estimate_date, :account_id, :estimate_number
  validates_uniqueness_of :estimate_number, :scope=>:company_id
  validates_presence_of :estimate_line_items
  validate :check_estimate_line_items
  validates_associated :estimate_line_items, :message => "fields with * are mandatory"
  validates_associated :tax_line_items, :message => "fields with * are mandatory. You can remove the Tax line item if you don't want to enter the Tax amount."
  validates_associated :shipping_line_items, :message => "account and amount both are mandatory"

  has_attached_file :attachment,
                    :storage=>:s3,
                    :s3_credentials=>"#{Rails.root}/config/s3.yml",
                    :url => ":s3_domain_url",
                    :path => "/uploaded_data/:class/:id/:basename.:extension"
  validates_attachment_size :attachment, :less_than => 5.megabytes

  validates_attachment_content_type :attachment, :content_type => ['image/jpeg','image/png','image /jpg','image/gif', 'application/pdf'],
                                    :message=>" must be of .jpeg,'.jpg', '.gif', .png or .pdf type",
                                    :allow_nil => true
  validate :storage_limit
  validate :save_in_frozen_fy
  validates_presence_of :exchange_rate, :if => lambda{|e| !e.account.blank? && !e.account.get_currency_id.blank?}
   validates_presence_of :place_of_supply, :if => lambda{|e| (e.gst_estimate? && !e.export_estimate?)}
  validate :validate_exchange_rate, :if => :exchange_rate
  validate :account_effective_date

  attr_accessor :fin_year


  def place_of_supply_state
    state=""
    if self.place_of_supply.present?
      state= State.find_by_state_code(self.place_of_supply).name 
    end
    state
  end


  def account_effective_date
    if !account.blank? && !estimate_date.blank? && estimate_date < account.start_date
      errors.add(:estimate_date, "must be after account activation, #{account.name} is activated since #{account.start_date}")
    end
  end

  def get_party
    account.customer.blank? ? account.vendor : account.customer
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
    if !estimate_date.blank? && in_frozen_year?
      errors.add(:estimate_date, "can't be in frozen financial year")
    end
  end

  def in_frozen_year?
    FinancialYear.check_if_frozen(company_id, estimate_date)
  end

  def increase_storage
    Subscription.increase_storage(company_id, attachment_file_size, old_file_size)
  end

  def update_storage
    Subscription.increase_storage(company_id, attachment_file_size, old_file_size)
  end

  def delete_attachment
    @file_delete ||= "0"
  end

  def delete_attachment=(value)
    @file_delete = value
  end

  def file_name
    attachment_file_name
  end

  def file_size
    attachment_file_size
  end

  def validate_account_type
     if !["SundryDebtor","SundryCreditor"].include?(Account.find(account_id).accountable_type)
      errors.add(:account_id,"you entered is not a customer, please select right account")
     end
  end

  def currency
    if currency_id.blank?
      self.company.currency_code
    else
      Currency.find(currency_id).currency_code
    end
  end

  def get_discount
    discount = 0
    estimate_line_items.each do |line|
      discount += (line.unit_rate*line.quantity)*(line.discount/100.0) unless line.discount.blank? || line.amount.blank?
    end
    discount
  end

  def get_total_amount
    estimate_total =0
    estimate_line_items.each do |line_item|
      if line_item.marked_for_destruction? 
        next
      end
      estimate_total += line_item.amount
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

    total = estimate_total + ( tax_inclusive? ? 0 : tax_total ) + ship_charge
  end

  def customer_name
    account.name if account
  end
   def total_quantity
   qty_total = self.estimate_line_items.sum(:quantity)
   qty_total
  end

  #Added the amount calculation fix for issue during inclusive tax scenario
  #Author: Ashish Wadekar
  #Date: 22 February 2017
  def amount
    estimate_total = self.estimate_line_items.sum(:amount)
        if self.tax_inclusive? 
        tax_total =  0 
        else
           tax_total =  0 
            tax_line_items.each do |line_item|
              tax_account = line_item.account
              next if (tax_account.accountable_type=='DutiesAndTaxesAccounts' && tax_account.accountable.calculation_method==4 && tax_account.accountable.split_tax == 0)      
              tax_total += line_item.amount
            end
        end
    ship_charge = self.shipping_line_items.sum(:amount)
    estimate_total + tax_total + ship_charge
  end

  def sub_total
    self.estimate_line_items.sum(:amount)
  end
  def has_tax_lines?
    !tax_line_items.blank?
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

  def ship_charge
    self.shipping_line_items.sum(:amount)
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
    self.estimate_line_items.each do |line_item|
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
  #soft delete invoice
  def delete(deleted_by_user)
    result = false
    result = update_attributes(:deleted_by => deleted_by_user, :deleted => true, :deleted_datetime => Time.zone.now)
  end
  #restore estimate
  def restore(restored_by_user)
    result = false
    result = update_attributes(:restored_by => restored_by_user, :deleted => false, :restored_datetime => Time.zone.now)
  end


  def created_by_user
    User.find(created_by).full_name
  end

  class << self

    def get_customer_estimates(company, account)
      where(:company_id => company, :account_id => account, :deleted => false)
    end
    def invoiced_estimates
      Estimate.where(:status => "Invoiced")
    end

    def accepted_estimates
      Estimate.where(:status => "Accepted")
    end

    def rejected_estimates
      Estimate.where(:status => "Rejected")
    end

    def new_estimate(params, company)
      estimate = Estimate.new
      estimate.company_id = company.id
      if company.currency_code == 'INR'
        estimate.gst_estimate = true
      end
      estimate.account_id = params[:account_id] unless params[:account_id].blank?
      estimate.estimate_line_items.build
      estimate.estimate_line_items.each {|line_item| 2.times{ line_item.estimate_taxes.build}}
      estimate
    end

    def create_estimate(params, company, user, fyr)
      estimate = Estimate.new(params[:estimate])
      estimate.account_id=nil if estimate.account.blank?
      estimate.gst_estimate = params[:gst_estimate] unless params[:gst_estimate].blank?
      estimate.company_id = company
      estimate.created_by = user.id
      estimate.branch_id = user.branch_id unless user.branch_id.blank?
      estimate.currency_id = estimate.account.get_currency_id unless estimate.account.blank?
      if estimate.currency_id.blank? || estimate.account.get_currency == estimate.company.currency_code
        estimate.exchange_rate = 0
      end
      estimate.fin_year = fyr
      estimate.build_estimate_tax
      estimate.total_amount= estimate.get_total_amount
      # create_estimate_history(estimate.id,company, user.id, "created")
      estimate
    end

    def create_estimate_history(estimate,company,user,action)
      estimate_history = EstimateHistory.new
      estimate_history.estimate_id = estimate
      estimate_history.company_id = company
      estimate_history.description = action
      estimate_history.created_by = user
      estimate_history.record_date = Time.zone.now
      estimate_history.save
    end

    def update_estimate(params, company, user, fyr)
      estimate = Estimate.find(params[:id])
      EstimateLineItem.delete(estimate.tax_line_items)
      estimate.reload
      estimate.gst_estimate = params[:gst_estimate] unless params[:gst_estimate].blank?
      estimate.assign_attributes(params[:estimate])
      estimate.account_id=nil if estimate.account.blank?
      estimate.branch_id = user.branch_id unless user.branch_id.blank?
      estimate.currency_id = estimate.account.get_currency_id unless estimate.account.blank?
      if estimate.currency_id.blank? || estimate.account.get_currency == estimate.company.currency_code
        estimate.exchange_rate = 0
      end
      estimate.build_tax
      #estimate.total_amount=estimate.get_total_amount
      create_estimate_history(estimate.id,company, user.id, "updated")
      estimate
    end

    def update_status(id, status)
      result = false
      estimate = Estimate.find(id)
      if !estimate.blank? && estimate.update_attribute(:status, status)
        result = true
      end
    end

    def get_record_with_custom_field(params, company, current_financial_year)
      start_date = params[:start_date].blank? ? current_financial_year.start_date : params[:start_date].to_date
      end_date = params[:end_date].blank? ? Time.zone.now.to_date : params[:end_date].to_date
      voucher_type = params[:voucher_type]
      val = params[:custom_field] unless params[:custom_field].blank?
      estimate = Estimate.where(:company_id=> company.id, :estimate_date=> start_date..end_date).by_custom_field(val)
    end
  end

  # Naveen Apr 29 2016
  # This method is called to fix the nil error when creating a new estimate with tax inclusive flag true.
  # The reason the old code is failing is because of draft save not implemented in estimate.
  #
  def build_estimate_tax
    estimate_line_items.each do |line|
      add_tax_line(line)
    end
  end

  def add_tax_line(line)
    unless line.marked_for_destruction?
      line.estimate_taxes.each do |tax|
        account = tax.account
        unless account.blank? || (line.has_attribute?(:quantity) && line.quantity.blank?) || (line.has_attribute?(:unit_rate) && line.unit_rate.blank?)
          tax_lines=account.add_estimate_tax_lines(self, line)
          tax_lines.each { |tax_line| self.tax_line_items<<tax_line}
        end
      end
    end
  end


  def register_user_action(remote_ip, action)
    Subscription.increase_storage(company_id, attachment_file_size, old_file_size)
    Workstream.register_user_action(company_id, created_by, remote_ip,
    " #{estimate_number} #{action} for customer #{customer_name} for amount #{amount}.", action, branch_id)
  end

  def register_delete_action(remote_ip, user, action)
    Subscription.increase_storage(company_id, attachment_file_size, old_file_size)
    Workstream.register_user_action(company_id, user.id, remote_ip,
    " #{estimate_number} #{action} for customer #{customer_name} for amount #{amount}.", action, branch_id)
  end

  def get_status
    if status == 1
      "Invoiced"
    elsif status == 2
      "Converted to SO"
    end
  end

  def foreign_currency?
    !currency_id.blank? && !exchange_rate.blank? && exchange_rate != 0 && company.currency_code != currency
  end


  private
    def storage_limit
      errors[:base] << "Storage limit reached, your plan does not allow storing any more files." if Subscription.storage_limit?(company_id, attachment_file_size, old_file_size)
    end

    def destroy_attachment?
      self.attachment.clear if @file_delete == "1" and !attachment.dirty?
    end

    #This method has been added to check atleast one line item is present when line items are marked for deletion via JavaScript
    #Author : Ashish Wadekar
    #Date : 16th August 2016
    def check_estimate_line_items
      if self.estimate_line_items.size < 1 || self.estimate_line_items.all?{|estimate_line_item| estimate_line_item.marked_for_destruction?}
        errors[:base] << " Atleast one line item has to be present in an estimate."
      end
    end
end


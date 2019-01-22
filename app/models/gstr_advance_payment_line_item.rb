class GstrAdvancePaymentLineItem < ActiveRecord::Base
  include VoucherLineItem
	scope :by_deleted, lambda {|del| where(:deleted => del)}
  scope :by_date, lambda{|fin_year| where(:received_date => fin_year.start_date..fin_year.end_date) unless fin_year.blank?}
  scope :by_customer, lambda{|customer| where(:from_account_id=> customer) unless customer.blank? }
  scope :by_voucher, lambda{|voucher_no| where("voucher_number like ?", "%#{voucher_no}%")}
  scope :by_date_range, lambda{|start_date, end_date| where(:received_date=> start_date..end_date) unless start_date.blank? || end_date.blank? }
  scope :by_amount_range, lambda{|min_amt, max_amt| where(:amount=> min_amt..max_amt)}
  scope :by_project, lambda{|project| where(:project_id=>project) unless project.blank? }
  
  has_many :gstr_advance_payment_taxes, :dependent=>:destroy
  has_many :tax_accounts, :class_name=>"Account", :through=> :gstr_advance_payment_taxes, :source=>:account
  belongs_to :company
  belongs_to :account
  belongs_to :product
  # belongs_to :to_account, :class_name=>"Account", :foreign_key=>:to_account_id
  # belongs_to :from_account, :class_name=>"Account", :foreign_key=>:from_account_id
  belongs_to :user, :foreign_key=> :created_by
  belongs_to :currency
  belongs_to :purchase
  belongs_to  :gstr_advance_payment
  has_one :payment_detail, :as => :voucher, :dependent => :destroy
  has_one :billing_address, :class_name=>'Address', :as=>:addressable, :conditions=>{:address_type=>1}


  validates :unit_rate, :quantity, :presence => true, :if => lambda{|e| e.line_item_type ==  'GstrAdvancePaymentLineItem'}
  validates :product_id,:presence =>true, :if =>  lambda{|e| e.line_item_type ==  'GstrAdvancePaymentLineItem'}
  #validates :account_id,:presence =>true, :if =>  lambda{|e| e.line_item_type ==  nil}

  accepts_nested_attributes_for :gstr_advance_payment_taxes, :reject_if => lambda{|a| a[:account_id].blank? }, :allow_destroy => true

  attr_accessible :tax_account_id, :line_item_type, :discount, :purchase_id, :product_id, :account_id, :description, :quantity, :unit_rate, :amount,:tax, :gstr_advance_payment_taxes_attributes, :discount_percentage

  validates_associated :payment_detail

  def amount_with_exchange_rate
    line_amount=0
    if ["GstrAdvanePaymentLineItem", "TimeLineItem"].include?(self.line_item_type.to_s)
      line_amount = quantity * item_cost unless quantity.blank? || item_cost.blank?
    else
      line_amount = amount.abs
    end
    gstr_advance_payment.foreign_currency? ? line_amount*gstr_advance_payment.exchange_rate : line_amount
  end

  def gst_tax_rate
    self.tax_accounts.first.accountable.tax_rate
  end


   def tax_rate
    tax_rate=0
    tax_accounts.each do |account|
      tax_rate+=account.tax_rate
    end
    tax_rate
  end

  def discount_amount
    product_amt = quantity * unit_rate
    discount_amt = 0
    discount_amt = product_amt*(discount_percentage/100)
  end

  def tax_unit_cost
    unit_rate
  end

  def item_name
    product_id.blank? ? Account.find(account_id).name : Product.find(product_id).name
  end
  
  def item_cost
    item_unit_cost
  end

  def item_unit_cost
    send("tax_unit_cost")
  end  

  def unit_cost
    unit_rate
  end


  def discount
    discount = 0
    gstr_advance_payment_line_items.each do |line|
      discount += (line.unit_rate*line.quantity)*(line.discount_percentage/100.0) unless line.amount.blank? || line.discount_percentage.blank?
      gstr_advance_payment.foreign_currency? ? discount*gstr_advance_payment.exchange_rate : discount
    end
    discount
  end

  def tax_account
    Account.find_by_id(account_id)
  end

  def applied_taxes
    names=""
    tax_accounts.each do |account|
      names+= ", " if tax_accounts.last.equal?(account) && !tax_accounts.first.equal?(account)
      names+= account.name.chomp('on sales')
    end
    names
  end

  # def inventoriable?
  #   product = Product.find(product_id)
  #   if type == "GstrAdvancePaymentLineItem"
  #    product.inventoriable?
  #   else
  #     false
  #   end
  #end


end

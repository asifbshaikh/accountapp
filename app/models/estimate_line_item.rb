class EstimateLineItem < ActiveRecord::Base
  include VoucherLineItem

  belongs_to :estimate
  belongs_to :product
  belongs_to :account
  # belongs_to :tax_account, :class_name=>"Account", :foreign_key=>:tax_account_id
  has_many :estimate_taxes, :dependent=> :destroy
  has_many :tax_accounts, :class_name=>"Account", :through=> :estimate_taxes, :source=>:account, :autosave=>true

  #validation
  validates :amount, :numericality => {:greater_than_or_equal_to => 0.01,
    :message => " should not be zero or negative ." }, :if => lambda{|a| a.line_item_type != "ShippingLineItem" }
  validates :quantity, :numericality => {:greater_than_or_equal_to => 0.01, :message => " should not be zero or negative"}, :if => lambda{|a| a.line_item_type == "EstimateLineItem" }
  # validates :account_id,:presence => true #:uniqueness => {:scope => :estimate_id, :message => "should once per estimate entry" }
  validates_presence_of :product_id, :if => lambda{|a| a.line_item_type == "EstimateLineItem" }
  validates_presence_of :account_id, :if => lambda{|a| a.line_item_type != "EstimateLineItem" }

  accepts_nested_attributes_for :estimate_taxes#, :reject_if=>lambda { |o| o[:account_id].blank? }
  attr_accessible :tax_account_id, :line_item_type, :discount, :product_id, :purchase_id, :account_id, :description, :quantity, :unit_rate, :amount,:tax, :estimate_taxes_attributes

  TAX_TYPE={true=>'inclusive', false=>'exclusive'}

  #[FIXME] Callback needs to be evaluated. Potential Harzardous code
  before_save :check_tax_destruction
  def check_tax_destruction
    estimate_taxes.each do |tax|
      tax.mark_for_destruction if tax.account_id.blank?
    end
  end
  def tax_line_amount
    estimate.tax_line_items.where(:account_id=>account_id).sum(:amount)
  end

  def item_cost
    item_unit_cost
  end

  def item_unit_cost
    send("tax_#{TAX_TYPE[estimate.tax_inclusive?]}_unit_cost")
  end

  def tax_inclusive_unit_cost
    # unit_rate-(tax_amount/quantity) unless quantity==0
    discount=discount_percent.blank? ? 0.0 : discount_percent
    (unit_rate*(1-(discount/100.0)))/(1+(tax_rate/100.0))
  end

  def tax_rate
    
    tax_rate=0
    tax_accounts.each do |account|
      tax_rate+=account.tax_rate
    end
    tax_rate
  end

  def tax_exclusive_unit_cost
    unit_rate
  end

  def discount_percent
    discount
  end

  def tax_account
    Account.find_by_id(tax_account_id)
  end

  def self.subclasses
    [TaxLineItem]
  end

  def item_name
    product_id.blank? ? Account.find(account_id).name : Product.find(product_id).name
  end

  def discount_amount
    product_amt = quantity * unit_rate
    discount_amt = 0
    discount_amt = product_amt*(discount_percent/100)
  end

  def applied_taxes
    names=""
    tax_accounts.each do |account|
      names+= ", " if tax_accounts.last.equal?(account) && !tax_accounts.first.equal?(account)
      names+= account.name.chomp('on sales')
    end
    names
  end
  # def tax_amount
  #   tax_amt = 0
  #   tax_accounts.each do |account|
  #     unless account.blank? || self.quantity.blank? || self.unit_rate.blank?
  #       parent_tax_amount=0
  #       account.parent_child_accounts.reverse.each do |acc|
  #         if acc.parent_id.blank?
  #           tmp_tax_amount = estimate.tax_inclusive? ? acc.tax_inclusive_amt(amount) : acc.get_tax_amount(amount)
  #           tax_amt+=tmp_tax_amount
  #           parent_tax_amount = tmp_tax_amount
  #         else
  #           tax_amt += estimate.tax_inclusive? ? acc.tax_inclusive_amt(parent_tax_amount) : acc.get_tax_amount(parent_tax_amount)
  #         end
  #       end
  #     end
  #   end
  #   tax_amt
  # end
end

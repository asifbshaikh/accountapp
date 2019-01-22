class DutiesAndTaxesAccounts < ActiveRecord::Base
	has_one :account, :as => :accountable
  has_one :address, :as => :addressable

  validates :calculate_on_percent, :tax_rate, :presence => true
  accepts_nested_attributes_for :address

  TAX_TYPES = { "1" => "Excise", "2" => "Service Tax", "3" => "VAT", "4" => "Others", "5" =>"TDS", "6" => "GST"}
  TAX_CALC_TYPES = { 1 => 'On base amount', 2 => 'On base price + Primary tax', 3 => 'On base amount'}


  #Class methods
  class << self

  end

  def tax=(name)
      self.tax_id = TAX_TYPES.index(name)
  end

  def tax
    TAX_TYPES[self.tax_id.to_s]
  end


end
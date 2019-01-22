class BankAccount < ActiveRecord::Base
  has_one :account, :as => :accountable
  has_one :address, :as => :addressable
  
  accepts_nested_attributes_for :address
  # attr_accessible :account_number, :bank_name, :micr_code, :rtgs_code, :addressable_attributes, :ifsc_code
  # validates :account_number, :length =>{:in=> 10..16}
end

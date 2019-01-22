class LoanAccount < ActiveRecord::Base
	has_one :account, :as => :accountable
  has_one :address, :as => :addressable
  accepts_nested_attributes_for :address
end

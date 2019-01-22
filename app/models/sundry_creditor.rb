class SundryCreditor < ActiveRecord::Base
	has_one :account, :as => :accountable
  has_one :address, :as => :addressable
  
  accepts_nested_attributes_for :address
	# validates_format_of :email,
                          # :with =>  /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i,
                          # :message => ":Its not a valid format", :allow_blank => true
end

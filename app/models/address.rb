class Address < ActiveRecord::Base
  belongs_to  :addressable, :polymorphic  => true

  accepts_nested_attributes_for :addressable
  attr_accessible :address_type, :address_line1, :address_line2, :city, :state, :country, :postal_code, :state_code, :addressable_attributes
  # validates_presence_of :state, :message => "State can not be blank."

  #[FIXME] Revisit this code and change at all places where required
  def get_address
  	address = ""
  	address = "#{address_line1}".gsub(/[\n]/, '')  unless address_line1.blank?
  	address += address.blank? ? "#{address_line2}" : ", #{address_line2}" unless address_line2.blank?
  	address += address.blank? ? "#{city}" : ",\n #{city}" unless city.blank?
  	address += address.blank? ? "#{state}" : ", #{state}" unless state.blank?
    address += address.blank? ? "#{state_code}" : ", #{state_code}" unless state.blank?
  	address += address.blank? ? "#{country}" : ", #{country}" unless country.blank?
  	address += address.blank? ? "Pin : #{postal_code}" : ", Pin : #{postal_code}" unless postal_code.blank?
  	address += "." unless address.blank?
    if address.blank?
      address =" "
    else
      address
    end
    address_line1
  end

  def get_shipping_address
    address = ""
    address = "#{address_line1}".gsub(/[\n]/, '')  unless address_line1.blank?
    address += address.blank? ? "#{address_line2}" : ", #{address_line2}" unless address_line2.blank?
    address += address.blank? ? "#{city}" : ",\n #{city}" unless city.blank?
    address += address.blank? ? "#{state}" : ", #{state}" unless state.blank?
    address += address.blank? ? "#{state_code}" : ", #{state_code}" unless state.blank?
    address += address.blank? ? "#{country}" : ", #{country}" unless country.blank?
    address += address.blank? ? "Pin : #{postal_code}" : ", Pin : #{postal_code}" unless postal_code.blank?
    address += "." unless address.blank?
    if address.blank?
      address =" "
    else
      address
    end
  end
end

class Country < ActiveRecord::Base
  has_many :states
  has_many :companies
  has_many :country_companies

  MIDDLE_EAST_COUNTRIES = [210]
end

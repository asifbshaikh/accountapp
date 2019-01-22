class Year < ActiveRecord::Base
  has_many :financial_years
  has_many :company, :through => :financial_years
end

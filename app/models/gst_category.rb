class GstCategory < ActiveRecord::Base
  has_many :companies
  has_many :vendors
  has_many :customers
  has_many :gst_return_types

end

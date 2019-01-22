class PayheadType < ActiveRecord::Base
  
  validate :name, :description, :presence => true
end

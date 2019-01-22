class Designation < ActiveRecord::Base
  has_many :users
  belongs_to :company
   
   #validation start
  
   validates_presence_of :title, :description#, :status
   validates_uniqueness_of :title, :scope => :company_id
end

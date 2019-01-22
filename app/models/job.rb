class Job < ActiveRecord::Base
  belongs_to :user
   
   #validation start
  
   validates_presence_of :title, :description, :status
end

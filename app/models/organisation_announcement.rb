class OrganisationAnnouncement < ActiveRecord::Base
  #relationship
  belongs_to :user
  belongs_to :company
  
  #validation
  validates_presence_of :title, :announcement
  
end

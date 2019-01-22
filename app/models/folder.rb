class Folder < ActiveRecord::Base
  acts_as_tree
 #relationship
  belongs_to :user
  has_many :myfiles, :dependent => :destroy
  has_many :shared_folders, :dependent => :destroy
  
  attr_accessible :name, :parent_id, :user_id
  validates_presence_of :name
  
   #a method to check if a folder has been shared or not  
  def shared?  
     !self.shared_sharable_documents.empty?  
  end 
end

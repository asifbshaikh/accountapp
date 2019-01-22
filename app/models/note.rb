class Note < ActiveRecord::Base
   acts_as_taggable_on :tags   
   #relationships
    belongs_to :user
   
  #validations
   validates :subject, :description,  :presence => true
   validates_length_of :description, :maximum => 5000
   #validates_length_of :subject, :within => 10..200         

 
 
  def self.deleted_notes
    Note.where(:status => "deleted" )
  end
 
end

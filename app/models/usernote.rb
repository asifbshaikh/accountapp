class Usernote < ActiveRecord::Base
  belongs_to :user
  validates :notes, :length=>{:maximum => 200} 
  def self.delete_usernote(id, user_id)
  	usernote = Usernote.find_by_id_and_user_id(id, user_id)
  	usernote.destroy
  end
end

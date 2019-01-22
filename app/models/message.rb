class Message < ActiveRecord::Base
  belongs_to  :user
  belongs_to :company

  paginates_per 20 
  
  validates_presence_of :user_id, :subject
  #validates_presence_of :description, :message => "Your message is empty. Please enter some content"
 validates :description, :length => { :within => 20..150 } 
  def from 
    User.find(self.created_by).full_name
  end

  def to
    User.find(self.user_id).full_name
  end

  def self.message_count(user_id)
    self.where("user_id = ? and status = 0", user_id).count
  end

  def self.today
      self.where(:created_at => Date.today)
  end

  def self.week
      self.where("created_at between ? and ?",Date.today.beginning_of_week,Date.today.end_of_week)
  end
  
  def self.received_messages( company_id, user_id)
    self.where("company_id=? and user_id=?",company_id, user_id)
  end

  def self.sent_messages( company_id, user_id)
    self.where("company_id=? and created_by=?",company_id, user_id)
  end

  def can_delete? (user_id)
    created_by == user_id
  end

  def sent_by_you?(user_id)
    self.created_by == user_id
  end
  
  def sent_to_you?  
    self.user_id == user_id
  end
    
  def self.find_all_replies(msg)
    msg_array = Array.new
    message = find_by_reply_id(msg.id)
    if message.blank?
      msg_array
    else     
      msg_array << message
      msg_array.concat(find_all_replies(message))
    end  
  end

end
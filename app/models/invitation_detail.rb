class InvitationDetail < ActiveRecord::Base
  belongs_to :company
  belongs_to :user
  
  validates_presence_of :email, :name
  validates_format_of :email, :with =>  /^(|(([A-Za-z0-9]+_+)|([A-Za-z0-9]+\-+)|([A-Za-z0-9]+\.+)|([A-Za-z0-9]+\++))*[A-Za-z0-9]+@((\w+\-+)|(\w+\.))*\w{1,63}\.[a-zA-Z]{2,6})$/i, :uniqueness => true, :message => "should be valid email"
  validates_format_of :name, :with => /^[a-zA-Z]*['\s']{0,1}[a-zA-Z]*$/
  
  def get_status
    stat_arr = ['Pending', 'Accept', 'Reject']
    stat_arr[status_id]
  end
  
  def decline
    update_attributes(:status_id => 2)
  end
end

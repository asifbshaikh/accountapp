class ClientInvitation < ActiveRecord::Base
  belongs_to :company
  belongs_to :user
  belongs_to :auditor
  
  validates_presence_of :email, :name
  validates_uniqueness_of :email
  validates_format_of :email, :with =>  /^(|(([A-Za-z0-9]+_+)|([A-Za-z0-9]+\-+)|([A-Za-z0-9]+\.+)|([A-Za-z0-9]+\++))*[A-Za-z0-9]+@((\w+\-+)|(\w+\.))*\w{1,63}\.[a-zA-Z]{2,6})$/i, :uniqueness => true, :message => "should be valid email"
  validates_format_of :name, :with => /^[a-zA-Z]*['\s']{0,1}[a-zA-Z]*$/
  
  STATUS = {pending: 0, accept: 1, decline: 2}

  def get_status
    stat_arr = ['Pending', 'Accept', 'Reject']
    stat_arr[status_id]
  end

  def self.get_email(company)
    client = ClientInvitation.find_by_email(company.email)
    if client.present?
         
      client.accept
    end
  end
  
  def decline
    update_attributes(:status_id => STATUS[:decline])
  end

  def accept 
    update_attributes(:status_id => STATUS[:accept])
  end

  def pending
    update_attributes(:status_id => STATUS[:pending])
  end


end
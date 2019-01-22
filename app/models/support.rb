class Support < ActiveRecord::Base
  belongs_to :company
 validates_presence_of :subject

  def admin_name
     SuperUser.find(self.assigned_to).full_name
  end
  def send_by
     User.find(self.created_by).username
  end

def self.get_status
   support = 
 if payroll_detail.blank?
    "Attendance not taken"
  elsif payroll_detail.status==0
    "Pending"
   elsif payroll_detail.status == 1
    "Under processing"
   else 
     "Processed"
   end
end

#to close support ticket
 def self.close_ticket(ticket_number)
    result = false
    supports = self.where(:ticket_number=> ticket_number)
    if !supports.blank? && supports.update_all(:status_id => 2, :completed_date => Time.zone.now.to_date)
      result = true
    end
    result
  end
#delete support ticket
def self.permanent_delete(ticket_number)
    result = false
    supports = self.where(:ticket_number=> ticket_number)
    if !supports.blank? && supports.delete_all
      result = true
    end
    result
  end
end

module MyprofileHelper

LEAVE_STATUS = {1 => :Approved, 2 => :Rejected, 0 => :Pending, 3 => :Revoked}
LEAVE_STATUS_BADGES = {"Rejected" => "bg-danger","Pending"=>"bg-warning","Revoked"=>"bg-info","Approved"=>"bg-success"}.with_indifferent_access



def leave_status_badge(status)
      MyprofileHelper::LEAVE_STATUS_BADGES[status]
     # return "bg-primary"
  end
end

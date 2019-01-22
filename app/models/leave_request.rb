class LeaveRequest < ActiveRecord::Base
  paginates_per 20
  belongs_to :user
  belongs_to :leave_type
  belongs_to :company

  STATUS = {:pending_approval => 0, :approved => 1, :rejected => 2, :revoked => 3}
  LEAVE_STATUS = {1 => :Approved, 2 => :Rejected, 0 => :Pending, 3 => :Revoked}

  #validations
  validates_presence_of  :contact_during_leave, :reason_for_leave, :start_date, :end_date
  #validates_format_of :contact_during_leave, :with => /^[1-9][0-9]{9}$/,  :on => :create, :message => "should not start with 0"
  validate :start_date_and_end_date
  validate :leave_count, :on=>:create


  def start_date_and_end_date
    if(!end_date.blank? && !start_date.blank? && end_date < start_date)#||(end_date == start_date)
      errors.add(:end_date, " should be greater than or equal to start date" )
    end
  end

  def leave_count
    if !leave_type_id.blank? && !start_date.blank? && !end_date.blank?

      leave_card = LeaveCard.find_by_leave_type_id_and_company_id_and_user_id_and_card_year(leave_type_id, company_id, user_id, Time.zone.now.year)
      leave_balance = leave_card.pending_leave_count
      return true if leave_balance == 0 # for loss of pay leave types.
      requested_leaves = no_of_days_on_leave
      if (requested_leaves >= leave_balance)
        errors.add(:base, "You are requesting for #{requested_leaves} day's leave and your leave balance is #{leave_balance}")
      end
    else
      errors.add(:base, "Leave type can't be blank")
    end
  end


  def get_status
  LeaveRequest::LEAVE_STATUS[leave_status]

  end

  class << self
    def new_leave_request(params, user, company)
      leave_request = LeaveRequest.new(params[:leave_request])
      leave_request.user_id= user.id
      leave_request.company_id = company.id
      leave_request.leave_status = LeaveRequest::STATUS[:pending_approval]
      return leave_request
    end

    def pending_for_approval_by_user user
      self.where("approved_by = ? and leave_status=0", user.id)
    end

     def all_requests user_id
      self.where("user_id = ?", user_id)
    end


    def pending_approval user_id
      self.where("user_id = ? and leave_status=0", user_id)
    end

    def approved(user_id)
      self.where("user_id = ? and leave_status=1", user_id)
    end

    def rejected user_id
      self.where("user_id = ? and leave_status=2", user_id)
    end

    def last_five_pending_approvals( user_id )
      where(:user_id => user_id, :leave_status => 0).limit(5).order(" created_at DESC")
    end

    def last_five_pending_for_approval_by_user user
      self.where("approved_by = ? and leave_status=0", user.id).limit(5).order("created_at DESC")
    end

    def get_leave_status(status)
      if status==0
        "Pending Approval"
      elsif status==1
        "Approved"
      elsif status==2
        "Rejected"
      else
        "Revoked"
      end
    end

  end

  def approver_name
    User.find(self.approved_by).full_name unless approved_by.blank?
  end

  def approve
    leave_card = LeaveCard.find_by_leave_type_id_and_user_id_and_card_year(self.leave_type_id, self.user_id, Time.zone.now.year)
    leave_card.add_to_utilized_leaves no_of_days_on_leave
    update_attributes!(:leave_status => LeaveRequest::STATUS[:approved])
  end

  def revoke
    if leave_status == STATUS[:approved]
      leave_card = LeaveCard.find_by_leave_type_id_and_user_id_and_card_year(self.leave_type_id, self.user_id, Time.zone.now.year)
      leave_card.revoke_utilized_leaves no_of_days_on_leave
    end
    update_attributes(:leave_status => LeaveRequest::STATUS[:revoked])
  end

  def no_of_days_on_leave
    days = (end_date - start_date).to_i
    days+1
  end

  def approved?
    leave_status == LeaveRequest::STATUS[:approved]
  end

  def register_user_action(remote_ip, action, branch_id)
     Workstream.register_user_action(company_id, user_id, remote_ip,
         " Leave request from #{start_date} to #{end_date} #{action}", action, branch_id)
  end

end
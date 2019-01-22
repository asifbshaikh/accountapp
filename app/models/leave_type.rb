class LeaveType < ActiveRecord::Base
  belongs_to :company
  has_many :leave_requests #, :dependent => :destroy
  has_many :leave_cards, :dependent => :destroy

  #validation start
  # the validation of uniqueness with case insenstive will be with poor performance and needs to re-visited at a later date.
  validates :leave_type, :presence => {:message => "cannot be blank. Please enter a leave type."},
    :uniqueness => {:scope => :company_id, :case_sensitive => false, :message => "already exists. Please enter a different leave type."}
  validates_presence_of :allowed_leaves

  def carry_forward?
    carry? ? "Yes" : "No"
  end

  def leave_balance
    leave_balance = allowed_leaves
    leave_balance = allowed_leaves - utilised_leave
    leave_balance
  end

  def utilised_leave
    leave_requests = LeaveRequest.find_all_by_company_id_and_leave_type_id(self.company_id, self.id)
    total_utilised_leave = 0
    for leave_request in leave_requests
      sd = leave_request.start_date
      ed = leave_request.end_date
      utilised_leave = (ed - sd)
      total_utilised_leave += utilised_leave
    end
    total_utilised_leave
  end

  def total_leave_count
    total_leave += self.sum(allowed_leaves)
    total_leave
  end

 class << self
  #method to create default leave type @ new signup
  def create_default_leave_types(company_id, user_id)
    leave_type_names = ["Sick Leave","Casual Leave", "Leave without pay"]
    leave_type_names.each do |name|
      leave_type = LeaveType.new
      leave_type.company_id = company_id
      leave_type.created_by = user_id
      leave_type.leave_type = name
      leave_type.allowed_leaves = 10
      leave_type.carry = false
      if leave_type.save!
        leave_card = LeaveCard.new
        leave_card.company_id = company_id
        leave_card.user_id = user_id
        leave_card.leave_type_id = leave_type.id
        leave_card.card_year = Time.zone.now.year
        leave_card.total_leave_cnt = leave_type.allowed_leaves
        leave_card.utilized_leave_cnt = 0
        leave_card.save!
      end
     end
  end

  def create_leave_type(params, company, user)
    leave_type = LeaveType.new(params[:leave_type])
    leave_type.company_id = company.id
    leave_type.created_by = user.id
    leave_type
  end
end
#-------------------------
  def save_with_leave_card(company)
   company = Company.find_by_id(company.id)
   users = company.users
   result = false
    transaction do
      save
      for user in users
      leave_card = LeaveCard.new(:company_id => company.id,
                                 :user_id => user.id,
                                 :leave_type_id => id,
                                 :card_year => Time.zone.now.year,
                                 :total_leave_cnt => allowed_leaves,
                                 :utilized_leave_cnt => 0)
        leave_card.save
      end
    result = true
    end
    result
  end

  def register_user_action(remote_ip, action, branch_id)
    Workstream.register_user_action(company_id, created_by, remote_ip,
     " leave type #{leave_type} and this leave allowed for #{allowed_leaves} days #{action}", action, branch_id)
  end

end
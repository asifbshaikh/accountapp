class Label < ActiveRecord::Base
  belongs_to :company

  validates :estimate_label, :warehouse_label, :customer_label ,:length => { :maximum => 30, :too_long => "%{count} characters is the maximum allowed" }

class << self
  def new_record(user)
    label = Label.new
    label.created_by = user
    label 
  end
 def create_record(params, company)
   label = Label.new(params[:label])
   label.company_id = company
   label
 end
#method to create default custom fields for company at the time of company registration
 def create_default_record(company_id, user_id)
    label = Label.new
    label.company_id = company_id
    label.created_by = user_id
    label.estimate_label = "Estimate"
    label.warehouse_label = "Warehouse"
    label.customer_label = "Customer"
    label.save!
  end
end

 def register_user_action(created_by, remote_ip, action,branch_id)
    Workstream.register_user_action(company_id, created_by, remote_ip,
    " Terminology ", action, branch_id)
  end

end

class VoucherTitle < ActiveRecord::Base
  belongs_to :company

  validates :voucher_title ,:length => { :maximum => 30, :too_long => "%{count} characters is the maximum allowed" }
  validates_uniqueness_of :voucher_title, :message => "has already been taken" , :scope => :company_id
  validates_presence_of :voucher_title

class << self
  def new_record(voucher_type)
    voucher_title = VoucherTitle.new
    voucher_title.voucher_type = voucher_type
    voucher_title 
  end
 def create_record(params, company)
   voucher_title = VoucherTitle.new(params[:voucher_title])
   voucher_title.company_id = company
   voucher_title.voucher_type = "Invoice"
   voucher_title
 end
#method to create default custom fields for company at the time of company registration
 def create_default_record(company_id)
   titles = ["Invoice", "Tax Invoice"]
   titles.each do |title|
    voucher_title = VoucherTitle.new
    voucher_title.company_id = company_id
    voucher_title.voucher_title = title
    voucher_title.voucher_type ="Invoice"
    voucher_title.status = true
    voucher_title.save!
   end
 end

end

 def register_user_action(created_by, remote_ip, action,branch_id)
    Workstream.register_user_action(company_id, created_by, remote_ip,
    " VoucherTitle for #{voucher_type} ", action, branch_id)
  end


end

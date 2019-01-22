class CustomField < ActiveRecord::Base
  belongs_to :company

  validates :custom_label1, :custom_label2, :custom_label3, :default_value1,:default_value2,:default_value3 ,:length => { :maximum => 30, :too_long => "%{count} characters is the maximum allowed" }

VOUCHER_TYPES = {1=>'Estimate', 5=>'Purchase', 15=> "StockIssueVoucher",16=>'StockReceiptVoucher', 18=>'StockWastageVoucher'}

class << self
  def get_custom_fields(company, voucher_type)
    custom_field = CustomField.find_by_company_id_and_voucher_type(company, voucher_type)
  end
  def new_record(voucher)
    custom_field = CustomField.new
    custom_field.voucher_type = voucher
    custom_field 
  end
 def create_record(params, company)
   custom_field = CustomField.new(params[:custom_field])
   custom_field.company_id = company
   custom_field
 end
#method to create default custom fields for company at the time of company registration
 def create_default_record(company_id)
   voucher_type_names = ["Invoice", "StockIssueVoucher","StockReceiptVoucher", "StockWastageVoucher","Estimate","Purchase"]
   voucher_type_names.each do |name|
    custom_field = CustomField.new
    custom_field.company_id = company_id
    custom_field.voucher_type = name
    custom_field.status = false
    custom_field.save!
   end
 end
  
  def get_custom_field(company, index)
    cstm_fld={}
    voucher_type = CustomField.get_voucher_type(index)
    custom_field = CustomField.find_by_company_id_and_voucher_type(company, voucher_type)
     if !custom_field.blank?  
      cstm_fld['custom_label1']=custom_field.custom_label1
      cstm_fld['custom_label2']=custom_field.custom_label2
      cstm_fld['custom_label3']=custom_field.custom_label3
      cstm_fld['default_value1']=custom_field.default_value1
      cstm_fld['default_value2']=custom_field.default_value2
      cstm_fld['default_value3']=custom_field.default_value3
      cstm_fld['status']=custom_field.status
     end
      cstm_fld.to_json
  end
  def get_voucher_type(index)
    VOUCHER_TYPES[index]
  end

end

 def register_user_action(created_by, remote_ip, action,branch_id)
    Workstream.register_user_action(company_id, created_by, remote_ip,
    " CustomField for #{voucher_type} ", action, branch_id)
 end
  

  def update_with_strategy(params)
    cf1 = params[:custom_label1] unless params[:custom_label1].blank?
    cf2 = params[:custom_label2] unless params[:custom_label2].blank?
    cf3 = params[:custom_label3] unless params[:custom_label3].blank?
    dv1 = params[:default_value1] unless params[:default_value1].blank?
    dv2 = params[:default_value2] unless params[:default_value2].blank?
    dv3 = params[:default_value3] unless params[:default_value3].blank?
    status = params[:status] unless params[:status].blank?
    
    transaction do
     result = false
      update_attributes!(:custom_label1 => cf1, :custom_label2=> cf2, :custom_label3=> cf3, 
                      :default_value1=> dv1, :default_value2 => dv2, :default_value3 => dv3, :status=> status)
    end      
  end

end

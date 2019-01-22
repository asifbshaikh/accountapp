class CompanyAuditor < ActiveRecord::Base
  belongs_to :company
  belongs_to :auditor
  #validates_uniqueness_of :auditor_id, :scope => :company_id
  def self.accept_request(invitation_detail_id, auditor)
    result = false
    #begin
		transaction do
		  invitation_detail = InvitationDetail.find invitation_detail_id
		  CompanyAuditor.create(:company_id => invitation_detail.company_id, :auditor_id => auditor)
		  invitation_detail.update_attribute(:status_id, 1)
		  result = true
		end 
    #rescue
     # result = false
    #end
    result
  end
  
  def self.soft_delete(company, auditor)
  result = false
  #begin
    transaction do
      company_auditor = CompanyAuditor.find_by_company_id_and_auditor_id(company, auditor).update_attributes!(:deleted => true, :deleted_datetime => Time.zone.now.to_date)
      result = true
    end
  #rescue
   # result = false
  #end
  end 
end

class LeadCompany < ActiveRecord::Base
  belongs_to :lead
  belongs_to :company

  attr_accessible :lead_id, :company_id
end

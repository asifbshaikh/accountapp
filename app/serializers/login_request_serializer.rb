class LoginRequestSerializer < ActiveModel::Serializer
  attributes :id, :company_id, :created_by, :status, :calling_action, :gsp_id
end

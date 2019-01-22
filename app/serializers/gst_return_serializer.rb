class GstReturnSerializer < ActiveModel::Serializer
  attributes :id, :company_id, :financial_year_id, :month
end

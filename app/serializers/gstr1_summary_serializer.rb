class Gstr1SummarySerializer < ActiveModel::Serializer
  attributes :id, :company_id, :gstr_one_id, :ret_period, :chksum, :summ_typ, :sec_sum
end

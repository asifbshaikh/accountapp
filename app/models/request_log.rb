class RequestLog < ActiveRecord::Base
	belongs_to :company
class << self

	def save_gstr1_filing_payload(company_id,payload)
		 gstr1_entity = Gstr1Service.new()
		 gstr1_entity.file_gstr1(payload)
		 gstr1_entry = self.new(:gsp_detail_id =>1,:gsp_id=>3,:txn_id=>2, :request_payload=>payload,:company_id => company_id)
		 gstr1_entry.save!
	end


end


end

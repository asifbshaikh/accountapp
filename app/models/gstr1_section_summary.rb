class Gstr1SectionSummary < ActiveRecord::Base
belongs_to :gstr1_summary
has_many :gstr1_counter_party_summaries, :dependent => :destroy
has_many :gstr1_state_code_summaries, :dependent => :destroy

	def update_counter_party_summary(summary)
    	attr = {:gstr1_section_summary_id =>id, :ctin =>summary.ctin, :chksum => summary.chksum, :total_record => summary.ttl_rec, :total_value => summary.ttl_val, 
        		:total_igst => summary.ttl_igst, :total_cgst => summary.ttl_cgst, :total_sgst => summary.ttl_sgst, :total_taxable_value => summary.ttl_tax}
    	gstr1_counter_party_summaries << Gstr1CounterPartySummary.new(attr)
  	end

  	def update_state_code_summary(summary)
    	attr = {:gstr1_section_summary_id =>id, :state_code =>summary.state_cd, :chksum => summary.chksum, :total_record => summary.ttl_rec, :total_value => summary.ttl_val, 
        		:total_igst => summary.ttl_igst, :total_cgst => summary.ttl_cgst, :total_sgst => summary.ttl_sgst, :total_taxable_value => summary.ttl_tax}
    	gstr1_state_code_summaries << Gstr1StateCodeSummary.new(attr)
  	end
end
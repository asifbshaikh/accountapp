class Gstr1Summary < ActiveRecord::Base
  belongs_to :company
  belongs_to :gstr_one
  has_many :gstr1_section_summaries, :dependent => :destroy

  STATUS = {processing: 0, updated: 1, final: 2, failed: 3}

  def processing?
    self.status == STATUS[:processing]
  end

  def processing
    update_attributes(:status => STATUS[:processing])
  end

  def failed
      update_attributes(:status => STATUS[:failed])
  end

  def update_summary(return_period, summary_type, chksum)
    update_attributes(:return_period => return_period, :summary_type => summary_type, :chksum => chksum , status: STATUS[:updated])
  end

  def update_section_summary(summary)
    attr = {:gstr1_summary_id =>id, :section_type =>summary.sec_nm, :chksum => chksum, :total_record => summary.ttl_rec, :total_value => summary.ttl_val, 
        :total_igst => summary.ttl_igst, :total_cgst => summary.ttl_cgst, :total_sgst => summary.ttl_sgst, :total_taxable_value => summary.ttl_tax, 
        :nil_supply_amt => summary.ttl_nilsup_amt, :exempted_supply_amt => summary.ttl_expt_amt, :ngsup_outward_amt => summary.ttl_ngsup_amt,
        :total_doc_issued => summary.ttl_doc_issued, :total_doc_cancelled => summary.ttl_doc_cancelled, :net_doc_issued => summary.net_doc_issued}
    gstr1_section_summaries << Gstr1SectionSummary.new(attr)
  end

end

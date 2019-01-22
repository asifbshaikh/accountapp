require 'ostruct'

class Gstr1SummaryResponseHandler
  def initialize(company, gstr1_summary, hash_data)
    @company = company
    @gstr1_summary = gstr1_summary
    @ost_res = OpenStruct.new(hash_data)
  end

  def handle_summary_response
  	return_period = @ost_res.ret_period
  	summary_type = @ost_res.summ_typ
  	chksum = @ost_res.chksum
  	@gstr1_summary.update_summary(return_period, summary_type, chksum)  	
  	handle_section_summary(@gstr1_summary, @ost_res.sec_sum)
  end

  def handle_section_summary(gstr1_summary, section_summary)
    ActiveRecord::Base.transaction do
    	present_sec_summary = gstr1_summary.gstr1_section_summaries
    	if !present_sec_summary.blank?
    		present_sec_summary.each do |summary|
    			summary.destroy
    		end
    	end
    	section_summary.each do |summary|
    		os_summary = OpenStruct.new(summary)
    		gstr1_section_summary = gstr1_summary.update_section_summary(os_summary)
    		if os_summary.sec_nm.eql?("B2B") || os_summary.sec_nm.eql?("CDNR")
    			type = os_summary.sec_nm
    			handle_counter_party_summary(gstr1_section_summary, os_summary, type)
    		elsif os_summary.sec_nm.eql?("B2CL") || os_summary.sec_nm.eql?("CDNUR")
    			type = os_summary.sec_nm
    			handle_state_code_summary(gstr1_section_summary, os_summary, type)
    		end
    	end
    end
  end

  def handle_counter_party_summary(section_summary, cp_summary, type)
  	type_summary = section_summary.find_by_section_type(type)
  	cpty_summary = cp_summary.cpty_sum
  	if !cpty_summary.blank?
	  	cpty_summary.each do |summary|
	  		os_summary = OpenStruct.new(summary)
	  	 	type_summary.update_counter_party_summary(os_summary)
	  	end
  	end
  end

  def handle_state_code_summary(section_summary, sc_summary, type)
  	type_summary = section_summary.find_by_section_type(type)
  	cpty_summary = sc_summary.cpty_sum
  	if !cpty_summary.blank?
	  	cpty_summary.each do |summary|
	  		os_summary = OpenStruct.new(summary)
	  		type_summary.update_state_code_summary(os_summary)
	  	end
  	end
  end
























end
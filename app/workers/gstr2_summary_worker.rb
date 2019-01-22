class Gstr2SummaryWorker
  include Sidekiq::Worker

  def perform(company_id, usr_ip_addr, gstr_two_id)
    company = Company.find_by_id(company_id)
    gstr_two = company.gstr_twos.find(gstr_two_id)
    gstr2_srvc = Gstr2Service.new(company, usr_ip_addr, gstr_two)
    if gstr2_srvc.update_summary
      Sidekiq.logger.info "GstrTwoSummaryWorker::perform::successfull"
    else
      Sidekiq.logger.info "GstrTwoSummaryWorker::perform::FAILED"      
    end
  end
  
end
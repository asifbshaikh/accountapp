class Gstr2aWorker
  include Sidekiq::Worker

  def perform(company_id, usr_ip_addr, gstr_two_id, ctin)
    company = Company.find_by_id(company_id)
    gstr_two = company.gstr_twos.find(gstr_two_id)

    gstr2a_srvc = Gstr2aService.new(company, usr_ip_addr, gstr_two, ctin)
    Rails.logger.debug " going towards request_b2b=============================================================="
    if gstr2a_srvc.request_b2b
      Sidekiq.logger.info "Gstr2aWorker::perform::successfull"
    else
      Sidekiq.logger.info "Gstr2aWorker::perform::FAILED"      
    end
  end
  
end
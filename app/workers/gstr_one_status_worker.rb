class GstrOneStatusWorker
  include Sidekiq::Worker

  def perform(company_id, usr_ip_addr, gstr_one_id)
  	company = Company.find_by_id(company_id)
  	gstr_one = company.gstr_ones.find(gstr_one_id)

  	gstr1_srvc = Gstr1Service.new(company, usr_ip_addr, gstr_one)
  	if gstr1_srvc.get_return_status
      Sidekiq.logger.info "GstrOneUploadWorker::perform::successfull"
    else
      Sidekiq.logger.info "GstrOneUploadWorker::perform::FAILED"      
    end
  end
  
end
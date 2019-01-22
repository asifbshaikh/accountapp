class Gstr1SummaryWorker
  include Sidekiq::Worker

  #[FIXME] add exception handling
  def perform(company_id, usr_ip_addr, gstr_one_id)
    company = Company.find_by_id(company_id)
    gstr1_summary = company.gstr1_summaries.find_by_gstr_one_id(gstr_one_id)
    gstr_one = company.gstr_ones.find(gstr_one_id)

    begin
      gstr1_srvc = Gstr1Service.new(company, usr_ip_addr, gstr_one)
      if gstr1_srvc.update_summary
        Sidekiq.logger.info "Gstr1SummaryWorker::perform::successful"
      else
        Sidekiq.logger.info "Gstr1SummaryWorker::perform::FAILED"      
      end
    rescue Exception => e
      Sidekiq.logger.error e
      ErrorMailer.experror(e, @company.users.first, "GSTR1 summary worker for  #{company_id} and #{gstr_one_id}").deliver
      #raise e
    end
  end
  
end
class GstReportGenerationWorker
  include Sidekiq::Worker

  def perform(company_id)
    months = [7, 8, 9]
    one_dates = ["2017-09-05", "2017-09-20", "2017-10-10"]
    two_dates = ["2017-09-05", "2017-09-20", "2017-10-10"]
    company = Company.find(company_id)
    @return_types = company.gst_category.gst_return_types
    begin        
      months.each_with_index do |month, index|
        gst_return = GstReturn.create_return(company, month)
        gstr_one = GstrOne.create_return(company, gst_return, one_dates[index])
        gstr_two = GstrTwo.create_return(company, gst_return, one_dates[index])
        Sidekiq.logger.debug "GST returns created for company #{company.name} for month #{Date::MONTHNAMES[month]}"
      end
    rescue Exception => e
      "failed for company #{company.id} #{company.name}"
      Sidekiq.logger.error e
      ErrorMailer.experror(e, @company.users.first, "GstReportGenerationWorker").deliver
      raise e
    end  
  end

end
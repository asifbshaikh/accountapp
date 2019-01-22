class GstInvoiceDeleteWorker
  include Sidekiq::Worker

  def perform(company_id, invoice_id, invoice_date_str)
    Sidekiq.logger.info " parameters are company #{company_id} invoice_id #{invoice_id} invoice_date #{invoice_date_str}"
    @company = Company.find(company_id)
    begin
      #we need to delete from gstr_one table based on month from date
      invoice_date = Date.strptime(invoice_date_str,"%Y%m%d")
      invoice_month = invoice_date.month
      @gst_returns = @company.gst_returns.return_month(invoice_month)
      if @gst_returns.present?
        @gst_returns.gstr_one.remove_invoice(invoice_id)
      end
    rescue Exception => e
      Rails.logger.error e
      ErrorMailer.experror(e, @company.users.first, "GstInvoiceDeleteWorker").deliver
      raise e
    end  

  end

end

#This is a Sidekiq worker added for generating invoice details for gstr1 filing .
#assigning invoice classiifier for further process
#Author: Rohit Chandran
#Date: 25-07-2017 

class InvoiceFilerWorker 
  include Sidekiq::Worker

  # @queue = :product_imports_queue
  def perform(company_id, invoice_id)

    @company = Company.find(company_id)
    @invoice = @company.invoices.find(invoice_id)

    begin 
      Sidekiq.logger.debug "InvoiceFilerWorker::perform::begin for invoice #{@invoice.inspect}"
      #determine invoice date so we know which gstr1 we need to add this item
      invoice_month = @invoice.invoice_date.month
      @gst_returns = @company.gst_returns.return_month(invoice_month)
      if @gst_returns.present? && @gst_returns.gstr_one.present?
        @gst_returns.gstr_one.add_invoice(@invoice)
      end
    rescue Exception => e
      Sidekiq.logger.error e
      ErrorMailer.experror(e, @company.users.first, "InvoiceFilerWorker for invoice #{@invoice.id} and #{@invoice.invoice_number}").deliver
      #raise e
    end     
  end
end

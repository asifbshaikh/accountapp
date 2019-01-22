class InvoiceReportController < ApplicationController

def index
	 @accounts = Account.get_customer_accounts(@company.id) 
	 Rails.logger.debug "----------------------------------#{@accounts}" 
 if(params[:account_id].present?)
    @account = Account.find_by_id params[:account_id]
   end
    now = Time.zone.now.to_date
    @start_date = params[:start_date].blank? ? (now - 3.months) : params[:start_date].to_date
    @end_date = params[:end_date].blank? ? now : params[:end_date].to_date
    if @account.present?
   	  @invoices = Invoice.invoice_records(@account, @company, @start_date, @end_date)
    else
      @invoices = @company.invoices.by_invoice_date_range(@start_date, @end_date)
    end
    respond_to do |format|
      format.html
      format.xls
      format.pdf        
    end

  end

end

	
	


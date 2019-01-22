class DebtorAgingController < ApplicationController

  def index
    invoice = Invoice.where("invoice_status_id=? and company_id=? and total_amount >?",0,@company.id,0).first
    @account = Account.find_by_customer_id(params[:customer_id])
    @account_heads = AccountHead.get_customer_and_vendor_account_heads(@company.id)
    # @invoice = Invoice.where(:company_id => @company.id).order('invoice_date DESC')
    #naveent The company created date is not the correct start date. We have many customers who are entering past data.
    # naveent Don't retrieve all invoices, we are only interested in invoices that are not paid. Please see invoice statuses
    @start_date = params[:start_date].blank? ? (@company.activation_date) : params[:start_date].to_date
    @end_date = params[:end_date].blank? ? Time.zone.now.to_date : params[:end_date].to_date
    @branch_id = params[:branch_id].blank? ? @current_user.branch_id : params[:branch_id].to_i
    @customer_id = params[:customer_id].blank? ? "" : params[:customer_id].to_i
    if @customer_id.present?
      @invoice = Invoice.includes(:account).where("company_id=? and account_id=? and invoice_date BETWEEN ? AND ? and invoice_status_id=? and total_amount >?", @company.id,@account.id,@start_date,@end_date,0,0).order('invoice_date DESC')
    else
      @invoice = Invoice.includes(:account).where("company_id=? and invoice_date BETWEEN ? AND ? and invoice_status_id=? and total_amount >?", @company.id,@start_date,@end_date,0,0).order('invoice_date DESC')
    end
    respond_to do |format|
      format.html # index.html.erb
      format.xls
      format.json  {render :json => InvoiceDatatable.new(view_context, @company, @current_user, @financial_year) }
      format.pdf do
        pdf=DebtorAgingPdf.new(view_context, @invoice,@company, @start_date,@end_date)
        send_data pdf.render, :filename=>"debtor_aging.pdf", :disposition=>"inline", :type=>"application/pdf"
      end
    end
  end

end

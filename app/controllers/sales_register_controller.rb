class SalesRegisterController < ApplicationController

  def index
    @accounts = Account.get_customer_accounts(@company.id) #for filter
    if(params[:account_id].present?)
      @account = Account.find_by_id params[:account_id]
    end
    now = Time.zone.now.to_date
    @start_date = params[:start_date].blank? ? (now - 30.days) : params[:start_date].to_date
    @end_date = params[:end_date].blank? ? now : params[:end_date].to_date
    @branch_id = params[:branch_id].blank? ? @current_user.branch_id : params[:branch_id].to_i

    @invoices = Invoice.sales_register_records(params[:user_id], @current_user, @account, @company, @start_date, @end_date, @branch_id)
    respond_to do |format|
      format.html
      format.xls
      format.pdf do
        pdf = SalesRegisterReport.new(view_context, @invoices, @account, @company, @start_date, @end_date, @branch_id)
        send_data pdf.render, :filename=>"sales_register.pdf", :disposition=>"inline", :type=>"application/pdf"
      end
    end
  end

end

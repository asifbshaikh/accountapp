class PurchaseRegisterController < ApplicationController

  def index
    @accounts = Account.find_all_by_company_id_and_accountable_type_and_deleted(@company.id, ["SundryCreditor","SundryDebtor"], false)
    if(!params[:account_id].blank?)
      @account = Account.find_by_id params[:account_id].to_i
    end
    today = Time.zone.now.to_date
    @start_date = params[:start_date].blank? ? (today - 30.days) : params[:start_date].to_date
    @end_date = params[:end_date].blank? ? today : params[:end_date].to_date
    @branch_id = params[:branch_id].blank? ? @current_user.branch_id : params[:branch_id].to_i
    @include_line_items = params[:line_items].present? ? true : false
    @purchases = Purchase.purchase_register_records(@financial_year, @current_user, @account, @company, @start_date, @end_date, @branch_id)

    respond_to do |format|
      format.html
      format.xls
      format.pdf do
        pdf = PurchaseRegisterReport.new(view_context, @purchases, @account, @company, @start_date, @end_date, @branch_id, @include_line_items)
        send_data pdf.render, :filename=>"purchase_register.pdf", :disposition=>"inline", :type=>"application/pdf"
      end
    end
  end

end

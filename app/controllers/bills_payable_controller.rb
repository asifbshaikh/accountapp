class BillsPayableController < ApplicationController
  def index
    @accounts = TransactionType.fetch_to_accounts(@company.id, 'sales')
    unless @accounts.blank?
	  	@start_date = params[:start_date].blank? ? (Time.zone.now.to_date - 30.days) : params[:start_date].to_date
      @end_date = params[:end_date].blank? ? Time.zone.now.to_date : params[:end_date].to_date
      @branch_id = params[:branch_id].blank? ? @current_user.branch_id : params[:branch_id].to_i
			@account=@company.accounts.find_by_id(params[:account_id].to_i)
      
      @purchases = @company.purchases.by_status(0).by_vendor(params[:account_id]).by_date_range(@start_date, @end_date)
      @purchases = @purchases.by_branch_id(@branch_id) unless @current_user.owner? && @branch_id.blank?
    end
    prawnto :filename => "outstanding_payment.pdf"
  end
end
class PurchaseSettlementController < ApplicationController
  def index
		@start_date = params[:start_date].blank? ? (Time.zone.now.to_date - 30.days) : params[:start_date].to_date
    @end_date = params[:end_date].blank? ? Time.zone.now.to_date : params[:end_date].to_date
    @branch_id = params[:branch_id].blank? ? @current_user.branch_id : params[:branch_id].to_i
		@purchases = @company.purchases.by_status(3).by_vendor(params[:account_id]).by_settlement_date_range(@start_date,@end_date+1.days)
		@purchases = @purchases.by_branch_id(@branch_id) unless @current_user.owner? && @branch_id.blank?
		@accounts = Account.get_customer_vendor_accounts(@company.id)
		@account =@company.accounts.find_by_id(params[:account_id])
		respond_to do |format|
			format.html
			format.xls
			format.pdf do
				pdf = PurchaseSettlementPdf.new(view_context, @company, @purchases, @start_date, @end_date, @branch_id, @accounts, @account)
				send_data pdf.render, :filename=>"stock_summary.pdf", :disposition=>"inline", :type=>"application/pdf"
			end
		end
  end

end

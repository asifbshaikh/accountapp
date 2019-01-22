class InvoiceSettlementController < ApplicationController
	def index
		# @invoices = Invoice.where(:company_id => @company.id,:invoice_status_id => 3)
		@start_date = params[:start_date].blank? ? (Time.zone.now.to_date - 30.days) : params[:start_date].to_date
    @end_date = params[:end_date].blank? ? Time.zone.now.to_date : params[:end_date].to_date
    @branch_id = params[:branch_id].blank? ? @current_user.branch_id : params[:branch_id].to_i
		@invoices = @company.invoices.by_status(3).by_customer(params[:account_id]).by_settlement_date_range(@start_date,@end_date+1.days)
		@invoices = @invoices.by_branch_id(@branch_id) unless @current_user.owner? && @branch_id.blank?
		@accounts = Account.get_customer_vendor_accounts(@company.id)
		@account =@company.accounts.find_by_id(params[:account_id])
	end
	
end

class BillsReceivableController < ApplicationController
  def index
    @accounts = TransactionType.fetch_to_accounts(@company.id, 'sales')
    unless @accounts.blank?
      @start_date = params[:start_date].blank? ? (Time.zone.now.to_date - 3.months) : params[:start_date].to_date
      @end_date = params[:end_date].blank? ? Time.zone.now.to_date : params[:end_date].to_date
      @branch_id = params[:branch_id].blank? ? @current_user.branch_id : params[:branch_id].to_i
		#[FIXME] Duplicate logic, needs to be moved into Account.rb without any duplicates
  	#	@account=@company.accounts.find_by_id(params[:account_id].to_i)
		#[FIXME] Duplicate logic, needs to be moved into invoice.rb without any duplicates
   		#@invoices = @company.invoices.by_status(0).by_cash_invoice(false).by_customer(params[:account_id]).by_date_range(@start_date, @end_date)
      if params[:account_id].present?
        @invoices = @company.invoices.includes(:account).by_cash_invoice(false).by_customer(params[:account_id]).
          by_invoice_date_range(@start_date, @end_date).where("invoice_status_id NOT IN (?)", 
          [Invoice::INVOICE_STATUS[:paid], Invoice::INVOICE_STATUS[:settled]]).order("invoice_date DESC")
      else
        @invoices = @company.invoices.includes(:account).by_cash_invoice(false).
          by_invoice_date_range(@start_date, @end_date).where("invoice_status_id NOT IN (?)", 
          [Invoice::INVOICE_STATUS[:paid], Invoice::INVOICE_STATUS[:settled]]).order("invoice_date DESC")
      end  
      @invoices = @invoices.by_branch_id(@branch_id) unless @current_user.owner? && @branch_id.blank?
    end
    prawnto :filename => "outstanding_receipts.pdf"
  end
end

class BillingHistoryController < ApplicationController
  skip_before_filter :company_active?
  def index
  	@page_name = 'History'
  	@menu = 'Billing'
  	@billing_invoices = @company.billing_invoices.page(params[:page]).per(20);
  end

  def show
  	@page_name = "View details"
  	@menu = 'Billing'
  	@billing_invoice = @invoice  = BillingInvoice.find(params[:id])
    @company = @company
  end

end

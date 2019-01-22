class CustomerStatementsController < ApplicationController
  def index
    start_date = params[:start_date].blank? ? @financial_year.start_date.to_date : params[:start_date].to_date
    end_date= params[:end_date].blank? ? Time.zone.now.end_of_month.to_date : params[:end_date].to_date
    @accounts = Account.get_customer_vendor_accounts(@company.id)
  	@customer = params[:account_id].blank? ? @accounts.first : @company.accounts.find_by_id(params[:account_id].to_i)
  	@invoices = Invoice.invoices_for_customer_as_of_date(@company, @customer.id, start_date, params[:end_date] )
  	@receipt_vouchers = ReceiptVoucher.receipts_for_customer_as_on_date(@company, @customer.id, start_date, params[:end_date])
    @journal_line_items = JournalLineItem.for_customer_as_on_date(@company, @customer.id, start_date, params[:end_date])
    @reimbursement_notes = ReimbursementNote.for_customer_as_on_date(@company, @customer.id, start_date, params[:end_date])
    @reimbursement_vouchers = ReimbursementVoucher.for_customer_as_on_date(@company, @customer.id, start_date, params[:end_date])
    @receipt_amount = 0
    #@opening_balance=@customer.get_opening_balance(@current_user, @company.id, @financial_year, start_date, @current_user.branch_id)
    #@closing_balance=@customer.get_closing_balance(@current_user, @company.id, @financial_year, params[:end_date], @current_user.branch_id)
    @opening_balance = @customer.opening_balance_on_date(start_date)
    @closing_balance = @customer.closing_balance_on_date(end_date)
    @receipt_vouchers.each do |rv|
      @receipt_amount += rv.foreign_currency? ? rv.amount*rv.exchange_rate : rv.amount
    end
    @invoiced_amount=0
    @invoices.each do |invoice|
      @invoiced_amount+=invoice.foreign_currency? ? invoice.total_amount*invoice.exchange_rate : invoice.total_amount
    end
    @currency = @company.currency_code
    respond_to do |format|
      format.html
      format.xls
      format.pdf do
        pdf = CustomerStatementPdf.new(view_context, @company, @current_user, @accounts, @customer, @invoices, @receipt_vouchers, @reimbursement_notes, @reimbursement_vouchers, @journal_line_items, @opening_balance, @closing_balance, @receipt_amount, @invoiced_amount, start_date, end_date)
        send_data pdf.render, :filename=>"customer_statement.pdf", :disposition=>"inline", :type=>'application/pdf'
      end
    end
  end

  def email_customer_statement
    start_date = params[:start_date].blank? ? @financial_year.start_date.to_date : params[:start_date].to_date
    end_date= params[:end_date].blank? ? Time.zone.now.end_of_month.to_date : params[:end_date].to_date
    @accounts = Account.get_customer_vendor_accounts(@company.id)
    @customer = params[:account_id].blank? ? @accounts.first : @company.accounts.find_by_id(params[:account_id].to_i)
    @invoices = Invoice.invoices_for_customer_as_of_date(@company, @customer.id, start_date, params[:end_date] )
    @receipt_vouchers = ReceiptVoucher.receipts_for_customer_as_on_date(@company, @customer.id, start_date, params[:end_date])
    @journal_line_items = JournalLineItem.for_customer_as_on_date(@company, @customer.id, start_date, params[:end_date])
    @receipt_amount = 0
    @reimbursement_notes = ReimbursementNote.for_customer_as_on_date(@company, @customer.id, start_date, params[:end_date])
    @reimbursement_vouchers = ReimbursementVoucher.for_customer_as_on_date(@company, @customer.id, start_date, params[:end_date])
    
    #@opening_balance=@customer.get_opening_balance(@current_user, @company.id, @financial_year, start_date, @current_user.branch_id)
    #@closing_balance=@customer.get_closing_balance(@current_user, @company.id, @financial_year, params[:end_date], @current_user.branch_id)
    @opening_balance = @customer.opening_balance_on_date(start_date)
    @closing_balance = @customer.closing_balance_on_date(end_date)

    @receipt_vouchers.each do |rv|
      @receipt_amount += rv.foreign_currency? ? rv.amount*rv.exchange_rate : rv.amount
    end
    @invoiced_amount=0
    @invoices.each do |invoice|
      @invoiced_amount+=invoice.foreign_currency? ? invoice.total_amount*invoice.exchange_rate : invoice.total_amount
    end
    pdf = CustomerStatementPdf.new(view_context, @company, @current_user, @accounts, @customer, @invoices, @receipt_vouchers, @reimbursement_notes, @reimbursement_vouchers, @journal_line_items, @opening_balance, @closing_balance, @receipt_amount, @invoiced_amount, start_date, end_date)
    attachment = pdf.render
    to_email = params[:email]
    cc = params[:email2]
    subject = params[:subject]
    text = params[:text]
    if !params[:email].blank?
      Email.send_customer_statement(attachment, @customer,@invoices,@receipt_vouchers, @balance_amount, @company, @current_user, subject, text, to_email,cc).deliver
      Customer.email_sending_action(request.remote_ip, 'sent',to_email,cc,@company.id,@current_user.id)
      flash[:success] = 'Email has been sent successfully.'
    else
      flash[:error]='Email can not be blank'
    end
  end
end

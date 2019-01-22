class CashBookController < ApplicationController
  def index
    @accounts = @company.get_accounts_of('Cash Accounts')
    # @account = Account.find params[:account_id] unless params[:account_id].blank?
    @account = params[:account_id].blank? ? @accounts.first : Account.find(params[:account_id])
    @start_date = params[:start_date].blank? ? (Time.zone.now.to_date - 30.days) : params[:start_date].to_date
    @end_date = params[:end_date].blank? ? Time.zone.now.to_date : params[:end_date].to_date
    @branch_id = params[:branch_id].blank? ? @current_user.branch_id : params[:branch_id].to_i
    @opening_balance = @account.opening_balance_on_date(@start_date)
    unless @accounts.blank?
      @ledgers = Ledger.get_cash_book_records(@company, @current_user, @account, @start_date, @end_date, @branch_id)
    end
   	# prawnto :filename => "cash_book.pdf"
  end
end

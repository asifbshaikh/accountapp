class BankBookController < ApplicationController
  def index
    @menu = "Reports"
    @page_name = "Bank Book"
    @accounts = @company.get_accounts_of('Bank Accounts')
    @account = (params[:account_id].nil?)? @accounts.first : @company.accounts.find(params[:account_id].to_i)
    @start_date = params[:start_date].blank? ? (Time.current.to_date - 3.months) : params[:start_date].to_date
    @end_date = params[:end_date].blank? ? Time.current.to_date : params[:end_date].to_date
    @branch_id = params[:branch_id].blank? ? @current_user.branch_id : params[:branch_id].to_i
    @opening_balance = @account.opening_balance_on_date(@start_date)
    @ledgers = Ledger.get_record(@start_date, @end_date, @branch_id, @financial_year, @current_user, @account)
    prawnto :filename => "bank_book.pdf"
  end
end

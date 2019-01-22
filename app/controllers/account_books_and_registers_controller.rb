class AccountBooksAndRegistersController < ApplicationController
  layout 'application'

  def reports

  end

  #This method displays the ledger of an account. If no account is selected
  #then the ledgers of the first accounts in the list are shown.
  def ledger
    @accounts = @company.accounts.valid_accounts
    @account = (params[:account_id].nil?)? @accounts.first : @accounts.find(params[:account_id])
    @start_date = params[:start_date].blank? ? @financial_year.start_date : params[:start_date].to_date
    @end_date = params[:end_date].blank? ? Time.current.to_date : params[:end_date].to_date
    @branch_id = params[:branch_id].blank? ? @current_user.branch_id : params[:branch_id].to_i
    @opening_balance = @account.opening_balance_on_date(@start_date)
    @ledgers = Ledger.get_record(@start_date, @end_date, @branch_id, @financial_year, @current_user, @account)
    respond_to do |format|
      format.html
      format.pdf
      format.xls
    end
    prawnto :filename => "ledger.pdf"
  end

end

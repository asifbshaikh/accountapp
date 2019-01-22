class SundryCreditorController < ApplicationController
  
  def index
    @accounts = Account.find_all_by_company_id_and_accountable_type(@company.id, 'SundryCreditor')
    @account = (params[:account_id].nil?)? @accounts.first : Account.find_by_id_and_company_id(params[:account_id].to_i, @company.id)
    @start_date = params[:start_date].blank? ? @financial_year.start_date : params[:start_date].to_date
    @end_date = params[:end_date].blank? ? Time.current.to_date : params[:end_date].to_date
    @branch_id = params[:branch_id].blank? ? @current_user.branch_id : params[:branch_id].to_i

    @ledgers = Ledger.get_record(@start_date, @end_date, @branch_id, @financial_year, @current_user, @account)
    prawnto :filename => "sundry_creditor.pdf"
  end
end
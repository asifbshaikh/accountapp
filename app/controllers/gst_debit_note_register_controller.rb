class GstDebitNoteRegisterController < ApplicationController
	def index
    @accounts = Account.find_all_by_company_id_and_accountable_type_and_deleted(@company.id, ["SundryCreditor","SundryDebtor"], false)

    @account = (params[:account_id].nil?)? @accounts.first : @company.accounts.find(params[:account_id])
    @start_date = params[:start_date].blank? ? @financial_year.start_date : params[:start_date].to_date
    @end_date = params[:end_date].blank? ? Time.current.to_date : params[:end_date].to_date
    @branch_id = params[:branch_id].blank? ? @current_user.branch_id : params[:branch_id].to_i

    @ledgers = Ledger.by_voucher("GstDebitNote").get_record(@start_date, @end_date, @branch_id, @financial_year, @current_user, @account)
 
    prawnto :filename => "gst_debit_note_register.pdf"
  end
end

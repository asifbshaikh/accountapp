class ReimbursementReportsController < ApplicationController

  def outstanding_report
    @accounts = TransactionType.fetch_from_accounts(@company.id, 'purchases')
    unless @accounts.blank?
    	@start_date = params[:start_date].blank? ? (Time.zone.now.to_date - 30.days) : params[:start_date].to_date
      @end_date = params[:end_date].blank? ? Time.zone.now.to_date : params[:end_date].to_date
      @branch_id = params[:branch_id].blank? ? @current_user.branch_id : params[:branch_id].to_i
      @reimbursement_notes = @company.reimbursement_notes.by_party(params[:account_id]).by_date_range(@start_date, @end_date).where(:submitted => false, :deleted => false)
    end
  end
end
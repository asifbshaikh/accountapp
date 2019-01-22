class TrialBalanceController < ApplicationController

  def index
    @start_date = params[:start_date].blank? ? @financial_year.start_date : params[:start_date].to_date
    @end_date = params[:end_date].blank? ? Time.zone.now.to_date : params[:end_date].to_date
    @account_heads = @company.account_heads.where(:parent_id => nil)
    logger.debug "Account #{Account.total_opening_balance(@company, @end_date)}"
    @opening_balance_difference = ((Account.total_opening_balance(@company, @end_date) + Product.opening_inventory_valuation(@company))) * -1
    @opening_inventory_valuation=Product.total_inventory_valuation(@company, @start_date - 1.days)
    @closing_inventory_valuation=Product.total_inventory_valuation(@company, @end_date)

    respond_to do |format|
      format.html
      format.xls do
        response.headers['Content-Disposition'] = 'attachment; filename="' + "trial_balance_#{@end_date}" + '.xls"'
      end
      format.pdf do
        prawnto :filename => "trial_balance_#{@end_date}"+".pdf"
      end
    end
  end

  def group_summary_report
    @start_date = params[:start_date].blank? ? @financial_year.start_date : params[:start_date].to_date
    @end_date = params[:end_date].blank? ? @financial_year.end_date : params[:end_date].to_date
    branch_id = params[:branch_id].blank? ? @current_user.branch_id : params[:branch_id].to_i
    @transaction_type = params[:transaction_type] unless params[:transaction_type].blank?
    account_head=AccountHead.find(params[:id].to_i) unless params[:id].blank?
    @opening_balance_difference = 0
    if account_head.blank?
      @accounts = Account.where(:company_id=> @company.id, :accountable_type => @transaction_type, :deleted=> false)
    else
      @accounts=@company.accounts.by_parent(account_head.id)
    end
    respond_to do |format|
      format.html
      format.xls
      format.pdf do
        prawnto :filename => "group_summary_report.pdf"
      end
    end
  end

end

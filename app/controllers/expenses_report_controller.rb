class ExpensesReportController < ApplicationController
	def index
    respond_to do |format|
      format.html # index.html.erb
      format.json  {render :json => ExpenseDatatable.new(view_context, @company, @current_user, @financial_year) }
    end
  end
  
  def expenses_report
    @status_id = params[:status].to_s
    if @status_id == "Paid"
      @status_id=1
    elsif @status_id=="Unpaid"
      @status_id=0
    else
      @status_id=2 
    end   
   
    @start_date = params[:start_date].blank? ? (Time.zone.now.to_date - 3.months) : params[:start_date].to_date
    @end_date = params[:end_date].blank? ? Time.zone.now.to_date : params[:end_date].to_date
    @branch_id = params[:branch_id].blank? ? @current_user.branch_id : params[:branch_id].to_i
    if @status_id==2
      @expenses = Expense.where("company_id=? and expense_date BETWEEN ? AND ? ", @company.id,@start_date,@end_date).order("expense_date ASC") 
    else
      @expenses = Expense.where("company_id=? and status_id=? and expense_date BETWEEN ? AND ? ", @company.id,@status_id,@start_date,@end_date).order("expense_date ASC")
    end
  end

end

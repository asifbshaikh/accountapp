class CreditExpenseReportsController < ApplicationController
  def index
  	@accounts = Account.find_all_by_company_id_and_accountable_type_and_deleted(@company.id, ["SundryCreditor","SundryDebtor"], false)
  	@account=@company.accounts.find_by_id(params[:account_id])
  	@expenses = @company.expenses.records_by_filter(params, @current_user)
  	respond_to do |format|
  		format.html
  		format.xls
  		format.pdf do 
  			pdf=ExpenseReportPdf.new(view_context, @expenses, @account, @company)
  			send_data pdf.render, :filename=>"outstanding_expenses.pdf", :disposition=>"inline", :type=>"application/pdf"
  		end
  	end
  end
end

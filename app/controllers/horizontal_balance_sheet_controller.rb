class HorizontalBalanceSheetController < ApplicationController

  def index
    #@account_heads = @company.account_heads.roots
    @end_date = params[:balance_sheet_date].blank? ? Time.zone.now.to_date : params[:balance_sheet_date].to_date
    @branch = params[:branch_id].blank? ? @current_user.branch : @company.branches.find(params[:branch_id].to_i)

    @balance_sheet = BalanceSheet.new(@company, @financial_year, @current_user, @end_date, @branch )

    respond_to do |format|
      format.html
      format.xls
      format.pdf do
        prawnto :filename => "balance_sheet.pdf"
      end
    end
  end
end

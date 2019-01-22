class HorizontalProfitAndLossController < ApplicationController
  def index
    start_date = params[:start_date].blank? ? @financial_year.start_date : params[:start_date].to_date
  	end_date = params[:end_date].blank? ? Time.zone.now.to_date : params[:end_date].to_date

    @profit_loss = ProfitLoss.new(@company, @financial_year, start_date, end_date)

    @net_profit = @profit_loss.profit_and_loss
    @opening_stock_valuation = @profit_loss.opening_stock_valuation

    @direct_expense_with_sub_heads=AccountHead.fetch_direct_expenses_with_children(@company.id)
    @desh_hash=Hash.new
    @direct_expense_with_sub_heads.each {|head| @desh_hash[head.id]=head.get_linked_account_balance(@current_user, start_date, end_date, nil)}


    @indirect_expense_with_sub_heads = AccountHead.fetch_indirect_expenses_with_children(@company.id)
    @iewsh_hash=Hash.new
    @indirect_expense_with_sub_heads.each{|head| @iewsh_hash[head.id]=head.get_linked_account_balance(@current_user, start_date, end_date, nil)}

    @direct_income_with_sub_heads = AccountHead.fetch_direct_income_with_children(@company.id)
    @diwsh_hash=Hash.new
    @direct_income_with_sub_heads.each {|head| @diwsh_hash[head.id]=head.get_linked_account_balance(@current_user, start_date, end_date, nil)}

    @indirect_income_with_sub_heads=AccountHead.fetch_indirect_income_with_children(@company.id)
    @iiwsh_hash=Hash.new
    @indirect_income_with_sub_heads.each {|head| @iiwsh_hash[head.id]=head.get_linked_account_balance(@current_user, start_date, end_date, nil)}




    respond_to do |format|
      format.pdf do
        pdf=ProfitLossPdf.new(view_context, @company, end_date, nil,
          @opening_stock_valuation, @direct_expense_with_sub_heads, @desh_hash, @indirect_expense_with_sub_heads, @iewsh_hash,
          @direct_income_with_sub_heads, @diwsh_hash, @indirect_income_with_sub_heads, @iiwsh_hash,
          @profit_loss.inventory_valuation, @net_profit, @profit_loss.total_expenses, @profit_loss.total_income)
        send_data pdf.render, :filename=>"profit_and_loss_#{end_date}.pdf", :disposition=>"inline"
      end
      format.html
      format.xls do
        response.headers['Content-Disposition'] = 'attachment; filename="' + "profit_and_loss_#{end_date}.pdf" + '.xls"'
        render "index.xls.erb"
      end
    end

  end
end

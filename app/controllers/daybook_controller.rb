class DaybookController < ApplicationController
  def index
    @menu = "Reports"
    @page_name = "Day Book"
    @accounts = @company.accounts.order(:name)
    unless @accounts.blank?
      @ledgers = Ledger.get_daybook_record(params, @company, @current_user)
    end
    prawnto :filename => "day_book.pdf"
  end

end

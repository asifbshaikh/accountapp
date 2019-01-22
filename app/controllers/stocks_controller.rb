class StocksController < ApplicationController
  def index
    @menu = 'inventory'
    @page_name = 'stocks'
    @stocks = Stock.find_by_company_id(@company.id)

    respond_to do |format|
      format.html
    end
  end

end

class ProductUpdatesController < ApplicationController

  def index
    @product_updates = ProfitbooksWorkstream.published_updates.page(params[:page]).per(5)
    respond_to do |format|
      format.html # index.html.erb
    end
  end

end

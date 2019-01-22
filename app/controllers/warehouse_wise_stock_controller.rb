class WarehouseWiseStockController < ApplicationController

  def index
    @branch_id = params[:branch_id].blank? ? @current_user.branch_id : params[:branch_id].to_i
    @warehouse_id = params[:warehouse_id]
    @stocks = Stock.get_warehouse_wise_stock(params, @company, @current_user, @branch_id)
    #prawnto :filename => "#{@company.label.warehouse_label}"+" "+ "Wise Stock.pdf"
  end

  def inventory_valuation
    @branch_id = params[:branch_id].blank? ? @current_user.branch_id : params[:branch_id].to_i
    @date = Time.zone.now
  	#@stocks = Stock.get_warehouse_wise_stock(params, @company, @current_user, @branch_id)
    @products = @company.products.where(:inventory => true)
  end

end

class LowStockController < ApplicationController
  def index
    @menu = "Inventory Reports"
    @page_name = "Low stock register"
    @products = Product.get_low_stock(params, @company)
    prawnto :filename => "low_stock_register.pdf"
  end

end

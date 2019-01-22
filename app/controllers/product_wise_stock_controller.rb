class ProductWiseStockController < ApplicationController
  def index
    @menu = "Inventory Reports"
    @page_name = "Product Wise Stock"
    @products = @company.products.where(:inventory=>true)
    prawnto :filename => "product_wise_stock_report.pdf"
  end

end

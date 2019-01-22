class StockMovementController < ApplicationController
  def index
    @menu = "Inventory Reports"
    @page_name = "Stock Movement Report"
    @products = @company.products.where(:type => ['SalesItem', 'PurchaseItem', 'ResellerItem'])
    prawnto :filename => "stock_movement_report.pdf"
  end

end

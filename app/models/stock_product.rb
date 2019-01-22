class StockProduct

  #This class is a decorator over the Product model.
  #The additional attributes defined are for Stock Summary reports
  def initialize(product, start_date, end_date, branch_id)
    @product = product
    @start_date = start_date
    @end_date = end_date
    @branch_id = branch_id
  end

  def product
    @product
  end

  def opening_stock_quantity
    @opening_stock_qty ||= @product.opening_stock_on_date(@start_date, @branch_id)
  end

  def opening_stock_valuation
    #@opening_stock_amt ||= @product.opening_stock_amount_on_date(@start_date, @branch_id)
    @opening_stock_amt ||= @product.inventory_valuation(@start_date)
  end

  def purchase_amount
    @purchase_amt ||= fetch_purchase_amount
  end

  def purchase_quantity
    @purchase_qty ||= fetch_purchase_quantity
  end

  def purchase_return_quantity
    @purchase_retrn_qty ||= fetch_purchase_return_quantity
  end

  def average_purchase_price
    @average_purchase_price ||= average_price(@purchase_amt, @purchase_qty)
  end

  def stock_received_quantity
    @stock_received_qty ||= fetch_stock_received_quantity
  end

  def stock_wasted_quantity
    @stock_wasted_qty ||= fetch_stock_wasted_quantity
  end

  def stock_wasted_amount
    @stock_wasted_amount ||= fetch_stock_wasted_amount
  end

  def stock_received_amount
    @stock_received_amt ||= fetch_stock_received_amount
  end

  def stock_issued_quantity
    @stock_issued_qty ||= fetch_stock_issued_quantity
  end

  def stock_issued_amount
    @stock_issued_amt ||= fetch_stock_issued_amount
  end


  def sales_quantity
    @sales_qty ||= fetch_sales_quantity
  end

  def sales_amount
    @sales_amt ||= fetch_sales_amount
  end

  def average_sales_price
    @average_sales_price = average_price(@sales_amt, @sales_qty)
  end

  def sales_return_quantity
    @sales_retrn_qty ||= fetch_sales_return_quantity
  end

  def sales_return_amount
    @sales_retrn_amount ||= fetch_sales_return_amount
  end

#This method has been modified to calculate items in hand for a product in Product Statement View
#and corresponding methods are changed in product_statement.html.erb, product_statement.xls.erb &
#product_statement_pdf.rb
#Author : Ashish Wadekar
#Date : 11th August 2016
  def net_quantity
    @net_qty ||= (opening_stock_quantity + purchase_quantity + stock_received_quantity + sales_return_quantity) - (sales_quantity + stock_issued_quantity + fetch_stock_wasted_quantity + purchase_return_quantity)
  end

  def inventory_valuation
    @net_amt ||= @product.inventory_valuation(@end_date)
  end

  private

    # The below two methods are written to avoid calling the query twice
    # Both the instance variables are populated in the same method call irrespective
    # of which is called first
    def fetch_purchase_amount
      result = fetch_purchase_details
      @purchase_quantity = result[0].purchase_quantity.blank? ? 0 : result[0].purchase_quantity
      @purchase_amount = result[0].purchase_amount.blank? ? 0:result[0].purchase_amount
    end

    def fetch_purchase_quantity
      result = fetch_purchase_details
      @purchase_amount = result[0].purchase_amount.blank? ? 0:result[0].purchase_amount
      @purchase_quantity = result[0].purchase_quantity.blank? ? 0 : result[0].purchase_quantity
    end

    def fetch_purchase_details
      product.purchase_quantity_amount_in_period(@start_date, @end_date, @branch_id)
    end


    def fetch_purchase_return_amount
      result = fetch_purchase_return_details
      @purchase_retrn_qty = result[0].purchase_return_quantity.blank? ? 0:result[0].purchase_return_quantity
      @purchase_retrn_amount = result[0].purchase_return_amount.blank? ? 0:result[0].purchase_return_amount

    end

    def fetch_purchase_return_quantity
      result = fetch_purchase_return_details
      @purchase_retrn_amount = result[0].purchase_return_amount.blank? ? 0:result[0].purchase_return_amount
      @purchase_retrn_qty = result[0].purchase_return_quantity.blank? ? 0:result[0].purchase_return_quantity
    end

    def fetch_purchase_return_details
      product.purchase_return_quantity_amount_in_period(@start_date, @end_date, @branch_id)
    end


    def fetch_stock_received_quantity
      stock_received = fetch_stock_received_details
      @stock_received_amt = stock_received[0].received_amount.blank? ? 0:stock_received[0].received_amount
      stock_received[0].received_quantity.blank? ? 0:stock_received[0].received_quantity
    end

     def fetch_stock_wasted_quantity
      stock_wasted = fetch_stock_wasted_details
      @stock_wasted_qty = stock_wasted[0].wasted_quantity.blank? ? 0:stock_wasted[0].wasted_quantity
      stock_wasted[0].wasted_quantity.blank? ? 0:stock_wasted[0].wasted_quantity
    end

    def fetch_stock_received_amount
      stock_received = fetch_stock_received_details
      @stock_received_qty = stock_received[0].received_quantity.blank? ? 0:stock_received[0].received_quantity
      stock_received[0].received_amount.blank? ? 0:stock_received[0].received_amount
    end

    def fetch_stock_wasted_amount
      stock_wasted = fetch_stock_wasted_details
      @stock_wasted_amt = stock_wasted[0].wasted_amount.blank? ? 0:stock_wasted[0].wasted_amount
      stock_wasted[0].wasted_amount.blank? ? 0:stock_wasted[0].wasted_amount
    end

    def fetch_stock_received_details
      product.production_stock_received_qty_amt_in_period(@start_date, @end_date, @branch_id)
    end

    def fetch_stock_wasted_details
      product.production_stock_wasted_qty_amt_in_period(@start_date, @end_date, @branch_id)
    end

    def fetch_stock_issued_quantity
      stock_issued = fetch_stock_issued_details
      stock_issued[0].issued_quantity.blank? ? 0:stock_issued[0].issued_quantity
    end

    def fetch_stock_issued_amount
      @stock_issued_qty = fetch_stock_issued_quantity
      @stock_issued_qty * @average_purchase_price
    end

    def fetch_stock_issued_details
      product.production_stock_issued_qty_in_period(@start_date, @end_date, @branch_id)
    end

    def average_price(total_amount, total_quantity)
      # ((total_amount == 0 || total_quantity == 0) ? 0.00 : (total_amount/ total_quantity))
    if (total_amount == 0 || total_quantity == 0)
     return 0.00 
    elsif (total_amount.present? && total_quantity.present?)
      return (total_amount/ total_quantity)
     else
      return 0.00
     end
    end

    def fetch_sales_quantity
      sales_data = fetch_sales_details
      @sales_amt = sales_data[0].invoice_amount.blank? ? 0:sales_data[0].invoice_amount
      sales_data[0].invoice_quantity.blank? ? 0 : sales_data[0].invoice_quantity
    end

    def fetch_sales_amount
      sales_data = fetch_sales_details
      @sales_qty = sales_data[0].invoice_quantity.blank? ? 0 : sales_data[0].invoice_quantity
      sales_data[0].invoice_amount.blank? ? 0:sales_data[0].invoice_amount
    end

    def fetch_sales_details
      product.sales_quantity_amount_in_period(@start_date, @end_date, @branch_id)
    end

    def fetch_sales_return_quantity
      sales_return_data = fetch_sales_return_details
      @sales_return_amt = sales_return_data[0].total_stk_retrn_amount.blank? ? 0:sales_return_data[0].total_stk_retrn_amount
      sales_return_data[0].total_stk_retrn_qty.blank? ? 0 : sales_return_data[0].total_stk_retrn_qty
    end

    def fetch_sales_return_amount
      invoice_returns = fetch_sales_return_details
      @sales_return_qty = invoice_returns[0].total_stk_retrn_amount.blank? ? 0 : invoice_returns[0].total_stk_retrn_amount
      invoice_returns[0].total_stk_retrn_qty.blank? ? 0 : invoice_returns[0].total_stk_retrn_qty
    end

    def fetch_sales_return_details
      product.sales_return_quantity_amount_in_period(@start_date, @end_date, @branch_id)
    end


end

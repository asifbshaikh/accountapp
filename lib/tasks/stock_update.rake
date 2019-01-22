##########################################################################
## Author : Rohit Chandran
## Created On 7th March
## Updated On 18th March 
##########################################################################



namespace :stock_update do

  task :for_company => :environment do
    @company = Company.find_by_id(966)
    @products= @company.products.where(:inventory=> true)
    @warehouses =@company.warehouses
    start_date = @company.financial_years.first.start_date
    end_date = Time.zone.now.to_date 
    branch_id = nil
    puts "*************************************************************"
    puts "Product\tWarehouse\tQuantity"
    @products.each do |product|
    @warehouse_total=0
    @warehouse_id =[]
    @warehouses.each do |warehouse|
      @warehouse_id << warehouse.id
      quantity=calculate_remaining_stock(start_date, end_date, branch_id,warehouse.id,product,@company.id)
            puts "#{product.name}\t#{warehouse.id}\t#{quantity}"
            stock = Stock.find_by_product_id_and_warehouse_id(product.id, warehouse.id)
            if stock.present? && stock.quantity != quantity 
              update_stock_entries(quantity,stock)
            end
            
            @warehouse_total+=quantity    
      end
      puts "Total Quantity for #{product.name} as per ware house wise stock  --- #{@warehouse_total}-----------\n" 
      total_quantity = calculate_remaining_stock(start_date, end_date, branch_id,nil,product,@company.id)
      puts "Total Quantity for #{product.name} as per stock summary --- #{total_quantity}-----------\n" 
      puts "Difference warehousewise - stock summary --- #{@warehouse_total-total_quantity}-----------\n" 
      if @warehouse_total != total_quantity
        puts "Missing Quantity details in SWD #{missing_sales_stock(product,@company.id,@warehouse_id)}"
        puts "Missing Quantity details in PWD #{missing_purchase_stock(product,@company.id,@warehouse_id)}"
      end
    puts "*****************************************************************"
    end
  end

def missing_sales_stock(product,company_id,warehouse_id)
      start_date = @company.financial_years.first.start_date
      end_date = Time.zone.now.to_date 
      branch_id = nil
      in_warehouse_wise = product.invoice_line_items.select("sum(sales_warehouse_details.quantity) as invoice_quantity, sum(invoice_line_items.amount) as invoice_amount").joins(:invoice).joins(:sales_warehouse_details)
      .where(:invoices =>{:company_id=> company_id, :deleted => false, :invoice_status_id => [0,2,3,4], :invoice_date => start_date..end_date, :branch_id => branch_id},:sales_warehouse_details =>{:warehouse_id => warehouse_id})
      in_stock_summary = product.invoice_line_items.select("sum(quantity) as invoice_quantity, sum(amount) as invoice_amount").joins(:invoice)
      .where(:invoices =>{:company_id=> company_id, :deleted => false, :invoice_status_id => [0,2,3,4], :invoice_date => start_date..end_date, :branch_id => branch_id})
      in_warehouse_wise_item = product.invoice_line_items.select("invoice_line_items.id").joins(:invoice).joins(:sales_warehouse_details)
      .where(:invoices =>{:company_id=> company_id, :deleted => false, :invoice_status_id => [0,2,3,4], :invoice_date => start_date..end_date, :branch_id => branch_id},:sales_warehouse_details =>{:warehouse_id => warehouse_id})
      in_stock_summary_item = product.invoice_line_items.select("invoice_line_items.id").joins(:invoice)
      .where(:invoices =>{:company_id=> company_id, :deleted => false, :invoice_status_id => [0,2,3,4], :invoice_date => start_date..end_date, :branch_id => branch_id})
      puts "&&&&&&&&&&#{find_the_difference(in_warehouse_wise_item,in_stock_summary_item)}"
      missing_quantity_in_swd = in_warehouse_wise[0].invoice_quantity.to_f - in_stock_summary[0].invoice_quantity.to_f  
      missing_quantity_in_swd 
end

def missing_purchase_stock(product,company_id,warehouse_id)
      start_date = @company.financial_years.first.start_date
      end_date = Time.zone.now.to_date 
      branch_id = nil
      in_warehouse_wise = product.purchase_line_items.select("sum(purchase_warehouse_details.quantity) as purchase_quantity, sum(purchase_line_items.amount) as purchase_amount").joins(:purchase).joins(:purchase_warehouse_details)
      .where(:purchases =>{:company_id=> company_id, :status_id => [0,1,3], :record_date => start_date..end_date, :branch_id => branch_id},:purchase_warehouse_details =>{:warehouse_id => warehouse_id})
      in_stock_summary = product.purchase_line_items.select("sum(quantity) as purchase_quantity, sum(amount) as purchase_amount").joins(:purchase)
      .where(:purchases =>{:company_id=> company_id, :status_id => [0,1,3], :record_date => start_date..end_date, :branch_id => branch_id})
      in_warehouse_wise_items = product.purchase_line_items.select("purchase_line_items.id").joins(:purchase).joins(:purchase_warehouse_details)
      .where(:purchases =>{:company_id=> company_id, :status_id => [0,1,3], :record_date => start_date..end_date, :branch_id => branch_id},:purchase_warehouse_details =>{:warehouse_id => warehouse_id})
      in_stock_summary_items = product.purchase_line_items.select("purchase_line_items.id").joins(:purchase)
      .where(:purchases =>{:company_id=> company_id, :status_id => [0,1,3], :record_date => start_date..end_date, :branch_id => branch_id})
      missing_quantity_in_pwd = in_warehouse_wise[0].purchase_quantity.to_f - in_stock_summary[0].purchase_quantity.to_f  
      missing_quantity_in_pwd 
end

def update_stock_entries(quantity,stock_item)

  puts "Updating stock entry for #{stock_item.id}"
  stock_item.update_column(:quantity,quantity)
end


def find_the_difference(in_warehouse_wise,in_stock_summary)
  stock_item =[]
  warehouse_item = []
  in_warehouse_wise.each do |line_item|
    warehouse_item << line_item.id
  end

  in_stock_summary.each do |line_item|
    stock_item << line_item.id
  end

  ids = in_warehouse_wise.map{|x| x.id}
  difference= in_stock_summary.reject{|x| ids.include? x.id}
  puts "list of missing line items #{difference}"
  puts "Number of insertions needed #{difference.count}"
  puts "Input warehouse ID"
  warehouse_id= 944
  difference.each do |difference|
    line_item =  InvoiceLineItem.find_by_id(difference)
     swd= SalesWarehouseDetail.new(:invoice_line_item_id => line_item.id,:warehouse_id => warehouse_id, :quantity => line_item.quantity ,:product_id => line_item.product_id)
    swd.save!
  end
   difference    
end


  def calculate_remaining_stock(start_date, end_date, branch_id,warehouse_id,product,company_id)
          opening_stock_quantity= opening_stock_on_date(start_date,end_date,branch_id,warehouse_id,product)
          purchase_quantity = purchase_quantity_amount_in_period(start_date, end_date, branch_id,warehouse_id,product,company_id)
          stock_received_quantity = production_stock_received_qty_amt_in_period(start_date, end_date, branch_id,warehouse_id,product,company_id)
          sales_return_quantity = sales_return_quantity_amount_in_period(start_date, end_date, branch_id,warehouse_id,product,company_id)
          received_from_other_warehouse = stock_received_quantity_in_period(start_date, end_date, branch_id,warehouse_id,product,company_id)
          sales_quantity = sales_quantity_amount_in_period(start_date, end_date, branch_id,warehouse_id,product,company_id)
          stock_issued_quantity = production_stock_issued_qty_in_period(start_date, end_date, branch_id,warehouse_id,product,company_id)
          fetch_stock_wasted_quantity = production_stock_wasted_qty_amt_in_period(start_date, end_date, branch_id,warehouse_id,product,company_id)
          purchase_return_quantity = purchase_return_quantity_amount_in_period(start_date, end_date, branch_id,warehouse_id,product,company_id)
          transfered_to_other_warehouse = stock_transfered_quantity_in_period(start_date, end_date, branch_id,warehouse_id,product,company_id)
          if warehouse_id.blank?
          quantity =(opening_stock_quantity + purchase_quantity[0].purchase_quantity.to_f +
          stock_received_quantity[0].received_quantity.to_f + sales_return_quantity[0].total_stk_retrn_qty.to_f) - (sales_quantity[0].invoice_quantity.to_f + stock_issued_quantity[0].issued_quantity.to_f +
          fetch_stock_wasted_quantity[0].wasted_quantity.to_f +
          purchase_return_quantity[0].purchase_return_quantity.to_f)

          else
          quantity =(opening_stock_quantity + purchase_quantity[0].purchase_quantity.to_f +
          stock_received_quantity[0].received_quantity.to_f + sales_return_quantity[0].total_stk_retrn_qty.to_f+
          received_from_other_warehouse[0].total_received_qty.to_f) - (sales_quantity[0].invoice_quantity.to_f + stock_issued_quantity[0].issued_quantity.to_f +
          fetch_stock_wasted_quantity[0].wasted_quantity.to_f +
          purchase_return_quantity[0].purchase_return_quantity.to_f+transfered_to_other_warehouse[0].total_transfered_qty.to_f)
          end 
  end

  def opening_stock_on_date(given_date,end_date, branch_id,warehouse_id,product)
    quantity=0
    opening_stock_quantity = get_opening_stock_warehouse(warehouse_id,product) 
    opening_stock_quantity
  end

##################### opening Stock #############################
  def get_opening_stock_warehouse(warehouse_id,product)
    if warehouse_id.blank?
      product.stocks.sum(:opening_stock)
    else
    product.stocks.where(:warehouse_id=> warehouse_id).sum(:opening_stock)
    end
  end

###################################################################

############# Inward Stock ########################################

   def purchase_quantity_amount_in_period(start_date, end_date, branch_id,warehouse_id,product,company_id)
    if warehouse_id.blank?
    purchases = product.purchase_line_items.select("sum(quantity) as purchase_quantity, sum(amount) as purchase_amount").joins(:purchase)
      .where(:purchases =>{:company_id=> company_id, :status_id => [0,1,3], :record_date => start_date..end_date, :branch_id => branch_id})
    else
       purchases = product.purchase_line_items.select("sum(purchase_warehouse_details.quantity) as purchase_quantity, sum(purchase_line_items.amount) as purchase_amount").joins(:purchase).joins(:purchase_warehouse_details)
      .where(:purchases =>{:company_id=> company_id, :status_id => [0,1,3], :record_date => start_date..end_date, :branch_id => branch_id},:purchase_warehouse_details =>{:warehouse_id => warehouse_id})
      purchases
    end
  end

  def production_stock_received_qty_amt_in_period(start_date, end_date, branch_id,warehouse_id,product,company_id)
    if warehouse_id.blank?
      stock_receipt_vouchers = product.stock_receipt_line_items.select("sum(quantity) as received_quantity, sum(unit_rate*quantity) as received_amount").joins(:stock_receipt_voucher)
      .where(:stock_receipt_vouchers =>{:company_id=> company_id, :voucher_date => start_date..end_date, :branch_id => branch_id})
    else
    stock_receipt_vouchers = product.stock_receipt_line_items.select("sum(quantity) as received_quantity, sum(unit_rate*quantity) as received_amount").joins(:stock_receipt_voucher)
      .where(:stock_receipt_vouchers =>{:company_id=> company_id, :voucher_date => start_date..end_date, :branch_id => branch_id,:warehouse_id => warehouse_id})
    end
  end

   def sales_return_quantity_amount_in_period(start_date, end_date, branch_id,warehouse_id,product,company_id)
    if warehouse_id.blank?
    invoice_returns = product.invoice_return_line_items.
      select(" sum(quantity * unit_rate) as total_stk_retrn_amount, sum(quantity) as total_stk_retrn_qty").
      joins(:invoice_return).
      where(:invoice_returns => {:company_id=> company_id, :record_date => start_date..end_date, :branch_id => branch_id})
    else
      invoice_returns = product.invoice_return_line_items.
      select(" sum(quantity * unit_rate) as total_stk_retrn_amount, sum(quantity) as total_stk_retrn_qty").
      joins(:invoice_return).
      where(:invoice_returns => {:company_id=> company_id, :record_date => start_date..end_date, :branch_id => branch_id,:warehouse_id=>warehouse_id})
    end
  end

  def stock_received_quantity_in_period(start_date, end_date, branch_id,warehouse_id,product,company_id)
    stock_transfer= product.stock_transfer_line_items.
      select("sum(transfer_quantity) as total_received_qty").
      joins(:stock_transfer_voucher).
      where(:stock_transfer_vouchers => {:company_id=> company_id, :voucher_date => start_date..end_date, :branch_id => branch_id},:stock_transfer_line_items => {:destination_warehouse_id => warehouse_id})
  end
  #######################################################################

  ################### Outward Stock #####################################

  def sales_quantity_amount_in_period(start_date, end_date, branch_id,warehouse_id,product,company_id)
    if warehouse_id.blank?
    sales = product.invoice_line_items.select("sum(quantity) as invoice_quantity, sum(amount) as invoice_amount").joins(:invoice)
      .where(:invoices =>{:company_id=> company_id, :deleted => false, :invoice_status_id => [0,2,3,4], :invoice_date => start_date..end_date, :branch_id => branch_id})
    else

       sales = product.invoice_line_items.select("sum(sales_warehouse_details.quantity) as invoice_quantity, sum(invoice_line_items.amount) as invoice_amount").joins(:invoice).joins(:sales_warehouse_details)
      .where(:invoices =>{:company_id=> company_id, :deleted => false, :invoice_status_id => [0,2,3,4], :invoice_date => start_date..end_date, :branch_id => branch_id},:sales_warehouse_details =>{:warehouse_id => warehouse_id})
    end
  end

  def production_stock_issued_qty_in_period(start_date, end_date, branch_id,warehouse_id,product,company_id)
    if warehouse_id.blank?
    stock_issue_vouchers = product.stock_issue_line_items.select("sum(quantity) as issued_quantity").joins(:stock_issue_voucher)
      .where(:stock_issue_vouchers =>{:company_id=> company_id, :voucher_date => start_date..end_date, :branch_id => branch_id})
    else
        stock_issue_vouchers = product.stock_issue_line_items.select("sum(quantity) as issued_quantity").joins(:stock_issue_voucher)
      .where(:stock_issue_vouchers =>{:company_id=> company_id, :voucher_date => start_date..end_date, :branch_id => branch_id,:warehouse_id=>warehouse_id})
    end
  end

  def production_stock_wasted_qty_amt_in_period(start_date, end_date, branch_id,warehouse_id,product,company_id)
    if warehouse_id.blank?
    stock_wastage_vouchers = product.stock_wastage_line_items.select("sum(quantity) as wasted_quantity").joins(:stock_wastage_voucher)
      .where(:stock_wastage_vouchers =>{:company_id=> company_id, :voucher_date => start_date..end_date, :branch_id => branch_id})
    else
       stock_wastage_vouchers = product.stock_wastage_line_items.select("sum(quantity) as wasted_quantity").joins(:stock_wastage_voucher)
      .where(:stock_wastage_vouchers =>{:company_id=> company_id, :voucher_date => start_date..end_date, :branch_id => branch_id,:warehouse_id=>warehouse_id})
    end
  end

  def purchase_return_quantity_amount_in_period(start_date, end_date, branch_id,warehouse_id,product,company_id)
    if warehouse_id.blank?
    purchase_retrn_qty =product.purchase_return_line_items.select("sum(quantity) as purchase_return_quantity, sum(amount) as purchase_return_amount").joins(:purchase_return)
      .where(:purchase_returns => {:company_id => company_id, :record_date => start_date..end_date, :branch_id => branch_id})
    else
      purchase_retrn_qty = product.purchase_return_line_items.select("sum(quantity) as purchase_return_quantity, sum(amount) as purchase_return_amount").joins(:purchase_return)
      .where(:purchase_returns => {:company_id => company_id, :record_date => start_date..end_date, :branch_id => branch_id},:purchase_returns => {:warehouse_id => warehouse_id})
    end
  end

     def stock_transfered_quantity_in_period(start_date, end_date, branch_id,warehouse_id,product,company_id)
    stock_transfer= product.stock_transfer_line_items.
      select("sum(transfer_quantity) as total_transfered_qty").
      joins(:stock_transfer_voucher).
      where(:stock_transfer_vouchers => {:company_id=> company_id, :voucher_date => start_date..end_date, :branch_id => branch_id,:warehouse_id=>warehouse_id})
  end



  ########################################################################


  
end
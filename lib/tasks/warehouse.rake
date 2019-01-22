namespace :warehouse do 
	task :migrate_existing_records_to_default_warehouse => :environment do
		ActiveRecord::Base.transaction do 
			# change product batch warehouse
			product_batchs = ProductBatch.where("warehouse_id not in(?)", Warehouse.all.map)
			puts "#{product_batchs.count} records need to migrate to default warehouse."
			product_batchs.each do |product_batch|
				company = product_batch.company
				puts"------ #{company.name}-------"
				default_warehouse = company.warehouses.first
				if default_warehouse.blank?
					puts"+++ #{company.name} dont have default warehouse. Creating..."
					default_warehouse = Warehouse.create(:name=>"Default warehouse", :company_id=> company.id, :created_by => company.users.first.id)
				end
				product_batch.update_attribute('warehouse_id',default_warehouse.id)
			end

			# purchase_warehouse_details
			purchase_warehouse_details = PurchaseWarehouseDetail.where("warehouse_id not in(?)", Warehouse.all.map)
			puts "#{purchase_warehouse_details.count} records need to migrate to default warehouse."
			purchase_warehouse_details.each do |purchase_warehouse_detail|
				company = purchase_warehouse_detail.company
				puts"------ #{company.name}-------"
				default_warehouse = company.warehouses.first
				if default_warehouse.blank?
					puts"+++ #{company.name} dont have default warehouse. Creating..."
					default_warehouse = Warehouse.create(:name=>"Default warehouse", :company_id=> company.id, :created_by => company.users.first.id)
				end
				purchase_warehouse_detail.update_attribute('warehouse_id',default_warehouse.id)
			end

			# sales_warehouse_details
			sales_warehouse_details = SalesWarehouseDetail.where("warehouse_id not in(?)", Warehouse.all.map)
			puts "#{sales_warehouse_details.count} records need to migrate to default warehouse."
			sales_warehouse_details.each do |sales_warehouse_detail|
				company = sales_warehouse_detail.invoice_line_item.invoice.company
				puts"------ #{company.name}-------"
				default_warehouse = company.warehouses.first
				if default_warehouse.blank?
					puts"+++ #{company.name} dont have default warehouse. Creating..."
					default_warehouse = Warehouse.create(:name=>"Default warehouse", :company_id=> company.id, :created_by => company.users.first.id)
				end
				sales_warehouse_detail.update_attribute('warehouse_id',default_warehouse.id)
			end

			# stock_transfer_line_items
			stock_transfer_line_items = StockTransferLineItem.where("destination_warehouse_id not in(?)", Warehouse.all.map)
			puts "#{stock_transfer_line_items.count} records need to migrate to default warehouse."
			stock_transfer_line_items.each do |stock_transfer_line_item|
				company = stock_transfer_line_item.stock_transfer_voucher.company
				puts"------ #{company.name}-------"
				default_warehouse = company.warehouses.first
				if default_warehouse.blank?
					puts"+++ #{company.name} dont have default warehouse. Creating..."
					default_warehouse = Warehouse.create(:name=>"Default warehouse", :company_id=> company.id, :created_by => company.users.first.id)
				end
				stock_transfer_line_item.update_attribute('destination_warehouse_id',default_warehouse.id)
			end

			# Delete stock from deleted warehouse
			stocks = Stock.where("warehouse_id not in(?)", Warehouse.all.map)
			puts "#{stocks.count} records need to migrate to default warehouse."
			stocks.each do |stock|
				company = stock.company
				puts"------ #{company.name}-------"
				default_warehouse = company.warehouses.first
				exist_stock = Stock.where(:warehouse_id => default_warehouse.id, :product_id=> stock.product_id).first
				if exist_stock.blank? 
					stock.update_attribute('warehouse_id',default_warehouse.id)
				else
					exist_stock.update_attribute('quantity', (exist_stock.quantity + stock.quantity))
				end
			end
		end
	end
end
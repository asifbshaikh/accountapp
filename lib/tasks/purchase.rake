namespace :purchase do 
	desc "find and update purchase warehouse details with null product id."
	task :fix_warehouse_details => :environment do
		purchase_warehouse_details=PurchaseWarehouseDetail.where(product_id: nil)
		i=j=0
		purchase_warehouse_details.each do |pwd|
			if pwd.purchase_line_item.blank?
				pwd.delete
				i+=1
			else
				pwd.update_attribute(:product_id, pwd.purchase_line_item.product_id)
				j+=1
			end
			print"#{i} orphan records deleted and #{j} record updated\r"
		end
		puts"#{i} orphan records deleted and #{j} records updated"
	end	
	desc "migrating tax to double tax"
	task :migrate_into_double_tax => :environment do
	  purchase_line_items = PurchaseLineItem.where("tax_account_id is not null")
	  index=0
	  purchase_line_items.each do |line_item|
	  	if line_item.purchase_taxes.blank?
		    line_item.purchase_taxes<<PurchaseTax.new(:account_id=>line_item.tax_account_id)
		    index+=1
		  end
	    print"Updating #{index} out of #{purchase_line_items.count}\r"
	  end
	  print"#{index} records updated out of #{purchase_line_items.count}"
	  puts
	end

	desc "For updating value of newly added product_id to purchase_warehouse_details table"
	task :update_product_id_in_purchase_warehouse_details => :environment do
		purchase_warehouse_details = PurchaseWarehouseDetail.where("product_id is null")
		i=0
		purchase_warehouse_details.each do |pwd|
			if !pwd.purchase_line_item.blank? && pwd.update_attribute("product_id", pwd.purchase_line_item.product_id)
				i+=1
			end
		end
		puts"#{i} records updated out of #{purchase_warehouse_details.count}"
	end

	task :update_total_amount => :environment do
	  ActiveRecord::Base.transaction do 
	  purchases = Purchase.all
	  purchases.each do |purchase|
	    begin
	      purchase.update_attribute(:total_amount, purchase.amount)
	    rescue Exception => e
	      puts"++++++Error in purchase(#{purchase.id})++++++"
	      puts"#{e}"
	    end
	  end
	 end
	end
	task :create_sequence => :environment do 
		ActiveRecord::Base.transaction do 
			companies = Company.all
			i=0
			puts"creating sequences for all companies..."
			companies.each do |company|
				if PurchaseSequence.create(:company_id => company.id)
					i+=1
				end
			end
			puts"sequences for #{i} out of #{companies.count} has been created"
		end
	end

	task :customize_voucher_number => :environment do 
		ActiveRecord::Base.transaction do 
			company = Company.find(1136)
			purchases = Purchase.where(:company_id=>company.id)
			voucher_setting = VoucherSetting.find_by_company_id_and_voucher_type(company.id, 5)
			purchase_sequence = PurchaseSequence.find_by_company_id(company.id)

			voucher_setting.update_attributes!(:voucher_number_strategy=>1, :prefix=>"13-14/GCS/PUR")
			purchase_sequence.update_attribute('purchase_sequence', 0)
			purchases.each do |purchase|
				voucher_number = VoucherSetting.next_purchase_number(company)
				purchase.update_attribute('purchase_number', voucher_number)
				purchase.reload
				purchase.ledgers.update_all(:voucher_number=> voucher_number)
			end
		end
	end
end
namespace :purchase_order do 
  desc "migrating tax to double tax"
  task :migrate_into_double_tax => :environment do
    purchase_order_line_items = PurchaseOrderLineItem.where("tax_account_id is not null")
    index=0
    purchase_order_line_items.each do |line_item|
      if line_item.purchase_order_taxes.blank?
        line_item.purchase_order_taxes<<PurchaseOrderTax.new(:account_id=>line_item.tax_account_id)
        index+=1
      end
      print"Updating #{index} out of #{purchase_order_line_items.count}\r"
    end
    print"#{index} records updated out of #{purchase_order_line_items.count}"
    puts
  end

  task :update_total_amount => :environment do
    @purchase_orders = PurchaseOrder.all
    @purchase_orders.each do |purchase_order|
      puts "purchase_order.amount #{purchase_order.amount}"
      purchase_order.update_attribute(:total_amount, purchase_order.amount)
    end
  end

  task :create_sequence => :environment do 
  	ActiveRecord::Base.transaction do 
  		companies = Company.all
  		i=0
  		puts"Creating sequences for all companies..."

  		companies.each do |company|
  			if PurchaseOrderSequence.create!(:company_id=>company.id)
  				i+=1
  			end
  		end
  		puts"Sequences for #{i} out of #{companies.count} has been created"
  	end
  end

  task :customize_voucher_number => :environment do 
    ActiveRecord::Base.transaction do 
      company = Company.find(1136)
      purchase_orders = PurchaseOrder.where(:company_id=>company.id)
      voucher_setting = VoucherSetting.find_by_company_id_and_voucher_type(company.id, 6)
      purchase_order_sequence = PurchaseOrderSequence.find_by_company_id(company.id)

      voucher_setting.update_attributes!(:voucher_number_strategy=>1, :prefix=>"13-14/GCS/PO")
      purchase_order_sequence.update_attribute('purchase_order_sequence', 0)
      purchase_orders.each do |purchase_order|
        purchase_order.update_attribute('purchase_order_number', VoucherSetting.next_purchase_order_number(company))
      end
    end
  end

  desc "To change status of vouchers where respective purchase is deleted"
  task :change_status => :environment do
    purchase_orders = PurchaseOrder.where(:status=>1)
    i=0
    purchase_orders.each_with_index do |po, index|
      if po.purchase.blank?
        po.set_opened
        i+=1 
      end
      print"checking #{index+1} records out of #{purchase_orders.count}\r"
    end
    print"\r"
    puts"#{i} records found and repaired successfully"
  end
end
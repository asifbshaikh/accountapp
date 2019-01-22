namespace :purchase_return do
	desc "migrating tax to double tax"
	task :migrate_into_double_tax => :environment do
	  purchase_return_line_items = PurchaseReturnLineItem.where("tax_account_id is not null")
	  index=0
	  purchase_return_line_items.each do |line_item|
	  	if line_item.purchase_return_taxes.blank? 
		    line_item.purchase_return_taxes<<PurchaseReturnTax.new(:account_id=>line_item.tax_account_id)
		    index+=1
		  end
	    print"Updating #{index} out of #{purchase_return_line_items.count}\r"
	  end
	  print"#{index} records updated out of #{purchase_return_line_items.count}"
	  puts
	end

	desc "to add purchase_return voucher setting"
	task :add_voucher_setting => :environment do
		ActiveRecord::Base.transaction do
			companies=Company.all
			companies.each do |company|
				VoucherSetting.create!(:company_id=> company.id, :voucher_number_strategy=>1, :voucher_type=>21)
				PurchaseReturnSequence.create!(:company_id=>company.id, :purchase_return_sequence=>1)
			end
		end
	end
end
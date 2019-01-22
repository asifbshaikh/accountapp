namespace :invoice_return do
	
	desc "integer discount to decimal convertion"
	task :discount_fix => :environment do
		invoice_return_line_items=InvoiceReturnLineItem.includes(:invoice_line_item).where("invoice_line_items.discount_percent<>invoice_return_line_items.discount_percent")
		i=0
		invoice_return_line_items.each do |line_item|
			amount=line_item.unit_rate*line_item.quantity
			line_item.discount_percent=line_item.invoice_line_item.discount_percent
			line_item.amount = amount - amount*(line_item.discount_percent/100.0)
			line_item.save
			invoice_return=line_item.invoice_return
			invoice_return.update_and_post_ledgers
			i+=1
			print"#{i} records updated.\r"
		end
		puts"#{i} records updated."
	end

	desc "migrating tax to double tax"
	task :migrate_into_double_tax => :environment do
	  invoice_return_line_items = InvoiceReturnLineItem.where("tax_account_id is not null")
	  index=0
	  invoice_return_line_items.each do |line_item|
	  	if line_item.invoice_return_taxes.blank? 
		    line_item.invoice_return_taxes<<InvoiceReturnTax.new(:account_id=>line_item.tax_account_id)
		    index+=1
		  end
	    print"Updating #{index} out of #{invoice_return_line_items.count}\r"
	  end
	  print"#{index} records updated out of #{invoice_return_line_items.count}"
	  puts
	end

	desc "add setting for invoice return"
	task :add_voucher_setting => :environment do
		ActiveRecord::Base.transaction do
			companies=Company.order("id DESC").limit(100)
			# companies=Company.where("id not in(?)", Company.includes(:invoice_return).map { |c| c.id })
			companies.each_with_index do |company, index|
				if company.invoice_return_sequence.blank?
				puts "#{index+1}) company id is #{company.id}"
				VoucherSetting.create!(:company_id=> company.id, :voucher_number_strategy=>1, :voucher_type=>22)
				InvoiceReturnSequence.create!(:company_id=>company.id, :invoice_return_sequence=>0)
				end
			end
		end
	end
end
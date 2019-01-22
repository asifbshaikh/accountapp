namespace :sales_order do 
  
  desc "migrating tax to double tax"
  task :migrate_into_double_tax => :environment do
    sales_order_line_items = SalesOrderLineItem.where("tax_account_id is not null")
    index=0
    sales_order_line_items.each do |line_item|
      if line_item.sales_order_taxes.blank? 
        line_item.sales_order_taxes<<SalesOrderTax.new(:account_id=>line_item.tax_account_id)
        index+=1
      end
      print"Updating #{index} out of #{sales_order_line_items.count}\r"
    end
    print"#{index} records updated out of #{sales_order_line_items.count}"
    puts
  end

  task :create_sequence => :environment do 
  	companies  = Company.all
  	puts"Adding sales_order number sequence..."
  	i=0
  	companies.each do |company|
     so_seq = SalesOrderSequence.find_by_company_id(company.id)
     if so_seq.blank? 
  		if SalesOrderSequence.create!(:company_id=> company.id)
	  		puts"@@@ created soseq for company #{company.name} "
        i+=1
	  	end
     else
       puts"@@@ company #{company.name} has right record"
     end 
  	end
  	puts"Sequence for #{i} out of #{companies.count} companies has been added."
  end

  task :update_sales_order => :environment do
    Company.all.each do |company|
    sales_orders = company.sales_orders.where("customer_id is null")
    puts"@@@company #{company.name} has #{sales_orders.count} SO"
     sales_orders.each do |so|
       if !so.account_id.blank?
        customer = so.account.customer.blank? ? so.account.vendor : so.account.customer
         so.update_attribute("customer_id", customer.id)
         puts "so updated successfully with id #{so.id} and customer id #{so.customer_id}"
       else
         puts "so account id is blank"
       end
     end
    end
  end
  
  task :update_sales_order_branch_id => :environment do
    Company.enterprise_plan.each do |company|
    sales_orders = company.sales_orders.where("branch_id is null")
     sales_orders.each do |so|
        branch_id = User.find(so.created_by).branch_id
        if !branch_id.blank?
         so.update_attribute("branch_id", branch_id)
        end
     end
    end
  end
end
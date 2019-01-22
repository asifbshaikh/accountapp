namespace :customer_export do 
	task :export_csv=> :environment do 
		ActiveRecord::Base.transaction do 
			require 'csv'
    		CSV.open("#{Rails.root}/resources/customers.csv", "w") do |csv|
    			@customer=Customer.where(:company_id=>11172)
      			csv << ['customer_id', 'customer_name', 'GSTIN']  #column head of csv file
     			@customer.each do |customer|
      				csv << [customer.id, customer.name] #fields name
      			end
    		end
		end
	end

	task :import_csv=> :environment do 
		ActiveRecord::Base.transaction do 
			require 'csv'
    		CSV.foreach("#{Rails.root}/resources/customers.csv", :headers => true) do |row|
    			customer=Customer.find_by_id(row[0])
    			customer.update_attributes(:gstn_id => row[2])
 			 end
		end
	end
end
namespace :vendor_export  do
	task :export_csv=> :environment do 
		ActiveRecord::Base.transaction do 
			require 'csv'
    		CSV.open("#{Rails.root}/resources/vendors.csv", "w") do |csv|
    			@vendor=Vendor.where(:company_id=>11172)
      			csv << ['vendor_id', 'vendor_name', 'GSTIN']  #column head of csv file
     			@vendor.each do |vendor|
      				csv << [vendor.id, vendor.name] #fields name
      			end
    		end
		end
	end

	task :import_csv=> :environment do 
		ActiveRecord::Base.transaction do 
			require 'csv'
    		CSV.foreach("#{Rails.root}/resources/vendors.csv", :headers => true) do |row|
    			vendor=Vendor.find_by_id(row[0])
    			vendor.update_attributes(:gstn_id => row[2])
 			 end
		end
	end
end
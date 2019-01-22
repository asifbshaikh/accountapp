namespace :product_export  do
	task :export_csv=> :environment do 
		ActiveRecord::Base.transaction do 
			require 'csv'
			company_id=23544
    		CSV.open("#{Rails.root}/resources/#{company_id}_products.csv", "w") do |csv|
    			@product=Product.where(:company_id=> company_id)
      			csv << [ 'Product Id', 'product name', 'HSN/SAC code', 'Unit of Supply']  #column head of csv file
     			@product.each do |product|
      				csv << [ product.id, product.name, product.hsn_code, product.unit_of_measure] #fields name
      			end
    		end
		end
	end

	task :import_csv=> :environment do 
		ActiveRecord::Base.transaction do 
			require 'csv'
			company_id=11172
			company = Company.find_by_id(company_id)
    		CSV.foreach("#{Rails.root}/resources/#{company_id}_products.csv", :headers => true) do |row|
    			product=company.products.find(row[0])
    			product.update_attributes(:hsn_code => row[2])
 			 end
		end
	end
end
namespace :export_port_code do 
	task :create_entries=> :environment do 
		ActiveRecord::Base.transaction do 
				i=0
				CSV.foreach(File.join(Rails.root, 'resources', "export_list_of_ports.csv"),:col_sep => "$", :skip_blanks => true,:headers => true, :encoding => 'utf-8') do |row|
				unless row[0].blank? || row[1].blank?
				entry = ExportPortCode.new(:port_code => row[0],:description => row[0] +" "+ row[1])
				entry.save!
				i=i+1
				end
				end
			puts  "Inserted #{i} port codes"
		end
	end
end
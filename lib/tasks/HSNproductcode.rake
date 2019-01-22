namespace :HSNproductcode do 
	task :create_entries=> :environment do 
		ActiveRecord::Base.transaction do 
			code_arr=[]
			description =""
				CSV.foreach(File.join(Rails.root, 'resources', "HSN.csv"),:col_sep => "$", :skip_blanks => true,:headers => true, :encoding => 'utf-8') do |row|
					code=[]
					if row[0].blank?
						description= description + row[1].to_s
					else
						code.push(row[0])
						description.blank? ? code.push(row[1]): code.push(description+" "+row[1])
						description= "" unless row[1].blank?
					end
					code_arr << code if !row[0].blank?
				end	
				puts "Beginning to Insert...Please Wait "
				code_arr.each_with_index do |entry,index|
				id = entry[0].to_s
				desc = entry[1].to_s
				# puts "******************************"
				# puts desc
				entry = HsnCode.new(:HSN_Code => id,:description => desc.capitalize,:code_type=>'HSN')
				entry.save!
				end
			puts  "Inserted #{code_arr.count} HSN codes"
		end
	end
end
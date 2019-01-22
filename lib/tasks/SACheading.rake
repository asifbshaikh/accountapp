namespace :SACheading do 
	task :create_headings=> :environment do 
		ActiveRecord::Base.transaction do 
			code_arr=[]
				CSV.foreach(File.join(Rails.root, 'resources', "modified_SAC.csv"),:col_sep => "$", :skip_blanks => true,:headers => true, :encoding => 'utf-8') do |row|
				unless row[0].blank?	
					if row[0].include? "Heading No."
						heading_index = row[0].split(".")[1,2].join(":").strip
						heading = "Heading #{heading_index} ".concat(row[2].to_s)
						code=[]
						code.push(heading_index)
						code.push(heading)
						code_arr << code 
					end				
				end
			end
				# puts "ddddddddd#{code_arr.count}"
				puts "Beginning to Insert...Please Wait "
				code_arr.each_with_index do |entry,index|
				id = entry[0].to_s
				desc = entry[1].to_s
				puts "******************************"
				puts id
				puts desc
				new_heading = SacHeading.new(:heading_index =>id,:heading=>desc)
				new_heading.save!
				end
			puts  "Inserted #{code_arr.count}  chapter headings"
		end
	end

	task :create_entries=> :environment do 
		ActiveRecord::Base.transaction do 
			 remove_entry = HsnCode.where(:code_type =>'SAC')
			 puts "Entries need to be removed #{remove_entry.count}"
			 remove_entry.delete_all
			 puts "Removed all previous Entries "
			code_arr=[]
				CSV.foreach(File.join(Rails.root, 'resources', "modified_SAC.csv"),:col_sep => "$", :skip_blanks => true,:headers => true, :encoding => 'utf-8') do |row|
				unless row[1].blank?	
						sac_code = row[1].strip
						description = row[2].to_s
						code=[]
						code.push(sac_code)
						code.push(description)
						code_arr << code 			
				end
			end
				# puts "ddddddddd#{code_arr.count}"
				puts "Beginning to Insert...Please Wait "
				code_arr.each_with_index do |entry,index|
				id = entry[0].to_s
				desc = entry[1].to_s
				puts "******************************"
				puts id
				puts desc
				new_entry = HsnCode.new(:HSN_Code =>id,:description=>desc,:code_type => 'SAC')
				new_entry.save!
				end
			puts  "Inserted #{code_arr.count}  chapter entries"
		end
	end
end
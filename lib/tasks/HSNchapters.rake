namespace :HSNchapters do 
	task :create_entries=> :environment do 
		ActiveRecord::Base.transaction do 
			code_arr=[]
			description =""
			chapter= 1
				CSV.foreach(File.join(Rails.root, 'resources', "HSN-chapters.csv"),:col_sep => ",", :skip_blanks => true,:headers => false, :encoding => 'utf-8') do |row|
					index=chapter.to_s.rjust(2, '0')
					hsn_chapter=HsnChapter.new(:chapter_index => index, :chapter_heading => row[0])
					hsn_chapter.save!
					chapter+=1
				end	
		end
	end
end
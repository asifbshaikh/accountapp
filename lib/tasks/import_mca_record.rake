namespace :mca_record do 
	task :import_records => :environment do 
		ActiveRecord::Base.transaction do 
			@file = CSV.read("#{Rails.root}/MCA_records.csv")
			@file.drop(1).each do |row|
				if !row[5].blank?
					date = Date.strptime("#{row[5]}","%d/%m/%Y")
				else
					date = nil
				end
			@mca_records = McaRecord.new(:category => row[0], :month => row[1], :cin => row[2],
				:company_name => row[3],:email => row[4],:date_of_incorporation => date,
				:state => row[6],:ROC => row[7],:authorized_capital => row[8],:paid_capital => row[9],
				:no_of_members => row[10],:activity_description => row[11],:registered_office_address => row[12])
         	@mca_records.save
         	puts"record saving...."
         	end
		end	
	end

	task :import_april_records => :environment do 
		ActiveRecord::Base.transaction do 
			@file = CSV.read("#{Rails.root}/April_2014.csv")
			@file.drop(1).each do |row|
				if !row[3].blank?
					begin
					date = Date.strptime("#{row[3]}","%m/%d/%Y")
					rescue 
					date = nil
					end
				end
			@mca_records = McaRecord.new(:category => row[6], :month => "April-2014", :cin => row[0],
				:company_name => row[1],:email => row[2],:date_of_incorporation => date,
				:state => row[4],:ROC => row[5],:authorized_capital => row[9],:paid_capital => row[10],
				:no_of_members => row[11],:activity_description => row[12],:registered_office_address => row[13], :source => 1)
         	@mca_records.save
         	puts"record saving...."
         	end
		end	
	end

	task :import_June_records => :environment do 
		ActiveRecord::Base.transaction do 
			@file = CSV.read("#{Rails.root}/June01-2014.csv")
			 @file.drop(1).each do |row|
				if !row[3].blank?
					begin
					date = Date.strptime("#{row[3]}","%m/%d/%Y")
					rescue 
					date = nil
					end
				end
			@mca_records = McaRecord.new(:month => "June-2014", :cin => row[0], :email=> row[1], :date_of_incorporation=> date, :source => 1)
         	@mca_records.save
         	puts"record saving...."
            end
		end	
	end

	task :import_Junellp_records => :environment do 
		ActiveRecord::Base.transaction do 
			@file = CSV.read("#{Rails.root}/JuneLLP01.csv")
			@file.drop(1).each do |row|
				if !row[3].blank?
					begin
					date = Date.strptime("#{row[3]}","%m/%d/%Y")
					rescue 
					date = nil
					end
				end
			@mca_records = McaRecord.new(:month => "June-2014", :cin => row[0], :email=> row[1], :date_of_incorporation=> date, :source => 1)
         	@mca_records.save
         	puts"record saving...."
         	end
		end	
	end


	task :add_active_users => :environment do
		ActiveRecord::Base.transaction do
			@file = CSV.read("#{Rails.root}/emails_for_active.csv")
			@email_array = []
			@file.each do |row|
				@email_array << row[0]
			end
			@mca_records = McaRecord.all
			@count = 0
			@mca_records.each do |record|
				if @email_array.include?(record.email)
					record.update_attributes(:active => true)
					@count += 1
				end
			end
			puts"******************#{@count} records has made active"
		end
	end

	task :add_source => :environment do
		ActiveRecord::Base.transaction do
			@mca_records = McaRecord.all
			@count = 0
			@mca_records.each do |record|
				record.update_attributes(:source => 1)
					@count += 1
			end
			puts"******************source added to #{@count} records"
		end
	end

	task :import_new_records => :environment do 
		ActiveRecord::Base.transaction do 
			@file = CSV.read("#{Rails.root}/Mahatech_records.csv")
			@file.drop(1).each do |row|
			@mca_records = McaRecord.new(:email => row[0],:source => 2)
         	@mca_records.save
         	puts"record saving...."
         	end
		end	
	end

end

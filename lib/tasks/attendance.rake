namespace :attendance do 
	task :update_days_absent => :environment do 
		ActiveRecord::Base.transaction do 
			attendances = Attendance.all

			attendances.each do |attendance|
				attendance.update_attribute(:days_absent, (attendance.month.end_of_month.day - attendance.days_present))
			end
		end
	end
end
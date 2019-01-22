class Dashboard < ActiveRecord::Base

	def self.todays_birthday(company)
	  @users = company.users.joins(:user_information).where(:user_informations => {:birth_date => Time.zone.now.to_date})
	end

	def self.weeks_birthday(company)
	  @users = company.users
	  @birthdays = []
	  @users.each do |b|
	  	if !b.user_information.blank?
			@birthdate = b.user_information.birth_date unless b.user_information.birth_date.blank?
	    		if !@birthdate.blank?
	     			if @birthdate.day >= Time.zone.now.to_date.day && @birthdate.month >= Time.zone.now.to_date.month && @birthdate.month <= Time.zone.now.to_date.end_of_week.month
	      				@birthdays << b.user_information
	     			end
	    		end
	    end
      end
      @birthdays
	end

	def self.timesheets(company, user)
		timesheet = Timesheet.where(:company_id => company.id, :user_id => user.id).order("record_date DESC")
	end
end

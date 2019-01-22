class UserSalaryDetail < ActiveRecord::Base
   belongs_to :user
   
     # validate :birth_date_and_date_of_joining
    # validate :date_of_leaving_and_date_of_joining
    # validate :date_of_leaving_and_birth_date


     def birth_date_and_date_of_joining
      if !user.user_information.birth_date.blank? && !date_of_joining.blank?
         valid = user.user_information.birth_date && date_of_joining && user.user_information.birth_date < date_of_joining
         errors.add(:base, "must be before date of joining") unless valid
       end
     end

     def date_of_leaving_and_date_of_joining
      if !date_of_joining.blank? && !date_of_leaving.blank?
     	 valid = date_of_joining && date_of_leaving && date_of_joining < date_of_leaving
         errors.add(:date_of_joining, "must be before date of leaving") unless valid
     end
     end

     def date_of_leaving_and_birth_date
      if !user.user_information.birth_date.blank? && !date_of_leaving.blank?
     	valid = user.user_information.birth_date && date_of_leaving && user.user_information.birth_date < date_of_leaving
        errors.add(:base , " birth date must be before date of leaving") unless valid
     end
     end

 # def left_this_month
	# sef.where(:date_of_leaving => Time.zone.now.to_date.beginning_of_month..Time.zone.now.to_date.end_of_month)
 # end
end

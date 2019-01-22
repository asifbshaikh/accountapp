class UserInformation < ActiveRecord::Base
  belongs_to :user


    # validates_format_of :passport_number, :with => /\A[a-zA-Z0-9]+\z/
    # validate :birth_date_and_marriage_date_validation
    # validate :birth_date_and_passport_expiry_date_validation



    def birth_date_and_marriage_date_validation
      if !birth_date.blank? && !marriage_date.blank?
       valid = birth_date && marriage_date && birth_date < marriage_date
       errors.add(:birth_date, "must be before marriage date") unless valid
     end

   end

   def birth_date_and_passport_expiry_date_validation
    if !birth_date.blank? && !passport_expiry_date.blank?
      valid = birth_date && passport_expiry_date && birth_date < passport_expiry_date
      errors.add(:birth_date, "must be before passport expiry date") unless valid
    end
  end

  def birthday?(date)
    result = false
    if !self.birth_date.blank?
      today = date.strftime("%d-%m")
      birth_dt = self.birth_date.strftime("%d-%m")
      result = (today == birth_dt)
    end
    result
  end


end

class Attendance < ActiveRecord::Base
 belongs_to :company
 belongs_to :user
 validates_presence_of :user_id, :company_id, :month, :days_absent

  validate :absent_days_count
  def absent_days_count
    if !days_absent.blank? && days_absent > month.end_of_month.day
      errors.add(:days_absent, "should not greater than #{month.end_of_month.day}")
    end
  end
  def months()
    months={
       '1'=> 'January',
       '2'=> 'February',      
       '3'=> 'March',
       '4'=> 'April',
       '5'=> 'May',
       '6'=> 'June',
       '7'=> 'July',
       '8'=> 'August',
       '9'=> 'September',
       '10'=> 'October',
       '11'=> 'November',
       '12' => 'December'
      }
  end   

  def self.get_month(month)
    months={
       '1'=> 'January',
       '2'=> 'February',      
       '3'=> 'March',
       '4'=> 'April',
       '5'=> 'May',
       '6'=> 'June',
       '7'=> 'July',
       '8'=> 'August',
       '9'=> 'September',
       '10'=> 'October',
       '11'=> 'November',
       '12' => 'December'
      }
    months[month]
  end 
end

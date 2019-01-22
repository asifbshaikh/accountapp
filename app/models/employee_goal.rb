class EmployeeGoal < ActiveRecord::Base
    #relationship
    belongs_to :user
    belongs_to :master_objective
    belongs_to :company
    
    
    #validations
    validates_presence_of  :goals, :from_date, :to_date
    #attr_accessible :from_date, :to_date
   
    validate :from_date_and_to_date
    
    def from_date_and_to_date
      if (!to_date.nil? && to_date < from_date)
        errors.add(:to_date, "should be greater than or equal to from date.")
      end
    end
    
    def for_employee_name
      User.find(for_employee).first_name
    end
end

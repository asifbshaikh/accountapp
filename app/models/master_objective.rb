class MasterObjective < ActiveRecord::Base
    #relationship
    belongs_to :department
    has_one :employee_goal
    belongs_to :user
    belongs_to :company
    
    #validations
    validates_presence_of  :department_id, :objective_name, :details 
   
   def department_name
     Department.find(department_id).name
   end
end

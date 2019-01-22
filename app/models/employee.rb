class Employee < ActiveRecord::Base
  
      #relationships
       belongs_to :company
       belongs_to :user
       belongs_to :department
       has_many :employee_goals
    #validation start
       validates_presence_of :employee_name, :gender, :email, :present_address, :phone,:blood_group, :date_of_birth, :maratial_status, :emergency_contact1, :emergency_contact2,
                            :passport_number, :passport_expiry_date, :department,:status, :work_location,:work_phone, :date_of_joining, :bank_account_number, :bank_name, :PAN, :EPS_account_number, :PF_account_number
      
      
      validates_format_of :email,
                          :with =>  /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i,
                          :message => ":Its not a valid format"
      
                          
     
      
      
    
end




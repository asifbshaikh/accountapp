ActiveRecord::Base.transaction do
  premium_plan = Plan.find_by_name('Premium')
  enterprise_plan = Plan.find_by_name('Enterprise')
  trial_plan = Plan.find_by_name('Trial')
  
  premium_owner = Role.find_by_name_and_plan_id('Owner', premium_plan)
  premium_accountant = Role.find_by_name_and_plan_id('Accountant', premium_plan)
  premium_auditor = Role.find_by_name_and_plan_id('Auditor', premium_plan)
  premium_staff = Role.find_by_name_and_plan_id('Staff', premium_plan)
  premium_employee = Role.find_by_name_and_plan_id('Employee', premium_plan)

  enterprise_owner = Role.find_by_name_and_plan_id('Owner', enterprise_plan)
  enterprise_accountant = Role.find_by_name_and_plan_id('Accountant', enterprise_plan)
  enterprise_auditor = Role.find_by_name_and_plan_id('Auditor', enterprise_plan)
  enterprise_staff = Role.find_by_name_and_plan_id('Staff', enterprise_plan)
  enterprise_employee = Role.find_by_name_and_plan_id('Employee', enterprise_plan)

  trial_owner = Role.find_by_name_and_plan_id('Owner', trial_plan)
  trial_accountant = Role.find_by_name_and_plan_id('Accountant', trial_plan)
  trial_auditor = Role.find_by_name_and_plan_id('Auditor', trial_plan)
  trial_staff = Role.find_by_name_and_plan_id('Staff', trial_plan)
  trial_employee = Role.find_by_name_and_plan_id('Employee', trial_plan)



 #salary structure history
     salary_structure_histories_create = Right.create!(:resource => 'salary_structure_histories', :operation => 'CREATE') 
     salary_structure_histories_read = Right.create!(:resource => 'salary_structure_histories', :operation => 'READ') 
     salary_structure_histories_update = Right.create!(:resource => 'salary_structure_histories', :operation => 'UPDATE') 
     salary_structure_histories_delete = Right.create!(:resource => 'salary_structure_histories', :operation => 'DELETE') 
     
     
     #premium_owner 
        premium_owner.rights << salary_structure_histories_create
        premium_owner.rights << salary_structure_histories_read
        premium_owner.rights << salary_structure_histories_update
        premium_owner.rights << salary_structure_histories_delete
        #premium_accountant
        premium_accountant.rights << salary_structure_histories_read
      
      #enterprise_owner 
        enterprise_owner.rights << salary_structure_histories_create
        enterprise_owner.rights << salary_structure_histories_read
        enterprise_owner.rights << salary_structure_histories_update
        enterprise_owner.rights << salary_structure_histories_delete
        #enterprise_accountant
        enterprise_accountant.rights << salary_structure_histories_read
      
      #trial_owner 
        trial_owner.rights << salary_structure_histories_create
        trial_owner.rights << salary_structure_histories_read
        trial_owner.rights << salary_structure_histories_update
        trial_owner.rights << salary_structure_histories_delete
        #trial_accountant
        trial_accountant.rights << salary_structure_histories_read
      
end
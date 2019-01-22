ActiveRecord::Base.transaction do

  professional_plan = Plan.find_by_name('Professional')
  enterprise_plan = Plan.find_by_name('Enterprise')
  trial_plan = Plan.find_by_name('Trial')
  smb_plan = Plan.find_by_name('SMB')
  free_plan = Plan.find_by_name('Free')
  basic_plan = Plan.find_by_name('Basic')


  free_owner = Role.find_by_name_and_plan_id('Owner', free_plan)

  professional_owner = Role.find_by_name_and_plan_id('Owner', professional_plan)
  professional_accountant = Role.find_by_name_and_plan_id('Accountant', professional_plan)
  professional_auditor = Role.find_by_name_and_plan_id('Auditor', professional_plan)
  professional_staff = Role.find_by_name_and_plan_id('Staff', professional_plan)
  professional_employee = Role.find_by_name_and_plan_id('Employee', professional_plan)

  enterprise_owner = Role.find_by_name_and_plan_id('Owner', enterprise_plan)
  enterprise_accountant = Role.find_by_name_and_plan_id('Accountant', enterprise_plan)
  enterprise_auditor = Role.find_by_name_and_plan_id('Auditor', enterprise_plan)
  enterprise_staff = Role.find_by_name_and_plan_id('Staff', enterprise_plan)
  enterprise_employee = Role.find_by_name_and_plan_id('Employee', enterprise_plan)
  enterprise_inventory_manager = Role.find_by_name_and_plan_id('Inventory Manager', enterprise_plan)

  trial_owner = Role.find_by_name_and_plan_id('Owner', trial_plan)
  trial_accountant = Role.find_by_name_and_plan_id('Accountant', trial_plan)
  trial_auditor = Role.find_by_name_and_plan_id('Auditor', trial_plan)
  trial_staff = Role.find_by_name_and_plan_id('Staff', trial_plan)
  trial_employee = Role.find_by_name_and_plan_id('Employee', trial_plan)
  trial_inventory_manager = Role.find_by_name_and_plan_id('Inventory Manager', trial_plan)
  
  smb_owner = Role.find_by_name_and_plan_id('Owner', smb_plan)
  smb_accountant = Role.find_by_name_and_plan_id('Accountant', smb_plan)
  smb_auditor = Role.find_by_name_and_plan_id('Auditor', smb_plan)
  smb_staff = Role.find_by_name_and_plan_id('Staff', smb_plan)
  smb_employee = Role.find_by_name_and_plan_id('Employee', smb_plan)
  smb_inventory_manager = Role.find_by_name_and_plan_id('Inventory Manager', smb_plan)

# rights for label terminology
  labels_create = Right.create!(:resource => 'labels', :operation => 'CREATE')
  labels_read = Right.create!(:resource => 'labels', :operation => 'READ') 
  labels_delete = Right.create!(:resource => 'labels', :operation => 'DELETE')
  labels_update = Right.create!(:resource => 'labels', :operation => 'UPDATE')


     # #professional_owner  
      professional_owner.rights << labels_create
      professional_owner.rights << labels_read
      professional_owner.rights << labels_update
      professional_owner.rights << labels_delete
  #    professional_accountant
      professional_accountant.rights << labels_create
      professional_accountant.rights << labels_read
      professional_accountant.rights << labels_update
      professional_accountant.rights << labels_delete
    
  # enterprise_owner   
      enterprise_owner.rights << labels_create
      enterprise_owner.rights << labels_read
      enterprise_owner.rights << labels_update
      enterprise_owner.rights << labels_delete
  # enterprise_accountant
      enterprise_accountant.rights << labels_create
      enterprise_accountant.rights << labels_read
      enterprise_accountant.rights << labels_update
      enterprise_accountant.rights << labels_delete
    
  # trial_owner    
     trial_owner.rights << labels_create
     trial_owner.rights << labels_read
     trial_owner.rights << labels_update
     trial_owner.rights << labels_delete
  # trial_accountant
     trial_accountant.rights << labels_create
     trial_accountant.rights << labels_read
     trial_accountant.rights << labels_update
     trial_accountant.rights << labels_delete
    
  # smb_owner 
     smb_owner.rights << labels_create
     smb_owner.rights << labels_read
     smb_owner.rights << labels_update
     smb_owner.rights << labels_delete
  # smb_accountant
     smb_accountant.rights << labels_create
     smb_accountant.rights << labels_read
     smb_accountant.rights << labels_update
     smb_accountant.rights << labels_delete

end
ActiveRecord::Base.transaction do

  free_plan = Plan.find_by_name('Free')
  basic_plan = Plan.find_by_name('Basic')
  professional_plan = Plan.find_by_name('Professional')
  enterprise_plan = Plan.find_by_name('Enterprise')
  trial_plan = Plan.find_by_name('Trial')
  smb_plan = Plan.find_by_name('SMB')


  free_owner = Role.find_by_name_and_plan_id('Owner', free_plan)

  basic_owner = Role.find_by_name_and_plan_id('Owner', basic_plan)
  basic_accountant = Role.find_by_name_and_plan_id('Accountant', basic_plan)
  basic_auditor = Role.find_by_name_and_plan_id('Auditor', basic_plan)
  basic_staff = Role.find_by_name_and_plan_id('Staff', basic_plan)
  
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

# rights for banking terminology
  banking_create = Right.create!(:resource => 'banking', :operation => 'CREATE')
  banking_read = Right.create!(:resource => 'banking', :operation => 'READ') 
  banking_delete = Right.create!(:resource => 'banking', :operation => 'DELETE')
  banking_update = Right.create!(:resource => 'banking', :operation => 'UPDATE')

  customers_create = Right.create!(:resource => 'customers', :operation => 'CREATE')
  customers_read = Right.create!(:resource => 'customers', :operation => 'READ') 
  customers_delete = Right.create!(:resource => 'customers', :operation => 'DELETE')
  customers_update = Right.create!(:resource => 'customers', :operation => 'UPDATE')

  vendors_create = Right.create!(:resource => 'vendors', :operation => 'CREATE')
  vendors_read = Right.create!(:resource => 'vendors', :operation => 'READ') 
  vendors_delete = Right.create!(:resource => 'vendors', :operation => 'DELETE')
  vendors_update = Right.create!(:resource => 'vendors', :operation => 'UPDATE')

#free owner 
      free_owner.rights << banking_create
      free_owner.rights << banking_read
      free_owner.rights << banking_update
      free_owner.rights << banking_delete

      free_owner.rights << customers_create
      free_owner.rights << customers_read
      free_owner.rights << customers_update
      free_owner.rights << customers_delete

      free_owner.rights << vendors_create
      free_owner.rights << vendors_read
      free_owner.rights << vendors_update
      free_owner.rights << vendors_delete


# basic plan rights
      basic_owner.rights << banking_create
      basic_owner.rights << banking_read
      basic_owner.rights << banking_update
      basic_owner.rights << banking_delete

      basic_owner.rights << customers_create
      basic_owner.rights << customers_read
      basic_owner.rights << customers_update
      basic_owner.rights << customers_delete
      
      basic_owner.rights << vendors_create
      basic_owner.rights << vendors_read
      basic_owner.rights << vendors_update
      basic_owner.rights << vendors_delete

      basic_accountant.rights << banking_create
      basic_accountant.rights << banking_read
      basic_accountant.rights << banking_update
      basic_accountant.rights << banking_delete

      basic_accountant.rights << customers_create
      basic_accountant.rights << customers_read
      basic_accountant.rights << customers_update
      basic_accountant.rights << customers_delete

      basic_accountant.rights << vendors_create
      basic_accountant.rights << vendors_read
      basic_accountant.rights << vendors_update
      basic_accountant.rights << vendors_delete

 
      basic_staff.rights << banking_create
      basic_staff.rights << banking_read
      basic_staff.rights << banking_update
      basic_staff.rights << banking_delete
    
      basic_auditor.rights << banking_read
      basic_auditor.rights << customers_read
      basic_auditor.rights << vendors_read
     
     # #professional_owner  
      # professional_owner.rights << banking_create
      # professional_owner.rights << banking_read
      # professional_owner.rights << banking_update
      # professional_owner.rights << banking_delete

      # professional_owner.rights << customers_create
      # professional_owner.rights << customers_read
      # professional_owner.rights << customers_update
      # professional_owner.rights << customers_delete

      # professional_owner.rights << vendors_create
      # professional_owner.rights << vendors_read
      # professional_owner.rights << vendors_update
      # professional_owner.rights << vendors_delete

  #    professional_accountant
      # professional_accountant.rights << banking_create
      # professional_accountant.rights << banking_read
      # professional_accountant.rights << banking_update
      # professional_accountant.rights << banking_delete

      # professional_accountant.rights << customers_create
      # professional_accountant.rights << customers_read
      # professional_accountant.rights << customers_update
      # professional_accountant.rights << customers_delete

      # professional_accountant.rights << vendors_create
      # professional_accountant.rights << vendors_read
      # professional_accountant.rights << vendors_update
      # professional_accountant.rights << vendors_delete

      # professional_staff.rights << banking_create
      # professional_staff.rights << banking_read
      # professional_staff.rights << banking_update
      # professional_staff.rights << banking_delete
    
      # professional_auditor.rights << banking_read
      # professional_auditor.rights << customers_read
      # professional_auditor.rights << vendors_read

    
  # enterprise_owner   
      enterprise_owner.rights << banking_create
      enterprise_owner.rights << banking_read
      enterprise_owner.rights << banking_update
      enterprise_owner.rights << banking_delete

      enterprise_owner.rights << customers_create
      enterprise_owner.rights << customers_read
      enterprise_owner.rights << customers_update
      enterprise_owner.rights << customers_delete

      enterprise_owner.rights << vendors_create
      enterprise_owner.rights << vendors_read
      enterprise_owner.rights << vendors_update
      enterprise_owner.rights << vendors_delete

  # enterprise_accountant
      enterprise_accountant.rights << banking_create
      enterprise_accountant.rights << banking_read
      enterprise_accountant.rights << banking_update
      enterprise_accountant.rights << banking_delete

      enterprise_accountant.rights << customers_create
      enterprise_accountant.rights << customers_read
      enterprise_accountant.rights << customers_update
      enterprise_accountant.rights << customers_delete
      
      enterprise_accountant.rights << vendors_create
      enterprise_accountant.rights << vendors_read
      enterprise_accountant.rights << vendors_update
      enterprise_accountant.rights << vendors_delete

      enterprise_staff.rights << banking_create
      enterprise_staff.rights << banking_read
      enterprise_staff.rights << banking_update
      enterprise_staff.rights << banking_delete

      enterprise_inventory_manager.rights << banking_create
      enterprise_inventory_manager.rights << banking_read
      enterprise_inventory_manager.rights << banking_update
      enterprise_inventory_manager.rights << banking_delete
    
      enterprise_auditor.rights << banking_read
      enterprise_auditor.rights << customers_read
      enterprise_auditor.rights << vendors_read
  
  # trial_owner    
     trial_owner.rights << banking_create
     trial_owner.rights << banking_read
     trial_owner.rights << banking_update
     trial_owner.rights << banking_delete

     trial_owner.rights << customers_create
     trial_owner.rights << customers_read
     trial_owner.rights << customers_update
     trial_owner.rights << customers_delete

     trial_owner.rights << vendors_create
     trial_owner.rights << vendors_read
     trial_owner.rights << vendors_update
     trial_owner.rights << vendors_delete

  # trial_accountant
     trial_accountant.rights << banking_create
     trial_accountant.rights << banking_read
     trial_accountant.rights << banking_update
     trial_accountant.rights << banking_delete

     trial_accountant.rights << customers_create
     trial_accountant.rights << customers_read
     trial_accountant.rights << customers_update
     trial_accountant.rights << customers_delete

     trial_accountant.rights << vendors_create
     trial_accountant.rights << vendors_read
     trial_accountant.rights << vendors_update
     trial_accountant.rights << vendors_delete


      trial_staff.rights << banking_create
      trial_staff.rights << banking_read
      trial_staff.rights << banking_update
      trial_staff.rights << banking_delete

      trial_inventory_manager.rights << banking_create
      trial_inventory_manager.rights << banking_read
      trial_inventory_manager.rights << banking_update
      trial_inventory_manager.rights << banking_delete
    
      trial_auditor.rights << banking_read
      trial_auditor.rights << customers_read
      trial_auditor.rights << vendors_read
    
  # smb_owner 
     smb_owner.rights << banking_create
     smb_owner.rights << banking_read
     smb_owner.rights << banking_update
     smb_owner.rights << banking_delete

     smb_owner.rights << customers_create
     smb_owner.rights << customers_read
     smb_owner.rights << customers_update
     smb_owner.rights << customers_delete

     smb_owner.rights << vendors_create
     smb_owner.rights << vendors_read
     smb_owner.rights << vendors_update
     smb_owner.rights << vendors_delete

  # smb_accountant
     smb_accountant.rights << banking_create
     smb_accountant.rights << banking_read
     smb_accountant.rights << banking_update
     smb_accountant.rights << banking_delete

     smb_accountant.rights << customers_create
     smb_accountant.rights << customers_read
     smb_accountant.rights << customers_update
     smb_accountant.rights << customers_delete

     smb_accountant.rights << vendors_create
     smb_accountant.rights << vendors_read
     smb_accountant.rights << vendors_update
     smb_accountant.rights << vendors_delete



     smb_staff.rights << banking_create
     smb_staff.rights << banking_read
     smb_staff.rights << banking_update
     smb_staff.rights << banking_delete
    
    smb_inventory_manager.rights << banking_create
    smb_inventory_manager.rights << banking_read
    smb_inventory_manager.rights << banking_update
    smb_inventory_manager.rights << banking_delete
    
     smb_auditor.rights << banking_read
    smb_auditor.rights << customers_read
    smb_auditor.rights << vendors_read
end
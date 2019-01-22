ActiveRecord::Base.transaction do

  smb_plan = Plan.find_by_name('SMB')
  trial_plan = Plan.find_by_name('Trial')

  smb_owner = Role.find_by_name_and_plan_id('Owner', smb_plan)
  smb_accountant = Role.find_by_name_and_plan_id('Accountant', smb_plan)
  smb_auditor = Role.find_by_name_and_plan_id('Auditor', smb_plan)
  smb_staff = Role.find_by_name_and_plan_id('Staff', smb_plan)
  smb_employee = Role.find_by_name_and_plan_id('Employee', smb_plan)
  smb_inventory_manager = Role.find_by_name_and_plan_id('Inventory Manager', smb_plan)

  trial_owner = Role.find_by_name_and_plan_id('Owner', trial_plan)
  trial_accountant = Role.find_by_name_and_plan_id('Accountant', trial_plan)
  trial_auditor = Role.find_by_name_and_plan_id('Auditor', trial_plan)
  trial_staff = Role.find_by_name_and_plan_id('Staff', trial_plan)
  trial_employee = Role.find_by_name_and_plan_id('Employee', trial_plan)
  trial_inventory_manager = Role.find_by_name_and_plan_id('Inventory Manager', trial_plan)

# rights for voucher_titles terminology
  voucher_titles_create = Right.create!(:resource => 'voucher_titles', :operation => 'CREATE')
  voucher_titles_read = Right.create!(:resource => 'voucher_titles', :operation => 'READ') 
  voucher_titles_delete = Right.create!(:resource => 'voucher_titles', :operation => 'DELETE')
  voucher_titles_update = Right.create!(:resource => 'voucher_titles', :operation => 'UPDATE')

  
  
  # trial_owner    
     trial_owner.rights << voucher_titles_create
     trial_owner.rights << voucher_titles_read
     trial_owner.rights << voucher_titles_update
     trial_owner.rights << voucher_titles_delete

  # trial_accountant
     trial_accountant.rights << voucher_titles_create
     trial_accountant.rights << voucher_titles_read
     trial_accountant.rights << voucher_titles_update
     trial_accountant.rights << voucher_titles_delete

      trial_staff.rights << voucher_titles_create
      trial_staff.rights << voucher_titles_read
      trial_staff.rights << voucher_titles_update
      trial_staff.rights << voucher_titles_delete

      trial_inventory_manager.rights << voucher_titles_create
      trial_inventory_manager.rights << voucher_titles_read
      trial_inventory_manager.rights << voucher_titles_update
      trial_inventory_manager.rights << voucher_titles_delete
    
      trial_auditor.rights << voucher_titles_read
    
  # smb_owner 
     smb_owner.rights << voucher_titles_create
     smb_owner.rights << voucher_titles_read
     smb_owner.rights << voucher_titles_update
     smb_owner.rights << voucher_titles_delete

   
  # smb_accountant
     smb_accountant.rights << voucher_titles_create
     smb_accountant.rights << voucher_titles_read
     smb_accountant.rights << voucher_titles_update
     smb_accountant.rights << voucher_titles_delete

     smb_staff.rights << voucher_titles_create
     smb_staff.rights << voucher_titles_read
     smb_staff.rights << voucher_titles_update
     smb_staff.rights << voucher_titles_delete
    
    smb_inventory_manager.rights << voucher_titles_create
    smb_inventory_manager.rights << voucher_titles_read
    smb_inventory_manager.rights << voucher_titles_update
    smb_inventory_manager.rights << voucher_titles_delete
    
     smb_auditor.rights << voucher_titles_read
  # dropbox rights
   db_read = Right.find_by_resource_and_operation('db','READ')
     smb_owner.rights << db_read
     smb_accountant.rights << db_read
     smb_staff.rights << db_read
     smb_employee.rights << db_read
end
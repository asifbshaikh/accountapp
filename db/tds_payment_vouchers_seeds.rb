ActiveRecord::Base.transaction do

  professional_plan = Plan.find_by_name('Professional')
  enterprise_plan = Plan.find_by_name('Enterprise')
  trial_plan = Plan.find_by_name('Trial')
  smb_plan = Plan.find_by_name('SMB')
  free_plan = Plan.find_by_name('Free')
  basic_plan = Plan.find_by_name('Basic')


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



# rights for tds_payment_voucher terminology
  tds_payment_vouchers_create = Right.create!(:resource => 'tds_payment_vouchers', :operation => 'CREATE')
  tds_payment_vouchers_read = Right.create!(:resource => 'tds_payment_vouchers', :operation => 'READ') 
  tds_payment_vouchers_delete = Right.create!(:resource => 'tds_payment_vouchers', :operation => 'DELETE')
  tds_payment_vouchers_update = Right.create!(:resource => 'tds_payment_vouchers', :operation => 'UPDATE')

   # #free_owner  
      free_owner.rights << tds_payment_vouchers_create
      free_owner.rights << tds_payment_vouchers_read
      free_owner.rights << tds_payment_vouchers_update
      free_owner.rights << tds_payment_vouchers_delete
  
  # basic_owner  
      basic_owner.rights << tds_payment_vouchers_create
      basic_owner.rights << tds_payment_vouchers_read
      basic_owner.rights << tds_payment_vouchers_update
      basic_owner.rights << tds_payment_vouchers_delete
  #    basic_accountant
      basic_accountant.rights << tds_payment_vouchers_create
      basic_accountant.rights << tds_payment_vouchers_read
      basic_accountant.rights << tds_payment_vouchers_update
      basic_accountant.rights << tds_payment_vouchers_delete
  #   basic_staff
      basic_staff.rights << tds_payment_vouchers_create
      basic_staff.rights << tds_payment_vouchers_read
      basic_staff.rights << tds_payment_vouchers_update
      basic_staff.rights << tds_payment_vouchers_delete


     # #professional_owner  
      professional_owner.rights << tds_payment_vouchers_create
      professional_owner.rights << tds_payment_vouchers_read
      professional_owner.rights << tds_payment_vouchers_update
      professional_owner.rights << tds_payment_vouchers_delete
  #    professional_accountant
      professional_accountant.rights << tds_payment_vouchers_create
      professional_accountant.rights << tds_payment_vouchers_read
      professional_accountant.rights << tds_payment_vouchers_update
      professional_accountant.rights << tds_payment_vouchers_delete
 #   professional_staff
      professional_staff.rights << tds_payment_vouchers_create
      professional_staff.rights << tds_payment_vouchers_read
      professional_staff.rights << tds_payment_vouchers_update
      professional_staff.rights << tds_payment_vouchers_delete
    

  # enterprise_owner   
      enterprise_owner.rights << tds_payment_vouchers_create
      enterprise_owner.rights << tds_payment_vouchers_read
      enterprise_owner.rights << tds_payment_vouchers_update
      enterprise_owner.rights << tds_payment_vouchers_delete
  # enterprise_accountant
      enterprise_accountant.rights << tds_payment_vouchers_create
      enterprise_accountant.rights << tds_payment_vouchers_read
      enterprise_accountant.rights << tds_payment_vouchers_update
      enterprise_accountant.rights << tds_payment_vouchers_delete
   #   enterprise_staff
      enterprise_staff.rights << tds_payment_vouchers_create
      enterprise_staff.rights << tds_payment_vouchers_read
      enterprise_staff.rights << tds_payment_vouchers_update
      enterprise_staff.rights << tds_payment_vouchers_delete
 # enterprise_inventory_manager
      enterprise_inventory_manager.rights << tds_payment_vouchers_create
      enterprise_inventory_manager.rights << tds_payment_vouchers_read
      enterprise_inventory_manager.rights << tds_payment_vouchers_update
      enterprise_inventory_manager.rights << tds_payment_vouchers_delete


  # trial_owner    
     trial_owner.rights << tds_payment_vouchers_create
     trial_owner.rights << tds_payment_vouchers_read
     trial_owner.rights << tds_payment_vouchers_update
     trial_owner.rights << tds_payment_vouchers_delete
  # trial_accountant
     trial_accountant.rights << tds_payment_vouchers_create
     trial_accountant.rights << tds_payment_vouchers_read
     trial_accountant.rights << tds_payment_vouchers_update
     trial_accountant.rights << tds_payment_vouchers_delete
  #  trial_staff
      trial_staff.rights << tds_payment_vouchers_create
      trial_staff.rights << tds_payment_vouchers_read
      trial_staff.rights << tds_payment_vouchers_update
      trial_staff.rights << tds_payment_vouchers_delete
  # trial_inventory_manager
      trial_inventory_manager.rights << tds_payment_vouchers_create
      trial_inventory_manager.rights << tds_payment_vouchers_read
      trial_inventory_manager.rights << tds_payment_vouchers_update
      trial_inventory_manager.rights << tds_payment_vouchers_delete


  # smb_owner 
     smb_owner.rights << tds_payment_vouchers_create
     smb_owner.rights << tds_payment_vouchers_read
     smb_owner.rights << tds_payment_vouchers_update
     smb_owner.rights << tds_payment_vouchers_delete
  # smb_accountant
     smb_accountant.rights << tds_payment_vouchers_create
     smb_accountant.rights << tds_payment_vouchers_read
     smb_accountant.rights << tds_payment_vouchers_update
     smb_accountant.rights << tds_payment_vouchers_delete
#   smb_staff
      smb_staff.rights << tds_payment_vouchers_create
      smb_staff.rights << tds_payment_vouchers_read
      smb_staff.rights << tds_payment_vouchers_update
      smb_staff.rights << tds_payment_vouchers_delete
# smb_inventory_manager
      smb_inventory_manager.rights << tds_payment_vouchers_create
      smb_inventory_manager.rights << tds_payment_vouchers_read
      smb_inventory_manager.rights << tds_payment_vouchers_update
      smb_inventory_manager.rights << tds_payment_vouchers_delete


end
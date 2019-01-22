ActiveRecord::Base.transaction do
  professional_plan = Plan.find_by_name('Professional')
  enterprise_plan = Plan.find_by_name('Enterprise')
  trial_plan = Plan.find_by_name('Trial')
  smb_plan = Plan.find_by_name('SMB')
  free_plan = Plan.find_by_name('Free')
  basic_plan = Plan.find_by_name('Basic')
  
  basic_owner = Role.find_by_name_and_plan_id('Owner', basic_plan)
  basic_accountant = Role.find_by_name_and_plan_id('Accountant', basic_plan)
  basic_auditor = Role.find_by_name_and_plan_id('Auditor', basic_plan)
  basic_staff = Role.find_by_name_and_plan_id('Staff', basic_plan)
  

  professional_owner = Role.find_by_name_and_plan_id('Owner', professional_plan)
  professional_accountant = Role.find_by_name_and_plan_id('Accountant', professional_plan)
  professional_auditor = Role.find_by_name_and_plan_id('Auditor', professional_plan)
  professional_staff = Role.find_by_name_and_plan_id('Staff', professional_plan)

  enterprise_owner = Role.find_by_name_and_plan_id('Owner', enterprise_plan)
  enterprise_accountant = Role.find_by_name_and_plan_id('Accountant', enterprise_plan)
  enterprise_auditor = Role.find_by_name_and_plan_id('Auditor', enterprise_plan)
  enterprise_staff = Role.find_by_name_and_plan_id('Staff', enterprise_plan)
  enterprise_inventory_manager = Role.find_by_name_and_plan_id('Inventory Manager', enterprise_plan)

  trial_owner = Role.find_by_name_and_plan_id('Owner', trial_plan)
  trial_accountant = Role.find_by_name_and_plan_id('Accountant', trial_plan)
  trial_auditor = Role.find_by_name_and_plan_id('Auditor', trial_plan)
  trial_staff = Role.find_by_name_and_plan_id('Staff', trial_plan)
  trial_inventory_manager = Role.find_by_name_and_plan_id('Inventory Manager', trial_plan)
  
  smb_owner = Role.find_by_name_and_plan_id('Owner', smb_plan)
  smb_accountant = Role.find_by_name_and_plan_id('Accountant', smb_plan)
  smb_auditor = Role.find_by_name_and_plan_id('Auditor', smb_plan)
  smb_staff = Role.find_by_name_and_plan_id('Staff', smb_plan)
  smb_inventory_manager = Role.find_by_name_and_plan_id('Inventory Manager', smb_plan)

  Right.create!(:resource => 'debtor_aging', :operation => 'READ')
  Right.create!(:resource => 'debtor_aging', :operation => 'CREATE')
  Right.create!(:resource => 'debtor_aging', :operation => 'UPDATE')
  Right.create!(:resource => 'debtor_aging', :operation => 'DELETE')
 

  debtor_aging_create = Right.find_by_resource_and_operation('debtor_aging', 'CREATE')
  debtor_aging_read = Right.find_by_resource_and_operation('debtor_aging', 'READ')
  debtor_aging_delete = Right.find_by_resource_and_operation('debtor_aging', 'DELETE')
  debtor_aging_update = Right.find_by_resource_and_operation('debtor_aging', 'UPDATE')

  enterprise_owner.rights << debtor_aging_create
  enterprise_owner.rights << debtor_aging_read
  enterprise_owner.rights << debtor_aging_update
  enterprise_owner.rights << debtor_aging_delete

  enterprise_accountant.rights << debtor_aging_create
  enterprise_accountant.rights << debtor_aging_read
  enterprise_accountant.rights << debtor_aging_update
  enterprise_accountant.rights << debtor_aging_delete

  enterprise_auditor.rights << debtor_aging_create
  enterprise_auditor.rights << debtor_aging_read
  enterprise_auditor.rights << debtor_aging_update
  enterprise_auditor.rights << debtor_aging_delete

  enterprise_staff.rights << debtor_aging_create
  enterprise_staff.rights << debtor_aging_read
  enterprise_staff.rights << debtor_aging_update
  enterprise_staff.rights << debtor_aging_delete


  enterprise_inventory_manager.rights << debtor_aging_create
  enterprise_inventory_manager.rights << debtor_aging_read
  enterprise_inventory_manager.rights << debtor_aging_update
  enterprise_inventory_manager.rights << debtor_aging_delete

  professional_owner.rights << debtor_aging_create
  professional_owner.rights << debtor_aging_read
  professional_owner.rights << debtor_aging_update
  professional_owner.rights << debtor_aging_delete

  professional_accountant.rights << debtor_aging_create
  professional_accountant.rights << debtor_aging_read
  professional_accountant.rights << debtor_aging_update
  professional_accountant.rights << debtor_aging_delete

  professional_auditor.rights << debtor_aging_create
  professional_auditor.rights << debtor_aging_read
  professional_auditor.rights << debtor_aging_update
  professional_auditor.rights << debtor_aging_delete

  professional_staff.rights << debtor_aging_create
  professional_staff.rights << debtor_aging_read
  professional_staff.rights << debtor_aging_update
  professional_staff.rights << debtor_aging_delete

  trial_owner.rights << debtor_aging_create
  trial_owner.rights << debtor_aging_read
  trial_owner.rights << debtor_aging_update
  trial_owner.rights << debtor_aging_delete

  trial_accountant.rights << debtor_aging_create
  trial_accountant.rights << debtor_aging_read
  trial_accountant.rights << debtor_aging_update
  trial_accountant.rights << debtor_aging_delete

  trial_auditor.rights << debtor_aging_create
  trial_auditor.rights << debtor_aging_read
  trial_auditor.rights << debtor_aging_update
  trial_auditor.rights << debtor_aging_delete

  trial_staff.rights << debtor_aging_create
  trial_staff.rights << debtor_aging_read
  trial_staff.rights << debtor_aging_update
  trial_staff.rights << debtor_aging_delete


  trial_inventory_manager.rights << debtor_aging_create
  trial_inventory_manager.rights << debtor_aging_read
  trial_inventory_manager.rights << debtor_aging_update
  trial_inventory_manager.rights << debtor_aging_delete

  smb_owner.rights << debtor_aging_create
  smb_owner.rights << debtor_aging_read
  smb_owner.rights << debtor_aging_update
  smb_owner.rights << debtor_aging_delete

  smb_accountant.rights << debtor_aging_create
  smb_accountant.rights << debtor_aging_read
  smb_accountant.rights << debtor_aging_update
  smb_accountant.rights << debtor_aging_delete

  smb_auditor.rights << debtor_aging_create
  smb_auditor.rights << debtor_aging_read
  smb_auditor.rights << debtor_aging_update
  smb_auditor.rights << debtor_aging_delete

  smb_staff.rights << debtor_aging_create
  smb_staff.rights << debtor_aging_read
  smb_staff.rights << debtor_aging_update
  smb_staff.rights << debtor_aging_delete


  smb_inventory_manager.rights << debtor_aging_create
  smb_inventory_manager.rights << debtor_aging_read
  smb_inventory_manager.rights << debtor_aging_update
  smb_inventory_manager.rights << debtor_aging_delete


  basic_owner.rights << debtor_aging_create
  basic_owner.rights << debtor_aging_read
  basic_owner.rights << debtor_aging_update
  basic_owner.rights << debtor_aging_delete

  basic_accountant.rights << debtor_aging_create
  basic_accountant.rights << debtor_aging_read
  basic_accountant.rights << debtor_aging_update
  basic_accountant.rights << debtor_aging_delete

  basic_auditor.rights << debtor_aging_create
  basic_auditor.rights << debtor_aging_read
  basic_auditor.rights << debtor_aging_update
  basic_auditor.rights << debtor_aging_delete

  basic_staff.rights << debtor_aging_create
  basic_staff.rights << debtor_aging_read
  basic_staff.rights << debtor_aging_update
  basic_staff.rights << debtor_aging_delete
  
end

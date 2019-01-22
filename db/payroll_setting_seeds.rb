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
  basic_employee = Role.find_by_name_and_plan_id('Employee', basic_plan)


  professional_owner = Role.find_by_name_and_plan_id('Owner', professional_plan)
  professional_accountant = Role.find_by_name_and_plan_id('Accountant', professional_plan)
  professional_auditor = Role.find_by_name_and_plan_id('Auditor', professional_plan)
  professional_staff = Role.find_by_name_and_plan_id('Staff', professional_plan)
  professional_employee = Role.find_by_name_and_plan_id('Employee', professional_plan)

  enterprise_owner = Role.find_by_name_and_plan_id('Owner', enterprise_plan)
  enterprise_accountant = Role.find_by_name_and_plan_id('Accountant', enterprise_plan)
  enterprise_auditor = Role.find_by_name_and_plan_id('Auditor', enterprise_plan)
  enterprise_staff = Role.find_by_name_and_plan_id('Staff', enterprise_plan)
  enterprise_inventory_manager = Role.find_by_name_and_plan_id('Inventory Manager', enterprise_plan)
  enterprise_employee = Role.find_by_name_and_plan_id('Employee', enterprise_plan)

  trial_owner = Role.find_by_name_and_plan_id('Owner', trial_plan)
  trial_accountant = Role.find_by_name_and_plan_id('Accountant', trial_plan)
  trial_auditor = Role.find_by_name_and_plan_id('Auditor', trial_plan)
  trial_staff = Role.find_by_name_and_plan_id('Staff', trial_plan)
  trial_inventory_manager = Role.find_by_name_and_plan_id('Inventory Manager', trial_plan)
  trial_employee = Role.find_by_name_and_plan_id('Employee',  trial_plan)

  smb_owner = Role.find_by_name_and_plan_id('Owner', smb_plan)
  smb_accountant = Role.find_by_name_and_plan_id('Accountant', smb_plan)
  smb_auditor = Role.find_by_name_and_plan_id('Auditor', smb_plan)
  smb_staff = Role.find_by_name_and_plan_id('Staff', smb_plan)
  smb_inventory_manager = Role.find_by_name_and_plan_id('Inventory Manager', smb_plan)
  smb_employee = Role.find_by_name_and_plan_id('Employee', smb_plan)

  Right.create!(:resource => 'payroll_settings', :operation => 'READ')
  Right.create!(:resource => 'payroll_settings', :operation => 'CREATE')
  Right.create!(:resource => 'payroll_settings', :operation => 'UPDATE')
  Right.create!(:resource => 'payroll_settings', :operation => 'DELETE')


  payroll_settings_create = Right.find_by_resource_and_operation('payroll_settings', 'CREATE')
  payroll_settings_read = Right.find_by_resource_and_operation('payroll_settings', 'READ')
  payroll_settings_delete = Right.find_by_resource_and_operation('payroll_settings', 'DELETE')
  payroll_settings_update = Right.find_by_resource_and_operation('payroll_settings', 'UPDATE')

  enterprise_owner.rights << payroll_settings_create
  enterprise_owner.rights << payroll_settings_read
  enterprise_owner.rights << payroll_settings_update
  enterprise_owner.rights << payroll_settings_delete

  enterprise_accountant.rights << payroll_settings_create
  enterprise_accountant.rights << payroll_settings_read
  enterprise_accountant.rights << payroll_settings_update
  enterprise_accountant.rights << payroll_settings_delete

  professional_owner.rights << payroll_settings_create
  professional_owner.rights << payroll_settings_read
  professional_owner.rights << payroll_settings_update
  professional_owner.rights << payroll_settings_delete

  professional_accountant.rights << payroll_settings_create
  professional_accountant.rights << payroll_settings_read
  professional_accountant.rights << payroll_settings_update
  professional_accountant.rights << payroll_settings_delete

  trial_owner.rights << payroll_settings_create
  trial_owner.rights << payroll_settings_read
  trial_owner.rights << payroll_settings_update
  trial_owner.rights << payroll_settings_delete

  trial_accountant.rights << payroll_settings_create
  trial_accountant.rights << payroll_settings_read
  trial_accountant.rights << payroll_settings_update
  trial_accountant.rights << payroll_settings_delete

  smb_owner.rights << payroll_settings_create
  smb_owner.rights << payroll_settings_read
  smb_owner.rights << payroll_settings_update
  smb_owner.rights << payroll_settings_delete

  smb_accountant.rights << payroll_settings_create
  smb_accountant.rights << payroll_settings_read
  smb_accountant.rights << payroll_settings_update
  smb_accountant.rights << payroll_settings_delete

  basic_owner.rights << payroll_settings_create
  basic_owner.rights << payroll_settings_read
  basic_owner.rights << payroll_settings_update
  basic_owner.rights << payroll_settings_delete

  basic_accountant.rights << payroll_settings_create
  basic_accountant.rights << payroll_settings_read
  basic_accountant.rights << payroll_settings_update
  basic_accountant.rights << payroll_settings_delete

end

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

  Right.create!(:resource => 'invoice_attachments', :operation => 'READ')
  Right.create!(:resource => 'invoice_attachments', :operation => 'CREATE')
  Right.create!(:resource => 'invoice_attachments', :operation => 'UPDATE')
  Right.create!(:resource => 'invoice_attachments', :operation => 'DELETE')


  invoice_attachment_create = Right.find_by_resource_and_operation('invoice_attachments', 'CREATE')
  invoice_attachment_read = Right.find_by_resource_and_operation('invoice_attachments', 'READ')
  invoice_attachment_delete = Right.find_by_resource_and_operation('invoice_attachments', 'DELETE')
  invoice_attachment_update = Right.find_by_resource_and_operation('invoice_attachments', 'UPDATE')

  enterprise_owner.rights << invoice_attachment_create
  enterprise_owner.rights << invoice_attachment_read
  enterprise_owner.rights << invoice_attachment_update
  enterprise_owner.rights << invoice_attachment_delete

  enterprise_accountant.rights << invoice_attachment_create
  enterprise_accountant.rights << invoice_attachment_read
  enterprise_accountant.rights << invoice_attachment_update
  enterprise_accountant.rights << invoice_attachment_delete

  enterprise_auditor.rights << invoice_attachment_create
  enterprise_auditor.rights << invoice_attachment_read
  enterprise_auditor.rights << invoice_attachment_update
  enterprise_auditor.rights << invoice_attachment_delete

  enterprise_staff.rights << invoice_attachment_create
  enterprise_staff.rights << invoice_attachment_read
  enterprise_staff.rights << invoice_attachment_update
  enterprise_staff.rights << invoice_attachment_delete


  enterprise_inventory_manager.rights << invoice_attachment_create
  enterprise_inventory_manager.rights << invoice_attachment_read
  enterprise_inventory_manager.rights << invoice_attachment_update
  enterprise_inventory_manager.rights << invoice_attachment_delete

  enterprise_employee.rights << invoice_attachment_create
  enterprise_employee.rights << invoice_attachment_read
  enterprise_employee.rights << invoice_attachment_update
  enterprise_employee.rights << invoice_attachment_delete

  professional_owner.rights << invoice_attachment_create
  professional_owner.rights << invoice_attachment_read
  professional_owner.rights << invoice_attachment_update
  professional_owner.rights << invoice_attachment_delete

  professional_accountant.rights << invoice_attachment_create
  professional_accountant.rights << invoice_attachment_read
  professional_accountant.rights << invoice_attachment_update
  professional_accountant.rights << invoice_attachment_delete

  professional_auditor.rights << invoice_attachment_create
  professional_auditor.rights << invoice_attachment_read
  professional_auditor.rights << invoice_attachment_update
  professional_auditor.rights << invoice_attachment_delete

  professional_staff.rights << invoice_attachment_create
  professional_staff.rights << invoice_attachment_read
  professional_staff.rights << invoice_attachment_update
  professional_staff.rights << invoice_attachment_delete

  professional_employee.rights << invoice_attachment_create
  professional_employee.rights << invoice_attachment_read
  professional_employee.rights << invoice_attachment_update
  professional_employee.rights << invoice_attachment_delete

  trial_owner.rights << invoice_attachment_create
  trial_owner.rights << invoice_attachment_read
  trial_owner.rights << invoice_attachment_update
  trial_owner.rights << invoice_attachment_delete

  trial_accountant.rights << invoice_attachment_create
  trial_accountant.rights << invoice_attachment_read
  trial_accountant.rights << invoice_attachment_update
  trial_accountant.rights << invoice_attachment_delete

  trial_auditor.rights << invoice_attachment_create
  trial_auditor.rights << invoice_attachment_read
  trial_auditor.rights << invoice_attachment_update
  trial_auditor.rights << invoice_attachment_delete

  trial_staff.rights << invoice_attachment_create
  trial_staff.rights << invoice_attachment_read
  trial_staff.rights << invoice_attachment_update
  trial_staff.rights << invoice_attachment_delete


  trial_inventory_manager.rights << invoice_attachment_create
  trial_inventory_manager.rights << invoice_attachment_read
  trial_inventory_manager.rights << invoice_attachment_update
  trial_inventory_manager.rights << invoice_attachment_delete

  trial_employee.rights << invoice_attachment_create
  trial_employee.rights << invoice_attachment_read
  trial_employee.rights << invoice_attachment_update
  trial_employee.rights << invoice_attachment_delete


  smb_owner.rights << invoice_attachment_create
  smb_owner.rights << invoice_attachment_read
  smb_owner.rights << invoice_attachment_update
  smb_owner.rights << invoice_attachment_delete

  smb_accountant.rights << invoice_attachment_create
  smb_accountant.rights << invoice_attachment_read
  smb_accountant.rights << invoice_attachment_update
  smb_accountant.rights << invoice_attachment_delete

  smb_auditor.rights << invoice_attachment_create
  smb_auditor.rights << invoice_attachment_read
  smb_auditor.rights << invoice_attachment_update
  smb_auditor.rights << invoice_attachment_delete

  smb_staff.rights << invoice_attachment_create
  smb_staff.rights << invoice_attachment_read
  smb_staff.rights << invoice_attachment_update
  smb_staff.rights << invoice_attachment_delete


  smb_inventory_manager.rights << invoice_attachment_create
  smb_inventory_manager.rights << invoice_attachment_read
  smb_inventory_manager.rights << invoice_attachment_update
  smb_inventory_manager.rights << invoice_attachment_delete

  smb_employee.rights << invoice_attachment_create
  smb_employee.rights << invoice_attachment_read
  smb_employee.rights << invoice_attachment_update
  smb_employee.rights << invoice_attachment_delete


  basic_owner.rights << invoice_attachment_create
  basic_owner.rights << invoice_attachment_read
  basic_owner.rights << invoice_attachment_update
  basic_owner.rights << invoice_attachment_delete

  basic_accountant.rights << invoice_attachment_create
  basic_accountant.rights << invoice_attachment_read
  basic_accountant.rights << invoice_attachment_update
  basic_accountant.rights << invoice_attachment_delete

  basic_auditor.rights << invoice_attachment_create
  basic_auditor.rights << invoice_attachment_read
  basic_auditor.rights << invoice_attachment_update
  basic_auditor.rights << invoice_attachment_delete

  basic_staff.rights << invoice_attachment_create
  basic_staff.rights << invoice_attachment_read
  basic_staff.rights << invoice_attachment_update
  basic_staff.rights << invoice_attachment_delete


  basic_employee.rights << invoice_attachment_create
  basic_employee.rights << invoice_attachment_read
  basic_employee.rights << invoice_attachment_update
  basic_employee.rights << invoice_attachment_delete



  #PAYROLL SETTINGS
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


  #PURCHASE ATTACHMENT

  Right.create!(:resource => 'purchase_attachments', :operation => 'READ')
  Right.create!(:resource => 'purchase_attachments', :operation => 'CREATE')
  Right.create!(:resource => 'purchase_attachments', :operation => 'UPDATE')
  Right.create!(:resource => 'purchase_attachments', :operation => 'DELETE')


  purchase_attachment_create = Right.find_by_resource_and_operation('purchase_attachments', 'CREATE')
  purchase_attachment_read = Right.find_by_resource_and_operation('purchase_attachments', 'READ')
  purchase_attachment_delete = Right.find_by_resource_and_operation('purchase_attachments', 'DELETE')
  purchase_attachment_update = Right.find_by_resource_and_operation('purchase_attachments', 'UPDATE')

  enterprise_owner.rights << purchase_attachment_create
  enterprise_owner.rights << purchase_attachment_read
  enterprise_owner.rights << purchase_attachment_update
  enterprise_owner.rights << purchase_attachment_delete

  enterprise_accountant.rights << purchase_attachment_create
  enterprise_accountant.rights << purchase_attachment_read
  enterprise_accountant.rights << purchase_attachment_update
  enterprise_accountant.rights << purchase_attachment_delete

  enterprise_auditor.rights << purchase_attachment_create
  enterprise_auditor.rights << purchase_attachment_read
  enterprise_auditor.rights << purchase_attachment_update
  enterprise_auditor.rights << purchase_attachment_delete

  enterprise_staff.rights << purchase_attachment_create
  enterprise_staff.rights << purchase_attachment_read
  enterprise_staff.rights << purchase_attachment_update
  enterprise_staff.rights << purchase_attachment_delete


  enterprise_inventory_manager.rights << purchase_attachment_create
  enterprise_inventory_manager.rights << purchase_attachment_read
  enterprise_inventory_manager.rights << purchase_attachment_update
  enterprise_inventory_manager.rights << purchase_attachment_delete

  enterprise_employee.rights << purchase_attachment_create
  enterprise_employee.rights << purchase_attachment_read
  enterprise_employee.rights << purchase_attachment_update
  enterprise_employee.rights << purchase_attachment_delete

  professional_owner.rights << purchase_attachment_create
  professional_owner.rights << purchase_attachment_read
  professional_owner.rights << purchase_attachment_update
  professional_owner.rights << purchase_attachment_delete

  professional_accountant.rights << purchase_attachment_create
  professional_accountant.rights << purchase_attachment_read
  professional_accountant.rights << purchase_attachment_update
  professional_accountant.rights << purchase_attachment_delete

  professional_auditor.rights << purchase_attachment_create
  professional_auditor.rights << purchase_attachment_read
  professional_auditor.rights << purchase_attachment_update
  professional_auditor.rights << purchase_attachment_delete

  professional_staff.rights << purchase_attachment_create
  professional_staff.rights << purchase_attachment_read
  professional_staff.rights << purchase_attachment_update
  professional_staff.rights << purchase_attachment_delete

  professional_employee.rights << purchase_attachment_create
  professional_employee.rights << purchase_attachment_read
  professional_employee.rights << purchase_attachment_update
  professional_employee.rights << purchase_attachment_delete

  trial_owner.rights << purchase_attachment_create
  trial_owner.rights << purchase_attachment_read
  trial_owner.rights << purchase_attachment_update
  trial_owner.rights << purchase_attachment_delete

  trial_accountant.rights << purchase_attachment_create
  trial_accountant.rights << purchase_attachment_read
  trial_accountant.rights << purchase_attachment_update
  trial_accountant.rights << purchase_attachment_delete

  trial_auditor.rights << purchase_attachment_create
  trial_auditor.rights << purchase_attachment_read
  trial_auditor.rights << purchase_attachment_update
  trial_auditor.rights << purchase_attachment_delete

  trial_staff.rights << purchase_attachment_create
  trial_staff.rights << purchase_attachment_read
  trial_staff.rights << purchase_attachment_update
  trial_staff.rights << purchase_attachment_delete


  trial_inventory_manager.rights << purchase_attachment_create
  trial_inventory_manager.rights << purchase_attachment_read
  trial_inventory_manager.rights << purchase_attachment_update
  trial_inventory_manager.rights << purchase_attachment_delete

  trial_employee.rights << purchase_attachment_create
  trial_employee.rights << purchase_attachment_read
  trial_employee.rights << purchase_attachment_update
  trial_employee.rights << purchase_attachment_delete


  smb_owner.rights << purchase_attachment_create
  smb_owner.rights << purchase_attachment_read
  smb_owner.rights << purchase_attachment_update
  smb_owner.rights << purchase_attachment_delete

  smb_accountant.rights << purchase_attachment_create
  smb_accountant.rights << purchase_attachment_read
  smb_accountant.rights << purchase_attachment_update
  smb_accountant.rights << purchase_attachment_delete

  smb_auditor.rights << purchase_attachment_create
  smb_auditor.rights << purchase_attachment_read
  smb_auditor.rights << purchase_attachment_update
  smb_auditor.rights << purchase_attachment_delete

  smb_staff.rights << purchase_attachment_create
  smb_staff.rights << purchase_attachment_read
  smb_staff.rights << purchase_attachment_update
  smb_staff.rights << purchase_attachment_delete


  smb_inventory_manager.rights << purchase_attachment_create
  smb_inventory_manager.rights << purchase_attachment_read
  smb_inventory_manager.rights << purchase_attachment_update
  smb_inventory_manager.rights << purchase_attachment_delete

  smb_employee.rights << purchase_attachment_create
  smb_employee.rights << purchase_attachment_read
  smb_employee.rights << purchase_attachment_update
  smb_employee.rights << purchase_attachment_delete


  basic_owner.rights << purchase_attachment_create
  basic_owner.rights << purchase_attachment_read
  basic_owner.rights << purchase_attachment_update
  basic_owner.rights << purchase_attachment_delete

  basic_accountant.rights << purchase_attachment_create
  basic_accountant.rights << purchase_attachment_read
  basic_accountant.rights << purchase_attachment_update
  basic_accountant.rights << purchase_attachment_delete

  basic_auditor.rights << purchase_attachment_create
  basic_auditor.rights << purchase_attachment_read
  basic_auditor.rights << purchase_attachment_update
  basic_auditor.rights << purchase_attachment_delete

  basic_staff.rights << purchase_attachment_create
  basic_staff.rights << purchase_attachment_read
  basic_staff.rights << purchase_attachment_update
  basic_staff.rights << purchase_attachment_delete


  basic_employee.rights << purchase_attachment_create
  basic_employee.rights << purchase_attachment_read
  basic_employee.rights << purchase_attachment_update
  basic_employee.rights << purchase_attachment_delete


end

ActiveRecord::Base.transaction do
  professional_plan = Plan.find_by_name('Professional')
  enterprise_plan = Plan.find_by_name('Enterprise')
  trial_plan = Plan.find_by_name('Trial')
  smb_plan = Plan.find_by_name('SMB')
  essential_plan = Plan.find_by_name('Essential')
  free_plan = Plan.find_by_name('PWYW')
  
  professional_owner = Role.find_by_name_and_plan_id('Owner', professional_plan)
  professional_accountant = Role.find_by_name_and_plan_id('Accountant', professional_plan)
  professional_inventory_manager = Role.find_by_name_and_plan_id('Inventory Manager', professional_plan)
  professional_staff = Role.find_by_name_and_plan_id('Staff', professional_plan)
  professional_auditor = Role.find_by_name_and_plan_id('Auditor', professional_plan)

  enterprise_owner = Role.find_by_name_and_plan_id('Owner', enterprise_plan)
  enterprise_accountant = Role.find_by_name_and_plan_id('Accountant', enterprise_plan)
  enterprise_inventory_manager = Role.find_by_name_and_plan_id('Inventory Manager', enterprise_plan)
  enterprise_staff = Role.find_by_name_and_plan_id('Staff', enterprise_plan)
  enterprise_auditor = Role.find_by_name_and_plan_id('Auditor', enterprise_plan)

  trial_owner = Role.find_by_name_and_plan_id('Owner', trial_plan)
  trial_accountant = Role.find_by_name_and_plan_id('Accountant', trial_plan)
  trial_inventory_manager = Role.find_by_name_and_plan_id('Inventory Manager', trial_plan)
  trial_staff = Role.find_by_name_and_plan_id('Staff', trial_plan)
  trial_auditor = Role.find_by_name_and_plan_id('Auditor', trial_plan)
  
  smb_owner = Role.find_by_name_and_plan_id('Owner', smb_plan)
  smb_accountant = Role.find_by_name_and_plan_id('Accountant', smb_plan)
  smb_inventory_manager = Role.find_by_name_and_plan_id('Inventory Manager', smb_plan)
  smb_staff = Role.find_by_name_and_plan_id('Staff', smb_plan)
  smb_auditor = Role.find_by_name_and_plan_id('Auditor', smb_plan)

  essential_owner = Role.find_by_name_and_plan_id('Owner', essential_plan)
  essential_accountant = Role.find_by_name_and_plan_id('Accountant', essential_plan)
  essential_staff = Role.find_by_name_and_plan_id('Staff', essential_plan)
  essential_auditor = Role.find_by_name_and_plan_id('Auditor', essential_plan)

  free_owner = Role.find_by_name_and_plan_id('Owner', free_plan)

# bank statement rights and roles
  bank_statements_create = Right.create!(:resource => 'bank_statements', :operation => 'CREATE')
  bank_statements_read = Right.create!(:resource => 'bank_statements', :operation => 'READ')
  bank_statements_delete = Right.create!(:resource=>'bank_statements', :operation=>'DELETE')
  bank_statements_update = Right.create!(:resource => 'bank_statements', :operation => 'UPDATE')

  
  # professional_owner  
  professional_owner.rights << bank_statements_create
  professional_owner.rights << bank_statements_read
  professional_owner.rights << bank_statements_update
  professional_owner.rights << bank_statements_delete
  # professional_accountant
  professional_accountant.rights << bank_statements_create
  professional_accountant.rights << bank_statements_read
  professional_accountant.rights << bank_statements_update
  professional_accountant.rights << bank_statements_delete
  # professional_staff
  professional_staff.rights << bank_statements_create
  professional_staff.rights << bank_statements_read
  professional_staff.rights << bank_statements_update
  professional_staff.rights << bank_statements_delete
  # professional_auditor
  professional_auditor.rights << bank_statements_read

  #enterprise_owner  
  enterprise_owner.rights << bank_statements_create
  enterprise_owner.rights << bank_statements_read
  enterprise_owner.rights << bank_statements_update
  enterprise_owner.rights << bank_statements_delete
  # enterprise_accountant
  enterprise_accountant.rights << bank_statements_create
  enterprise_accountant.rights << bank_statements_read
  enterprise_accountant.rights << bank_statements_update
  enterprise_accountant.rights << bank_statements_delete
  # enterprise_staff
  enterprise_staff.rights << bank_statements_create
  enterprise_staff.rights << bank_statements_read
  enterprise_staff.rights << bank_statements_update
  enterprise_staff.rights << bank_statements_delete
  # enterprise_auditor
  enterprise_auditor.rights << bank_statements_read

 #trial_owner  
  trial_owner.rights << bank_statements_create
  trial_owner.rights << bank_statements_read
  trial_owner.rights << bank_statements_update
  trial_owner.rights << bank_statements_delete
  # trial_accountant
  trial_accountant.rights << bank_statements_create
  trial_accountant.rights << bank_statements_read
  trial_accountant.rights << bank_statements_update
  trial_accountant.rights << bank_statements_delete
  # trial_staff
  trial_staff.rights << bank_statements_create
  trial_staff.rights << bank_statements_read
  trial_staff.rights << bank_statements_update
  trial_staff.rights << bank_statements_delete
  # trial_auditor
  trial_auditor.rights << bank_statements_read

#smb_owner  
  smb_owner.rights << bank_statements_create
  smb_owner.rights << bank_statements_read
  smb_owner.rights << bank_statements_update
  smb_owner.rights << bank_statements_delete
  # smb_accountant
  smb_accountant.rights << bank_statements_create
  smb_accountant.rights << bank_statements_read
  smb_accountant.rights << bank_statements_update
  smb_accountant.rights << bank_statements_delete
  # smb_staff
  smb_staff.rights << bank_statements_create
  smb_staff.rights << bank_statements_read
  smb_staff.rights << bank_statements_update
  smb_staff.rights << bank_statements_delete
  # smb_auditor
  smb_auditor.rights << bank_statements_read

#essential_owner  
  essential_owner.rights << bank_statements_create
  essential_owner.rights << bank_statements_read
  essential_owner.rights << bank_statements_update
  essential_owner.rights << bank_statements_delete
  # essential_accountant
  essential_accountant.rights << bank_statements_create
  essential_accountant.rights << bank_statements_read
  essential_accountant.rights << bank_statements_update
  essential_accountant.rights << bank_statements_delete
  # essential_staff
  essential_staff.rights << bank_statements_create
  essential_staff.rights << bank_statements_read
  essential_staff.rights << bank_statements_update
  essential_staff.rights << bank_statements_delete
  # essential_auditor
  essential_auditor.rights << bank_statements_read

  # from seeds3.9
  gain_or_loss_report_read = Right.create!(:resource=>'gain_or_loss_report', :operation=>'READ') 

  #free owner
  free_owner.rights << gain_or_loss_report_read
  
  # essential_owner
  essential_owner.rights<<gain_or_loss_report_read
  # essential_accountant
  essential_accountant.rights<<gain_or_loss_report_read
  # essential_auditor
  essential_auditor.rights<<gain_or_loss_report_read


  # smb_owner
  smb_owner.rights<<gain_or_loss_report_read
  # smb_accountant
  smb_accountant.rights<<gain_or_loss_report_read
  # smb_auditor
  smb_auditor.rights<<gain_or_loss_report_read

  # enterprise_owner
  enterprise_owner.rights<<gain_or_loss_report_read
  # enterprise_accountant
  enterprise_accountant.rights<<gain_or_loss_report_read
  # enterprise_auditor
  enterprise_auditor.rights<<gain_or_loss_report_read

  # trial_owner
  trial_owner.rights<<gain_or_loss_report_read
  # trial_accountant
  trial_accountant.rights<<gain_or_loss_report_read
  # trial_auditor
  trial_auditor.rights<<gain_or_loss_report_read

  # professional_owner
  professional_owner.rights<<gain_or_loss_report_read
  # professional_accountant
  professional_accountant.rights<<gain_or_loss_report_read
  # professional_auditor
  professional_auditor.rights<<gain_or_loss_report_read

  # new customer and vendor rights for enterprise plan
  customers_create = Right.find_by_resource_and_operation('customers','CREATE')
  customers_read = Right.find_by_resource_and_operation('customers','READ') 
  customers_update = Right.find_by_resource_and_operation('customers','UPDATE')

  vendors_create = Right.find_by_resource_and_operation('vendors','CREATE')
  vendors_read = Right.find_by_resource_and_operation('vendors','READ') 
  vendors_update = Right.find_by_resource_and_operation('vendors','UPDATE')

# enterprise_staff
      enterprise_staff.rights << customers_create
      enterprise_staff.rights << customers_read
      enterprise_staff.rights << customers_update

      enterprise_staff.rights << vendors_create
      enterprise_staff.rights << vendors_read
      enterprise_staff.rights << vendors_update

# enterprise_inventory_manager
      enterprise_inventory_manager.rights << customers_create
      enterprise_inventory_manager.rights << customers_read
      enterprise_inventory_manager.rights << customers_update

      enterprise_inventory_manager.rights << vendors_create
      enterprise_inventory_manager.rights << vendors_read
      enterprise_inventory_manager.rights << vendors_update
end
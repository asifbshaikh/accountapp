ActiveRecord::Base.transaction do
	professional_plan = Plan.find_by_name('Professional')
	enterprise_plan = Plan.find_by_name('Enterprise')
	trial_plan = Plan.find_by_name('Trial')
	smb_plan = Plan.find_by_name('SMB')
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

  free_owner = Role.find_by_name_and_plan_id('Owner', free_plan)

#sales order rights and roles
  sales_orders_create = Right.create!(:resource => 'sales_orders', :operation => 'CREATE')
  sales_orders_read = Right.create!(:resource => 'sales_orders', :operation => 'READ')
  sales_orders_delete = Right.create!(:resource=>'sales_orders', :operation=>'DELETE')
  sales_orders_update = Right.create!(:resource => 'sales_orders', :operation => 'UPDATE')

  #enterprise_owner  
  enterprise_owner.rights << sales_orders_create
  enterprise_owner.rights << sales_orders_read
  enterprise_owner.rights << sales_orders_update
  enterprise_owner.rights << sales_orders_delete
  # enterprise_accountant
  enterprise_accountant.rights << sales_orders_create
  enterprise_accountant.rights << sales_orders_read
  enterprise_accountant.rights << sales_orders_update
  enterprise_accountant.rights << sales_orders_delete
  # enterprise_staff
  enterprise_staff.rights << sales_orders_create
  enterprise_staff.rights << sales_orders_read
  enterprise_staff.rights << sales_orders_update
  enterprise_staff.rights << sales_orders_delete
  
  #enterprise inventory manager
  enterprise_inventory_manager.rights << sales_orders_read
  enterprise_inventory_manager.rights << sales_orders_update
  enterprise_inventory_manager.rights << sales_orders_delete
  # enterprise_auditor
  enterprise_auditor.rights << sales_orders_read

 #trial_owner  
  trial_owner.rights << sales_orders_create
  trial_owner.rights << sales_orders_read
  trial_owner.rights << sales_orders_update
  trial_owner.rights << sales_orders_delete
  # trial_accountant
  trial_accountant.rights << sales_orders_create
  trial_accountant.rights << sales_orders_read
  trial_accountant.rights << sales_orders_update
  trial_accountant.rights << sales_orders_delete
  # trial_staff
  trial_staff.rights << sales_orders_create
  trial_staff.rights << sales_orders_read
  trial_staff.rights << sales_orders_update
  trial_staff.rights << sales_orders_delete
  #trial inventory manager
  trial_inventory_manager.rights << sales_orders_read
  trial_inventory_manager.rights << sales_orders_update
  trial_inventory_manager.rights << sales_orders_delete
  # trial_auditor
  trial_auditor.rights << sales_orders_read

#smb_owner  
  smb_owner.rights << sales_orders_create
  smb_owner.rights << sales_orders_read
  smb_owner.rights << sales_orders_update
  smb_owner.rights << sales_orders_delete
  # smb_accountant
  smb_accountant.rights << sales_orders_create
  smb_accountant.rights << sales_orders_read
  smb_accountant.rights << sales_orders_update
  smb_accountant.rights << sales_orders_delete
  # smb_staff
  smb_staff.rights << sales_orders_create
  smb_staff.rights << sales_orders_read
  smb_staff.rights << sales_orders_update
  smb_staff.rights << sales_orders_delete
  #smb inventory manager
  smb_inventory_manager.rights << sales_orders_read
  smb_inventory_manager.rights << sales_orders_update
  smb_inventory_manager.rights << sales_orders_delete
  # smb_auditor
  smb_auditor.rights << sales_orders_read

#delivery challan rights and roles
  delivery_challans_create = Right.create!(:resource => 'delivery_challans', :operation => 'CREATE')
  delivery_challans_read = Right.create!(:resource => 'delivery_challans', :operation => 'READ')
  delivery_challans_delete = Right.create!(:resource=>'delivery_challans', :operation=>'DELETE')
  delivery_challans_update = Right.create!(:resource => 'delivery_challans', :operation => 'UPDATE')


  #enterprise_owner  
  enterprise_owner.rights << delivery_challans_create
  enterprise_owner.rights << delivery_challans_read
  enterprise_owner.rights << delivery_challans_update
  enterprise_owner.rights << delivery_challans_delete
  # enterprise_accountant
  enterprise_accountant.rights << delivery_challans_create
  enterprise_accountant.rights << delivery_challans_read
  enterprise_accountant.rights << delivery_challans_update
  enterprise_accountant.rights << delivery_challans_delete
  # enterprise_staff
  enterprise_staff.rights << delivery_challans_create
  enterprise_staff.rights << delivery_challans_read
  enterprise_staff.rights << delivery_challans_update
  enterprise_staff.rights << delivery_challans_delete
  #enterprise inventory manager
  enterprise_inventory_manager.rights << delivery_challans_create
  enterprise_inventory_manager.rights << delivery_challans_read
  enterprise_inventory_manager.rights << delivery_challans_update
  enterprise_inventory_manager.rights << delivery_challans_delete
  # enterprise_auditor
  enterprise_auditor.rights << delivery_challans_read

 #trial_owner  
  trial_owner.rights << delivery_challans_create
  trial_owner.rights << delivery_challans_read
  trial_owner.rights << delivery_challans_update
  trial_owner.rights << delivery_challans_delete
  # trial_accountant
  trial_accountant.rights << delivery_challans_create
  trial_accountant.rights << delivery_challans_read
  trial_accountant.rights << delivery_challans_update
  trial_accountant.rights << delivery_challans_delete
  # trial_staff
  trial_staff.rights << delivery_challans_create
  trial_staff.rights << delivery_challans_read
  trial_staff.rights << delivery_challans_update
  trial_staff.rights << delivery_challans_delete
  #trial inventory manager
  trial_inventory_manager.rights << delivery_challans_create
  trial_inventory_manager.rights << delivery_challans_read
  trial_inventory_manager.rights << delivery_challans_update
  trial_inventory_manager.rights << delivery_challans_delete
  # trial_auditor
  trial_auditor.rights << delivery_challans_read

#smb_owner  
  smb_owner.rights << delivery_challans_create
  smb_owner.rights << delivery_challans_read
  smb_owner.rights << delivery_challans_update
  smb_owner.rights << delivery_challans_delete
  # smb_accountant
  smb_accountant.rights << delivery_challans_create
  smb_accountant.rights << delivery_challans_read
  smb_accountant.rights << delivery_challans_update
  smb_accountant.rights << delivery_challans_delete
  # smb_staff
  smb_staff.rights << delivery_challans_create
  smb_staff.rights << delivery_challans_read
  smb_staff.rights << delivery_challans_update
  smb_staff.rights << delivery_challans_delete
  #smb inventory manager
  smb_inventory_manager.rights << delivery_challans_create
  smb_inventory_manager.rights << delivery_challans_read
  smb_inventory_manager.rights << delivery_challans_update
  smb_inventory_manager.rights << delivery_challans_delete
  # smb_auditor
  smb_auditor.rights << delivery_challans_read

  
end
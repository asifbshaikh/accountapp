ActiveRecord::Base.transaction do
  professional_plan = Plan.find_by_name('Professional')
  enterprise_plan = Plan.find_by_name('Enterprise')
  trial_plan = Plan.find_by_name('Trial')
  smb_plan = Plan.find_by_name('SMB')
  essential_plan = Plan.find_by_name('Essential')
  free_plan = Plan.find_by_name('PWYW')



  #professional_inventory_manager = Role.find_by_name_and_plan_id('Inventory Manager', professional_plan)
  enterprise_inventory_manager = Role.find_by_name_and_plan_id('Inventory Manager', enterprise_plan)
  trial_inventory_manager = Role.find_by_name_and_plan_id('Inventory Manager', trial_plan)
  smb_inventory_manager = Role.find_by_name_and_plan_id('Inventory Manager', smb_plan)


  purchases_create = Right.find_by_resource_and_operation('purchases','CREATE')
  purchases_read = Right.find_by_resource_and_operation('purchases','READ')
  purchases_update = Right.find_by_resource_and_operation('purchases','UPDATE')
  purchases_delete = Right.find_by_resource_and_operation('purchases','DELETE')


  purchase_orders_create = Right.find_by_resource_and_operation('purchase_orders',  'CREATE')
  purchase_orders_read = Right.find_by_resource_and_operation('purchase_orders',  'READ')
  purchase_orders_delete = Right.find_by_resource_and_operation('purchase_orders',  'DELETE')
  purchase_orders_update = Right.find_by_resource_and_operation('purchase_orders',  'UPDATE')



  #professional_inventory_manager
  # professional_inventory_manager.rights << purchases_create
  # professional_inventory_manager.rights << purchases_read
  # professional_inventory_manager.rights << purchases_update
  # professional_inventory_manager.rights << purchases_delete


  #enterprise_inventory_manager
  enterprise_inventory_manager.rights << purchases_create
  enterprise_inventory_manager.rights << purchases_read
  enterprise_inventory_manager.rights << purchases_update
  enterprise_inventory_manager.rights << purchases_delete

  #trial_inventory_manager
  trial_inventory_manager.rights << purchases_create
  trial_inventory_manager.rights << purchases_read
  trial_inventory_manager.rights << purchases_update
  trial_inventory_manager.rights << purchases_delete

  #smb_inventory_manager
  smb_inventory_manager.rights << purchases_create
  smb_inventory_manager.rights << purchases_read
  smb_inventory_manager.rights << purchases_update
  smb_inventory_manager.rights << purchases_delete



  #professional_inventory_manager
  # professional_inventory_manager.rights << purchase_orders_create
  # professional_inventory_manager.rights << purchase_orders_read
  # professional_inventory_manager.rights << purchase_orders_update
  # professional_inventory_manager.rights << purchase_orders_delete


  #enterprise_inventory_manager
  enterprise_inventory_manager.rights << purchase_orders_create
  enterprise_inventory_manager.rights << purchase_orders_read
  enterprise_inventory_manager.rights << purchase_orders_update
  enterprise_inventory_manager.rights << purchase_orders_delete

  #trial_inventory_manager
  trial_inventory_manager.rights << purchase_orders_create
  trial_inventory_manager.rights << purchase_orders_read
  trial_inventory_manager.rights << purchase_orders_update
  trial_inventory_manager.rights << purchase_orders_delete

  #smb_inventory_manager
  smb_inventory_manager.rights << purchase_orders_create
  smb_inventory_manager.rights << purchase_orders_read
  smb_inventory_manager.rights << purchase_orders_update
  smb_inventory_manager.rights << purchase_orders_delete

end
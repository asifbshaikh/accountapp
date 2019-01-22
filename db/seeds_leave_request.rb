ActiveRecord::Base.transaction do
  smb_plan = Plan.find_by_name('SMB')
  professional_plan = Plan.find_by_name('Professional')
  enterprise_plan = Plan.find_by_name('Enterprise')
  free_plan = Plan.find_by_name('PWYW')
  trial_plan = Plan.find_by_name('Trial')

  #professional_inventory_manager = Role.find_by_name_and_plan_id('Inventory Manager', professional_plan)

  # SMB Plan 

# Sales leave request permission for roles
  smb_sales = Role.find_by_name_and_plan_id('Sales', smb_plan)

    leave_requests_create = Right.find_by_resource_and_operation('leave_requests','CREATE')
    leave_requests_read = Right.find_by_resource_and_operation('leave_requests','READ')
    leave_requests_update = Right.find_by_resource_and_operation('leave_requests','UPDATE')
    leave_requests_delete = Right.find_by_resource_and_operation('leave_requests','DELETE')

    smb_sales.rights << leave_requests_create
    smb_sales.rights << leave_requests_read
    smb_sales.rights << leave_requests_update
    smb_sales.rights << leave_requests_delete

    workstream_read=Right.find_by_resource_and_operation('workstream','READ')
    smb_sales.rights << workstream_read


    smb_sales.save

# HR leave request permission for roles
  smb_hr = Role.find_by_name_and_plan_id('Hr', smb_plan)

    leave_requests_create = Right.find_by_resource_and_operation('leave_requests','CREATE')
    leave_requests_read = Right.find_by_resource_and_operation('leave_requests','READ')
    leave_requests_update = Right.find_by_resource_and_operation('leave_requests','UPDATE')
    leave_requests_delete = Right.find_by_resource_and_operation('leave_requests','DELETE')

    smb_hr.rights << leave_requests_create
    smb_hr.rights << leave_requests_read
    smb_hr.rights << leave_requests_update
    smb_hr.rights << leave_requests_delete

    workstream_read=Right.find_by_resource_and_operation('workstream','READ')
    smb_hr.rights << workstream_read


    smb_hr.save

# Inventory Manager leave request permission for roles
  smb_inventory_manager = Role.find_by_name_and_plan_id('Inventory Manager', smb_plan)

    leave_requests_create = Right.find_by_resource_and_operation('leave_requests','CREATE')
    leave_requests_read = Right.find_by_resource_and_operation('leave_requests','READ')
    leave_requests_update = Right.find_by_resource_and_operation('leave_requests','UPDATE')
    leave_requests_delete = Right.find_by_resource_and_operation('leave_requests','DELETE')

    smb_inventory_manager.rights << leave_requests_create
    smb_inventory_manager.rights << leave_requests_read
    smb_inventory_manager.rights << leave_requests_update
    smb_inventory_manager.rights << leave_requests_delete

    workstream_read=Right.find_by_resource_and_operation('workstream','READ')
    smb_hr.rights << workstream_read


    smb_inventory_manager.save


# Proffessional Plan

# Sales leave request permission for roles
  professional_sales = Role.find_by_name_and_plan_id('Sales',  professional_plan)

    leave_requests_create = Right.find_by_resource_and_operation('leave_requests','CREATE')
    leave_requests_read = Right.find_by_resource_and_operation('leave_requests','READ')
    leave_requests_update = Right.find_by_resource_and_operation('leave_requests','UPDATE')
    leave_requests_delete = Right.find_by_resource_and_operation('leave_requests','DELETE')

    professional_sales.rights << leave_requests_create
    professional_sales.rights << leave_requests_read
    professional_sales.rights << leave_requests_update
    professional_sales.rights << leave_requests_delete

    workstream_read=Right.find_by_resource_and_operation('workstream','READ')
    professional_sales.rights << workstream_read

    professional_sales.save

# HR leave request permission for roles
  professional_hr = Role.find_by_name_and_plan_id('Hr',  professional_plan)

    leave_requests_create = Right.find_by_resource_and_operation('leave_requests','CREATE')
    leave_requests_read = Right.find_by_resource_and_operation('leave_requests','READ')
    leave_requests_update = Right.find_by_resource_and_operation('leave_requests','UPDATE')
    leave_requests_delete = Right.find_by_resource_and_operation('leave_requests','DELETE')

    professional_hr.rights << leave_requests_create
    professional_hr.rights << leave_requests_read
    professional_hr.rights << leave_requests_update
    professional_hr.rights << leave_requests_delete

    workstream_read=Right.find_by_resource_and_operation('workstream','READ')
    professional_hr.rights << workstream_read

    professional_hr.save

# Inventory Manager leave request permission for roles
  professional_inventory_manager = Role.find_by_name_and_plan_id('Inventory Manager',  professional_plan)

    leave_requests_create = Right.find_by_resource_and_operation('leave_requests','CREATE')
    leave_requests_read = Right.find_by_resource_and_operation('leave_requests','READ')
    leave_requests_update = Right.find_by_resource_and_operation('leave_requests','UPDATE')
    leave_requests_delete = Right.find_by_resource_and_operation('leave_requests','DELETE')

    professional_inventory_manager.rights << leave_requests_create
    professional_inventory_manager.rights << leave_requests_read
    professional_inventory_manager.rights << leave_requests_update
    professional_inventory_manager.rights << leave_requests_delete

    workstream_read=Right.find_by_resource_and_operation('workstream','READ')
    professional_inventory_manager.rights << workstream_read


    professional_inventory_manager.save



# Enterprise Plan

# Sales leave request permission for roles
  enterprise_sales = Role.find_by_name_and_plan_id('Sales',  enterprise_plan)

    leave_requests_create = Right.find_by_resource_and_operation('leave_requests','CREATE')
    leave_requests_read = Right.find_by_resource_and_operation('leave_requests','READ')
    leave_requests_update = Right.find_by_resource_and_operation('leave_requests','UPDATE')
    leave_requests_delete = Right.find_by_resource_and_operation('leave_requests','DELETE')

    enterprise_sales.rights << leave_requests_create
    enterprise_sales.rights << leave_requests_read
    enterprise_sales.rights << leave_requests_update
    enterprise_sales.rights << leave_requests_delete

    workstream_read=Right.find_by_resource_and_operation('workstream','READ')
    enterprise_sales.rights << workstream_read

    enterprise_sales.save

# HR leave request permission for roles
  enterprise_hr = Role.find_by_name_and_plan_id('Hr',  enterprise_plan)

    leave_requests_create = Right.find_by_resource_and_operation('leave_requests','CREATE')
    leave_requests_read = Right.find_by_resource_and_operation('leave_requests','READ')
    leave_requests_update = Right.find_by_resource_and_operation('leave_requests','UPDATE')
    leave_requests_delete = Right.find_by_resource_and_operation('leave_requests','DELETE')

    enterprise_hr.rights << leave_requests_create
    enterprise_hr.rights << leave_requests_read
    enterprise_hr.rights << leave_requests_update
    enterprise_hr.rights << leave_requests_delete

    workstream_read=Right.find_by_resource_and_operation('workstream','READ')
    enterprise_hr.rights << workstream_read

    enterprise_hr.save

# Inventory Manager leave request permission for roles
  enterprise_inventory_manager = Role.find_by_name_and_plan_id('Inventory Manager',  enterprise_plan)

    leave_requests_create = Right.find_by_resource_and_operation('leave_requests','CREATE')
    leave_requests_read = Right.find_by_resource_and_operation('leave_requests','READ')
    leave_requests_update = Right.find_by_resource_and_operation('leave_requests','UPDATE')
    leave_requests_delete = Right.find_by_resource_and_operation('leave_requests','DELETE')

    enterprise_inventory_manager.rights << leave_requests_create
    enterprise_inventory_manager.rights << leave_requests_read
    enterprise_inventory_manager.rights << leave_requests_update
    enterprise_inventory_manager.rights << leave_requests_delete

    workstream_read=Right.find_by_resource_and_operation('workstream','READ')
    enterprise_inventory_manager.rights << workstream_read
    
    enterprise_inventory_manager.save


# Free Plan

# Sales leave request permission for roles
   free_sales = Role.find_by_name_and_plan_id('Sales',  free_plan)

    leave_requests_create = Right.find_by_resource_and_operation('leave_requests','CREATE')
    leave_requests_read = Right.find_by_resource_and_operation('leave_requests','READ')
    leave_requests_update = Right.find_by_resource_and_operation('leave_requests','UPDATE')
    leave_requests_delete = Right.find_by_resource_and_operation('leave_requests','DELETE')

    free_sales.rights << leave_requests_create
    free_sales.rights << leave_requests_read
    free_sales.rights << leave_requests_update
    free_sales.rights << leave_requests_delete

    workstream_read=Right.find_by_resource_and_operation('workstream','READ')
    free_sales.rights << workstream_read

    free_sales.save

 # HR leave request permission for roles
  free_hr = Role.find_by_name_and_plan_id('Hr',  free_plan)

    leave_requests_create = Right.find_by_resource_and_operation('leave_requests','CREATE')
    leave_requests_read = Right.find_by_resource_and_operation('leave_requests','READ')
    leave_requests_update = Right.find_by_resource_and_operation('leave_requests','UPDATE')
    leave_requests_delete = Right.find_by_resource_and_operation('leave_requests','DELETE')

    free_hr.rights << leave_requests_create
    free_hr.rights << leave_requests_read
    free_hr.rights << leave_requests_update
    free_hr.rights << leave_requests_delete

    workstream_read=Right.find_by_resource_and_operation('workstream','READ')
    free_hr.rights << workstream_read

    free_hr.save

 # Inventory Manager leave request permission for roles
  free_inventory_manager = Role.find_by_name_and_plan_id('Inventory Manager', free_plan)

    leave_requests_create = Right.find_by_resource_and_operation('leave_requests','CREATE')
    leave_requests_read = Right.find_by_resource_and_operation('leave_requests','READ')
    leave_requests_update = Right.find_by_resource_and_operation('leave_requests','UPDATE')
    leave_requests_delete = Right.find_by_resource_and_operation('leave_requests','DELETE')

    free_inventory_manager.rights << leave_requests_create
    free_inventory_manager.rights << leave_requests_read
    free_inventory_manager.rights << leave_requests_update
    free_inventory_manager.rights << leave_requests_delete

    workstream_read=Right.find_by_resource_and_operation('workstream','READ')
    free_inventory_manager.rights << workstream_read
    
    free_inventory_manager.save


# Trial Plan
# Sales leave request permission for roles
   trial_sales = Role.find_by_name_and_plan_id('Sales',  trial_plan)

    leave_requests_create = Right.find_by_resource_and_operation('leave_requests','CREATE')
    leave_requests_read = Right.find_by_resource_and_operation('leave_requests','READ')
    leave_requests_update = Right.find_by_resource_and_operation('leave_requests','UPDATE')
    leave_requests_delete = Right.find_by_resource_and_operation('leave_requests','DELETE')

    trial_sales.rights << leave_requests_create
    trial_sales.rights << leave_requests_read
    trial_sales.rights << leave_requests_update
    trial_sales.rights << leave_requests_delete

    workstream_read=Right.find_by_resource_and_operation('workstream','READ')
    trial_sales.rights << workstream_read

    trial_sales.save

# HR leave request permission for roles
  trial_hr = Role.find_by_name_and_plan_id('Hr', trial_plan)

    leave_requests_create = Right.find_by_resource_and_operation('leave_requests','CREATE')
    leave_requests_read = Right.find_by_resource_and_operation('leave_requests','READ')
    leave_requests_update = Right.find_by_resource_and_operation('leave_requests','UPDATE')
    leave_requests_delete = Right.find_by_resource_and_operation('leave_requests','DELETE')

    trial_hr.rights << leave_requests_create
    trial_hr.rights << leave_requests_read
    trial_hr.rights << leave_requests_update
    trial_hr.rights << leave_requests_delete

    workstream_read=Right.find_by_resource_and_operation('workstream','READ')
    trial_hr.rights << workstream_read

    trial_hr.save

 # Inventory Manager leave request permission for roles
  trial_inventory_manager = Role.find_by_name_and_plan_id('Inventory Manager', trial_plan)

    leave_requests_create = Right.find_by_resource_and_operation('leave_requests','CREATE')
    leave_requests_read = Right.find_by_resource_and_operation('leave_requests','READ')
    leave_requests_update = Right.find_by_resource_and_operation('leave_requests','UPDATE')
    leave_requests_delete = Right.find_by_resource_and_operation('leave_requests','DELETE')

    trial_inventory_manager.rights << leave_requests_create
    trial_inventory_manager.rights << leave_requests_read
    trial_inventory_manager.rights << leave_requests_update
    trial_inventory_manager.rights << leave_requests_delete

    workstream_read=Right.find_by_resource_and_operation('workstream','READ')
    trial_inventory_manager.rights << workstream_read
    
    trial_inventory_manager.save

end
ActiveRecord::Base.transaction do
  smb_plan = Plan.find_by_name('SMB')
  professional_plan = Plan.find_by_name('Professional')
  enterprise_plan = Plan.find_by_name('Enterprise')
  trial_plan = Plan.find_by_name('Trial')

  #professional_inventory_manager = Role.find_by_name_and_plan_id('Inventory Manager', professional_plan)
  leave_requests_create = Right.find_by_resource_and_operation('leave_requests','CREATE')
  leave_requests_read = Right.find_by_resource_and_operation('leave_requests','READ')
  leave_requests_update = Right.find_by_resource_and_operation('leave_requests','UPDATE')
  leave_requests_delete = Right.find_by_resource_and_operation('leave_requests','DELETE')

  workstreams_read = Right.find_by_resource_and_operation('workstreams','READ')

#=================================================================================================
# SMB Plan 

# # Sales leave request permission for roles
#   smb_sales = Role.find_by_name_and_plan_id('Sales', smb_plan)

    

#     smb_sales.rights << leave_requests_create
#     smb_sales.rights << leave_requests_read
#     smb_sales.rights << leave_requests_update
#     smb_sales.rights << leave_requests_delete

    
#     smb_sales.rights << workstreams_read


#     smb_sales.save

# # HR leave request permission for roles
#   smb_hr = Role.find_by_name_and_plan_id('Hr', smb_plan)


#     smb_hr.rights << leave_requests_create
#     smb_hr.rights << leave_requests_read
#     smb_hr.rights << leave_requests_update
#     smb_hr.rights << leave_requests_delete

#     smb_hr.rights << workstreams_read


#     smb_hr.save

# # Inventory Manager leave request permission for roles
  smb_inventory_manager = Role.find_by_name_and_plan_id('Inventory Manager', smb_plan)


#     smb_inventory_manager.rights << leave_requests_create
#     smb_inventory_manager.rights << leave_requests_read
#     smb_inventory_manager.rights << leave_requests_update
#     smb_inventory_manager.rights << leave_requests_delete

    smb_inventory_manager.rights << workstreams_read
    smb_inventory_manager.save

#========================================================================================================

# Enterprise Plan

# Sales leave request permission for roles
  enterprise_sales = Role.find_by_name_and_plan_id('Sales',  enterprise_plan)


    enterprise_sales.rights << leave_requests_create
    enterprise_sales.rights << leave_requests_read
    enterprise_sales.rights << leave_requests_update
    enterprise_sales.rights << leave_requests_delete

    enterprise_sales.rights << workstreams_read

    enterprise_sales.save

# # HR leave request permission for roles
#   enterprise_hr = Role.find_by_name_and_plan_id('Hr',  enterprise_plan)


#     enterprise_hr.rights << leave_requests_create
#     enterprise_hr.rights << leave_requests_read
#     enterprise_hr.rights << leave_requests_update
#     enterprise_hr.rights << leave_requests_delete

#     enterprise_hr.rights << workstreams_read

#     enterprise_hr.save

# # Inventory Manager leave request permission for roles
#   enterprise_inventory_manager = Role.find_by_name_and_plan_id('Inventory Manager',  enterprise_plan)


#     enterprise_inventory_manager.rights << leave_requests_create
#     enterprise_inventory_manager.rights << leave_requests_read
#     enterprise_inventory_manager.rights << leave_requests_update
#     enterprise_inventory_manager.rights << leave_requests_delete

#     enterprise_inventory_manager.rights << workstreams_read
    
#     enterprise_inventory_manager.save

#===========================================================================================================


# Trial Plan
# Sales leave request permission for roles
   trial_sales = Role.find_by_name_and_plan_id('Sales',  trial_plan)


    trial_sales.rights << leave_requests_create
    trial_sales.rights << leave_requests_read
    trial_sales.rights << leave_requests_update
    trial_sales.rights << leave_requests_delete

    trial_sales.rights << workstreams_read

    trial_sales.save

# # HR leave request permission for roles
#   trial_hr = Role.find_by_name_and_plan_id('Hr', trial_plan)


#     trial_hr.rights << leave_requests_create
#     trial_hr.rights << leave_requests_read
#     trial_hr.rights << leave_requests_update
#     trial_hr.rights << leave_requests_delete

#     trial_hr.rights << workstreams_read

#     trial_hr.save

#  # Inventory Manager leave request permission for roles
   trial_inventory_manager = Role.find_by_name_and_plan_id('Inventory Manager', trial_plan)


#     trial_inventory_manager.rights << leave_requests_create
#     trial_inventory_manager.rights << leave_requests_read
#     trial_inventory_manager.rights << leave_requests_update
#     trial_inventory_manager.rights << leave_requests_delete

     trial_inventory_manager.rights << workstreams_read
    
     trial_inventory_manager.save

end

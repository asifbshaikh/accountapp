ActiveRecord::Base.transaction do

  professional_plan = Plan.find_by_name('Professional')
  enterprise_plan = Plan.find_by_name('Enterprise')
  trial_plan = Plan.find_by_name('Trial')
  smb_plan = Plan.find_by_name('SMB')
  
  
 enterprise_hr = enterprise_plan.roles.find_by_name('HR')
 smb_hr = smb_plan.roles.find_by_name('HR')
 professional_hr = professional_plan.roles.find_by_name('HR')
 trial_hr = trial_plan.roles.find_by_name('HR')
  
 
  payheads_create = Right.find_by_resource_and_operation('payheads', 'CREATE')
  payheads_read = Right.find_by_resource_and_operation('payheads', 'READ')
  payheads_delete = Right.find_by_resource_and_operation('payheads', 'DELETE')
  payheads_update = Right.find_by_resource_and_operation('payheads', 'UPDATE')


  #enterprise_HR
  enterprise_hr.rights << payheads_create
  enterprise_hr.rights << payheads_read
  enterprise_hr.rights << payheads_update
  enterprise_hr.rights << payheads_delete

  #smb_HR
  smb_hr.rights << payheads_create
  smb_hr.rights << payheads_read
  smb_hr.rights << payheads_update
  smb_hr.rights << payheads_delete

  #professional_owner 
  professional_hr.rights << payheads_create
  professional_hr.rights << payheads_read
  professional_hr.rights << payheads_update
  professional_hr.rights << payheads_delete

  #trail_owner 
  trial_hr.rights << payheads_create
  trial_hr.rights << payheads_read
  trial_hr.rights << payheads_update
  trial_hr.rights << payheads_delete

end
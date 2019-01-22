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

# #crm rights and roles
#   crm_leads_create = Right.create!(:resource => 'crm_leads', :operation => 'CREATE')
#   crm_leads_read = Right.create!(:resource => 'crm_leads', :operation => 'READ')
#   crm_leads_delete = Right.create!(:resource=>'crm_leads', :operation=>'DELETE')
#   crm_leads_update = Right.create!(:resource => 'crm_leads', :operation => 'UPDATE')

  
#   #professional_owner  
#   professional_owner.rights << crm_leads_create
#   professional_owner.rights << crm_leads_read
#   professional_owner.rights << crm_leads_update
#   professional_owner.rights << crm_leads_delete
#   # professional_accountant
#   professional_accountant.rights << crm_leads_create
#   professional_accountant.rights << crm_leads_read
#   professional_accountant.rights << crm_leads_update
#   professional_accountant.rights << crm_leads_delete
#   # professional_staff
#   professional_staff.rights << crm_leads_create
#   professional_staff.rights << crm_leads_read
#   professional_staff.rights << crm_leads_update
#   professional_staff.rights << crm_leads_delete
#   # professional_auditor
#   professional_auditor.rights << crm_leads_read

#   #enterprise_owner  
#   enterprise_owner.rights << crm_leads_create
#   enterprise_owner.rights << crm_leads_read
#   enterprise_owner.rights << crm_leads_update
#   enterprise_owner.rights << crm_leads_delete
#   # enterprise_accountant
#   enterprise_accountant.rights << crm_leads_create
#   enterprise_accountant.rights << crm_leads_read
#   enterprise_accountant.rights << crm_leads_update
#   enterprise_accountant.rights << crm_leads_delete
#   # enterprise_staff
#   enterprise_staff.rights << crm_leads_create
#   enterprise_staff.rights << crm_leads_read
#   enterprise_staff.rights << crm_leads_update
#   enterprise_staff.rights << crm_leads_delete
#   # enterprise_auditor
#   enterprise_auditor.rights << crm_leads_read

#  #trial_owner  
#   trial_owner.rights << crm_leads_create
#   trial_owner.rights << crm_leads_read
#   trial_owner.rights << crm_leads_update
#   trial_owner.rights << crm_leads_delete
#   # trial_accountant
#   trial_accountant.rights << crm_leads_create
#   trial_accountant.rights << crm_leads_read
#   trial_accountant.rights << crm_leads_update
#   trial_accountant.rights << crm_leads_delete
#   # trial_staff
#   trial_staff.rights << crm_leads_create
#   trial_staff.rights << crm_leads_read
#   trial_staff.rights << crm_leads_update
#   trial_staff.rights << crm_leads_delete
#   # trial_auditor
#   trial_auditor.rights << crm_leads_read

# #smb_owner  
#   smb_owner.rights << crm_leads_create
#   smb_owner.rights << crm_leads_read
#   smb_owner.rights << crm_leads_update
#   smb_owner.rights << crm_leads_delete
#   # smb_accountant
#   smb_accountant.rights << crm_leads_create
#   smb_accountant.rights << crm_leads_read
#   smb_accountant.rights << crm_leads_update
#   smb_accountant.rights << crm_leads_delete
#   # smb_staff
#   smb_staff.rights << crm_leads_create
#   smb_staff.rights << crm_leads_read
#   smb_staff.rights << crm_leads_update
#   smb_staff.rights << crm_leads_delete
#   # smb_auditor
#   smb_auditor.rights << crm_leads_read

# CRM Dashboard

crm_dashboard_read = Right.create!(:resource => 'crm_dashboard', :operation => 'READ')
  
  # professional_owner
  professional_owner.rights << crm_dashboard_read
  # professional_accountant
  professional_accountant.rights << crm_dashboard_read
  # professional_staff
  professional_staff.rights << crm_dashboard_read
  # professional_auditor
  professional_auditor.rights << crm_dashboard_read

  #enterprise_owner  
  enterprise_owner.rights << crm_dashboard_read
  # enterprise_accountant
  enterprise_accountant.rights << crm_dashboard_read
  # enterprise_staff
  enterprise_staff.rights << crm_dashboard_read
  # enterprise_auditor
  enterprise_auditor.rights << crm_dashboard_read

  #trial_owner  
  trial_owner.rights << crm_dashboard_read
  # trial_accountant
  trial_accountant.rights << crm_dashboard_read
  # trial_staff
  trial_staff.rights << crm_dashboard_read
  # trial_auditor
  trial_auditor.rights << crm_dashboard_read

  #smb_owner  
  smb_owner.rights << crm_dashboard_read
  # smb_accountant
  smb_accountant.rights << crm_dashboard_read
  # smb_staff
  smb_staff.rights << crm_dashboard_read
  # smb_auditor
  smb_auditor.rights << crm_dashboard_read


# CRM Contacts
  contacts_create = Right.create!(:resource => 'contacts', :operation => 'CREATE')
  contacts_read = Right.create!(:resource => 'contacts', :operation => 'READ')
  contacts_delete = Right.create!(:resource=>'contacts', :operation=>'DELETE')
  contacts_update = Right.create!(:resource => 'contacts', :operation => 'UPDATE')


  #professional_owner  
  professional_owner.rights << contacts_create
  professional_owner.rights << contacts_read
  professional_owner.rights << contacts_update
  professional_owner.rights << contacts_delete
  # professional_accountant
  professional_accountant.rights << contacts_create
  professional_accountant.rights << contacts_read
  professional_accountant.rights << contacts_update
  professional_accountant.rights << contacts_delete
  # professional_staff
  professional_staff.rights << contacts_create
  professional_staff.rights << contacts_read
  professional_staff.rights << contacts_update
  professional_staff.rights << contacts_delete
  # professional_auditor
  professional_auditor.rights << contacts_read

  #enterprise_owner  
  enterprise_owner.rights << contacts_create
  enterprise_owner.rights << contacts_read
  enterprise_owner.rights << contacts_update
  enterprise_owner.rights << contacts_delete
  # enterprise_accountant
  enterprise_accountant.rights << contacts_create
  enterprise_accountant.rights << contacts_read
  enterprise_accountant.rights << contacts_update
  enterprise_accountant.rights << contacts_delete
  # enterprise_staff
  enterprise_staff.rights << contacts_create
  enterprise_staff.rights << contacts_read
  enterprise_staff.rights << contacts_update
  enterprise_staff.rights << contacts_delete
  # enterprise_auditor
  enterprise_auditor.rights << contacts_read

  #trial_owner  
  trial_owner.rights << contacts_create
  trial_owner.rights << contacts_read
  trial_owner.rights << contacts_update
  trial_owner.rights << contacts_delete
  # trial_accountant
  trial_accountant.rights << contacts_create
  trial_accountant.rights << contacts_read
  trial_accountant.rights << contacts_update
  trial_accountant.rights << contacts_delete
  # trial_staff
  trial_staff.rights << contacts_create
  trial_staff.rights << contacts_read
  trial_staff.rights << contacts_update
  trial_staff.rights << contacts_delete
  # trial_auditor
  trial_auditor.rights << contacts_read

  #smb_owner  
  smb_owner.rights << contacts_create
  smb_owner.rights << contacts_read
  smb_owner.rights << contacts_update
  smb_owner.rights << contacts_delete
  # smb_accountant
  smb_accountant.rights << contacts_create
  smb_accountant.rights << contacts_read
  smb_accountant.rights << contacts_update
  smb_accountant.rights << contacts_delete
  # smb_staff
  smb_staff.rights << contacts_create
  smb_staff.rights << contacts_read
  smb_staff.rights << contacts_update
  smb_staff.rights << contacts_delete
  # smb_auditor
  smb_auditor.rights << contacts_read

  # CRM Oppoopportunities_
  opportunities_create = Right.create!(:resource => 'opportunities', :operation => 'CREATE')
  opportunities_read = Right.create!(:resource => 'opportunities', :operation => 'READ')
  opportunities_delete = Right.create!(:resource=>'opportunities', :operation=>'DELETE')
  opportunities_update = Right.create!(:resource => 'opportunities', :operation => 'UPDATE')


  #professional_owner  
  professional_owner.rights << opportunities_create
  professional_owner.rights << opportunities_read
  professional_owner.rights << opportunities_update
  professional_owner.rights << opportunities_delete
  # professional_accountant
  professional_accountant.rights << opportunities_create
  professional_accountant.rights << opportunities_read
  professional_accountant.rights << opportunities_update
  professional_accountant.rights << opportunities_delete
  # professional_staff
  professional_staff.rights << opportunities_create
  professional_staff.rights << opportunities_read
  professional_staff.rights << opportunities_update
  professional_staff.rights << opportunities_delete
  # professional_auditor
  professional_auditor.rights << opportunities_read

  #enterprise_owner  
  enterprise_owner.rights << opportunities_create
  enterprise_owner.rights << opportunities_read
  enterprise_owner.rights << opportunities_update
  enterprise_owner.rights << opportunities_delete
  # enterprise_accountant
  enterprise_accountant.rights << opportunities_create
  enterprise_accountant.rights << opportunities_read
  enterprise_accountant.rights << opportunities_update
  enterprise_accountant.rights << opportunities_delete
  # enterprise_staff
  enterprise_staff.rights << opportunities_create
  enterprise_staff.rights << opportunities_read
  enterprise_staff.rights << opportunities_update
  enterprise_staff.rights << opportunities_delete
  # enterprise_auditor
  enterprise_auditor.rights << opportunities_read

  #trial_owner  
  trial_owner.rights << opportunities_create
  trial_owner.rights << opportunities_read
  trial_owner.rights << opportunities_update
  trial_owner.rights << opportunities_delete
  # trial_accountant
  trial_accountant.rights << opportunities_create
  trial_accountant.rights << opportunities_read
  trial_accountant.rights << opportunities_update
  trial_accountant.rights << opportunities_delete
  # trial_staff
  trial_staff.rights << opportunities_create
  trial_staff.rights << opportunities_read
  trial_staff.rights << opportunities_update
  trial_staff.rights << opportunities_delete
  # trial_auditor
  trial_auditor.rights << opportunities_read

  #smb_owner  
  smb_owner.rights << opportunities_create
  smb_owner.rights << opportunities_read
  smb_owner.rights << opportunities_update
  smb_owner.rights << opportunities_delete
  # smb_accountant
  smb_accountant.rights << opportunities_create
  smb_accountant.rights << opportunities_read
  smb_accountant.rights << opportunities_update
  smb_accountant.rights << opportunities_delete
  # smb_staff
  smb_staff.rights << opportunities_create
  smb_staff.rights << opportunities_read
  smb_staff.rights << opportunities_update
  smb_staff.rights << opportunities_delete
  # smb_auditor
  smb_auditor.rights << opportunities_read
end
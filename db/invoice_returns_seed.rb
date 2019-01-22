ActiveRecord::Base.transaction do
  professional_plan = Plan.find_by_name('Professional')
  enterprise_plan = Plan.find_by_name('Enterprise')
  trial_plan = Plan.find_by_name('Trial')
  smb_plan = Plan.find_by_name('SMB')
  essential_plan = Plan.find_by_name('Essential')
  free_plan = Plan.find_by_name('PWYW')
  
  professional_owner = Role.find_by_name_and_plan_id('Owner', professional_plan)
  professional_accountant = Role.find_by_name_and_plan_id('Accountant', professional_plan)
  professional_staff = Role.find_by_name_and_plan_id('Staff', professional_plan)
  professional_auditor = Role.find_by_name_and_plan_id('Auditor', professional_plan)

  enterprise_owner = Role.find_by_name_and_plan_id('Owner', enterprise_plan)
  enterprise_accountant = Role.find_by_name_and_plan_id('Accountant', enterprise_plan)
  enterprise_staff = Role.find_by_name_and_plan_id('Staff', enterprise_plan)
  enterprise_auditor = Role.find_by_name_and_plan_id('Auditor', enterprise_plan)

  trial_owner = Role.find_by_name_and_plan_id('Owner', trial_plan)
  trial_accountant = Role.find_by_name_and_plan_id('Accountant', trial_plan)
  trial_staff = Role.find_by_name_and_plan_id('Staff', trial_plan)
  trial_auditor = Role.find_by_name_and_plan_id('Auditor', trial_plan)
  
  smb_owner = Role.find_by_name_and_plan_id('Owner', smb_plan)
  smb_accountant = Role.find_by_name_and_plan_id('Accountant', smb_plan)
  smb_staff = Role.find_by_name_and_plan_id('Staff', smb_plan)
  smb_auditor = Role.find_by_name_and_plan_id('Auditor', smb_plan)

  essential_owner = Role.find_by_name_and_plan_id('Owner', essential_plan)
  essential_accountant = Role.find_by_name_and_plan_id('Accountant', essential_plan)
  essential_staff = Role.find_by_name_and_plan_id('Staff', essential_plan)
  essential_auditor = Role.find_by_name_and_plan_id('Auditor', essential_plan)

  free_owner = Role.find_by_name_and_plan_id('Owner', free_plan)

	invoice_return_read=Right.create!(:resource=>"invoice_returns", :operation=>"READ")
	invoice_return_create=Right.create!(:resource=>"invoice_returns", :operation=>"CREATE")
	invoice_return_delete=Right.create!(:resource=>"invoice_returns", :operation=>"DELETE")
	invoice_return_update=Right.create!(:resource=>"invoice_returns", :operation=>"UPDATE")

  # professional_owner  
  professional_owner.rights << invoice_return_create
  professional_owner.rights << invoice_return_read
  professional_owner.rights << invoice_return_update
  professional_owner.rights << invoice_return_delete
  # professional_accountant
  professional_accountant.rights << invoice_return_create
  professional_accountant.rights << invoice_return_read
  professional_accountant.rights << invoice_return_update
  professional_accountant.rights << invoice_return_delete
  # professional_staff
  professional_staff.rights << invoice_return_create
  professional_staff.rights << invoice_return_read
  professional_staff.rights << invoice_return_update
  professional_staff.rights << invoice_return_delete
  # professional_auditor
  professional_auditor.rights << invoice_return_read

  #enterprise_owner  
  enterprise_owner.rights << invoice_return_create
  enterprise_owner.rights << invoice_return_read
  enterprise_owner.rights << invoice_return_update
  enterprise_owner.rights << invoice_return_delete
  # enterprise_accountant
  enterprise_accountant.rights << invoice_return_create
  enterprise_accountant.rights << invoice_return_read
  enterprise_accountant.rights << invoice_return_update
  enterprise_accountant.rights << invoice_return_delete
  # enterprise_staff
  enterprise_staff.rights << invoice_return_create
  enterprise_staff.rights << invoice_return_read
  enterprise_staff.rights << invoice_return_update
  enterprise_staff.rights << invoice_return_delete
  # enterprise_auditor
  enterprise_auditor.rights << invoice_return_read

  #trial_owner  
  trial_owner.rights << invoice_return_create
  trial_owner.rights << invoice_return_read
  trial_owner.rights << invoice_return_update
  trial_owner.rights << invoice_return_delete
  # trial_accountant
  trial_accountant.rights << invoice_return_create
  trial_accountant.rights << invoice_return_read
  trial_accountant.rights << invoice_return_update
  trial_accountant.rights << invoice_return_delete
  # trial_staff
  trial_staff.rights << invoice_return_create
  trial_staff.rights << invoice_return_read
  trial_staff.rights << invoice_return_update
  trial_staff.rights << invoice_return_delete
  # trial_auditor
  trial_auditor.rights << invoice_return_read

	#smb_owner  
  smb_owner.rights << invoice_return_create
  smb_owner.rights << invoice_return_read
  smb_owner.rights << invoice_return_update
  smb_owner.rights << invoice_return_delete
  # smb_accountant
  smb_accountant.rights << invoice_return_create
  smb_accountant.rights << invoice_return_read
  smb_accountant.rights << invoice_return_update
  smb_accountant.rights << invoice_return_delete
  # smb_staff
  smb_staff.rights << invoice_return_create
  smb_staff.rights << invoice_return_read
  smb_staff.rights << invoice_return_update
  smb_staff.rights << invoice_return_delete
  # smb_auditor
  smb_auditor.rights << invoice_return_read

	#essential_owner  
  essential_owner.rights << invoice_return_create
  essential_owner.rights << invoice_return_read
  essential_owner.rights << invoice_return_update
  essential_owner.rights << invoice_return_delete
  # essential_accountant
  essential_accountant.rights << invoice_return_create
  essential_accountant.rights << invoice_return_read
  essential_accountant.rights << invoice_return_update
  essential_accountant.rights << invoice_return_delete
  # essential_staff
  essential_staff.rights << invoice_return_create
  essential_staff.rights << invoice_return_read
  essential_staff.rights << invoice_return_update
  essential_staff.rights << invoice_return_delete
  # essential_auditor
  essential_auditor.rights << invoice_return_read

  #free_owner
  free_owner.rights << invoice_return_create
  free_owner.rights << invoice_return_read
  free_owner.rights << invoice_return_update
  free_owner.rights << invoice_return_delete
end
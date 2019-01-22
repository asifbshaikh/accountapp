ActiveRecord::Base.transaction do
  professional_plan = Plan.find_by_name('Professional')
  enterprise_plan = Plan.find_by_name('Enterprise')
  trial_plan = Plan.find_by_name('Trial')
  smb_plan = Plan.find_by_name('SMB')
  essential_plan = Plan.find_by_name('Essential')
  free_plan = Plan.find_by_name('PWYW')
  
  free_owner = Role.find_by_name_and_plan_id('Owner', free_plan)
  
  professional_owner = Role.find_by_name_and_plan_id('Owner', professional_plan)
  professional_accountant = Role.find_by_name_and_plan_id('Accountant', professional_plan)
  professional_auditor = Role.find_by_name_and_plan_id('Auditor', professional_plan)

  enterprise_owner = Role.find_by_name_and_plan_id('Owner', enterprise_plan)
  enterprise_accountant = Role.find_by_name_and_plan_id('Accountant', enterprise_plan)
  enterprise_auditor = Role.find_by_name_and_plan_id('Auditor', enterprise_plan)

  trial_owner = Role.find_by_name_and_plan_id('Owner', trial_plan)
  trial_accountant = Role.find_by_name_and_plan_id('Accountant', trial_plan)
  trial_auditor = Role.find_by_name_and_plan_id('Auditor', trial_plan)
  
  smb_owner = Role.find_by_name_and_plan_id('Owner', smb_plan)
  smb_accountant = Role.find_by_name_and_plan_id('Accountant', smb_plan)
  smb_auditor = Role.find_by_name_and_plan_id('Auditor', smb_plan)

  essential_owner = Role.find_by_name_and_plan_id('Owner', essential_plan)
  essential_accountant = Role.find_by_name_and_plan_id('Accountant', essential_plan)
  essential_auditor = Role.find_by_name_and_plan_id('Auditor', essential_plan)


  invoice_settlement_read = Right.create!(:operation=>"READ", :resource=>"invoice_settlement")

  free_owner.rights<<invoice_settlement_read
  
  professional_owner.rights<<invoice_settlement_read
  professional_accountant.rights<<invoice_settlement_read
  professional_auditor.rights<<invoice_settlement_read

  enterprise_owner.rights<<invoice_settlement_read
  enterprise_accountant.rights<<invoice_settlement_read
  enterprise_auditor.rights<<invoice_settlement_read

  trial_owner.rights<<invoice_settlement_read
  trial_accountant.rights<<invoice_settlement_read
  trial_auditor.rights<<invoice_settlement_read

  smb_owner.rights<<invoice_settlement_read
  smb_accountant.rights<<invoice_settlement_read
  smb_auditor.rights<<invoice_settlement_read

  essential_owner.rights<<invoice_settlement_read
  essential_accountant.rights<<invoice_settlement_read
  essential_auditor.rights<<invoice_settlement_read

end
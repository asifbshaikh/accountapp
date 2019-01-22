ActiveRecord::Base.transaction do
  professional_plan = Plan.find_by_name('Professional')
  enterprise_plan = Plan.find_by_name('Enterprise')
  trial_plan = Plan.find_by_name('Trial')
  smb_plan = Plan.find_by_name('SMB')
  essential_plan = Plan.find_by_name('Essential')
  free_plan = Plan.find_by_name('PWYW')
  
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

  free_owner = Role.find_by_name_and_plan_id('Owner', free_plan)

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
end
ActiveRecord::Base.transaction do
  #Reimbursement Notes Rights CRUD to Owner & Accountant of Professional, Enterprise, Trial & SMB plans
  professional_plan = Plan.find_by_name('Professional')
  enterprise_plan = Plan.find_by_name('Enterprise')
  trial_plan = Plan.find_by_name('Trial')
  smb_plan = Plan.find_by_name('SMB')

  professional_owner = Role.find_by_name_and_plan_id('Owner', professional_plan)
  professional_accountant = Role.find_by_name_and_plan_id('Accountant', professional_plan)

  enterprise_owner = Role.find_by_name_and_plan_id('Owner', enterprise_plan)
  enterprise_accountant = Role.find_by_name_and_plan_id('Accountant', enterprise_plan)

  trial_owner = Role.find_by_name_and_plan_id('Owner', trial_plan)
  trial_accountant = Role.find_by_name_and_plan_id('Accountant', trial_plan)

  smb_owner = Role.find_by_name_and_plan_id('Owner', smb_plan)
  smb_accountant = Role.find_by_name_and_plan_id('Accountant', smb_plan)

  Right.create!(:resource => 'reimbursement_notes', :operation => 'READ')
  Right.create!(:resource => 'reimbursement_notes', :operation => 'CREATE')
  Right.create!(:resource => 'reimbursement_notes', :operation => 'UPDATE')
  Right.create!(:resource => 'reimbursement_notes', :operation => 'DELETE')


  reimbursement_note_create = Right.find_by_resource_and_operation('reimbursement_notes', 'CREATE')
  reimbursement_note_read = Right.find_by_resource_and_operation('reimbursement_notes', 'READ')
  reimbursement_note_delete = Right.find_by_resource_and_operation('reimbursement_notes', 'DELETE')
  reimbursement_note_update = Right.find_by_resource_and_operation('reimbursement_notes', 'UPDATE')

  enterprise_owner.rights << reimbursement_note_create
  enterprise_owner.rights << reimbursement_note_read
  enterprise_owner.rights << reimbursement_note_update
  enterprise_owner.rights << reimbursement_note_delete

  enterprise_accountant.rights << reimbursement_note_create
  enterprise_accountant.rights << reimbursement_note_read
  enterprise_accountant.rights << reimbursement_note_update
  enterprise_accountant.rights << reimbursement_note_delete

  professional_owner.rights << reimbursement_note_create
  professional_owner.rights << reimbursement_note_read
  professional_owner.rights << reimbursement_note_update
  professional_owner.rights << reimbursement_note_delete

  professional_accountant.rights << reimbursement_note_create
  professional_accountant.rights << reimbursement_note_read
  professional_accountant.rights << reimbursement_note_update
  professional_accountant.rights << reimbursement_note_delete

  trial_owner.rights << reimbursement_note_create
  trial_owner.rights << reimbursement_note_read
  trial_owner.rights << reimbursement_note_update
  trial_owner.rights << reimbursement_note_delete

  trial_accountant.rights << reimbursement_note_create
  trial_accountant.rights << reimbursement_note_read
  trial_accountant.rights << reimbursement_note_update
  trial_accountant.rights << reimbursement_note_delete

  smb_owner.rights << reimbursement_note_create
  smb_owner.rights << reimbursement_note_read
  smb_owner.rights << reimbursement_note_update
  smb_owner.rights << reimbursement_note_delete

  smb_accountant.rights << reimbursement_note_create
  smb_accountant.rights << reimbursement_note_read
  smb_accountant.rights << reimbursement_note_update
  smb_accountant.rights << reimbursement_note_delete

end

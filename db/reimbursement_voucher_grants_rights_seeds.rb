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

  Right.create!(:resource => 'reimbursement_vouchers', :operation => 'READ')
  Right.create!(:resource => 'reimbursement_vouchers', :operation => 'CREATE')
  Right.create!(:resource => 'reimbursement_vouchers', :operation => 'UPDATE')
  Right.create!(:resource => 'reimbursement_vouchers', :operation => 'DELETE')


  reimbursement_voucher_create = Right.find_by_resource_and_operation('reimbursement_vouchers', 'CREATE')
  reimbursement_voucher_read = Right.find_by_resource_and_operation('reimbursement_vouchers', 'READ')
  reimbursement_voucher_delete = Right.find_by_resource_and_operation('reimbursement_vouchers', 'DELETE')
  reimbursement_voucher_update = Right.find_by_resource_and_operation('reimbursement_vouchers', 'UPDATE')

  enterprise_owner.rights << reimbursement_voucher_create
  enterprise_owner.rights << reimbursement_voucher_read
  enterprise_owner.rights << reimbursement_voucher_update
  enterprise_owner.rights << reimbursement_voucher_delete

  enterprise_accountant.rights << reimbursement_voucher_create
  enterprise_accountant.rights << reimbursement_voucher_read
  enterprise_accountant.rights << reimbursement_voucher_update
  enterprise_accountant.rights << reimbursement_voucher_delete

  professional_owner.rights << reimbursement_voucher_create
  professional_owner.rights << reimbursement_voucher_read
  professional_owner.rights << reimbursement_voucher_update
  professional_owner.rights << reimbursement_voucher_delete

  professional_accountant.rights << reimbursement_voucher_create
  professional_accountant.rights << reimbursement_voucher_read
  professional_accountant.rights << reimbursement_voucher_update
  professional_accountant.rights << reimbursement_voucher_delete

  trial_owner.rights << reimbursement_voucher_create
  trial_owner.rights << reimbursement_voucher_read
  trial_owner.rights << reimbursement_voucher_update
  trial_owner.rights << reimbursement_voucher_delete

  trial_accountant.rights << reimbursement_voucher_create
  trial_accountant.rights << reimbursement_voucher_read
  trial_accountant.rights << reimbursement_voucher_update
  trial_accountant.rights << reimbursement_voucher_delete

  smb_owner.rights << reimbursement_voucher_create
  smb_owner.rights << reimbursement_voucher_read
  smb_owner.rights << reimbursement_voucher_update
  smb_owner.rights << reimbursement_voucher_delete

  smb_accountant.rights << reimbursement_voucher_create
  smb_accountant.rights << reimbursement_voucher_read
  smb_accountant.rights << reimbursement_voucher_update
  smb_accountant.rights << reimbursement_voucher_delete
end
ActiveRecord::Base.transaction do
  professional_plan = Plan.find_by_name('Professional')
  enterprise_plan = Plan.find_by_name('Enterprise')
  trial_plan = Plan.find_by_name('Trial')
  smb_plan = Plan.find_by_name('SMB')
  free_plan = Plan.find_by_name('PWYW')


  enterprise_owner = Role.find_by_name_and_plan_id('Owner', enterprise_plan)
  enterprise_accountant = Role.find_by_name_and_plan_id('Accountant', enterprise_plan)
  enterprise_inventory_manager = Role.find_by_name_and_plan_id('Inventory Manager', enterprise_plan)
  enterprise_staff = Role.find_by_name_and_plan_id('Staff', enterprise_plan)
  enterprise_auditor = Role.find_by_name_and_plan_id('Auditor', enterprise_plan)

  voucher_titles_create = Right.find_by_resource_and_operation('voucher_titles', 'CREATE')
  voucher_titles_read = Right.find_by_resource_and_operation('voucher_titles', 'READ')
  voucher_titles_delete = Right.find_by_resource_and_operation('voucher_titles', 'DELETE')
  voucher_titles_update = Right.find_by_resource_and_operation('voucher_titles', 'UPDATE')

  enterprise_owner.rights << voucher_titles_create
  enterprise_owner.rights << voucher_titles_read
  enterprise_owner.rights << voucher_titles_update
  enterprise_owner.rights << voucher_titles_delete

  enterprise_accountant.rights << voucher_titles_create
  enterprise_accountant.rights << voucher_titles_read
  enterprise_accountant.rights << voucher_titles_update
  enterprise_accountant.rights << voucher_titles_delete


end

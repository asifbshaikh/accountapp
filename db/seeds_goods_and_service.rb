ActiveRecord::Base.transaction do
  smb_plan = Plan.find_by_name('SMB')
  professional_plan = Plan.find_by_name('Professional')
  enterprise_plan = Plan.find_by_name('Enterprise')
  trial_plan = Plan.find_by_name('Trial')

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

  Right.create!(:resource => 'goods_and_services_tax', :operation => 'READ')
  Right.create!(:resource => 'goods_and_services_tax', :operation => 'DELETE')


  #dsaprofessional_inventory_manager = Role.find_by_name_and_plan_id('Inventory Manager', professional_plan)
  goods_and_services_tax_read = Right.find_by_resource_and_operation('goods_and_services_tax','READ')
  goods_and_services_tax_delete = Right.find_by_resource_and_operation('goods_and_services_tax','DELETE')

  enterprise_owner.rights << goods_and_services_tax_read
  enterprise_owner.rights << goods_and_services_tax_delete
  
  enterprise_accountant.rights << goods_and_services_tax_read
  enterprise_accountant.rights << goods_and_services_tax_delete

  enterprise_auditor.rights << goods_and_services_tax_read
  enterprise_auditor.rights << goods_and_services_tax_delete

  professional_owner.rights << goods_and_services_tax_read
  professional_owner.rights << goods_and_services_tax_delete
  
  professional_accountant.rights << goods_and_services_tax_read
  professional_accountant.rights << goods_and_services_tax_delete

  professional_auditor.rights << goods_and_services_tax_read
  professional_auditor.rights << goods_and_services_tax_delete

  smb_owner.rights << goods_and_services_tax_read
  smb_owner.rights << goods_and_services_tax_delete
  
  smb_accountant.rights << goods_and_services_tax_read
  smb_accountant.rights << goods_and_services_tax_delete

  smb_auditor.rights << goods_and_services_tax_read
  smb_auditor.rights << goods_and_services_tax_delete

  trial_owner.rights << goods_and_services_tax_read
  trial_owner.rights << goods_and_services_tax_delete
  
  trial_accountant.rights << goods_and_services_tax_read
  trial_accountant.rights << goods_and_services_tax_delete

  trial_auditor.rights << goods_and_services_tax_read
  trial_auditor.rights << goods_and_services_tax_delete

end
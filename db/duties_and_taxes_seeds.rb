 ActiveRecord::Base.transaction do  
  basic_plan = Plan.find_by_name('Basic')
  premium_plan = Plan.find_by_name('Premium')
  enterprise_plan = Plan.find_by_name('Enterprise')
  essential_plan = Plan.find_by_name('Essential')
  free_plan = Plan.find_by_name('Free')

  free_owner = Role.find_by_name_and_plan_id('Owner', free_plan)

  essential_owner = Role.find_by_name_and_plan_id('Owner', essential_plan)
  essential_accountant = Role.find_by_name_and_plan_id('Accountant', essential_plan)
  essential_staff = Role.find_by_name_and_plan_id('Staff', essential_plan)

  basic_owner = Role.find_by_name_and_plan_id('Owner', basic_plan)
  basic_accountant = Role.find_by_name_and_plan_id('Accountant', basic_plan)
  basic_staff = Role.find_by_name_and_plan_id('Staff', basic_plan)
  basic_auditor = Role.find_by_name_and_plan_id('Auditor', basic_plan)

  premium_owner = Role.find_by_name_and_plan_id('Owner', premium_plan)
  premium_accountant = Role.find_by_name_and_plan_id('Accountant', premium_plan)
  premium_auditor = Role.find_by_name_and_plan_id('Auditor', premium_plan)
  premium_staff = Role.find_by_name_and_plan_id('Staff', premium_plan)
  premium_employee = Role.find_by_name_and_plan_id('Employee', premium_plan)

  enterprise_owner = Role.find_by_name_and_plan_id('Owner', enterprise_plan)
  enterprise_accountant = Role.find_by_name_and_plan_id('Accountant', enterprise_plan)
  enterprise_auditor = Role.find_by_name_and_plan_id('Auditor', enterprise_plan)
  enterprise_staff = Role.find_by_name_and_plan_id('Staff', enterprise_plan)
  enterprise_employee = Role.find_by_name_and_plan_id('Employee', enterprise_plan)

  duties_and_taxes_read = Right.create!(:resource => 'duties_and_taxes', :operation => 'READ') 
  duties_and_taxes_create = Right.create!(:resource => 'duties_and_taxes', :operation => 'CREATE')
  duties_and_taxes_delete = Right.create!(:resource => 'duties_and_taxes', :operation => 'DELETE')
  duties_and_taxes_update = Right.create!(:resource => 'duties_and_taxes', :operation => 'UPDATE')

  #free_owner 
  free_owner.rights << duties_and_taxes_create
  free_owner.rights << duties_and_taxes_read
  free_owner.rights << duties_and_taxes_update
  free_owner.rights << duties_and_taxes_delete

  #essential_owner
  essential_owner.rights << duties_and_taxes_create
  essential_owner.rights << duties_and_taxes_read
  essential_owner.rights << duties_and_taxes_update
  essential_owner.rights << duties_and_taxes_delete
  #essential_accountant
  essential_accountant.rights << duties_and_taxes_create
  essential_accountant.rights << duties_and_taxes_read
  essential_accountant.rights << duties_and_taxes_update
  essential_accountant.rights << duties_and_taxes_delete

  #basic_owner
  basic_owner.rights << duties_and_taxes_create
  basic_owner.rights << duties_and_taxes_read
  basic_owner.rights << duties_and_taxes_update
  basic_owner.rights << duties_and_taxes_delete
  #basic_accountant
  basic_accountant.rights << duties_and_taxes_create
  basic_accountant.rights << duties_and_taxes_read
  basic_accountant.rights << duties_and_taxes_update
  basic_accountant.rights << duties_and_taxes_delete
  #basic_staff
  #basic_auditor
  basic_auditor.rights << duties_and_taxes_read

  #premium_owner  
  premium_owner.rights << duties_and_taxes_create
  premium_owner.rights << duties_and_taxes_read
  premium_owner.rights << duties_and_taxes_update
  premium_owner.rights << duties_and_taxes_delete
  #premium_accountant
  premium_accountant.rights << duties_and_taxes_create
  premium_accountant.rights << duties_and_taxes_read
  premium_accountant.rights << duties_and_taxes_update
  premium_accountant.rights << duties_and_taxes_delete
  #premium_staff
  #premium_auditor
  premium_auditor.rights << duties_and_taxes_read

  #enterprise_owner 
  enterprise_owner.rights << duties_and_taxes_create
  enterprise_owner.rights << duties_and_taxes_read
  enterprise_owner.rights << duties_and_taxes_update
  enterprise_owner.rights << duties_and_taxes_delete
  #enterprise_accountant
  enterprise_accountant.rights << duties_and_taxes_create
  enterprise_accountant.rights << duties_and_taxes_read
  enterprise_accountant.rights << duties_and_taxes_update
  enterprise_accountant.rights << duties_and_taxes_delete
  #enterprise_staff
  #enterprise_auditor
  enterprise_auditor.rights << duties_and_taxes_read

end
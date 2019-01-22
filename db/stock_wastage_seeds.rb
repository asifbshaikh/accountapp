ActiveRecord::Base.transaction do
  basic_plan = Plan.find_by_name('Basic')
  premium_plan = Plan.find_by_name('Premium')
  enterprise_plan = Plan.find_by_name('Enterprise')

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

  stock_wastage_vouchers_create = Right.create!(:resource => 'stock_wastage_vouchers', :operation => 'CREATE')
  stock_wastage_vouchers_read = Right.create!(:resource => 'stock_wastage_vouchers', :operation => 'READ') 
  stock_wastage_vouchers_delete = Right.create!(:resource => 'stock_wastage_vouchers', :operation => 'DELETE')
  stock_wastage_vouchers_update = Right.create!(:resource => 'stock_wastage_vouchers', :operation => 'UPDATE')

  #basic_owner
  basic_owner.rights << stock_wastage_vouchers_create
  basic_owner.rights << stock_wastage_vouchers_read
  basic_owner.rights << stock_wastage_vouchers_update
  basic_owner.rights << stock_wastage_vouchers_delete

  #basic_accountant
  basic_accountant.rights << stock_wastage_vouchers_create
  basic_accountant.rights << stock_wastage_vouchers_read
  basic_accountant.rights << stock_wastage_vouchers_update
  basic_accountant.rights << stock_wastage_vouchers_delete

  #basic_staff
  basic_staff.rights << stock_wastage_vouchers_create
  basic_staff.rights << stock_wastage_vouchers_read
  basic_staff.rights << stock_wastage_vouchers_update
  basic_staff.rights << stock_wastage_vouchers_delete

  #basic_auditor
  basic_auditor.rights << stock_wastage_vouchers_read

  #premium_owner
  premium_owner.rights << stock_wastage_vouchers_create
  premium_owner.rights << stock_wastage_vouchers_read
  premium_owner.rights << stock_wastage_vouchers_update
  premium_owner.rights << stock_wastage_vouchers_delete

  #premium_accountant
  premium_accountant.rights << stock_wastage_vouchers_create
  premium_accountant.rights << stock_wastage_vouchers_read
  premium_accountant.rights << stock_wastage_vouchers_update
  premium_accountant.rights << stock_wastage_vouchers_delete

  #premium_staff
  premium_staff.rights << stock_wastage_vouchers_create
  premium_staff.rights << stock_wastage_vouchers_read
  premium_staff.rights << stock_wastage_vouchers_update
  premium_staff.rights << stock_wastage_vouchers_delete

  #premium_auditor
  premium_auditor.rights << stock_wastage_vouchers_read

  #enterprise_owner
  enterprise_owner.rights << stock_wastage_vouchers_create
  enterprise_owner.rights << stock_wastage_vouchers_read
  enterprise_owner.rights << stock_wastage_vouchers_update
  enterprise_owner.rights << stock_wastage_vouchers_delete

  #enterprise_accountant
  enterprise_accountant.rights << stock_wastage_vouchers_create
  enterprise_accountant.rights << stock_wastage_vouchers_read
  enterprise_accountant.rights << stock_wastage_vouchers_update
  enterprise_accountant.rights << stock_wastage_vouchers_delete

  #enterprise_staff
  enterprise_staff.rights << stock_wastage_vouchers_create
  enterprise_staff.rights << stock_wastage_vouchers_read
  enterprise_staff.rights << stock_wastage_vouchers_update
  enterprise_staff.rights << stock_wastage_vouchers_delete

  #enterprise_auditor
  enterprise_auditor.rights << stock_wastage_vouchers_read
end
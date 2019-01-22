ActiveRecord::Base.transaction do
  free_plan = Plan.find_by_name('Free')
  essential_plan = Plan.find_by_name('Essential')
  basic_plan = Plan.find_by_name('Basic')
  premium_plan = Plan.find_by_name('Premium')
  enterprise_plan = Plan.find_by_name('Enterprise')
  essential_plan = Plan.find_by_name('Essential')
  free_plan = Plan.find_by_name('Free')


  free_owner = Role.find_by_name_and_plan_id('Owner', free_plan)

  essential_owner = Role.find_by_name_and_plan_id('Owner', essential_plan)
  essential_accountant = Role.find_by_name_and_plan_id('Accountant', essential_plan)
  essential_staff = Role.find_by_name_and_plan_id('Staff', essential_plan)

  products_create = Right.create!(:resource => 'products', :operation => 'CREATE')
  products_read = Right.create!(:resource => 'products', :operation => 'READ')
  products_delete = Right.create!(:resource => 'products', :operation => 'DELETE')
  products_update = Right.create!(:resource => 'products', :operation => 'UPDATE')

  #free_owner
  free_owner.rights << products_create
  free_owner.rights << products_read
  free_owner.rights << products_update
  free_owner.rights << products_delete

  #essential_owner
  essential_owner.rights << products_create
  essential_owner.rights << products_read
  essential_owner.rights << products_update
  essential_owner.rights << products_delete
  #essential_accountant
  essential_accountant.rights << products_create
  essential_accountant.rights << products_read
  essential_accountant.rights << products_update
  essential_accountant.rights << products_delete

  #essential_staff
  essential_staff.rights << products_create
  essential_staff.rights << products_read
  essential_staff.rights << products_update
  essential_staff.rights << products_delete


  free_owner = Role.find_by_name_and_plan_id('Owner', free_plan)

  essential_owner = Role.find_by_name_and_plan_id('Owner', essential_plan)
  essential_accountant = Role.find_by_name_and_plan_id('Accountant', essential_plan)
  essential_staff = Role.find_by_name_and_plan_id('Staff', essential_plan)
  essential_auditor = Role.find_by_name_and_plan_id('Auditor', essential_plan)


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

  #4)stock wastage register
    stock_wastage_register_read = Right.create!(:resource => 'stock_wastage_register', :operation => 'READ')

    #free_owner
    free_owner.rights << stock_wastage_register_read

  #essential_owner
   essential_owner.rights << stock_wastage_register_read
    #essential_accountant
   essential_accountant.rights << stock_wastage_register_read
    #essential_auditor
   essential_auditor.rights << stock_wastage_register_read

  #basic_owner
    basic_owner.rights << stock_wastage_register_read
    #basic_accountant
    basic_accountant.rights << stock_wastage_register_read
    #basic_auditor
    basic_auditor.rights << stock_wastage_register_read
    #premium_owner
    premium_owner.rights << stock_wastage_register_read
    #premium_accountant
    premium_accountant.rights << stock_wastage_register_read
    #premium_auditor
    premium_auditor.rights << stock_wastage_register_read
    #enterprise_owner
    enterprise_owner.rights << stock_wastage_register_read
    #enterprise_accountant
    enterprise_accountant.rights << stock_wastage_register_read
    #enterprise_auditor
    enterprise_auditor.rights << stock_wastage_register_read

  #enterprise_auditor
  enterprise_auditor.rights << stock_wastage_vouchers_read


      custom_fields_create = Right.create!(:resource => 'custom_fields', :operation => 'CREATE')
      custom_fields_read = Right.create!(:resource => 'custom_fields', :operation => 'READ')
      custom_fields_delete = Right.create!(:resource => 'custom_fields', :operation => 'DELETE')
      custom_fields_update = Right.create!(:resource => 'custom_fields', :operation => 'UPDATE')


     # #essential_owner
      essential_owner.rights << custom_fields_create
      essential_owner.rights << custom_fields_read
      essential_owner.rights << custom_fields_update
      essential_owner.rights << custom_fields_delete
  #    essential_accountant
      essential_accountant.rights << custom_fields_create
      essential_accountant.rights << custom_fields_read
      essential_accountant.rights << custom_fields_update
      essential_accountant.rights << custom_fields_delete

  # #   #basic_owner
      basic_owner.rights << custom_fields_create
      basic_owner.rights << custom_fields_read
      basic_owner.rights << custom_fields_update
      basic_owner.rights << custom_fields_delete
  # #   #basic_accountant
      basic_accountant.rights << custom_fields_create
      basic_accountant.rights << custom_fields_read
      basic_accountant.rights << custom_fields_update
      basic_accountant.rights << custom_fields_delete

  # #     #premium_owner
     premium_owner.rights << custom_fields_create
     premium_owner.rights << custom_fields_read
     premium_owner.rights << custom_fields_update
     premium_owner.rights << custom_fields_delete
  # #   #premium_accountant
     premium_accountant.rights << custom_fields_create
     premium_accountant.rights << custom_fields_read
     premium_accountant.rights << custom_fields_update
     premium_accountant.rights << custom_fields_delete

  # #   #enterprise_owner
     enterprise_owner.rights << custom_fields_create
     enterprise_owner.rights << custom_fields_read
     enterprise_owner.rights << custom_fields_update
     enterprise_owner.rights << custom_fields_delete
  # #  #enterprise_accountant
     enterprise_accountant.rights << custom_fields_create
     enterprise_accountant.rights << custom_fields_read
     enterprise_accountant.rights << custom_fields_update
     enterprise_accountant.rights << custom_fields_delete


=======
>>>>>>> b5f127e1a9607c61c4b25b2c845e26d6865eb123
end

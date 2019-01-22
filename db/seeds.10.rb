     essential_plan = Plan.find_by_name('Essential')
     essential_owner = essential_plan.roles.find_by_name('Owner')
     essential_accountant = essential_plan.roles.find_by_name('Accountant')
     essential_staff = essential_plan.roles.find_by_name('Staff')
     essential_employee = Role.create!(:name => 'Employee')
     essential_plan.roles << essential_employee

     #essential_employee = essential_plan.roles.find_by_name('Employee')

     essential_auditor = essential_plan.roles.find_by_name('Auditor')


      basic_plan = Plan.find_by_name('Basic')
      basic_owner = basic_plan.roles.find_by_name('Owner')
      basic_accountant = basic_plan.roles.find_by_name('Accountant')
      basic_staff = basic_plan.roles.find_by_name('Staff')
      basic_employee = Role.create!(:name => 'Employee')
      basic_plan.roles << basic_employee

      #basic_employee = basic_plan.roles.find_by_name('Employee')      
      basic_auditor = basic_plan.roles.find_by_name('Auditor')


      premium_plan = Plan.find_by_name('Premium')
      premium_owner = premium_plan.roles.find_by_name('Owner')
      premium_accountant = premium_plan.roles.find_by_name('Accountant')
      premium_staff = premium_plan.roles.find_by_name('Staff')
      premium_auditor = premium_plan.roles.find_by_name('Auditor')
      premium_employee = premium_plan.roles.find_by_name('Employee')

     enterprise_plan = Plan.find_by_name('Enterprise')
     enterprise_owner = enterprise_plan.roles.find_by_name('Owner')
     enterprise_accountant = enterprise_plan.roles.find_by_name('Accountant')
     enterprise_staff = enterprise_plan.roles.find_by_name('Staff')
     enterprise_employee = enterprise_plan.roles.find_by_name('Employee')
     enterprise_auditor = enterprise_plan.roles.find_by_name('Auditor')


     free_plan = Plan.find_by_name('Free')
     free_owner = free_plan.roles.find_by_name('Owner')

    leaves_create = Right.create!(:resource => 'leave_cards', :operation => 'CREATE')
    leaves_read = Right.create!(:resource => 'leave_cards', :operation => 'READ') 
    leaves_delete = Right.create!(:resource => 'leave_cards', :operation => 'DELETE')
    leaves_update = Right.create!(:resource => 'leave_cards', :operation => 'UPDATE')

    leaves_approval_create = Right.create!(:resource => 'leave_approval', :operation => 'CREATE')
    leaves_approval_read = Right.create!(:resource => 'leave_approval', :operation => 'READ') 
    leaves_approval_delete = Right.create!(:resource => 'leave_approval', :operation => 'DELETE')
    leaves_approval_update = Right.create!(:resource => 'leave_approval', :operation => 'UPDATE')

    leave_requests_create = Right.find_by_resource_and_operation('leave_requests','CREATE')
    leave_requests_read = Right.find_by_resource_and_operation('leave_requests','READ')
    leave_requests_update = Right.find_by_resource_and_operation('leave_requests','UPDATE')
    leave_requests_delete = Right.find_by_resource_and_operation('leave_requests','DELETE')

    # #free_owner 
    free_owner.rights << leaves_create
    free_owner.rights << leaves_read
    free_owner.rights << leaves_update
    free_owner.rights << leaves_delete
   
  #essential_owner  
    essential_owner.rights << leaves_create
    essential_owner.rights << leaves_read
    essential_owner.rights << leaves_update
    essential_owner.rights << leaves_delete

    essential_owner.rights << leaves_approval_create
    essential_owner.rights << leaves_approval_read
    essential_owner.rights << leaves_approval_update
    essential_owner.rights << leaves_approval_delete

   #basic_accountant
    essential_accountant.rights << leaves_create
    essential_accountant.rights << leaves_read
    essential_accountant.rights << leaves_update
    essential_accountant.rights << leaves_delete

    essential_accountant.rights << leaves_approval_create
    essential_accountant.rights << leaves_approval_read
    essential_accountant.rights << leaves_approval_update
    essential_accountant.rights << leaves_approval_delete

  #essential_staff
    essential_staff.rights << leaves_create
    essential_staff.rights << leaves_read
    essential_staff.rights << leaves_update
    essential_staff.rights << leaves_delete

    essential_staff.rights << leaves_approval_create
    essential_staff.rights << leaves_approval_read
    essential_staff.rights << leaves_approval_update
    essential_staff.rights << leaves_approval_delete

  #essential_employee
    essential_employee.rights << leaves_create
    essential_employee.rights << leaves_read
    essential_employee.rights << leaves_update
    essential_employee.rights << leaves_delete

    essential_employee.rights << leave_requests_delete


  #essential_auditor
  # essential_auditor.rights << leaves_read 

  #basic_owner 
    basic_owner.rights << leaves_create
    basic_owner.rights << leaves_read
    basic_owner.rights << leaves_update
    basic_owner.rights << leaves_delete

    basic_owner.rights << leaves_approval_create
    basic_owner.rights << leaves_approval_read
    basic_owner.rights << leaves_approval_update
    basic_owner.rights << leaves_approval_delete

  #basic_accountant
    basic_accountant.rights << leaves_create
    basic_accountant.rights << leaves_read
    basic_accountant.rights << leaves_update
    basic_accountant.rights << leaves_delete

    basic_accountant.rights << leaves_approval_create
    basic_accountant.rights << leaves_approval_read
    basic_accountant.rights << leaves_approval_update
    basic_accountant.rights << leaves_approval_delete

  #basic_staff
    basic_staff.rights << leaves_create
    basic_staff.rights << leaves_read
    basic_staff.rights << leaves_update
    basic_staff.rights << leaves_delete

    basic_staff.rights << leaves_approval_create
    basic_staff.rights << leaves_approval_read
    basic_staff.rights << leaves_approval_update
    basic_staff.rights << leaves_approval_delete


  #basic_employee
    basic_employee.rights << leaves_create
    basic_employee.rights << leaves_read
    basic_employee.rights << leaves_update
    basic_employee.rights << leaves_delete
    basic_employee.rights << leave_requests_delete
  #basic_auditor
    #basic_auditor.rights << leaves_read

  #premium_owner  
    premium_owner.rights << leaves_create
    premium_owner.rights << leaves_read
    premium_owner.rights << leaves_update
    premium_owner.rights << leaves_delete

    premium_owner.rights << leaves_approval_create
    premium_owner.rights << leaves_approval_read
    premium_owner.rights << leaves_approval_update
    premium_owner.rights << leaves_approval_delete

  #premium_accountant
    premium_accountant.rights << leaves_create
    premium_accountant.rights << leaves_read
    premium_accountant.rights << leaves_update
    premium_accountant.rights << leaves_delete

    premium_accountant.rights << leaves_approval_create
    premium_accountant.rights << leaves_approval_read
    premium_accountant.rights << leaves_approval_update
    premium_accountant.rights << leaves_approval_delete

  #premium_staff
    premium_staff.rights << leaves_create
    premium_staff.rights << leaves_read
    premium_staff.rights << leaves_update
    premium_staff.rights << leaves_delete

    premium_staff.rights << leaves_approval_create
    premium_staff.rights << leaves_approval_read
    premium_staff.rights << leaves_approval_update
    premium_staff.rights << leaves_approval_delete

  #premium_auditor
    #premium_auditor.rights << leaves_read
  #premium employee
      premium_employee.rights << leaves_create
      premium_employee.rights << leaves_read
      premium_employee.rights << leaves_update
      premium_employee.rights << leaves_delete

      premium_employee.rights << leaves_approval_create
      premium_employee.rights << leaves_approval_read
      premium_employee.rights << leaves_approval_update
      premium_employee.rights << leaves_approval_delete

      premium_employee.rights << leave_requests_delete

  #enterprise_owner 
    enterprise_owner.rights << leaves_create
    enterprise_owner.rights << leaves_read
    enterprise_owner.rights << leaves_update
    enterprise_owner.rights << leaves_delete

    enterprise_owner.rights << leaves_approval_create
    enterprise_owner.rights << leaves_approval_read
    enterprise_owner.rights << leaves_approval_update
    enterprise_owner.rights << leaves_approval_delete

  #enterprise_accountant
    enterprise_accountant.rights << leaves_create
    enterprise_accountant.rights << leaves_read
    enterprise_accountant.rights << leaves_update
    enterprise_accountant.rights << leaves_delete

    enterprise_accountant.rights << leaves_approval_create
    enterprise_accountant.rights << leaves_approval_read
    enterprise_accountant.rights << leaves_approval_update
    enterprise_accountant.rights << leaves_approval_delete

  #enterprise_staff
    enterprise_staff.rights << leaves_create
    enterprise_staff.rights << leaves_read
    enterprise_staff.rights << leaves_update
    enterprise_staff.rights << leaves_delete

    enterprise_staff.rights << leaves_approval_create
    enterprise_staff.rights << leaves_approval_read
    enterprise_staff.rights << leaves_approval_update
    enterprise_staff.rights << leaves_approval_delete

  #enterprise_auditor
    #enterprise_auditor.rights << leaves_read
  #enterprise_employee
     enterprise_employee.rights << leaves_create
     enterprise_employee.rights << leaves_read
     enterprise_employee.rights << leaves_update
     enterprise_employee.rights << leaves_delete
     enterprise_employee.rights << leave_requests_delete
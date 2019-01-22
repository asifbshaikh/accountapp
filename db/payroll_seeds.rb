#default holiday creation for payroll enabled companies  
  #  @companies = Company.all
  #  @companies.each do |company|
  #  if company.plan.payroll_enabled?	
  #   user = company.users.first
  #  	# fin_year = FinancialYear.find_by_company_id(company.id)
  #  	# puts"fin year start date is #{fin_year.start_date} and end date is #{fin_year.end_date}"
  #   # year = (Time.zone.now.to_date.month.to_i < fin_year.start_date.month ?  fin_year.end_date.year : fin_year.start_date.year )
  #   # holiday_date1 = Date.new(year.to_i, 1, 26)
  #   # holiday_date2 = Date.new(year.to_i, 8, 15)
  #   # holiday_date3 = Date.new(year.to_i, 10, 02)  
  #   # holiday = Holiday.create(:company_id => company.id, :created_by => user.id, :holiday=> "Republic day", :holiday_date => holiday_date1, :description =>"Republic day of India")
  #   # holiday = Holiday.create(:company_id => company.id, :created_by => user.id, :holiday=> "Independance Day", :holiday_date => holiday_date2, :description =>"Independance day of India")
  #   # holiday = Holiday.create(:company_id => company.id, :created_by => user.id, :holiday=> "Mahatma Gandhi Jayanti", :holiday_date => holiday_date3, :description =>"Gandhi Jayanti celebrated in India to mark the occasion of the birthday of Mahatma Gandhi.")

  # #leave type creation for payroll enabled companies
  #   leave_type = LeaveType.create(:company_id => company.id, :created_by => user.id, :leave_type=> "Sick Leave", :allowed_leaves => 10)
  #   leave_type = LeaveType.create(:company_id => company.id, :created_by => user.id, :leave_type=> "Casual Leave", :allowed_leaves => 10)
  #   leave_type = LeaveType.create(:company_id => company.id, :created_by => user.id, :leave_type=> "Leave without pay", :allowed_leaves => 10)
  #  end    
  # end


  essential_plan = Plan.find_by_name('Essential')
  essential_owner = essential_plan.roles.find_by_name('Owner')
  essential_accountant = essential_plan.roles.find_by_name('Accountant')
  essential_staff = essential_plan.roles.find_by_name('Staff')
  essential_auditor = essential_plan.roles.find_by_name('Auditor')

  basic_plan = Plan.find_by_name('Basic')
  basic_owner = basic_plan.roles.find_by_name('Owner')
  basic_accountant = basic_plan.roles.find_by_name('Accountant')
  basic_staff = basic_plan.roles.find_by_name('Staff')
  basic_auditor = basic_plan.roles.find_by_name('Auditor')

#payroll repors rights
  premium_plan = Plan.find_by_name('Premium')
  premium_owner = premium_plan.roles.find_by_name('Owner')
  premium_accountant = premium_plan.roles.find_by_name('Accountant')
  premium_auditor = premium_plan.roles.find_by_name('Auditor')
  premium_staff = premium_plan.roles.find_by_name('Staff')
  premium_employee = premium_plan.roles.find_by_name('Employee')

  enterprise_plan = Plan.find_by_name('Enterprise')
  enterprise_owner = enterprise_plan.roles.find_by_name('Owner')
  enterprise_accountant = enterprise_plan.roles.find_by_name('Accountant')
  enterprise_auditor = enterprise_plan.roles.find_by_name('Auditor')
  enterprise_staff = enterprise_plan.roles.find_by_name('Staff')
  enterprise_employee = enterprise_plan.roles.find_by_name('Employee')

# #payroll repors rights
#  # 1) Payroll register 
#    payroll_register_read = Right.create!(:resource => 'payroll_register', :operation => 'READ') 
  
#   #premium_owner  
#    premium_owner.rights << payroll_register_read
#   # premium_accountant
#    premium_accountant.rights << payroll_register_read
#   # premium_auditor
#    premium_auditor.rights << payroll_register_read
   
#   #enterprise_owner  
#    enterprise_owner.rights << payroll_register_read
#   #enterprise_accountant
#    enterprise_accountant.rights << payroll_register_read
#   #enterprise_auditor
#    enterprise_auditor.rights << payroll_register_read

# # 2) Attendance register
#    attendance_register_read = Right.create!(:resource => 'attendance_register', :operation => 'READ') 
  
#   #premium_owner  
#    premium_owner.rights << attendance_register_read
#   # premium_accountant
#    premium_accountant.rights << attendance_register_read
#   # premium_auditor
#    premium_auditor.rights << attendance_register_read
   
#   #enterprise_owner  
#    enterprise_owner.rights << attendance_register_read
#   #enterprise_accountant
#    enterprise_accountant.rights << attendance_register_read
#   #enterprise_auditor
#    enterprise_auditor.rights << attendance_register_read

# # 3) Employee breakup
#   employee_breakup_read = Right.create!(:resource => 'employee_breakup', :operation => 'READ') 
  
#   #premium_owner  
#    premium_owner.rights << employee_breakup_read
#   # premium_accountant
#    premium_accountant.rights << employee_breakup_read
#   # premium_auditor
#    premium_auditor.rights << employee_breakup_read
   
#   #enterprise_owner  
#    enterprise_owner.rights << employee_breakup_read
#   #enterprise_accountant
#    enterprise_accountant.rights << employee_breakup_read
#   #enterprise_auditor
#    enterprise_auditor.rights << employee_breakup_read

#  #4) Payment advice
#   payment_advice_read = Right.create!(:resource => 'payment_advice', :operation => 'READ') 
  
#   #premium_owner  
#    premium_owner.rights << payment_advice_read
#   # premium_accountant
#    premium_accountant.rights << payment_advice_read
#   # premium_auditor
#    premium_auditor.rights << payment_advice_read
   
#   #enterprise_owner  
#    enterprise_owner.rights << payment_advice_read
#   #enterprise_accountant
#    enterprise_accountant.rights << payment_advice_read
#   #enterprise_auditor
#    enterprise_auditor.rights << payment_advice_read  

# #My organisation rights
#    my_organisation_create = Right.create!(:resource => 'my_organisation', :operation => 'CREATE')
#    my_organisation_read = Right.create!(:resource => 'my_organisation', :operation => 'READ') 
#    my_organisation_delete = Right.create!(:resource => 'my_organisation', :operation => 'DELETE')
#    my_organisation_update = Right.create!(:resource => 'my_organisation', :operation => 'UPDATE')

# #   premium_owner 
#    premium_owner.rights << my_organisation_create
#    premium_owner.rights << my_organisation_read
#    premium_owner.rights << my_organisation_update
#    premium_owner.rights << my_organisation_delete
# #    premium_accountant
#    premium_accountant.rights << my_organisation_read
# #    premium_staff
#    premium_staff.rights << my_organisation_read
#  #   premium_employee
#     premium_employee.rights << my_organisation_read

#  #   enterprise_owner 
#    enterprise_owner.rights << my_organisation_create
#    enterprise_owner.rights << my_organisation_read
#    enterprise_owner.rights << my_organisation_update
#    enterprise_owner.rights << my_organisation_delete
#  #   enterprise_accountant
#    enterprise_accountant.rights << my_organisation_read
#  #   enterprise_staff
#    enterprise_staff.rights << my_organisation_read
#  #  enterprise_employee
#     enterprise_employee.rights << my_organisation_read


## 2) Attendance register
#    attendance_register_read = Right.create!(:resource => 'attendance_register', :operation => 'READ') 
  
#   #premium_owner  
#    premium_owner.rights << attendance_register_read
#   # premium_accountant
#    premium_accountant.rights << attendance_register_read
#   # premium_auditor
#    premium_auditor.rights << attendance_register_read
   
#   #enterprise_owner  
#    enterprise_owner.rights << attendance_register_read
#   #enterprise_accountant
#    enterprise_accountant.rights << attendance_register_read
#   #enterprise_auditor
#    enterprise_auditor.rights << attendance_register_read

# # 3) Employee breakup
#   employee_breakup_read = Right.create!(:resource => 'employee_breakup', :operation => 'READ') 
  
#   #premium_owner  
#    premium_owner.rights << employee_breakup_read
#   # premium_accountant
#    premium_accountant.rights << employee_breakup_read
#   # premium_auditor
#    premium_auditor.rights << employee_breakup_read
   
#   #enterprise_owner  
#    enterprise_owner.rights << employee_breakup_read
#   #enterprise_accountant
#    enterprise_accountant.rights << employee_breakup_read
#   #enterprise_auditor
#    enterprise_auditor.rights << employee_breakup_read

#  #4) Payment advice
#   payment_advice_read = Right.create!(:resource => 'payment_advice', :operation => 'READ') 
  
#   #premium_owner  
#    premium_owner.rights << payment_advice_read
#   # premium_accountant
#    premium_accountant.rights << payment_advice_read
#   # premium_auditor
#    premium_auditor.rights << payment_advice_read
   
#   #enterprise_owner  
#    enterprise_owner.rights << payment_advice_read
#   #enterprise_accountant
#    enterprise_accountant.rights << payment_advice_read
#   #enterprise_auditor
#    enterprise_auditor.rights << payment_advice_read  

# #My organisation rights
#    my_organisation_create = Right.create!(:resource => 'my_organisation', :operation => 'CREATE')
#    my_organisation_read = Right.create!(:resource => 'my_organisation', :operation => 'READ') 
#    my_organisation_delete = Right.create!(:resource => 'my_organisation', :operation => 'DELETE')
#    my_organisation_update = Right.create!(:resource => 'my_organisation', :operation => 'UPDATE')

# #   premium_owner 
#    premium_owner.rights << my_organisation_create
#    premium_owner.rights << my_organisation_read
#    premium_owner.rights << my_organisation_update
#    premium_owner.rights << my_organisation_delete
# #    premium_accountant
#    premium_accountant.rights << my_organisation_read
# #    premium_staff
#    premium_staff.rights << my_organisation_read
#  #   premium_employee
#     premium_employee.rights << my_organisation_read

#  #   enterprise_owner 
#    enterprise_owner.rights << my_organisation_create
#    enterprise_owner.rights << my_organisation_read
#    enterprise_owner.rights << my_organisation_update
#    enterprise_owner.rights << my_organisation_delete
#  #   enterprise_accountant
#    enterprise_accountant.rights << my_organisation_read
#  #   enterprise_staff
#    enterprise_staff.rights << my_organisation_read
#  #  enterprise_employee
#     enterprise_employee.rights << my_organisation_read

# TASKS
    projects_create = Right.create!(:resource => 'projects', :operation => 'CREATE')
    projects_read = Right.create!(:resource => 'projects', :operation => 'READ') 
    projects_delete = Right.create!(:resource => 'projects', :operation => 'DELETE')
    projects_update = Right.create!(:resource => 'projects', :operation => 'UPDATE')
    
    #essential_owner  
    essential_owner.rights << projects_create
    essential_owner.rights << projects_read
    essential_owner.rights << projects_update
    essential_owner.rights << projects_delete
    #essential_accountant
    essential_accountant.rights << projects_create
    essential_accountant.rights << projects_read
    essential_accountant.rights << projects_update
    essential_accountant.rights << projects_delete
    #essential_staff
    essential_staff.rights << projects_read
    #essential_auditor
    essential_auditor.rights << projects_read

    #basic_owner  
    basic_owner.rights << projects_create
    basic_owner.rights << projects_read
    basic_owner.rights << projects_update
    basic_owner.rights << projects_delete
    #basic_accountant
    basic_accountant.rights << projects_create
    basic_accountant.rights << projects_read
    basic_accountant.rights << projects_update
    basic_accountant.rights << projects_delete
    #basic_staff
    basic_staff.rights << projects_read
    #basic_auditor
    basic_auditor.rights << projects_read

    #premium_owner  
    premium_owner.rights << projects_create
    premium_owner.rights << projects_read
    premium_owner.rights << projects_update
    premium_owner.rights << projects_delete
    #premium_accountant
    premium_accountant.rights << projects_create
    premium_accountant.rights << projects_read
    premium_accountant.rights << projects_update
    premium_accountant.rights << projects_delete
    #premium_staff
    premium_staff.rights << projects_read
    #premium_auditor
    premium_auditor.rights << projects_read

    #enterprise_owner 
    enterprise_owner.rights << projects_create
    enterprise_owner.rights << projects_read
    enterprise_owner.rights << projects_update
    enterprise_owner.rights << projects_delete
    #enterprise_accountant
    enterprise_accountant.rights << projects_create
    enterprise_accountant.rights << projects_read
    enterprise_accountant.rights << projects_update
    enterprise_accountant.rights << projects_delete
    #enterprise_staff
    enterprise_staff.rights << projects_read
    #enterprise_auditor
    enterprise_auditor.rights << projects_read

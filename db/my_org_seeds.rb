ActiveRecord::Base.transaction do
  free_plan = Plan.find_by_name('Free')
  essential_plan = Plan.find_by_name('Essential')
  basic_plan = Plan.find_by_name('Basic')
  premium_plan = Plan.find_by_name('Premium')
  enterprise_plan = Plan.find_by_name('Enterprise')

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


#My organisation rights
   my_organisation_create = Right.create!(:resource => 'my_organisation', :operation => 'CREATE')
   my_organisation_read = Right.create!(:resource => 'my_organisation', :operation => 'READ') 
   my_organisation_delete = Right.create!(:resource => 'my_organisation', :operation => 'DELETE')
   my_organisation_update = Right.create!(:resource => 'my_organisation', :operation => 'UPDATE')

#   premium_owner 
   premium_owner.rights << my_organisation_create
   premium_owner.rights << my_organisation_read
   premium_owner.rights << my_organisation_update
   premium_owner.rights << my_organisation_delete
#    premium_accountant
   premium_accountant.rights << my_organisation_read
#    premium_staff
   premium_staff.rights << my_organisation_read
 #   premium_employee
    premium_employee.rights << my_organisation_read

 #   enterprise_owner 
   enterprise_owner.rights << my_organisation_create
   enterprise_owner.rights << my_organisation_read
   enterprise_owner.rights << my_organisation_update
   enterprise_owner.rights << my_organisation_delete
 #   enterprise_accountant
   enterprise_accountant.rights << my_organisation_read
 #   enterprise_staff
   enterprise_staff.rights << my_organisation_read
 #  enterprise_employee
    enterprise_employee.rights << my_organisation_read


# #low stock register register
#     low_stock_read = Right.create!(:resource => 'low_stock', :operation => 'READ') 

#     #free_owner 
#     free_owner.rights << low_stock_read

#   #essential_owner  
#    essential_owner.rights << low_stock_read
#     #essential_accountant
#    essential_accountant.rights << low_stock_read
#     #essential_auditor
#    essential_auditor.rights << low_stock_read  

#   #basic_owner  
#     basic_owner.rights << low_stock_read
#     #basic_accountant
#     basic_accountant.rights << low_stock_read
#     #basic_auditor
#     basic_auditor.rights << low_stock_read
#     #premium_owner  
#     premium_owner.rights << low_stock_read
#     #premium_accountant
#     premium_accountant.rights << low_stock_read
#     #premium_auditor
#     premium_auditor.rights << low_stock_read
#     #enterprise_owner 
#     enterprise_owner.rights << low_stock_read
#     #enterprise_accountant
#     enterprise_accountant.rights << low_stock_read
#     #enterprise_auditor
#     enterprise_auditor.rights << low_stock_read

end
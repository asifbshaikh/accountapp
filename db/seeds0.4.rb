# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first

#ADMIN CREATION
#  admin = SuperUser.create(:first_name => 'Naveen', :last_name => 'Thota', :username => 'naveent', :email => 'ravindra@thenextwave.in',
#                            :role => 'Admin', :active => true, :password => 'Admin@2012')

# PLANS DEFINITION
#  free_plan = Plan.create(:name => 'Free',:price => 0, :description => 'The Free plan.', :display_name => 'Free')
#   essential_plan = Plan.create(:name => 'Essential',:price => 375, :description => 'Essential plan with multi user accounting.', :display_name => 'Essential')
#  basic_plan = Plan.create(:name => 'Basic', :price => 525, :description => 'The accounting plus plan with inventory and multi-user accounting', :display_name => 'Plus')
#  premium_plan = Plan.create(:name => 'Premium', :price => 625, :description => 'The accounting pro plan with multi-user accounting and inventory and payroll', :display_name => 'Professional')
#  premium_plan = Plan.find_by_name('Premium')
#  enterprise_plan = Plan.create(:name => 'Enterprise', :price => 825, :description => 'The enterprise plan with multi-user accounting with inventory, payroll and crm', :display_name => 'Enterprise')
#  enterprise_plan = Plan.find_by_name('Enterprise')
# ROLES DEFINITIONS ACCORDING TO PLANS
#  free_owner = Role.create!(:name => 'Owner')
#  free_plan.roles << free_owner
 #Essential plan roles 
#  essential_owner = Role.create!(:name => 'Owner')
#  essential_plan.roles << essential_owner
#  essential_accountant = Role.create!(:name => 'Accountant')
#  essential_plan.roles << essential_accountant
#  essential_staff = Role.create!(:name => 'Staff')
#  essential_plan.roles << essential_staff
#  essential_auditor = Role.create!(:name => 'Auditor')
#  essential_plan.roles << essential_auditor
    essential_plan = Plan.find_by_name('Essential')
    essential_owner = essential_plan.roles.find_by_name('Owner')
    essential_accountant = essential_plan.roles.find_by_name('Accountant')
    essential_staff = essential_plan.roles.find_by_name('Staff')
    essential_auditor = essential_plan.roles.find_by_name('Auditor')

  #basic plan roles
#  basic_owner = Role.create!(:name => 'Owner')
#  basic_plan.roles << basic_owner
#  basic_accountant = Role.create!(:name => 'Accountant')
#  basic_plan.roles << basic_accountant
#  basic_staff = Role.create!(:name => 'Staff')
#  basic_plan.roles << basic_staff
#  basic_auditor = Role.create!(:name => 'Auditor')
#  basic_plan.roles << basic_auditor
     basic_plan = Plan.find_by_name('Basic')
     basic_owner = basic_plan.roles.find_by_name('Owner')
     basic_accountant = basic_plan.roles.find_by_name('Accountant')
     basic_staff = basic_plan.roles.find_by_name('Staff')
     basic_auditor = basic_plan.roles.find_by_name('Auditor')

  #premium plan roles
#  premium_owner = Role.create!(:name => 'Owner')
#  premium_plan.roles << premium_owner
#  premium_accountant = Role.create!(:name => 'Accountant')
#  premium_plan.roles << premium_accountant
#  premium_staff = Role.create!(:name => 'Staff')
#  premium_plan.roles << premium_staff
#  premium_auditor = Role.create!(:name => 'Auditor')
#  premium_plan.roles << premium_auditor
     premium_plan = Plan.find_by_name('Premium')
     premium_owner = premium_plan.roles.find_by_name('Owner')
     premium_accountant = premium_plan.roles.find_by_name('Accountant')
     premium_staff = premium_plan.roles.find_by_name('Staff')
     premium_auditor = premium_plan.roles.find_by_name('Auditor')
   
   premium_employee = Role.create!(:name => 'Employee')
   premium_plan.roles << premium_employee

  #enterprise plan roles
#  enterprise_owner = Role.create!(:name => 'Owner')
#  enterprise_plan.roles << enterprise_owner
#  enterprise_accountant = Role.create!(:name => 'Accountant')
#  enterprise_plan.roles << enterprise_accountant
#  enterprise_staff = Role.create!(:name => 'Staff')
#  enterprise_plan.roles << enterprise_staff
#  enterprise_auditor = Role.create!(:name => 'Auditor')
#  enterprise_plan.roles << enterprise_auditor
     enterprise_plan = Plan.find_by_name('Enterprise')
     enterprise_owner = enterprise_plan.roles.find_by_name('Owner')
     enterprise_accountant = enterprise_plan.roles.find_by_name('Accountant')
     enterprise_staff = enterprise_plan.roles.find_by_name('Staff')
     enterprise_auditor = enterprise_plan.roles.find_by_name('Auditor')
   
   enterprise_employee = Role.create!(:name => 'Employee')
   enterprise_plan.roles << enterprise_employee

    
#sandbox_gateway = PaymentGateway.create!(:name => "Citrus Sandbox",:key =>"a6d228d264111d6bbe30e9b719fb3b0048fdd3bb", :vanity_url => #"thenextwave", :gateway_url => "https://sandbox.citruspay.com/thenextwave",:production => true)

#production_gateway = PaymentGateway.create!(:name => "Citrus payment gateway",:key =>"b95517fd697ef838c8cf65d49d3706372ed49da7", :vanity_url => "thenextwave", :gateway_url => "https://www.citruspay.com/ thenextwave",:production => true)

#Accounting Rights for all controllers:
#     billing_read = Right.create!(:resource => 'billing', :operation => 'READ')

    #free_owner	
#     free_plan = Plan.find_by_name('Free')
#     free_owner = free_plan.roles.find_by_name('Owner')
#    free_owner.rights << billing_read


    #essential_owner	
     
#     essential_owner.rights << billing_read

  #basic_owner	
     
#     basic_owner.rights << billing_read

   #premium_owner	
#     premium_owner.rights << billing_read
    
#enterprise_owner	
#     enterprise_owner.rights << billing_read

     
		
# DASHBOARD
 #  dashboard_read = Right.create!(:resource => 'dashboard', :operation => 'READ') 

    #free_owner	
  #  free_owner.rights << dashboard_read
  
   #essential_owner	
#    essential_owner.rights << dashboard_read
    #essential_accountant
#    essential_accountant.rights << dashboard_read
    #essential_staff
 #   essential_staff.rights << dashboard_read
    #essential_auditor
 #   essential_auditor.rights << dashboard_read 
  
  #basic_owner	
#    basic_owner.rights << dashboard_read
    #basic_accountant
#    basic_accountant.rights << dashboard_read
    #basic_staff
#    basic_staff.rights << dashboard_read
    #basic_auditor
#    basic_auditor.rights << dashboard_read
   
   #premium_owner	
#    premium_owner.rights << dashboard_read
    #premium_accountant
#    premium_accountant.rights << dashboard_read
    #premium_staff
#    premium_staff.rights << dashboard_read
    #premium_auditor
#    premium_auditor.rights << dashboard_read
    #premium_employee

    #enterprise_owner	
#    enterprise_owner.rights << dashboard_read
    #enterprise_accountant
#    enterprise_accountant.rights << dashboard_read
    #enterprise_staff
#    enterprise_staff.rights << dashboard_read
    #enterprise_auditor
#    enterprise_auditor.rights << dashboard_read
    #enterprise_employee

# TASKS
#    tasks_create = Right.create!(:resource => 'tasks', :operation => 'CREATE')
#    tasks_read = Right.create!(:resource => 'tasks', :operation => 'READ') 
#    tasks_delete = Right.create!(:resource => 'tasks', :operation => 'DELETE')
#    tasks_update = Right.create!(:resource => 'tasks', :operation => 'UPDATE')
     tasks_create = Right.find_by_resource_and_operation('tasks','CREATE')  
     tasks_read = Right.find_by_resource_and_operation('tasks','READ')  
     tasks_delete = Right.find_by_resource_and_operation('tasks','DELETE')  
     tasks_update = Right.find_by_resource_and_operation('tasks','UPDATE')  
    #free_owner	
   # free_owner.rights << tasks_create
   # free_owner.rights << tasks_read
   # free_owner.rights << tasks_update
   # free_owner.rights << tasks_delete
   
  #essential_owner	
#    essential_owner.rights << tasks_create
#    essential_owner.rights << tasks_read
#    essential_owner.rights << tasks_update
#    essential_owner.rights << tasks_delete
#    #basic_accountant
#    essential_accountant.rights << tasks_create
#    essential_accountant.rights << tasks_read
#    essential_accountant.rights << tasks_update
#    essential_accountant.rights << tasks_delete
    #essential_staff
#    essential_staff.rights << tasks_create
#    essential_staff.rights << tasks_read
#    essential_staff.rights << tasks_update
#    essential_staff.rights << tasks_delete
    #essential_auditor
#    essential_auditor.rights << tasks_read 

   #basic_owner	
#    basic_owner.rights << tasks_create
#    basic_owner.rights << tasks_read
#    basic_owner.rights << tasks_update
#    basic_owner.rights << tasks_delete
    #basic_accountant
 #   basic_accountant.rights << tasks_create
 #   basic_accountant.rights << tasks_read
 #   basic_accountant.rights << tasks_update
 #   basic_accountant.rights << tasks_delete
    #basic_staff
 #   basic_staff.rights << tasks_create
 #   basic_staff.rights << tasks_read
 #   basic_staff.rights << tasks_update
 #   basic_staff.rights << tasks_delete
    #basic_auditor
 #   basic_auditor.rights << tasks_read

    #premium_owner	
#    premium_owner.rights << tasks_create
#    premium_owner.rights << tasks_read
#    premium_owner.rights << tasks_update
#    premium_owner.rights << tasks_delete
    #premium_accountant
#    premium_accountant.rights << tasks_create
#    premium_accountant.rights << tasks_read
#    premium_accountant.rights << tasks_update
#    premium_accountant.rights << tasks_delete
    #premium_staff
#    premium_staff.rights << tasks_create
#    premium_staff.rights << tasks_read
#    premium_staff.rights << tasks_update
 #   premium_staff.rights << tasks_delete
    #premium_auditor
 #   premium_auditor.rights << tasks_read
     #premium employee
     premium_employee.rights << tasks_create
     premium_employee.rights << tasks_read
     premium_employee.rights << tasks_update
     premium_employee.rights << tasks_delete

    #enterprise_owner	
#    enterprise_owner.rights << tasks_create
#    enterprise_owner.rights << tasks_read
#    enterprise_owner.rights << tasks_update
#    enterprise_owner.rights << tasks_delete
    #enterprise_accountant
#    enterprise_accountant.rights << tasks_create
#    enterprise_accountant.rights << tasks_read
#    enterprise_accountant.rights << tasks_update
#    enterprise_accountant.rights << tasks_delete
    #enterprise_staff
#    enterprise_staff.rights << tasks_create
#    enterprise_staff.rights << tasks_read
#    enterprise_staff.rights << tasks_update
#    enterprise_staff.rights << tasks_delete
    #enterprise_auditor
#    enterprise_auditor.rights << tasks_read
    #enterprise_employee
    enterprise_employee.rights << tasks_create
    enterprise_employee.rights << tasks_read
    enterprise_employee.rights << tasks_update
    enterprise_employee.rights << tasks_delete


# MESSAGES
#    messages_create = Right.create!(:resource => 'messages', :operation => 'CREATE')
#    messages_read = Right.create!(:resource => 'messages', :operation => 'READ') 
#    messages_delete = Right.create!(:resource => 'messages', :operation => 'DELETE')
#    messages_update = Right.create!(:resource => 'messages', :operation => 'UPDATE')
     messages_create = Right.find_by_resource_and_operation('messages','CREATE')  
     messages_read = Right.find_by_resource_and_operation('messages','READ')  
     messages_delete = Right.find_by_resource_and_operation('messages','DELETE')  
     messages_update = Right.find_by_resource_and_operation('messages','UPDATE')  

    #free_owner	
    #free_owner.rights << messages_create
    #free_owner.rights << messages_read
    #free_owner.rights << messages_update
    #free_owner.rights << messages_delete
    
#essential_owner	
#    essential_owner.rights << messages_create
#    essential_owner.rights << messages_read
#    essential_owner.rights << messages_update
#    essential_owner.rights << messages_delete
    #essential_accountant
#    essential_accountant.rights << messages_create
#    essential_accountant.rights << messages_read
#    essential_accountant.rights << messages_update
#    essential_accountant.rights << messages_delete
    #essential_staff
#    essential_staff.rights << messages_create
#    essential_staff.rights << messages_read
#    essential_staff.rights << messages_update
#    essential_staff.rights << messages_delete
    #essential_auditor
#    essential_auditor.rights << messages_read

#basic_owner	
#    basic_owner.rights << messages_create
#    basic_owner.rights << messages_read
#    basic_owner.rights << messages_update
#    basic_owner.rights << messages_delete
    #basic_accountant
#    basic_accountant.rights << messages_create
#    basic_accountant.rights << messages_read
#    basic_accountant.rights << messages_update
#    basic_accountant.rights << messages_delete
    #basic_staff
#    basic_staff.rights << messages_create
#    basic_staff.rights << messages_read
#    basic_staff.rights << messages_update
#    basic_staff.rights << messages_delete
    #basic_auditor
#    basic_auditor.rights << messages_read

    #premium_owner	
#    premium_owner.rights << messages_create
#    premium_owner.rights << messages_read
#    premium_owner.rights << messages_update
#    premium_owner.rights << messages_delete
    #premium_accountant
#    premium_accountant.rights << messages_create
#    premium_accountant.rights << messages_read
#    premium_accountant.rights << messages_update
#   premium_accountant.rights << messages_delete
    #premium_staff
#    premium_staff.rights << messages_create
#    premium_staff.rights << messages_read
#    premium_staff.rights << messages_update
#    premium_staff.rights << messages_delete
    #premium_auditor
#    premium_auditor.rights << messages_read
    #premium_employee
    premium_employee.rights << messages_create
    premium_employee.rights << messages_read
    premium_employee.rights << messages_update
    premium_employee.rights << messages_delete


    #enterprise_owner	
#    enterprise_owner.rights << messages_create
#    enterprise_owner.rights << messages_read
#    enterprise_owner.rights << messages_update
#    enterprise_owner.rights << messages_delete
    #enterprise_accountant
#    enterprise_accountant.rights << messages_create
#    enterprise_accountant.rights << messages_read
#    enterprise_accountant.rights << messages_update
#    enterprise_accountant.rights << messages_delete
    #enterprise_staff
#    enterprise_staff.rights << messages_create
#    enterprise_staff.rights << messages_read
#    enterprise_staff.rights << messages_update
#    enterprise_staff.rights << messages_delete
    #enterprise_employee
    enterprise_employee.rights << messages_create
    enterprise_employee.rights << messages_read
    enterprise_employee.rights << messages_update
    enterprise_employee.rights << messages_delete
    #enterprise_auditor
#    enterprise_auditor.rights << messages_read

# DOCUMENTS
#    documents_create = Right.create!(:resource => 'documents', :operation => 'CREATE')
#    documents_read = Right.create!(:resource => 'documents', :operation => 'READ') 
#    documents_delete = Right.create!(:resource => 'documents', :operation => 'DELETE')
#    documents_update = Right.create!(:resource => 'documents', :operation => 'UPDATE')
     documents_create = Right.find_by_resource_and_operation('documents','CREATE')  
     documents_read = Right.find_by_resource_and_operation('documents','READ')  
     documents_delete = Right.find_by_resource_and_operation('documents','DELETE')  
     documents_update = Right.find_by_resource_and_operation('documents','UPDATE')  
    
#free_owner	(not has the access for documents)
    #free_owner.rights << documents_create
    #free_owner.rights << documents_read
    #free_owner.rights << documents_update
    #free_owner.rights << documents_delete
    
 #essential_owner	
#     essential_owner.rights << documents_create
#     essential_owner.rights << documents_read
#     essential_owner.rights << documents_update
#     essential_owner.rights << documents_delete
    #essential_accountant
#     essential_accountant.rights << documents_create
#     essential_accountant.rights << documents_read
#     essential_accountant.rights << documents_update
#     essential_accountant.rights << documents_delete
     #essential_staff
#     essential_staff.rights << documents_create
#     essential_staff.rights << documents_read
#     essential_staff.rights << documents_update
#     essential_staff.rights << documents_delete
    #essential_auditor
#     essential_auditor.rights << documents_read
  
#basic_owner	
#    basic_owner.rights << documents_create
#    basic_owner.rights << documents_read
#    basic_owner.rights << documents_update
#    basic_owner.rights << documents_delete
    #basic_accountant#
#    basic_accountant.rights << documents_create
#    basic_accountant.rights << documents_read
#    basic_accountant.rights << documents_update
#    basic_accountant.rights << documents_delete
#    #basic_staff
#    basic_staff.rights << documents_create
#    basic_staff.rights << documents_read
#    basic_staff.rights << documents_update
#    basic_staff.rights << documents_delete
#    #basic_auditor
#    basic_auditor.rights << documents_read

    #premium_owner	
#     premium_owner.rights << documents_create
#     premium_owner.rights << documents_read
#     premium_owner.rights << documents_update
#     premium_owner.rights << documents_delete
    #premium_accountant
#     premium_accountant.rights << documents_create
#     premium_accountant.rights << documents_read
#     premium_accountant.rights << documents_update
#     premium_accountant.rights << documents_delete
    #premium_staff#
#     premium_staff.rights << documents_create
#     premium_staff.rights << documents_read
#     premium_staff.rights << documents_update
#     premium_staff.rights << documents_delete
    #premium_auditor
#     premium_auditor.rights << documents_read
    #premium_employee
     premium_employee.rights << documents_create
     premium_employee.rights << documents_read
     premium_employee.rights << documents_update
     premium_employee.rights << documents_delete
    
    #enterprise_owner	
#    enterprise_owner.rights << documents_create
#    enterprise_owner.rights << documents_read
#    enterprise_owner.rights << documents_update
#    enterprise_owner.rights << documents_delete
    #enterprise_accountant
#    enterprise_accountant.rights << documents_create
#    enterprise_accountant.rights << documents_read
#    enterprise_accountant.rights << documents_update
#    enterprise_accountant.rights << documents_delete
    #enterprise_staff
#    enterprise_staff.rights << documents_create
#    enterprise_staff.rights << documents_read
#    enterprise_staff.rights << documents_update
#    enterprise_staff.rights << documents_delete
    #enterprise_auditor
#    enterprise_auditor.rights << documents_read
    #enterprise_employee
    enterprise_employee.rights << documents_create
    enterprise_employee.rights << documents_read
    enterprise_employee.rights << documents_update
    enterprise_employee.rights << documents_delete

# NOTES
#    notes_create = Right.create!(:resource => 'notes', :operation => 'CREATE')
#    notes_read = Right.create!(:resource => 'notes', :operation => 'READ') 
#    notes_delete = Right.create!(:resource => 'notes', :operation => 'DELETE')
#    notes_update = Right.create!(:resource => 'notes', :operation => 'UPDATE')
     notes_create = Right.find_by_resource_and_operation('notes','CREATE')  
     notes_read = Right.find_by_resource_and_operation('notes','READ')  
     notes_delete = Right.find_by_resource_and_operation('notes','DELETE')  
     notes_update = Right.find_by_resource_and_operation('notes','UPDATE')  

    #free_owner	
#    free_owner.rights << notes_create
#    free_owner.rights << notes_read
#    free_owner.rights << notes_update
#    free_owner.rights << notes_delete

    #essential_owner	
#     essential_owner.rights << notes_create
#     essential_owner.rights << notes_read
#     essential_owner.rights << notes_update
#     essential_owner.rights << notes_delete
    #essential_accountant
#     essential_accountant.rights << notes_create
#     essential_accountant.rights << notes_read
#     essential_accountant.rights << notes_update
#     essential_accountant.rights << notes_delete
    #essential_staff
#     essential_staff.rights << notes_create
#     essential_staff.rights << notes_read
#     essential_staff.rights << notes_update
#     essential_staff.rights << notes_delete
    #essential_auditor
#     essential_auditor.rights << notes_read


    #basic_owner	
#    basic_owner.rights << notes_create
#    basic_owner.rights << notes_read
#   basic_owner.rights << notes_update
#   basic_owner.rights << notes_delete
    #basic_accountant
#    basic_accountant.rights << notes_create
#    basic_accountant.rights << notes_read
#    basic_accountant.rights << notes_update
#    basic_accountant.rights << notes_delete
#    #basic_staff
#    basic_staff.rights << notes_create
#    basic_staff.rights << notes_read
#    basic_staff.rights << notes_update
#    basic_staff.rights << notes_delete
    #basic_auditor
#    basic_auditor.rights << notes_read

    #premium_owner	
#    premium_owner.rights << notes_create
#    premium_owner.rights << notes_read
#    premium_owner.rights << notes_update
#    premium_owner.rights << notes_delete
#    #premium_accountant
#    premium_accountant.rights << notes_create
#    premium_accountant.rights << notes_read
#    premium_accountant.rights << notes_update
#    premium_accountant.rights << notes_delete
    #premium_staff
#    premium_staff.rights << notes_create
#    premium_staff.rights << notes_read
#    premium_staff.rights << notes_update
#    premium_staff.rights << notes_delete
    #premium_employee
    premium_employee.rights << notes_create
    premium_employee.rights << notes_read
    premium_employee.rights << notes_update
    premium_employee.rights << notes_delete
    #premium_auditor
#    premium_auditor.rights << notes_read

    #enterprise_owner	
#    enterprise_owner.rights << notes_create
#    enterprise_owner.rights << notes_read
#    enterprise_owner.rights << notes_update
#    enterprise_owner.rights << notes_delete
    #enterprise_accountant
#    enterprise_accountant.rights << notes_create
#    enterprise_accountant.rights << notes_read
#    enterprise_accountant.rights << notes_update
#    enterprise_accountant.rights << notes_delete
    #enterprise_staff
#    enterprise_staff.rights << notes_create
#    enterprise_staff.rights << notes_read
#    enterprise_staff.rights << notes_update
#    enterprise_staff.rights << notes_delete
    #enterprise_employee
    enterprise_employee.rights << notes_create
    enterprise_employee.rights << notes_read
    enterprise_employee.rights << notes_update
    enterprise_employee.rights << notes_delete
    #enterprise_auditor
#    enterprise_auditor.rights << notes_read



#INCOME MENU
#1)INVOICE
#    invoices_create = Right.create!(:resource => 'invoices', :operation => 'CREATE')
#    invoices_read = Right.create!(:resource => 'invoices', :operation => 'READ') 
#    invoices_delete = Right.create!(:resource => 'invoices', :operation => 'DELETE')
#    invoices_update = Right.create!(:resource => 'invoices', :operation => 'UPDATE')
    #free_owner	
#    free_owner.rights << invoices_create
#    free_owner.rights << invoices_read
#    free_owner.rights << invoices_update
#    free_owner.rights << invoices_delete
 
   #essential_owner	
#     essential_owner.rights << invoices_create
#     essential_owner.rights << invoices_read
#     essential_owner.rights << invoices_update
#     essential_owner.rights << invoices_delete
    #essential_accountant
#     essential_accountant.rights << invoices_create
#     essential_accountant.rights << invoices_read
#     essential_accountant.rights << invoices_update
#     essential_accountant.rights << invoices_delete
    #essential_staff
#     essential_staff.rights << invoices_create
#     essential_staff.rights << invoices_read
#     essential_staff.rights << invoices_update
#     essential_staff.rights << invoices_delete
    #essential_auditor
#     essential_auditor.rights << invoices_read


   #basic_owner	
#    basic_owner.rights << invoices_create
#    basic_owner.rights << invoices_read
#    basic_owner.rights << invoices_update
#    basic_owner.rights << invoices_delete
    #basic_accountant
#    basic_accountant.rights << invoices_create
#    basic_accountant.rights << invoices_read
#    basic_accountant.rights << invoices_update
#    basic_accountant.rights << invoices_delete
    #basic_staff
#    basic_staff.rights << invoices_create
#    basic_staff.rights << invoices_read
#    basic_staff.rights << invoices_update
#    basic_staff.rights << invoices_delete
    #basic_auditor
#    basic_auditor.rights << invoices_read

    #premium_owner	
#    premium_owner.rights << invoices_create
#    premium_owner.rights << invoices_read
#    premium_owner.rights << invoices_update
#    premium_owner.rights << invoices_delete
    #premium_accountant
#    premium_accountant.rights << invoices_create
#    premium_accountant.rights << invoices_read
#    premium_accountant.rights << invoices_update
#    premium_accountant.rights << invoices_delete
    #premium_staff
#    premium_staff.rights << invoices_create
#    premium_staff.rights << invoices_read
#    premium_staff.rights << invoices_update
#    premium_staff.rights << invoices_delete
    #premium_auditor
#    premium_auditor.rights << invoices_read

    #enterprise_owner	
#    enterprise_owner.rights << invoices_create
#    enterprise_owner.rights << invoices_read
#    enterprise_owner.rights << invoices_update
#    enterprise_owner.rights << invoices_delete
    #enterprise_accountant
#    enterprise_accountant.rights << invoices_create
#    enterprise_accountant.rights << invoices_read
#    enterprise_accountant.rights << invoices_update
#    enterprise_accountant.rights << invoices_delete
    #enterprise_staff
#    enterprise_staff.rights << invoices_create
#    enterprise_staff.rights << invoices_read
#    enterprise_staff.rights << invoices_update
#    enterprise_staff.rights << invoices_delete
    #enterprise_auditor
#    enterprise_auditor.rights << invoices_read


#2)RECEIPT VOUCHER
#    receipt_vouchers_create = Right.create!(:resource => 'receipt_vouchers', :operation => 'CREATE')
#    receipt_vouchers_read = Right.create!(:resource => 'receipt_vouchers', :operation => 'READ') 
#    receipt_vouchers_delete = Right.create!(:resource => 'receipt_vouchers', :operation => 'DELETE')
#    receipt_vouchers_update = Right.create!(:resource => 'receipt_vouchers', :operation => 'UPDATE')
    #free_owner	
#    free_owner.rights << receipt_vouchers_create
#    free_owner.rights << receipt_vouchers_read
#    free_owner.rights << receipt_vouchers_update
#    free_owner.rights << receipt_vouchers_delete
   
   #essential_owner	
#     essential_owner.rights << receipt_vouchers_create
#     essential_owner.rights << receipt_vouchers_read
#     essential_owner.rights << receipt_vouchers_update
#     essential_owner.rights << receipt_vouchers_delete
    #essential_accountant
#     essential_accountant.rights << receipt_vouchers_create
#     essential_accountant.rights << receipt_vouchers_read
#     essential_accountant.rights << receipt_vouchers_update
#     essential_accountant.rights << receipt_vouchers_delete
    #essential_staff
#     essential_staff.rights << receipt_vouchers_create
#     essential_staff.rights << receipt_vouchers_read
#     essential_staff.rights << receipt_vouchers_update
 #    essential_staff.rights << receipt_vouchers_delete
    #essential_auditor
#     essential_auditor.rights << receipt_vouchers_read


 #basic_owner	
#    basic_owner.rights << receipt_vouchers_create
#    basic_owner.rights << receipt_vouchers_read
#    basic_owner.rights << receipt_vouchers_update
#    basic_owner.rights << receipt_vouchers_delete
    #basic_accountant
#    basic_accountant.rights << receipt_vouchers_create
#    basic_accountant.rights << receipt_vouchers_read
#    basic_accountant.rights << receipt_vouchers_update
#    basic_accountant.rights << receipt_vouchers_delete
    #basic_staff
#    basic_staff.rights << receipt_vouchers_create
#    basic_staff.rights << receipt_vouchers_read
#    basic_staff.rights << receipt_vouchers_update
#    basic_staff.rights << receipt_vouchers_delete
   #basic_auditor
#    basic_auditor.rights << receipt_vouchers_read

    #premium_owner	
#    premium_owner.rights << receipt_vouchers_create
#    premium_owner.rights << receipt_vouchers_read
#    premium_owner.rights << receipt_vouchers_update
#    premium_owner.rights << receipt_vouchers_delete
    #premium_accountant
#    premium_accountant.rights << receipt_vouchers_create
#    premium_accountant.rights << receipt_vouchers_read
#    premium_accountant.rights << receipt_vouchers_update
#    premium_accountant.rights << receipt_vouchers_delete
    #premium_staff
#    premium_staff.rights << receipt_vouchers_create
#    premium_staff.rights << receipt_vouchers_read
#    premium_staff.rights << receipt_vouchers_update
#    premium_staff.rights << receipt_vouchers_delete
    #premium_auditor
#    premium_auditor.rights << receipt_vouchers_read

    #enterprise_owner	
#    enterprise_owner.rights << receipt_vouchers_create
#    enterprise_owner.rights << receipt_vouchers_read
#    enterprise_owner.rights << receipt_vouchers_update#
#    enterprise_owner.rights << receipt_vouchers_delete
    #enterprise_accountant
#    enterprise_accountant.rights << receipt_vouchers_create
#    enterprise_accountant.rights << receipt_vouchers_read
#    enterprise_accountant.rights << receipt_vouchers_update
#    enterprise_accountant.rights << receipt_vouchers_delete
    #enterprise_staff
#    enterprise_staff.rights << receipt_vouchers_create
#    enterprise_staff.rights << receipt_vouchers_read
#    enterprise_staff.rights << receipt_vouchers_update#
#   enterprise_staff.rights << receipt_vouchers_delete
    #enterprise_auditor
#    enterprise_auditor.rights << receipt_vouchers_read

#3)ESTIMATE
#    estimates_create = Right.create!(:resource => 'estimates', :operation => 'CREATE')
#    estimates_read = Right.create!(:resource => 'estimates', :operation => 'READ') 
#    estimates_delete = Right.create!(:resource => 'estimates', :operation => 'DELETE')
#    estimates_update = Right.create!(:resource => 'estimates', :operation => 'UPDATE')
    #free_owner	
#    free_owner.rights << estimates_create
#    free_owner.rights << estimates_read
#    free_owner.rights << estimates_update
#    free_owner.rights << estimates_delete
    
 #essential_owner	
#     essential_owner.rights << estimates_create
#     essential_owner.rights << estimates_read
#     essential_owner.rights << estimates_update
#     essential_owner.rights << estimates_delete
    #essential_accountant
#     essential_accountant.rights << estimates_create
#     essential_accountant.rights << estimates_read
#     essential_accountant.rights << estimates_update
#     essential_accountant.rights << estimates_delete
    #essential_staff
#     essential_staff.rights << estimates_create
#     essential_staff.rights << estimates_read
#     essential_staff.rights << estimates_update
#     essential_staff.rights << estimates_delete
    #essential_auditor
#     essential_auditor.rights << estimates_read




#basic_owner	
#    basic_owner.rights << estimates_create
#    basic_owner.rights << estimates_read
#    basic_owner.rights << estimates_update
#    basic_owner.rights << estimates_delete
    #basic_accountant
#    basic_accountant.rights << estimates_create
#    basic_accountant.rights << estimates_read
#    basic_accountant.rights << estimates_update
#    basic_accountant.rights << estimates_delete
    #basic_staff
#    basic_staff.rights << estimates_create
#    basic_staff.rights << estimates_read
#    basic_staff.rights << estimates_update
#    basic_staff.rights << estimates_delete
    #basic_auditor
#    basic_auditor.rights << estimates_read

    #premium_owner	
#    premium_owner.rights << estimates_create
#    premium_owner.rights << estimates_read
#    premium_owner.rights << estimates_update
#    premium_owner.rights << estimates_delete
    #premium_accountant
#    premium_accountant.rights << estimates_create
#    premium_accountant.rights << estimates_read
#    premium_accountant.rights << estimates_update
#    premium_accountant.rights << estimates_delete
    #premium_staff
#    premium_staff.rights << estimates_create
#    premium_staff.rights << estimates_read
#    premium_staff.rights << estimates_update
#    premium_staff.rights << estimates_delete
    #premium_auditor
#    premium_auditor.rights << estimates_read

    #enterprise_owner	
#    enterprise_owner.rights << estimates_create
#    enterprise_owner.rights << estimates_read
#    enterprise_owner.rights << estimates_update
#    enterprise_owner.rights << estimates_delete
    #enterprise_accountant
#    enterprise_accountant.rights << estimates_create
#    enterprise_accountant.rights << estimates_read
#    enterprise_accountant.rights << estimates_update
#    enterprise_accountant.rights << estimates_delete
    #enterprise_staff
#    enterprise_staff.rights << estimates_create
#    enterprise_staff.rights << estimates_read
#    enterprise_staff.rights << estimates_update
#    enterprise_staff.rights << estimates_delete
    #enterprise_auditor
#    enterprise_auditor.rights << estimates_read


#4)OTHER INCOME
#    income_vouchers_create = Right.create!(:resource => 'income_vouchers', :operation => 'CREATE')
#    income_vouchers_read = Right.create!(:resource => 'income_vouchers', :operation => 'READ') 
#    income_vouchers_delete = Right.create!(:resource => 'income_vouchers', :operation => 'DELETE')
#    income_vouchers_update = Right.create!(:resource => 'income_vouchers', :operation => 'UPDATE')
    #free_owner	
#    free_owner.rights << income_vouchers_create
#    free_owner.rights << income_vouchers_read
#    free_owner.rights << income_vouchers_update
#    free_owner.rights << income_vouchers_delete
  
  #essential_owner	
#     essential_owner.rights << income_vouchers_create
#     essential_owner.rights << income_vouchers_read
#     essential_owner.rights << income_vouchers_update
#     essential_owner.rights << income_vouchers_delete
    #essential_accountant
#     essential_accountant.rights << income_vouchers_create
#     essential_accountant.rights << income_vouchers_read
#     essential_accountant.rights << income_vouchers_update
#     essential_accountant.rights << income_vouchers_delete
    #essential_staff
#     essential_staff.rights << income_vouchers_create
#     essential_staff.rights << income_vouchers_read
#     essential_staff.rights << income_vouchers_update
#     essential_staff.rights << income_vouchers_delete
    #essential_auditor
#     essential_auditor.rights << income_vouchers_read

  #basic_owner	
#    basic_owner.rights << income_vouchers_create
#    basic_owner.rights << income_vouchers_read
#    basic_owner.rights << income_vouchers_update
#    basic_owner.rights << income_vouchers_delete
    #basic_accountant
#    basic_accountant.rights << income_vouchers_create
#    basic_accountant.rights << income_vouchers_read
#    basic_accountant.rights << income_vouchers_update
#    basic_accountant.rights << income_vouchers_delete
    #basic_staff
#    basic_staff.rights << income_vouchers_create
#    basic_staff.rights << income_vouchers_read
#    basic_staff.rights << income_vouchers_update
#    basic_staff.rights << income_vouchers_delete
    #basic_auditor
#    basic_auditor.rights << income_vouchers_read

    #premium_owner	

#    premium_owner.rights << income_vouchers_create
#    premium_owner.rights << income_vouchers_read
#    premium_owner.rights << income_vouchers_update
#    premium_owner.rights << income_vouchers_delete
    #premium_accountant
#    premium_accountant.rights << income_vouchers_create
#    premium_accountant.rights << income_vouchers_read
#    premium_accountant.rights << income_vouchers_update
#    premium_accountant.rights << income_vouchers_delete
    #premium_staff
#    premium_staff.rights << income_vouchers_create
#    premium_staff.rights << income_vouchers_read
#    premium_staff.rights << income_vouchers_update
#    premium_staff.rights << income_vouchers_delete
    #premium_auditor
#    premium_auditor.rights << income_vouchers_read

    #enterprise_owner	
#    enterprise_owner.rights << income_vouchers_create
#    enterprise_owner.rights << income_vouchers_read
#    enterprise_owner.rights << income_vouchers_update
#    enterprise_owner.rights << income_vouchers_delete
    #enterprise_accountant
#    enterprise_accountant.rights << income_vouchers_create
#    enterprise_accountant.rights << income_vouchers_read
#    enterprise_accountant.rights << income_vouchers_update
#    enterprise_accountant.rights << income_vouchers_delete
    #enterprise_staff
#    enterprise_staff.rights << income_vouchers_create
#    enterprise_staff.rights << income_vouchers_read
#    enterprise_staff.rights << income_vouchers_update
#    enterprise_staff.rights << income_vouchers_delete
    #enterprise_auditor
#    enterprise_auditor.rights << income_vouchers_read


#EXPENSE MENU

#1)EXPENSE
#    expenses_create = Right.create!(:resource => 'expenses', :operation => 'CREATE')
#    expenses_read = Right.create!(:resource => 'expenses', :operation => 'READ') 
#    expenses_delete = Right.create!(:resource => 'expenses', :operation => 'DELETE')
#    expenses_update = Right.create!(:resource => 'expenses', :operation => 'UPDATE')
    #free_owner	
 #   free_owner.rights << expenses_create
 #   free_owner.rights << expenses_read
 #   free_owner.rights << expenses_update
 #   free_owner.rights << expenses_delete

   #essential_owner	
#     essential_owner.rights << expenses_create
#     essential_owner.rights << expenses_read
#     essential_owner.rights << expenses_update
#     essential_owner.rights << expenses_delete
   #essential_accountant
#     essential_accountant.rights << expenses_create
#     essential_accountant.rights << expenses_read
#     essential_accountant.rights << expenses_update
#     essential_accountant.rights << expenses_delete
   #essential_staff
#     essential_staff.rights << expenses_create
#     essential_staff.rights << expenses_read
#     essential_staff.rights << expenses_update
#     essential_staff.rights << expenses_delete
   #essential_auditor
#     essential_auditor.rights << expenses_read#

    #basic_owner	
#    basic_owner.rights << expenses_create
#    basic_owner.rights << expenses_read
#    basic_owner.rights << expenses_update
#    basic_owner.rights << expenses_delete
 #   #basic_accountant
#    basic_accountant.rights << expenses_create
#    basic_accountant.rights << expenses_read
#    basic_accountant.rights << expenses_update
#    basic_accountant.rights << expenses_delete
 #   #basic_staff
#    basic_staff.rights << expenses_create
#    basic_staff.rights << expenses_read
#    basic_staff.rights << expenses_update
#    basic_staff.rights << expenses_delete
 #   #basic_auditor
#    basic_auditor.rights << expenses_read#

    #premium_owner	
#    premium_owner.rights << expenses_create
#    premium_owner.rights << expenses_read
#    premium_owner.rights << expenses_update
#    premium_owner.rights << expenses_delete
    #premium_accountant
#    premium_accountant.rights << expenses_create
 #   premium_accountant.rights << expenses_read
 #   premium_accountant.rights << expenses_update
 #   premium_accountant.rights << expenses_delete
 #   #premium_staff
#    premium_staff.rights << expenses_create
#    premium_staff.rights << expenses_read
#    premium_staff.rights << expenses_update
#    premium_staff.rights << expenses_delete
 #   #premium_auditor
#    premium_auditor.rights << expenses_read#

    #enterprise_owner	
#    enterprise_owner.rights << expenses_create
#    enterprise_owner.rights << expenses_read
#    enterprise_owner.rights << expenses_update
#    enterprise_owner.rights << expenses_delete
    #enterprise_accountant
#    enterprise_accountant.rights << expenses_create
#    enterprise_accountant.rights << expenses_read
#    enterprise_accountant.rights << expenses_update
#    enterprise_accountant.rights << expenses_delete
    #enterprise_staff
#    enterprise_staff.rights << expenses_create
#    enterprise_staff.rights << expenses_read
#    enterprise_staff.rights << expenses_update
#    enterprise_staff.rights << expenses_delete
    #enterprise_auditor
#    enterprise_auditor.rights << expenses_read


#2)PURCHASE
#    purchases_create = Right.create!(:resource => 'purchases', :operation => 'CREATE')
#    purchases_read = Right.create!(:resource => 'purchases', :operation => 'READ') 
#    purchases_delete = Right.create!(:resource => 'purchases', :operation => 'DELETE')
#    purchases_update = Right.create!(:resource => 'purchases', :operation => 'UPDATE')
    #free_owner	
#    free_owner.rights << purchases_create
#    free_owner.rights << purchases_read
#    free_owner.rights << purchases_update
#    free_owner.rights << purchases_delete
  
    #essential_owner	
#     essential_owner.rights << purchases_create
#    essential_owner.rights << purchases_read
#     essential_owner.rights << purchases_update
#     essential_owner.rights << purchases_delete
    #essential_accountant
#     essential_accountant.rights << purchases_create
#     essential_accountant.rights << purchases_read
#     essential_accountant.rights << purchases_update
#     essential_accountant.rights << purchases_delete
    #essential_staff
#     essential_staff.rights << purchases_create
#     essential_staff.rights << purchases_read
#     essential_staff.rights << purchases_update
#     essential_staff.rights << purchases_delete
    #essential_auditor
#    essential_auditor.rights << purchases_read



  #basic_owner	
#    basic_owner.rights << purchases_create
#    basic_owner.rights << purchases_read
#    basic_owner.rights << purchases_update
#    basic_owner.rights << purchases_delete
    #basic_accountant
#    basic_accountant.rights << purchases_create
#    basic_accountant.rights << purchases_read
#    basic_accountant.rights << purchases_update
#    basic_accountant.rights << purchases_delete
    #basic_staff
#    basic_staff.rights << purchases_create
#    basic_staff.rights << purchases_read
#    basic_staff.rights << purchases_update
#    basic_staff.rights << purchases_delete
    #basic_auditor
#    basic_auditor.rights << purchases_read

    #premium_owner	
#    premium_owner.rights << purchases_create
#    premium_owner.rights << purchases_read
#    premium_owner.rights << purchases_update
#    premium_owner.rights << purchases_delete
    #premium_accountant
#    premium_accountant.rights << purchases_create
#    premium_accountant.rights << purchases_read
#    premium_accountant.rights << purchases_update
#    premium_accountant.rights << purchases_delete
    #premium_staff
#    premium_staff.rights << purchases_create
#    premium_staff.rights << purchases_read
#    premium_staff.rights << purchases_update
#    premium_staff.rights << purchases_delete
    #premium_auditor
#    premium_auditor.rights << purchases_read

    #enterprise_owner	
#    enterprise_owner.rights << purchases_create
#    enterprise_owner.rights << purchases_read
#    enterprise_owner.rights << purchases_update
#    enterprise_owner.rights << purchases_delete
    #enterprise_accountant
#    enterprise_accountant.rights << purchases_create
#    enterprise_accountant.rights << purchases_read
#    enterprise_accountant.rights << purchases_update
#    enterprise_accountant.rights << purchases_delete
    #enterprise_staff
#    enterprise_staff.rights << purchases_create
#    enterprise_staff.rights << purchases_read
#    enterprise_staff.rights << purchases_update
#    enterprise_staff.rights << purchases_delete
   #enterprise_auditor
#    enterprise_auditor.rights << purchases_read


#3)PURCHASE ORDER
#    purchase_orders_create = Right.create!(:resource => 'purchase_orders', :operation => 'CREATE')
#    purchase_orders_read = Right.create!(:resource => 'purchase_orders', :operation => 'READ') 
#    purchase_orders_delete = Right.create!(:resource => 'purchase_orders', :operation => 'DELETE')
#    purchase_orders_update = Right.create!(:resource => 'purchase_orders', :operation => 'UPDATE')
    #free_owner	
 #   free_owner.rights << purchase_orders_create
 #   free_owner.rights << purchase_orders_read
 #   free_owner.rights << purchase_orders_update
 #   free_owner.rights << purchase_orders_delete
   
  #essential_owner	
#     essential_owner.rights << purchase_orders_create
#     essential_owner.rights << purchase_orders_read
#     essential_owner.rights << purchase_orders_update
#    essential_owner.rights << purchase_orders_delete
    #essential_accountant
#     essential_accountant.rights << purchase_orders_create
#     essential_accountant.rights << purchase_orders_read
#     essential_accountant.rights << purchase_orders_update
#     essential_accountant.rights << purchase_orders_delete
    #essential_staff
#     essential_staff.rights << purchase_orders_create
#     essential_staff.rights << purchase_orders_read
#     essential_staff.rights << purchase_orders_update
#     essential_staff.rights << purchase_orders_delete
    #essential_auditor
#    essential_auditor.rights << purchase_orders_read



 #basic_owner	
#    basic_owner.rights << purchase_orders_create
#    basic_owner.rights << purchase_orders_read
#    basic_owner.rights << purchase_orders_update
#    basic_owner.rights << purchase_orders_delete
   #basic_accountant
#    basic_accountant.rights << purchase_orders_create
#    basic_accountant.rights << purchase_orders_read
#    basic_accountant.rights << purchase_orders_update
#    basic_accountant.rights << purchase_orders_delete
   #basic_staff
#    basic_staff.rights << purchase_orders_create
#    basic_staff.rights << purchase_orders_read
#    basic_staff.rights << purchase_orders_update
#    basic_staff.rights << purchase_orders_delete
   #basic_auditor
#    basic_auditor.rights << purchase_orders_read

    #premium_owner	
#    premium_owner.rights << purchase_orders_create
#    premium_owner.rights << purchase_orders_read
#    premium_owner.rights << purchase_orders_update
#    premium_owner.rights << purchase_orders_delete
    #premium_accountant
#    premium_accountant.rights << purchase_orders_create
#    premium_accountant.rights << purchase_orders_read
#    premium_accountant.rights << purchase_orders_update
#    premium_accountant.rights << purchase_orders_delete
    #premium_staff
#    premium_staff.rights << purchase_orders_create
#    premium_staff.rights << purchase_orders_read
#    premium_staff.rights << purchase_orders_update
#    premium_staff.rights << purchase_orders_delete
    #premium_auditor
#    premium_auditor.rights << purchase_orders_read

    #enterprise_owner	
#    enterprise_owner.rights << purchase_orders_create
#    enterprise_owner.rights << purchase_orders_read
#    enterprise_owner.rights << purchase_orders_update
#    enterprise_owner.rights << purchase_orders_delete
    #enterprise_accountant
#    enterprise_accountant.rights << purchase_orders_create
#    enterprise_accountant.rights << purchase_orders_read
#    enterprise_accountant.rights << purchase_orders_update
#    enterprise_accountant.rights << purchase_orders_delete
    #enterprise_staff
#    enterprise_staff.rights << purchase_orders_create
#    enterprise_staff.rights << purchase_orders_read
#    enterprise_staff.rights << purchase_orders_update
#    enterprise_staff.rights << purchase_orders_delete
   #enterprise_auditor
#    enterprise_auditor.rights << purchase_orders_read


#4)PAYMENT VOUCHER
#    payment_vouchers_create = Right.create!(:resource => 'payment_vouchers', :operation => 'CREATE')
#    payment_vouchers_read = Right.create!(:resource => 'payment_vouchers', :operation => 'READ') 
#    payment_vouchers_delete = Right.create!(:resource => 'payment_vouchers', :operation => 'DELETE')
#    payment_vouchers_update = Right.create!(:resource => 'payment_vouchers', :operation => 'UPDATE')
    #free_owner	
#    free_owner.rights << payment_vouchers_read
##    free_owner.rights << payment_vouchers_update
 #   free_owner.rights << payment_vouchers_delete
   

 #essential_owner	
#     essential_owner.rights << payment_vouchers_create
#     essential_owner.rights << payment_vouchers_read
#     essential_owner.rights << payment_vouchers_update
#     essential_owner.rights << payment_vouchers_delete
    #essential_accountant
#    essential_accountant.rights << payment_vouchers_create
#    essential_accountant.rights << payment_vouchers_read
#    essential_accountant.rights << payment_vouchers_update
#    essential_accountant.rights << payment_vouchers_delete
    #essential_staff
#    essential_staff.rights << payment_vouchers_create
#    essential_staff.rights << payment_vouchers_read
#    essential_staff.rights << payment_vouchers_update
#    essential_staff.rights << payment_vouchers_delete
    # essential_auditor
#    essential_auditor.rights << payment_vouchers_read


 #basic_owner	
#    basic_owner.rights << payment_vouchers_create
#    basic_owner.rights << payment_vouchers_read
#    basic_owner.rights << payment_vouchers_update
#    basic_owner.rights << payment_vouchers_delete
    #basic_accountant
#    basic_accountant.rights << payment_vouchers_create
#    basic_accountant.rights << payment_vouchers_read
#    basic_accountant.rights << payment_vouchers_update
#    basic_accountant.rights << payment_vouchers_delete
    #basic_staff
#    basic_staff.rights << payment_vouchers_create
#    basic_staff.rights << payment_vouchers_read
#    basic_staff.rights << payment_vouchers_update
#    basic_staff.rights << payment_vouchers_delete
    #basic_auditor
#    basic_auditor.rights << payment_vouchers_read

    #premium_owner	
#    premium_owner.rights << payment_vouchers_create
#    premium_owner.rights << payment_vouchers_read
#    premium_owner.rights << payment_vouchers_update
#    premium_owner.rights << payment_vouchers_delete
    #premium_accountant
#    premium_accountant.rights << payment_vouchers_create
#    premium_accountant.rights << payment_vouchers_read
#    premium_accountant.rights << payment_vouchers_update
#    premium_accountant.rights << payment_vouchers_delete
    #premium_staff
#    premium_staff.rights << payment_vouchers_create
#    premium_staff.rights << payment_vouchers_read
#    premium_staff.rights << payment_vouchers_update
#    premium_staff.rights << payment_vouchers_delete
    #premium_auditor
#    premium_auditor.rights << payment_vouchers_read

    #enterprise_owner	
#    enterprise_owner.rights << payment_vouchers_create
#    enterprise_owner.rights << payment_vouchers_read
#    enterprise_owner.rights << payment_vouchers_update
#    enterprise_owner.rights << payment_vouchers_delete
#    #enterprise_accountant
#    enterprise_accountant.rights << payment_vouchers_create
#    enterprise_accountant.rights << payment_vouchers_read
#    enterprise_accountant.rights << payment_vouchers_update
#    enterprise_accountant.rights << payment_vouchers_delete
#    #enterprise_staff
#    enterprise_staff.rights << payment_vouchers_create
#    enterprise_staff.rights << payment_vouchers_read
#    enterprise_staff.rights << payment_vouchers_update
#    enterprise_staff.rights << payment_vouchers_delete
    #enterprise_auditor
#    enterprise_auditor.rights << payment_vouchers_read

#BANKING MENU

#1)WITHDRAWAL
#    withdrawals_create = Right.create!(:resource => 'withdrawals', :operation => 'CREATE')
#    withdrawals_read = Right.create!(:resource => 'withdrawals', :operation => 'READ') 
#    withdrawals_delete = Right.create!(:resource => 'withdrawals', :operation => 'DELETE')
#    withdrawals_update = Right.create!(:resource => 'withdrawals', :operation => 'UPDATE')
    #free_owner	
#    free_owner.rights << withdrawals_create
#    free_owner.rights << withdrawals_read
##    free_owner.rights << withdrawals_update
 #   free_owner.rights << withdrawals_delete
   
 #essential_owner	
#   essential_owner.rights << withdrawals_create
#   essential_owner.rights << withdrawals_read
#   essential_owner.rights << withdrawals_update
#   essential_owner.rights << withdrawals_delete
    #essential_accountant
#   essential_accountant.rights << withdrawals_create
#   essential_accountant.rights << withdrawals_read
#   essential_accountant.rights << withdrawals_update
 #  essential_accountant.rights << withdrawals_delete
    #essential_staff
#   essential_staff.rights << withdrawals_create
#   essential_staff.rights << withdrawals_read
#   essential_staff.rights << withdrawals_update
#   essential_staff.rights << withdrawals_delete
    #essential_auditor
#   essential_auditor.rights << withdrawals_read


 #basic_owner	
#    basic_owner.rights << withdrawals_create
#    basic_owner.rights << withdrawals_read
#    basic_owner.rights << withdrawals_update
#    basic_owner.rights << withdrawals_delete
   #basic_accountant
#    basic_accountant.rights << withdrawals_create
#    basic_accountant.rights << withdrawals_read
#    basic_accountant.rights << withdrawals_update
#    basic_accountant.rights << withdrawals_delete
    #basic_staff
#    basic_staff.rights << withdrawals_create
#    basic_staff.rights << withdrawals_read
#    basic_staff.rights << withdrawals_update
#    basic_staff.rights << withdrawals_delete
    #basic_auditor
#    basic_auditor.rights << withdrawals_read

    #premium_owner	
#    premium_owner.rights << withdrawals_create
#    premium_owner.rights << withdrawals_read
#    premium_owner.rights << withdrawals_update
#    premium_owner.rights << withdrawals_delete
    #premium_accountant
#    premium_accountant.rights << withdrawals_create
#    premium_accountant.rights << withdrawals_read
#    premium_accountant.rights << withdrawals_update
#    premium_accountant.rights << withdrawals_delete
    #premium_staff
#    premium_staff.rights << withdrawals_create
#    premium_staff.rights << withdrawals_read
#    premium_staff.rights << withdrawals_update
#    premium_staff.rights << withdrawals_delete
    #premium_auditor
#    premium_auditor.rights << withdrawals_read

    #enterprise_owner	
#    enterprise_owner.rights << withdrawals_create
#    enterprise_owner.rights << withdrawals_read
#    enterprise_owner.rights << withdrawals_update
#    enterprise_owner.rights << withdrawals_delete
    #enterprise_accountant
#    enterprise_accountant.rights << withdrawals_create
#    enterprise_accountant.rights << withdrawals_read
#    enterprise_accountant.rights << withdrawals_update
#    enterprise_accountant.rights << withdrawals_delete
    #enterprise_staff
#    enterprise_staff.rights << withdrawals_create
#    enterprise_staff.rights << withdrawals_read
#    enterprise_staff.rights << withdrawals_update
#    enterprise_staff.rights << withdrawals_delete
    #enterprise_auditor
#    enterprise_auditor.rights << withdrawals_read


#2)DEPOSIT
#    deposits_create = Right.create!(:resource => 'deposits', :operation => 'CREATE')
#    deposits_read = Right.create!(:resource => 'deposits', :operation => 'READ') 
#    deposits_delete = Right.create!(:resource => 'deposits', :operation => 'DELETE')
#    deposits_update = Right.create!(:resource => 'deposits', :operation => 'UPDATE')
    #free_owner	
 #   free_owner.rights << deposits_create
 #   free_owner.rights << deposits_read
 #   free_owner.rights << deposits_update
 #   free_owner.rights << deposits_delete
  
  #essential_owner	
#   essential_owner.rights << deposits_create
#   essential_owner.rights << deposits_read
#   essential_owner.rights << deposits_update
#   essential_owner.rights << deposits_delete
    #essential_accountant
#   essential_accountant.rights << deposits_create
#   essential_accountant.rights << deposits_read
#   essential_accountant.rights << deposits_update
#   essential_accountant.rights << deposits_delete
    #essential_staff
#   essential_staff.rights << deposits_create
#   essential_staff.rights << deposits_read
#   essential_staff.rights << deposits_update
#   essential_staff.rights << deposits_delete
    #essential_auditor
#   essential_auditor.rights << deposits_read


  #basic_owner	
#    basic_owner.rights << deposits_create
#    basic_owner.rights << deposits_read
#    basic_owner.rights << deposits_update
#    basic_owner.rights << deposits_delete
#    #basic_accountant
#    basic_accountant.rights << deposits_create
#    basic_accountant.rights << deposits_read
#    basic_accountant.rights << deposits_update
#    basic_accountant.rights << deposits_delete
    #basic_staff
#    basic_staff.rights << deposits_create
#    basic_staff.rights << deposits_read
#    basic_staff.rights << deposits_update
#    basic_staff.rights << deposits_delete
    #basic_auditor
#    basic_auditor.rights << deposits_read

    #premium_owner	
#    premium_owner.rights << deposits_create
#    premium_owner.rights << deposits_read
#    premium_owner.rights << deposits_update
#    premium_owner.rights << deposits_delete
    #premium_accountant
#    premium_accountant.rights << deposits_create
#    premium_accountant.rights << deposits_read
#    premium_accountant.rights << deposits_update
#    premium_accountant.rights << deposits_delete
    #premium_staff
#    premium_staff.rights << deposits_create
#    premium_staff.rights << deposits_read
#    premium_staff.rights << deposits_update
#    premium_staff.rights << deposits_delete
    #premium_auditor
#    premium_auditor.rights << deposits_read

    #enterprise_owner	
#    enterprise_owner.rights << deposits_create
#    enterprise_owner.rights << deposits_read
#    enterprise_owner.rights << deposits_update
#    enterprise_owner.rights << deposits_delete
    #enterprise_accountant
#    enterprise_accountant.rights << deposits_create
#    enterprise_accountant.rights << deposits_read
#    enterprise_accountant.rights << deposits_update
#    enterprise_accountant.rights << deposits_delete
    #enterprise_staff
#    enterprise_staff.rights << deposits_create
#    enterprise_staff.rights << deposits_read
#    enterprise_staff.rights << deposits_update
#    enterprise_staff.rights << deposits_delete
    #enterprise_auditor
#    enterprise_auditor.rights << deposits_read


#3)TRANSFER CASHES
#    transfer_cashes_create = Right.create!(:resource => 'transfer_cashes', :operation => 'CREATE')
#    transfer_cashes_read = Right.create!(:resource => 'transfer_cashes', :operation => 'READ') 
#    transfer_cashes_delete = Right.create!(:resource => 'transfer_cashes', :operation => 'DELETE')
#    transfer_cashes_update = Right.create!(:resource => 'transfer_cashes', :operation => 'UPDATE')
    #free_owner	
 #   free_owner.rights << transfer_cashes_create
 #   free_owner.rights << transfer_cashes_read
 #   free_owner.rights << transfer_cashes_update
 #   free_owner.rights << transfer_cashes_delete
   
  #essential_owner	
#    essential_owner.rights << transfer_cashes_create
#    essential_owner.rights << transfer_cashes_read
#    essential_owner.rights << transfer_cashes_update
#    essential_owner.rights << transfer_cashes_delete
    #essential_accountant
#    essential_accountant.rights << transfer_cashes_create
#    essential_accountant.rights << transfer_cashes_read
#    essential_accountant.rights << transfer_cashes_update
#    essential_accountant.rights << transfer_cashes_delete
    #essential_staff
#    essential_staff.rights << transfer_cashes_create
#    essential_staff.rights << transfer_cashes_read
#    essential_staff.rights << transfer_cashes_update
#    essential_staff.rights << transfer_cashes_delete
    #essential_auditor
#    essential_auditor.rights << transfer_cashes_read



 #basic_owner	
#    basic_owner.rights << transfer_cashes_create
#    basic_owner.rights << transfer_cashes_read
#    basic_owner.rights << transfer_cashes_update
#    basic_owner.rights << transfer_cashes_delete
    #basic_accountant
#    basic_accountant.rights << transfer_cashes_create
#    basic_accountant.rights << transfer_cashes_read
#    basic_accountant.rights << transfer_cashes_update
#    basic_accountant.rights << transfer_cashes_delete
    #basic_staff
#    basic_staff.rights << transfer_cashes_create
#    basic_staff.rights << transfer_cashes_read
#    basic_staff.rights << transfer_cashes_update
#    basic_staff.rights << transfer_cashes_delete
    #basic_auditor
#    basic_auditor.rights << transfer_cashes_read

    #premium_owner	
#    premium_owner.rights << transfer_cashes_create
#    premium_owner.rights << transfer_cashes_read
#    premium_owner.rights << transfer_cashes_update
#    premium_owner.rights << transfer_cashes_delete
    #premium_accountant
#    premium_accountant.rights << transfer_cashes_create
#    premium_accountant.rights << transfer_cashes_read
#    premium_accountant.rights << transfer_cashes_update
#    premium_accountant.rights << transfer_cashes_delete
    #premium_staff
#    premium_staff.rights << transfer_cashes_create
#    premium_staff.rights << transfer_cashes_read
#    premium_staff.rights << transfer_cashes_update
#    premium_staff.rights << transfer_cashes_delete
    #premium_auditor
#    premium_auditor.rights << transfer_cashes_read

    #enterprise_owner	
#    enterprise_owner.rights << transfer_cashes_create
#    enterprise_owner.rights << transfer_cashes_read
#    enterprise_owner.rights << transfer_cashes_update
#    enterprise_owner.rights << transfer_cashes_delete
    #enterprise_accountant
#    enterprise_accountant.rights << transfer_cashes_create
#    enterprise_accountant.rights << transfer_cashes_read
#    enterprise_accountant.rights << transfer_cashes_update
#    enterprise_accountant.rights << transfer_cashes_delete
    #enterprise_staff
#    enterprise_staff.rights << transfer_cashes_create
#    enterprise_staff.rights << transfer_cashes_read
#    enterprise_staff.rights << transfer_cashes_update
#    enterprise_staff.rights << transfer_cashes_delete
    #enterprise_auditor
#    enterprise_auditor.rights << transfer_cashes_read


#JOURNAL MENU

#1)JOURNAL ENTRY
#    journals_create = Right.create!(:resource => 'journals', :operation => 'CREATE')
#    journals_read = Right.create!(:resource => 'journals', :operation => 'READ') 
#    journals_delete = Right.create!(:resource => 'journals', :operation => 'DELETE')
#    journals_update = Right.create!(:resource => 'journals', :operation => 'UPDATE')
    #free_owner	
#    free_owner.rights << journals_create
#    free_owner.rights << journals_read
#    free_owner.rights << journals_update
#    free_owner.rights << journals_delete
  
 #essential_owner	
#   essential_owner.rights << journals_create
#   essential_owner.rights << journals_read
#   essential_owner.rights << journals_update
#   essential_owner.rights << journals_delete
    #essential_accountant
#   essential_accountant.rights << journals_create
#   essential_accountant.rights << journals_read
#   essential_accountant.rights << journals_update
#   essential_accountant.rights << journals_delete
    #essential_staff
#   essential_staff.rights << journals_create
#   essential_staff.rights << journals_read
#   essential_staff.rights << journals_update
#   essential_staff.rights << journals_delete
    #essential_auditor
#    essential_auditor.rights << journals_read


  #basic_owner	
#    basic_owner.rights << journals_create
#    basic_owner.rights << journals_read
#    basic_owner.rights << journals_update
#    basic_owner.rights << journals_delete
#    #basic_accountant
#    basic_accountant.rights << journals_create
#    basic_accountant.rights << journals_read
#    basic_accountant.rights << journals_update
#    basic_accountant.rights << journals_delete
    #basic_staff
#    basic_staff.rights << journals_create
#    basic_staff.rights << journals_read
#    basic_staff.rights << journals_update
#    basic_staff.rights << journals_delete
    #basic_auditor
#    basic_auditor.rights << journals_read#

    #premium_owner	
#    premium_owner.rights << journals_create
#    premium_owner.rights << journals_read
#    premium_owner.rights << journals_update
#    premium_owner.rights << journals_delete
    #premium_accountant
#    premium_accountant.rights << journals_create
#    premium_accountant.rights << journals_read
#    premium_accountant.rights << journals_update
#    premium_accountant.rights << journals_delete
    #premium_staff
#    premium_staff.rights << journals_create
#    premium_staff.rights << journals_read
#    premium_staff.rights << journals_update
#    premium_staff.rights << journals_delete
    #premium_auditor
#    premium_auditor.rights << journals_read

    #enterprise_owner	
#    enterprise_owner.rights << journals_create
#    enterprise_owner.rights << journals_read
#    enterprise_owner.rights << journals_update
#    enterprise_owner.rights << journals_delete
    #enterprise_accountant
#    enterprise_accountant.rights << journals_create
#    enterprise_accountant.rights << journals_read
#    enterprise_accountant.rights << journals_update
#    enterprise_accountant.rights << journals_delete
    #enterprise_staff
#    enterprise_staff.rights << journals_create
#    enterprise_staff.rights << journals_read
#    enterprise_staff.rights << journals_update
#    enterprise_staff.rights << journals_delete
    #enterprise_auditor
#    enterprise_auditor.rights << journals_read

#2)DEBIT NOTE
#    debit_notes_create = Right.create!(:resource => 'debit_notes', :operation => 'CREATE')
#    debit_notes_read = Right.create!(:resource => 'debit_notes', :operation => 'READ') 
#    debit_notes_delete = Right.create!(:resource => 'debit_notes', :operation => 'DELETE')
#    debit_notes_update = Right.create!(:resource => 'debit_notes', :operation => 'UPDATE')
    #free_owner	
#    free_owner.rights << debit_notes_create
#    free_owner.rights << debit_notes_read
#    free_owner.rights << debit_notes_update
#    free_owner.rights << debit_notes_delete
  
 #essential_owner	
#    essential_owner.rights << debit_notes_create
#    essential_owner.rights << debit_notes_read
#    essential_owner.rights << debit_notes_update
#    essential_owner.rights << debit_notes_delete
    #essential_accountant
#    essential_accountant.rights << debit_notes_create
#    essential_accountant.rights << debit_notes_read
#    essential_accountant.rights << debit_notes_update
#    essential_accountant.rights << debit_notes_delete
    #essential_staff
#    essential_staff.rights << debit_notes_create
#    essential_staff.rights << debit_notes_read
#    essential_staff.rights << debit_notes_update
#    essential_staff.rights << debit_notes_delete
    #essential_auditor
#    essential_auditor.rights << debit_notes_read


  #basic_owner	
#    basic_owner.rights << debit_notes_create
#    basic_owner.rights << debit_notes_read
#    basic_owner.rights << debit_notes_update
#    basic_owner.rights << debit_notes_delete
    #basic_accountant
#    basic_accountant.rights << debit_notes_create
#    basic_accountant.rights << debit_notes_read
#    basic_accountant.rights << debit_notes_update
#    basic_accountant.rights << debit_notes_delete
    #basic_staff
#    basic_staff.rights << debit_notes_create
#    basic_staff.rights << debit_notes_read
#    basic_staff.rights << debit_notes_update
#    basic_staff.rights << debit_notes_delete
    #basic_auditor
#    basic_auditor.rights << debit_notes_read

    #premium_owner	
#    premium_owner.rights << debit_notes_create
#    premium_owner.rights << debit_notes_read
#    premium_owner.rights << debit_notes_update
#    premium_owner.rights << debit_notes_delete
    #premium_accountant
#    premium_accountant.rights << debit_notes_create
#    premium_accountant.rights << debit_notes_read
#    premium_accountant.rights << debit_notes_update
#    premium_accountant.rights << debit_notes_delete
    #premium_staff
#    premium_staff.rights << debit_notes_create
#    premium_staff.rights << debit_notes_read
#    premium_staff.rights << debit_notes_update
#    premium_staff.rights << debit_notes_delete
    #premium_auditor
#    premium_auditor.rights << debit_notes_read

    #enterprise_owner	
#    enterprise_owner.rights << debit_notes_create
#    enterprise_owner.rights << debit_notes_read
#    enterprise_owner.rights << debit_notes_update
#    enterprise_owner.rights << debit_notes_delete
    #enterprise_accountant
#    enterprise_accountant.rights << debit_notes_create
#    enterprise_accountant.rights << debit_notes_read
#    enterprise_accountant.rights << debit_notes_update
#    enterprise_accountant.rights << debit_notes_delete
    #enterprise_staff
#    enterprise_staff.rights << debit_notes_create
#    enterprise_staff.rights << debit_notes_read
#    enterprise_staff.rights << debit_notes_update
#    enterprise_staff.rights << debit_notes_delete
    #enterprise_auditor
#    enterprise_auditor.rights << debit_notes_read


#3)CREDIT NOTE
#    credit_notes_create = Right.create!(:resource => 'credit_notes', :operation => 'CREATE')
#    credit_notes_read = Right.create!(:resource => 'credit_notes', :operation => 'READ') 
#    credit_notes_delete = Right.create!(:resource => 'credit_notes', :operation => 'DELETE')
#    credit_notes_update = Right.create!(:resource => 'credit_notes', :operation => 'UPDATE')
    #free_owner	
#    free_owner.rights << credit_notes_create
#    free_owner.rights << credit_notes_read
#    free_owner.rights << credit_notes_update
#    free_owner.rights << credit_notes_delete
   
 #essential_owner	
#    essential_owner.rights << credit_notes_create
#    essential_owner.rights << credit_notes_read
#    essential_owner.rights << credit_notes_update
#    essential_owner.rights << credit_notes_delete
    #essential_accountant
#    essential_accountant.rights << credit_notes_create
#    essential_accountant.rights << credit_notes_read
#    essential_accountant.rights << credit_notes_update
#    essential_accountant.rights << credit_notes_delete
    #essential_staff
#    essential_staff.rights << credit_notes_create
#    essential_staff.rights << credit_notes_read
#    essential_staff.rights << credit_notes_update
#    essential_staff.rights << credit_notes_delete
    #essential_auditor
#     essential_auditor.rights << credit_notes_read


 #basic_owner	
#    basic_owner.rights << credit_notes_create
#    basic_owner.rights << credit_notes_read
#    basic_owner.rights << credit_notes_update
#    basic_owner.rights << credit_notes_delete
    #basic_accountant
#    basic_accountant.rights << credit_notes_create
#    basic_accountant.rights << credit_notes_read
#    basic_accountant.rights << credit_notes_update
#    basic_accountant.rights << credit_notes_delete
    #basic_staff
#    basic_staff.rights << credit_notes_create
#    basic_staff.rights << credit_notes_read
#    basic_staff.rights << credit_notes_update
#    basic_staff.rights << credit_notes_delete
    #basic_auditor#
#    basic_auditor.rights << credit_notes_read

    #premium_owner	
#    premium_owner.rights << credit_notes_create
#    premium_owner.rights << credit_notes_read
#    premium_owner.rights << credit_notes_update
#    premium_owner.rights << credit_notes_delete
    #premium_accountant
#    premium_accountant.rights << credit_notes_create
#    premium_accountant.rights << credit_notes_read
#    premium_accountant.rights << credit_notes_update
#    premium_accountant.rights << credit_notes_delete
#    #premium_staff
#    premium_staff.rights << credit_notes_create
#    premium_staff.rights << credit_notes_read
#    premium_staff.rights << credit_notes_update
#    premium_staff.rights << credit_notes_delete
#    #premium_auditor
#    premium_auditor.rights << credit_notes_read

    #enterprise_owner	
#    enterprise_owner.rights << credit_notes_create
#    enterprise_owner.rights << credit_notes_read
#    enterprise_owner.rights << credit_notes_update
#    enterprise_owner.rights << credit_notes_delete
   #enterprise_accountant
#    enterprise_accountant.rights << credit_notes_create
#    enterprise_accountant.rights << credit_notes_read
#    enterprise_accountant.rights << credit_notes_update
#    enterprise_accountant.rights << credit_notes_delete
    #enterprise_staff
#    enterprise_staff.rights << credit_notes_create
#    enterprise_staff.rights << credit_notes_read
#    enterprise_staff.rights << credit_notes_update
#    enterprise_staff.rights << credit_notes_delete
    #enterprise_auditor
#    enterprise_auditor.rights << credit_notes_read


#4)SIMPLE ACCOUNTING ENTRY
#    saccountings_create = Right.create!(:resource => 'saccountings', :operation => 'CREATE')
#    saccountings_read = Right.create!(:resource => 'saccountings', :operation => 'READ') 
#    saccountings_delete = Right.create!(:resource => 'saccountings', :operation => 'DELETE')
#    saccountings_update = Right.create!(:resource => 'saccountings', :operation => 'UPDATE')
#    #free_owner	
##    free_owner.rights << saccountings_create
##   free_owner.rights << saccountings_read
#    free_owner.rights << saccountings_update
#    free_owner.rights << saccountings_delete
  
 #essential_owner	
#    essential_owner.rights << saccountings_create
#    essential_owner.rights << saccountings_read
#    essential_owner.rights << saccountings_update
#    essential_owner.rights << saccountings_delete
    #essential_accountant
#    essential_accountant.rights << saccountings_create
#    essential_accountant.rights << saccountings_read
#    essential_accountant.rights << saccountings_update
#    essential_accountant.rights << saccountings_delete
    #essential_staff
#    essential_staff.rights << saccountings_create
#    essential_staff.rights << saccountings_read
#    essential_staff.rights << saccountings_update
#    essential_staff.rights << saccountings_delete
    #essential_auditor
#    essential_auditor.rights << saccountings_read

  #basic_owner	
#    basic_owner.rights << saccountings_create
#    basic_owner.rights << saccountings_read
#    basic_owner.rights << saccountings_update
#    basic_owner.rights << saccountings_delete
    #basic_accountant
#    basic_accountant.rights << saccountings_create
#    basic_accountant.rights << saccountings_read
#    basic_accountant.rights << saccountings_update
#    basic_accountant.rights << saccountings_delete
    #basic_staff
#    basic_staff.rights << saccountings_create
#    basic_staff.rights << saccountings_read
#    basic_staff.rights << saccountings_update
#    basic_staff.rights << saccountings_delete
    #basic_auditor
#    basic_auditor.rights << saccountings_read

    #premium_owner	
#    premium_owner.rights << saccountings_create
#    premium_owner.rights << saccountings_read
#    premium_owner.rights << saccountings_update
#    premium_owner.rights << saccountings_delete
    #premium_accountant
#    premium_accountant.rights << saccountings_create
#    premium_accountant.rights << saccountings_read
#    premium_accountant.rights << saccountings_update
#    premium_accountant.rights << saccountings_delete
   #premium_staff
#    premium_staff.rights << saccountings_create
#    premium_staff.rights << saccountings_read
#    premium_staff.rights << saccountings_update
#    premium_staff.rights << saccountings_delete
    #premium_auditor
#    premium_auditor.rights << saccountings_read

    #enterprise_owner	
#    enterprise_owner.rights << saccountings_create
#    enterprise_owner.rights << saccountings_read
#    enterprise_owner.rights << saccountings_update
#    enterprise_owner.rights << saccountings_delete
    #enterprise_accountant
#    enterprise_accountant.rights << saccountings_create
#    enterprise_accountant.rights << saccountings_read
#    enterprise_accountant.rights << saccountings_update
#    enterprise_accountant.rights << saccountings_delete
   #enterprise_staff
#    enterprise_staff.rights << saccountings_create
#    enterprise_staff.rights << saccountings_read
#    enterprise_staff.rights << saccountings_update
#    enterprise_staff.rights << saccountings_delete
    #enterprise_auditor
#    enterprise_auditor.rights << saccountings_read

#INVENTORY MENU
#1) PRODUCTS
#    products_create = Right.create!(:resource => 'products', :operation => 'CREATE')
#    products_read = Right.create!(:resource => 'products', :operation => 'READ') 
#    products_delete = Right.create!(:resource => 'products', :operation => 'DELETE')
#    products_update = Right.create!(:resource => 'products', :operation => 'UPDATE')
   

 #essential_owner	
#    essential_owner.rights << products_create
#    essential_owner.rights << products_read
#    essential_owner.rights << products_update
#    essential_owner.rights << products_delete
#    #essential_accountant
#    essential_accountant.rights << products_create
#    essential_accountant.rights << products_read
#    essential_accountant.rights << products_update
#    essential_accountant.rights << products_delete
    #essential_staff
#    essential_staff.rights << products_create
#    essential_staff.rights << products_read
#    essential_staff.rights << products_update
#    essential_staff.rights << products_delete
    #essential_auditor
#    essential_auditor.rights << products_read


 #basic_owner	
#    basic_owner.rights << products_create
#    basic_owner.rights << products_read
#    basic_owner.rights << products_update
#    basic_owner.rights << products_delete
    #basic_accountant
#    basic_accountant.rights << products_create
#    basic_accountant.rights << products_read
#    basic_accountant.rights << products_update
#    basic_accountant.rights << products_delete
    #basic_staff
#    basic_staff.rights << products_create
#    basic_staff.rights << products_read
#    basic_staff.rights << products_update
#    basic_staff.rights << products_delete
    #basic_auditor
#    basic_auditor.rights << products_read
#    #premium_owner	
#    premium_owner.rights << products_create
#    premium_owner.rights << products_read
#    premium_owner.rights << products_update
#    premium_owner.rights << products_delete
    #premium_accountant
#    premium_accountant.rights << products_create
#    premium_accountant.rights << products_read
#    premium_accountant.rights << products_update
#    premium_accountant.rights << products_delete
    #premium_staff
#    premium_staff.rights << products_create
#    premium_staff.rights << products_read
#    premium_staff.rights << products_update
#    premium_staff.rights << products_delete
    #premium_auditor
#    premium_auditor.rights << products_read

    #enterprise_owner	
#    enterprise_owner.rights << products_create
#    enterprise_owner.rights << products_read
#    enterprise_owner.rights << products_update
#    enterprise_owner.rights << products_delete
    #enterprise_accountant
#    enterprise_accountant.rights << products_create
#    enterprise_accountant.rights << products_read
#    enterprise_accountant.rights << products_update
#    enterprise_accountant.rights << products_delete
   #enterprise_staff
#    enterprise_staff.rights << products_create
#    enterprise_staff.rights << products_read
#    enterprise_staff.rights << products_update
#    enterprise_staff.rights << products_delete
    #enterprise_auditor
#    enterprise_auditor.rights << products_read

#2) WAREHOUSES
#    warehouses_create = Right.create!(:resource => 'warehouses', :operation => 'CREATE')
#    warehouses_read = Right.create!(:resource => 'warehouses', :operation => 'READ') 
#    warehouses_delete = Right.create!(:resource => 'warehouses', :operation => 'DELETE')
#    warehouses_update = Right.create!(:resource => 'warehouses', :operation => 'UPDATE')

  #essential_owner	
#    essential_owner.rights << warehouses_create
#    essential_owner.rights << warehouses_read
#    essential_owner.rights << warehouses_update
#    essential_owner.rights << warehouses_delete
    #essential_accountant
#    essential_accountant.rights << warehouses_create
#    essential_accountant.rights << warehouses_read
#    essential_accountant.rights << warehouses_update
#    essential_accountant.rights << warehouses_delete
    #essential_staff
#    essential_staff.rights << warehouses_create
#    essential_staff.rights << warehouses_read
#    essential_staff.rights << warehouses_update
#    essential_staff.rights << warehouses_delete
    #essential_auditor
#    essential_auditor.rights << warehouses_read

    #basic_owner	
#    basic_owner.rights << warehouses_create
#    basic_owner.rights << warehouses_read
#    basic_owner.rights << warehouses_update
#    basic_owner.rights << warehouses_delete
    #basic_accountant
#    basic_accountant.rights << warehouses_create
#    basic_accountant.rights << warehouses_read
#    basic_accountant.rights << warehouses_update
#    basic_accountant.rights << warehouses_delete
    #basic_staff
#    basic_staff.rights << warehouses_create
#    basic_staff.rights << warehouses_read
#    basic_staff.rights << warehouses_update
#    basic_staff.rights << warehouses_delete
    #basic_auditor
#    basic_auditor.rights << warehouses_read
    #premium_owner	
#    premium_owner.rights << warehouses_create
#    premium_owner.rights << warehouses_read
#    premium_owner.rights << warehouses_update
#    premium_owner.rights << warehouses_delete
   #premium_accountant
#    premium_accountant.rights << warehouses_create
#    premium_accountant.rights << warehouses_read
#    premium_accountant.rights << warehouses_update
#    premium_accountant.rights << warehouses_delete
    #premium_staff
#    premium_staff.rights << warehouses_create
#    premium_staff.rights << warehouses_read
#    premium_staff.rights << warehouses_update
#    premium_staff.rights << warehouses_delete
    #premium_auditor
#    premium_auditor.rights << warehouses_read

    #enterprise_owner	
 #   enterprise_owner.rights << warehouses_create
 #   enterprise_owner.rights << warehouses_read
 #   enterprise_owner.rights << warehouses_update
 #   enterprise_owner.rights << warehouses_delete
 #   #enterprise_accountant
 #   enterprise_accountant.rights << warehouses_create
 #   enterprise_accountant.rights << warehouses_read
 #   enterprise_accountant.rights << warehouses_update
 #   enterprise_accountant.rights << warehouses_delete
    #enterprise_staff
 #   enterprise_staff.rights << warehouses_create
 #   enterprise_staff.rights << warehouses_read
 #   enterprise_staff.rights << warehouses_update
 #   enterprise_staff.rights << warehouses_delete
    #enterprise_auditor
 #   enterprise_auditor.rights << warehouses_read

#3) STOCK ISSUE VOUCHERS
#    stock_issue_vouchers_create = Right.create!(:resource => 'stock_issue_vouchers', :operation => 'CREATE')
#    stock_issue_vouchers_read = Right.create!(:resource => 'stock_issue_vouchers', :operation => 'READ') 
#    stock_issue_vouchers_delete = Right.create!(:resource => 'stock_issue_vouchers', :operation => 'DELETE')
#    stock_issue_vouchers_update = Right.create!(:resource => 'stock_issue_vouchers', :operation => 'UPDATE')
  
 #essential_owner	
#    essential_owner.rights << stock_issue_vouchers_create
#    essential_owner.rights << stock_issue_vouchers_read
#    essential_owner.rights << stock_issue_vouchers_update
#    essential_owner.rights << stock_issue_vouchers_delete
    #essential_accountant
#    essential_accountant.rights << stock_issue_vouchers_create
#    essential_accountant.rights << stock_issue_vouchers_read
#    essential_accountant.rights << stock_issue_vouchers_delete
    #essential_staff
#    essential_staff.rights << stock_issue_vouchers_create
#    essential_staff.rights << stock_issue_vouchers_read
#    essential_staff.rights << stock_issue_vouchers_update
#    essential_staff.rights << stock_issue_vouchers_delete
    #essential_auditor
#    essential_auditor.rights << stock_issue_vouchers_read

  #basic_owner	
#    basic_owner.rights << stock_issue_vouchers_create
#    basic_owner.rights << stock_issue_vouchers_read
#    basic_owner.rights << stock_issue_vouchers_update
#    basic_owner.rights << stock_issue_vouchers_delete
    #basic_accountant
#    basic_accountant.rights << stock_issue_vouchers_create
#    basic_accountant.rights << stock_issue_vouchers_read
#    basic_accountant.rights << stock_issue_vouchers_delete
   #basic_staff
#    basic_staff.rights << stock_issue_vouchers_create
#    basic_staff.rights << stock_issue_vouchers_read
#    basic_staff.rights << stock_issue_vouchers_update
#    basic_staff.rights << stock_issue_vouchers_delete
    #basic_auditor
#    basic_auditor.rights << stock_issue_vouchers_read

    #premium_owner	
#    premium_owner.rights << stock_issue_vouchers_create
#    premium_owner.rights << stock_issue_vouchers_read
#    premium_owner.rights << stock_issue_vouchers_update
#    premium_owner.rights << stock_issue_vouchers_delete
   #premium_accountant
#    premium_accountant.rights << stock_issue_vouchers_create
#    premium_accountant.rights << stock_issue_vouchers_read
#    premium_accountant.rights << stock_issue_vouchers_update
#    premium_accountant.rights << stock_issue_vouchers_delete
    #premium_staff
#    premium_staff.rights << stock_issue_vouchers_create
#    premium_staff.rights << stock_issue_vouchers_read
#    premium_staff.rights << stock_issue_vouchers_update
#    premium_staff.rights << stock_issue_vouchers_delete
    #premium_auditor
#    premium_auditor.rights << stock_issue_vouchers_read

    #enterprise_owner	
#    enterprise_owner.rights << stock_issue_vouchers_create
#    enterprise_owner.rights << stock_issue_vouchers_read
#    enterprise_owner.rights << stock_issue_vouchers_update
 #   enterprise_owner.rights << stock_issue_vouchers_delete
 #   #enterprise_accountant
#    enterprise_accountant.rights << stock_issue_vouchers_create
#    enterprise_accountant.rights << stock_issue_vouchers_read
#    enterprise_accountant.rights << stock_issue_vouchers_update
#    enterprise_accountant.rights << stock_issue_vouchers_delete
    #enterprise_staff
#    enterprise_staff.rights << stock_issue_vouchers_create
#    enterprise_staff.rights << stock_issue_vouchers_read
#    enterprise_staff.rights << stock_issue_vouchers_update
#    enterprise_staff.rights << stock_issue_vouchers_delete
    #enterprise_auditor
#    enterprise_auditor.rights << stock_issue_vouchers_read

#4) STOCK RECEIPT VOUCHERS
#    stock_receipt_vouchers_create = Right.create!(:resource => 'stock_receipt_vouchers', :operation => 'CREATE')
#    stock_receipt_vouchers_read = Right.create!(:resource => 'stock_receipt_vouchers', :operation => 'READ') 
#    stock_receipt_vouchers_delete = Right.create!(:resource => 'stock_receipt_vouchers', :operation => 'DELETE')
#    stock_receipt_vouchers_update = Right.create!(:resource => 'stock_receipt_vouchers', :operation => 'UPDATE')

 #essential_owner	
#    essential_owner.rights << stock_receipt_vouchers_create
#    essential_owner.rights << stock_receipt_vouchers_read
#    essential_owner.rights << stock_receipt_vouchers_update
#    essential_owner.rights << stock_receipt_vouchers_delete
    #essential_accountant
#    essential_accountant.rights << stock_receipt_vouchers_create
#    essential_accountant.rights << stock_receipt_vouchers_read
#    essential_accountant.rights << stock_receipt_vouchers_update
#    essential_accountant.rights << stock_receipt_vouchers_delete
    #essential_staff
#    essential_staff.rights << stock_receipt_vouchers_create
#    essential_staff.rights << stock_receipt_vouchers_read
#    essential_staff.rights << stock_receipt_vouchers_update
#    essential_staff.rights << stock_receipt_vouchers_delete
    #essential_auditor
#    essential_auditor.rights << stock_receipt_vouchers_read


    #basic_owner	
#    basic_owner.rights << stock_receipt_vouchers_create
#    basic_owner.rights << stock_receipt_vouchers_read
#    basic_owner.rights << stock_receipt_vouchers_update
#    basic_owner.rights << stock_receipt_vouchers_delete
    #basic_accountant
#    basic_accountant.rights << stock_receipt_vouchers_create
#    basic_accountant.rights << stock_receipt_vouchers_read
#    basic_accountant.rights << stock_receipt_vouchers_update
#    basic_accountant.rights << stock_receipt_vouchers_delete
    #basic_staff
#    basic_staff.rights << stock_receipt_vouchers_create
#    basic_staff.rights << stock_receipt_vouchers_read
#    basic_staff.rights << stock_receipt_vouchers_update
#    basic_staff.rights << stock_receipt_vouchers_delete
    #basic_auditor
#    basic_auditor.rights << stock_receipt_vouchers_read

    #premium_owner	
#    premium_owner.rights << stock_receipt_vouchers_create
#    premium_owner.rights << stock_receipt_vouchers_read
#    premium_owner.rights << stock_receipt_vouchers_update
#    premium_owner.rights << stock_receipt_vouchers_delete
    #premium_accountant
#    premium_accountant.rights << stock_receipt_vouchers_create
#    premium_accountant.rights << stock_receipt_vouchers_read
#    premium_accountant.rights << stock_receipt_vouchers_update
#    premium_accountant.rights << stock_receipt_vouchers_delete
    #premium_staff
#    premium_staff.rights << stock_receipt_vouchers_create
#    premium_staff.rights << stock_receipt_vouchers_read
#    premium_staff.rights << stock_receipt_vouchers_update
#    premium_staff.rights << stock_receipt_vouchers_delete
    #premium_auditor
#    premium_auditor.rights << stock_receipt_vouchers_read

    #enterprise_owner	
#    enterprise_owner.rights << stock_receipt_vouchers_create
#    enterprise_owner.rights << stock_receipt_vouchers_read
#    enterprise_owner.rights << stock_receipt_vouchers_update
#    enterprise_owner.rights << stock_receipt_vouchers_delete
   #enterprise_accountant
#    enterprise_accountant.rights << stock_receipt_vouchers_create
#    enterprise_accountant.rights << stock_receipt_vouchers_read
#    enterprise_accountant.rights << stock_receipt_vouchers_update
#    enterprise_accountant.rights << stock_receipt_vouchers_delete
    #enterprise_staff
#    enterprise_staff.rights << stock_receipt_vouchers_create
#    enterprise_staff.rights << stock_receipt_vouchers_read
#    enterprise_staff.rights << stock_receipt_vouchers_update
#    enterprise_staff.rights << stock_receipt_vouchers_delete
    #enterprise_auditor
#    enterprise_auditor.rights << stock_receipt_vouchers_read



#REPORT MENU
#1)FINAL ACCOUNTS
  #1.1)BALANCE SHEET
#    horizontal_balance_sheet_read = Right.create!(:resource => 'horizontal_balance_sheet', :operation => 'READ') 
    #free_owner	
#    free_owner.rights << horizontal_balance_sheet_read

   #essential_owner	
#    essential_owner.rights << horizontal_balance_sheet_read
    #essential_accountant
#    essential_accountant.rights << horizontal_balance_sheet_read
    #essential_auditor
#    essential_auditor.rights << horizontal_balance_sheet_read  

  #basic_owner	
#    basic_owner.rights << horizontal_balance_sheet_read
    #basic_accountant
#    basic_accountant.rights << horizontal_balance_sheet_read
    #basic_auditor
#    basic_auditor.rights << horizontal_balance_sheet_read
    #premium_owner	
#    premium_owner.rights << horizontal_balance_sheet_read
    #premium_accountant
#    premium_accountant.rights << horizontal_balance_sheet_read
    #premium_auditor
#    premium_auditor.rights << horizontal_balance_sheet_read
    #enterprise_owner	
#    enterprise_owner.rights << horizontal_balance_sheet_read
   #enterprise_accountant
#    enterprise_accountant.rights << horizontal_balance_sheet_read
    #enterprise_auditor
#    enterprise_auditor.rights << horizontal_balance_sheet_read


  #1.2)PROFIT AND LOSS
#    horizontal_profit_and_loss_read = Right.create!(:resource => 'horizontal_profit_and_loss', :operation => 'READ') 
    #free_owner	
#    free_owner.rights << horizontal_profit_and_loss_read

  #essential_owner	
#    essential_owner.rights << horizontal_profit_and_loss_read
    #essential_accountant
#    essential_accountant.rights << horizontal_profit_and_loss_read
    #essential_auditor
#    essential_auditor.rights << horizontal_profit_and_loss_read   

 #basic_owner	
#    basic_owner.rights << horizontal_profit_and_loss_read
    #basic_accountant
#    basic_accountant.rights << horizontal_profit_and_loss_read
    #basic_auditor
#    basic_auditor.rights << horizontal_profit_and_loss_read
    #premium_owner	
#    premium_owner.rights << horizontal_profit_and_loss_read
    #premium_accountant
#    premium_accountant.rights << horizontal_profit_and_loss_read
    #premium_auditor
#    premium_auditor.rights << horizontal_profit_and_loss_read
    #enterprise_owner	
#    enterprise_owner.rights << horizontal_profit_and_loss_read
    #enterprise_accountant
#    enterprise_accountant.rights << horizontal_profit_and_loss_read
    #enterprise_auditor
#    enterprise_auditor.rights << horizontal_profit_and_loss_read

  #1.3)TRIAL BALANCE
#    trial_balance_read = Right.create!(:resource => 'trial_balance', :operation => 'READ') 
    #free_owner	
#    free_owner.rights << trial_balance_read
    
  #essential_owner	
#     essential_owner.rights << trial_balance_read
    #essential_accountant
#    essential_accountant.rights << trial_balance_read
    #essential_auditor
#    essential_auditor.rights << trial_balance_read    

#basic_owner	
#    basic_owner.rights << trial_balance_read
    #basic_accountant
#    basic_accountant.rights << trial_balance_read
    #basic_auditor
#    basic_auditor.rights << trial_balance_read
    #premium_owner	
#    premium_owner.rights << trial_balance_read
    #premium_accountant
#    premium_accountant.rights << trial_balance_read
    #premium_auditor
#    premium_auditor.rights << trial_balance_read
    #enterprise_owner	
#    enterprise_owner.rights << trial_balance_read
    #enterprise_accountant
#    enterprise_accountant.rights << trial_balance_read
    #enterprise_auditor
#    enterprise_auditor.rights << trial_balance_read

#2) ACCOUNT BOOKS AND REGISTERS
 #2.1)BANK BOOK
#    bank_book_read = Right.create!(:resource => 'bank_book', :operation => 'READ') 
    #free_owner	
#    free_owner.rights << bank_book_read
    
#essential_owner	#
#    essential_owner.rights << bank_book_read
    #essential_accountant
#    essential_accountant.rights << bank_book_read
    #essential_auditor
#     essential_auditor.rights << bank_book_read
   #basic_owner	#
#    basic_owner.rights << bank_book_read
    #basic_accountant
#    basic_accountant.rights << bank_book_read
    #basic_auditor
#    basic_auditor.rights << bank_book_read
    #premium_owner	
#    premium_owner.rights << bank_book_read
   #premium_accountant
#    premium_accountant.rights << bank_book_read
    #premium_auditor
#    premium_auditor.rights << bank_book_read
    #enterprise_owner	
#    enterprise_owner.rights << bank_book_read
    #enterprise_accountant
#    enterprise_accountant.rights << bank_book_read
    #enterprise_auditor
#    enterprise_auditor.rights << bank_book_read

 #2.2)CASH BOOK
#    cash_book_read = Right.create!(:resource => 'cash_book', :operation => 'READ') 
    #free_owner	
#    free_owner.rights << cash_book_read
   
#essential_owner	
#    essential_owner.rights << cash_book_read
    #essential_accountant
#    essential_accountant.rights << cash_book_read
    #essential_auditor
#    essential_auditor.rights << cash_book_read
  
#basic_owner	
#    basic_owner.rights << cash_book_read
    #basic_accountant
#    basic_accountant.rights << cash_book_read
    #basic_auditor
#    basic_auditor.rights << cash_book_read
    #premium_owner	
#    premium_owner.rights << cash_book_read
    #premium_accountant
#    premium_accountant.rights << cash_book_read
    #premium_auditor
#    premium_auditor.rights << cash_book_read
    #enterprise_owner	
#    enterprise_owner.rights << cash_book_read
    #enterprise_accountant
#    enterprise_accountant.rights << cash_book_read
    #enterprise_auditor
#    enterprise_auditor.rights << cash_book_read

 #2.3)CREDIT NOTE REGISTER
#    credit_note_register_read = Right.create!(:resource => 'credit_note_register', :operation => 'READ') 
    #free_owner	
#    free_owner.rights << credit_note_register_read
 #essential_owner	
#   essential_owner.rights << credit_note_register_read
    #essential_accountant
#   essential_accountant.rights << credit_note_register_read
    #essential_auditor
#   essential_auditor.rights << credit_note_register_read  


  #basic_owner	
#    basic_owner.rights << credit_note_register_read
    #basic_accountant
#    basic_accountant.rights << credit_note_register_read
    #basic_auditor
#    basic_auditor.rights << credit_note_register_read
    #premium_owner	
#    premium_owner.rights << credit_note_register_read
    #premium_accountant
#    premium_accountant.rights << credit_note_register_read
    #premium_auditor
#    premium_auditor.rights << credit_note_register_read
    #enterprise_owner	
#    enterprise_owner.rights << credit_note_register_read
    #enterprise_accountant
#    enterprise_accountant.rights << credit_note_register_read
    #enterprise_auditor
#    enterprise_auditor.rights << credit_note_register_read

 #2.4)DEBIT NOTE REGISTER
#    debit_note_register_read = Right.create!(:resource => 'debit_note_register', :operation => 'READ') 
    #free_owner	
 #   free_owner.rights << debit_note_register_read
 #essential_owner	
#    essential_owner.rights << debit_note_register_read
    #essential_accountant
#    essential_accountant.rights << debit_note_register_read
    #essential_auditor
#    essential_auditor.rights << debit_note_register_read
    #basic_owner	
#    basic_owner.rights << debit_note_register_read
    #basic_accountant
#    basic_accountant.rights << debit_note_register_read
    #basic_auditor
#    basic_auditor.rights << debit_note_register_read
    #premium_owner	
#    premium_owner.rights << debit_note_register_read
    #premium_accountant
#    premium_accountant.rights << debit_note_register_read
    #premium_auditor
#    premium_auditor.rights << debit_note_register_read
    #enterprise_owner	
#    enterprise_owner.rights << debit_note_register_read
    #enterprise_accountant
#    enterprise_accountant.rights << debit_note_register_read
    #enterprise_auditor
#    enterprise_auditor.rights << debit_note_register_read

 #2.5)JOURNAL REGISTER
#    journal_register_read = Right.create!(:resource => 'journal_register', :operation => 'READ') 
    #free_owner	
 #   free_owner.rights << journal_register_read
 #essential_owner	
#     essential_owner.rights << journal_register_read
    #essential_accountant
 #   essential_accountant.rights << journal_register_read
    #essential_auditor
 #   essential_auditor.rights << journal_register_read

   #basic_owner	
#    basic_owner.rights << journal_register_read
    #basic_accountant
#    basic_accountant.rights << journal_register_read
    #basic_auditor
#   basic_auditor.rights << journal_register_read
    #premium_owner	
#     premium_owner.rights << journal_register_read
    #premium_accountant
#    premium_accountant.rights << journal_register_read
    #premium_auditor
#    premium_auditor.rights << journal_register_read
    #enterprise_owner	
#    enterprise_owner.rights << journal_register_read
    #enterprise_accountant
#    enterprise_accountant.rights << journal_register_read
    #enterprise_auditor
#    enterprise_auditor.rights << journal_register_read

 #2.6)OUTSTANDING PAYMENTS
#    bills_payable_read = Right.create!(:resource => 'bills_payable', :operation => 'READ') 
    #free_owner	
   # free_owner.rights << bills_payable_read
  
  #essential_owner	
#    essential_owner.rights << bills_payable_read
    #essential_accountant
#    essential_accountant.rights << bills_payable_read
    #essential_auditor
#    essential_auditor.rights << bills_payable_read 

   #basic_owner	
#    basic_owner.rights << bills_payable_read
    #basic_accountant
#    basic_accountant.rights << bills_payable_read
    #basic_auditor
#    basic_auditor.rights << bills_payable_read
    #premium_owner	
#    premium_owner.rights << bills_payable_read
    #premium_accountant
#    premium_accountant.rights << bills_payable_read
    #premium_auditor
#    premium_auditor.rights << bills_payable_read
    #enterprise_owner	
#    enterprise_owner.rights << bills_payable_read
    #enterprise_accountant
#    enterprise_accountant.rights << bills_payable_read
    #enterprise_auditor
#    enterprise_auditor.rights << bills_payable_read

 #2.7)OUTSTANDING RECEIPTS
#    bills_receivable_read = Right.create!(:resource => 'bills_receivable', :operation => 'READ') 
    #free_owner	
    #free_owner.rights << bills_receivable_read
  #essential_owner	
#    essential_owner.rights << bills_receivable_read
    #essential_accountant
#    essential_accountant.rights << bills_receivable_read
    #essential_auditor
#    essential_auditor.rights << bills_receivable_read 

   #basic_owner	
#    basic_owner.rights << bills_receivable_read
    #basic_accountant
#    basic_accountant.rights << bills_receivable_read
    #basic_auditor
#    basic_auditor.rights << bills_receivable_read
    #premium_owner	
#    premium_owner.rights << bills_receivable_read
    #premium_accountant
#    premium_accountant.rights << bills_receivable_read
    #premium_auditor
#    premium_auditor.rights << bills_receivable_read
    #enterprise_owner	
#    enterprise_owner.rights << bills_receivable_read
    #enterprise_accountant
#    enterprise_accountant.rights << bills_receivable_read
    #enterprise_auditor
#    enterprise_auditor.rights << bills_receivable_read

 #2.8)PURCHASE REGISTERS
#    purchase_register_read = Right.create!(:resource => 'purchase_register', :operation => 'READ') 
    #free_owner	
   #  free_owner.rights << purchase_register_read
    #essential_owner	
#    essential_owner.rights << purchase_register_read
    #essential_accountant
#    essential_accountant.rights << purchase_register_read
    #essential_auditor
#    essential_auditor.rights << purchase_register_read 

  #basic_owner	
#    basic_owner.rights << purchase_register_read
    #basic_accountant
#    basic_accountant.rights << purchase_register_read
    #basic_auditor
#    basic_auditor.rights << purchase_register_read
    #premium_owner	
#    premium_owner.rights << purchase_register_read
    #premium_accountant
#    premium_accountant.rights << purchase_register_read
    #premium_auditor
#    premium_auditor.rights << purchase_register_read
    #enterprise_owner	
#    enterprise_owner.rights << purchase_register_read
    #enterprise_accountant
#    enterprise_accountant.rights << purchase_register_read
    #enterprise_auditor
#    enterprise_auditor.rights << purchase_register_read

 #2.9)SALES REGISTERS
#    sales_register_read = Right.create!(:resource => 'sales_register', :operation => 'READ') 
    #free_owner	
  #  free_owner.rights << sales_register_read
   #essential_owner	
#   essential_owner.rights << sales_register_read
    #essential_accountant
#   essential_accountant.rights << sales_register_read
    #essential_auditor
#   essential_auditor.rights << sales_register_read  

  #basic_owner	
#    basic_owner.rights << sales_register_read
    #basic_accountant
#    basic_accountant.rights << sales_register_read
    #basic_auditor
#    basic_auditor.rights << sales_register_read
    #premium_owner	
#    premium_owner.rights << sales_register_read
    #premium_accountant
#   premium_accountant.rights << sales_register_read
    #premium_auditor
#    premium_auditor.rights << sales_register_read
    #enterprise_owner	
#    enterprise_owner.rights << sales_register_read
    #enterprise_accountant
#    enterprise_accountant.rights << sales_register_read
    #enterprise_auditor
#    enterprise_auditor.rights << sales_register_read

 #2.10)SUNDRY CREDITOR
#    sundry_creditor_read = Right.create!(:resource => 'sundry_creditor', :operation => 'READ') 
    #free_owner	
   # free_owner.rights << sundry_creditor_read
   #essential_owner	
#    essential_owner.rights << sundry_creditor_read
    #essential_accountant
#   essential_accountant.rights << sundry_creditor_read
    #essential_auditor
#    essential_auditor.rights << sundry_creditor_read

   #basic_owner	
#    basic_owner.rights << sundry_creditor_read
    #basic_accountant
#    basic_accountant.rights << sundry_creditor_read
    #basic_auditor
#    basic_auditor.rights << sundry_creditor_read
    #premium_owner	
#    premium_owner.rights << sundry_creditor_read
    #premium_accountant
#    premium_accountant.rights << sundry_creditor_read
    #premium_auditor
#    premium_auditor.rights << sundry_creditor_read
    #enterprise_owner	
#    enterprise_owner.rights << sundry_creditor_read
    #enterprise_accountant
#    enterprise_accountant.rights << sundry_creditor_read
    #enterprise_auditor
#    enterprise_auditor.rights << sundry_creditor_read

#3)LEDGER 
#    account_books_and_registers_read = Right.create!(:resource => 'account_books_and_registers', :operation => 'READ') 
    #free_owner	
#  #  free_owner.rights << account_books_and_registers_read
  #essential_owner	
#  essential_owner.rights << account_books_and_registers_read
    #  essential_accountant
#   essential_accountant.rights << account_books_and_registers_read
    #  essential_auditor
#  essential_auditor.rights << account_books_and_registers_read  

  #basic_owner	
#    basic_owner.rights << account_books_and_registers_read
    #basic_accountant
#    basic_accountant.rights << account_books_and_registers_read
    #basic_auditor
#    basic_auditor.rights << account_books_and_registers_read
    #premium_owner	
#    premium_owner.rights << account_books_and_registers_read
    #premium_accountant
#    premium_accountant.rights << account_books_and_registers_read
    #premium_auditor
#    premium_auditor.rights << account_books_and_registers_read
    #enterprise_owner	
#    enterprise_owner.rights << account_books_and_registers_read
    #enterprise_accountant
#    enterprise_accountant.rights << account_books_and_registers_read
    #enterprise_auditor
#    enterprise_auditor.rights << account_books_and_registers_read

#4)DAY BOOK
#    daybook_read = Right.create!(:resource => 'daybook', :operation => 'READ') 
    #free_owner	
  #  free_owner.rights << daybook_read
  #essential_owner	
#   essential_owner.rights << daybook_read
    #essential_accountant
#   essential_accountant.rights << daybook_read
    #essential_auditor
#   essential_auditor.rights << daybook_read  

  #basic_owner	
#    basic_owner.rights << daybook_read
    #basic_accountant
#    basic_accountant.rights << daybook_read
    #basic_auditor
#    basic_auditor.rights << daybook_read
    #premium_owner	
#    premium_owner.rights << daybook_read
    #premium_accountant
#    premium_accountant.rights << daybook_read
    #premium_auditor
#    premium_auditor.rights << daybook_read
    #enterprise_owner	
#    enterprise_owner.rights << daybook_read
    #enterprise_accountant
#    enterprise_accountant.rights << daybook_read
    #enterprise_auditor
#    enterprise_auditor.rights << daybook_read

#5)WORKSTREAM
#    workstreams_read = Right.create!(:resource => 'workstreams', :operation => 'READ') 
    #free_owner	
   # free_owner.rights << workstreams_read
   #essential_owner	
#   essential_owner.rights << workstreams_read
    #essential_accountant
#   essential_accountant.rights << workstreams_read
    #essential_auditor
#   essential_auditor.rights << workstreams_read  

  #basic_owner	
#    basic_owner.rights << workstreams_read
    #basic_accountant
#    basic_accountant.rights << workstreams_read
    #basic_auditor
#    basic_auditor.rights << workstreams_read
    #premium_owner	
#    premium_owner.rights << workstreams_read
    #premium_accountant
#    premium_accountant.rights << workstreams_read
    #premium_auditor
#    premium_auditor.rights << workstreams_read
    #enterprise_owner	
#    enterprise_owner.rights << workstreams_read
    #enterprise_accountant
#    enterprise_accountant.rights << workstreams_read
   #enterprise_auditor
#   enterprise_auditor.rights << workstreams_read

# SETTINGS MENU

#1.1)ACCOUNTS
#    accounts_create = Right.create!(:resource => 'accounts', :operation => 'CREATE')
#    accounts_read = Right.create!(:resource => 'accounts', :operation => 'READ') 
#    accounts_delete = Right.create!(:resource => 'accounts', :operation => 'DELETE')
#    accounts_update = Right.create!(:resource => 'accounts', :operation => 'UPDATE')

    #free_owner	
  #  free_owner.rights << accounts_create
   # free_owner.rights << accounts_read
   # free_owner.rights << accounts_update
   # free_owner.rights << accounts_delete
    #essential_owner	
#   essential_owner.rights << accounts_create
#   essential_owner.rights << accounts_read
#   essential_owner.rights << accounts_update
#   essential_owner.rights << accounts_delete
    #essential_accountant
#   essential_accountant.rights << accounts_create
#   essential_accountant.rights << accounts_read
#   essential_accountant.rights << accounts_update
#   essential_accountant.rights << accounts_delete
    #essential_staff
    #essential_auditor
#   essential_auditor.rights << accounts_read

#basic_owner	
#    basic_owner.rights << accounts_create
#    basic_owner.rights << accounts_read
#    basic_owner.rights << accounts_update
#    basic_owner.rights << accounts_delete
   #basic_accountant
#    basic_accountant.rights << accounts_create
#    basic_accountant.rights << accounts_read
#    basic_accountant.rights << accounts_update
 #   basic_accountant.rights << accounts_delete
   #basic_staff
    #basic_auditor
#    basic_auditor.rights << accounts_read
#    #premium_owner	
#    premium_owner.rights << accounts_create
#    premium_owner.rights << accounts_read
#    premium_owner.rights << accounts_update
#    premium_owner.rights << accounts_delete
    #premium_accountant
#    premium_accountant.rights << accounts_create
#    premium_accountant.rights << accounts_read
#    premium_accountant.rights << accounts_update
#    premium_accountant.rights << accounts_delete
    #premium_staff
   #premium_auditor
#    premium_auditor.rights << accounts_read

    #enterprise_owner	
#    enterprise_owner.rights << accounts_create
#    enterprise_owner.rights << accounts_read
#    enterprise_owner.rights << accounts_update
#    enterprise_owner.rights << accounts_delete
   #enterprise_accountant
#    enterprise_accountant.rights << accounts_create
#    enterprise_accountant.rights << accounts_read
#    enterprise_accountant.rights << accounts_update
#    enterprise_accountant.rights << accounts_delete
    #enterprise_staff
   #enterprise_auditor
#    enterprise_auditor.rights << accounts_read

#1.2) ACCOUNT HEADS
#    account_heads_create = Right.create!(:resource => 'account_heads', :operation => 'CREATE')
#    account_heads_read = Right.create!(:resource => 'account_heads', :operation => 'READ') 
#    account_heads_delete = Right.create!(:resource => 'account_heads', :operation => 'DELETE')
#    account_heads_update = Right.create!(:resource => 'account_heads', :operation => 'UPDATE')
    #free_owner	
  #  free_owner.rights << account_heads_create
  #  free_owner.rights << account_heads_read
  #  free_owner.rights << account_heads_update
  #  free_owner.rights << account_heads_delete
    #essential_owner	
#     essential_owner.rights << account_heads_create
#     essential_owner.rights << account_heads_read
#     essential_owner.rights << account_heads_update
#     essential_owner.rights << account_heads_delete
    #essential_accountant
#     essential_accountant.rights << account_heads_create
#     essential_accountant.rights << account_heads_read
#     essential_accountant.rights << account_heads_update
#     essential_accountant.rights << account_heads_delete
    #essential_staff
#     essential_staff.rights << account_heads_create
#     essential_staff.rights << account_heads_read
#     essential_staff.rights << account_heads_update
#     essential_staff.rights << account_heads_delete
    #essential_auditor
#     essential_auditor.rights << account_heads_read   

 #basic_owner	
#    basic_owner.rights << account_heads_create
#    basic_owner.rights << account_heads_read
#    basic_owner.rights << account_heads_update
#    basic_owner.rights << account_heads_delete
    #basic_accountant
#    basic_accountant.rights << account_heads_create
#    basic_accountant.rights << account_heads_read
#    basic_accountant.rights << account_heads_update
#    basic_accountant.rights << account_heads_delete
    #basic_staff
#    basic_staff.rights << account_heads_create
#    basic_staff.rights << account_heads_read
#    basic_staff.rights << account_heads_update
#    basic_staff.rights << account_heads_delete
    #basic_auditor
#    basic_auditor.rights << account_heads_read

    #premium_owner	
#    premium_owner.rights << account_heads_create
#    premium_owner.rights << account_heads_read
#    premium_owner.rights << account_heads_update
#    premium_owner.rights << account_heads_delete
    #premium_accountant
#    premium_accountant.rights << account_heads_create
#    premium_accountant.rights << account_heads_read
#    premium_accountant.rights << account_heads_update
#    premium_accountant.rights << account_heads_delete
    #premium_staff
#    premium_staff.rights << account_heads_create
#    premium_staff.rights << account_heads_read
#    premium_staff.rights << account_heads_update
#    premium_staff.rights << account_heads_delete
    #premium_auditor
#    premium_auditor.rights << account_heads_read

    #enterprise_owner	
#    enterprise_owner.rights << account_heads_create
#    enterprise_owner.rights << account_heads_read
#    enterprise_owner.rights << account_heads_update
#    enterprise_owner.rights << account_heads_delete
    #enterprise_accountant
#    enterprise_accountant.rights << account_heads_create
#    enterprise_accountant.rights << account_heads_read
#    enterprise_accountant.rights << account_heads_update
#    enterprise_accountant.rights << account_heads_delete
    #enterprise_staff
#    enterprise_staff.rights << account_heads_create
#    enterprise_staff.rights << account_heads_read
#    enterprise_staff.rights << account_heads_update
#    enterprise_staff.rights << account_heads_delete
    #enterprise_auditor
#    enterprise_auditor.rights << account_heads_read


#2)MY SETTING
#    users_create = Right.create!(:resource => 'users', :operation => 'CREATE')
#    users_read = Right.create!(:resource => 'users', :operation => 'READ') 
#    users_delete = Right.create!(:resource => 'users', :operation => 'DELETE')
#    users_update = Right.create!(:resource => 'users', :operation => 'UPDATE')
     users_read = Right.find_by_resource_and_operation('users','READ')  
     users_update = Right.find_by_resource_and_operation('users','UPDATE')  

    #free_owner	
 #   free_owner.rights << users_read
 #   free_owner.rights << users_update
 #   free_owner.rights << users_delete
    #essential_owner	
#   essential_owner.rights << users_create
#   essential_owner.rights << users_read
#   essential_owner.rights << users_update
#   essential_owner.rights << users_delete
    #essential_accountant
#   essential_accountant.rights << users_create
 #  essential_accountant.rights << users_read
 #  essential_accountant.rights << users_update
 #  essential_accountant.rights << users_delete
    #essential_staff
 #  essential_staff.rights << users_read
    #essential_auditor
 #  essential_auditor.rights << users_read    

#basic_owner	
 #   basic_owner.rights << users_create
 #   basic_owner.rights << users_read
 #   basic_owner.rights << users_update
 #   basic_owner.rights << users_delete
    #basic_accountant
#    basic_accountant.rights << users_create
 #   basic_accountant.rights << users_read
#    basic_accountant.rights << users_update
#   basic_accountant.rights << users_delete
    #basic_staff
#    basic_staff.rights << users_read
    #basic_auditor
#    basic_auditor.rights << users_read

    #premium_owner	
#    premium_owner.rights << users_create
#    premium_owner.rights << users_read
#    premium_owner.rights << users_update
#    premium_owner.rights << users_delete
    #premium_accountant
#    premium_accountant.rights << users_create
 #   premium_accountant.rights << users_read
 #   premium_accountant.rights << users_update
 #   premium_accountant.rights << users_delete
    #premium_staff
 #   premium_staff.rights << users_read
    #premium_auditor
 #   premium_auditor.rights << users_read
  #premium_employee
    premium_employee.rights << users_read
    premium_employee.rights << users_update

    #enterprise_owner	
  #  enterprise_owner.rights << users_create
  #  enterprise_owner.rights << users_read
  #  enterprise_owner.rights << users_update
  #  enterprise_owner.rights << users_delete
    #enterprise_accountant
  #  enterprise_accountant.rights << users_create
  #  enterprise_accountant.rights << users_read
  #  enterprise_accountant.rights << users_update
  #  enterprise_accountant.rights << users_delete
    #enterprise_staff
  #  enterprise_staff.rights << users_read
    #enterprise_auditor
  #  enterprise_auditor.rights << users_read
    #enterprise_employee
    enterprise_employee.rights << users_read
    enterprise_employee.rights << users_update

#3)COMPANY
#    companies_create = Right.create!(:resource => 'companies', :operation => 'CREATE')
 #   companies_read = Right.create!(:resource => 'companies', :operation => 'READ') 
#    companies_delete = Right.create!(:resource => 'companies', :operation => 'DELETE')
#    companies_update = Right.create!(:resource => 'companies', :operation => 'UPDATE')

    #free_owner	
  #  free_owner.rights << companies_read
  #  free_owner.rights << companies_update
  #  free_owner.rights << companies_delete
    #essential_owner	
#     essential_owner.rights << companies_create
#     essential_owner.rights << companies_read
#     essential_owner.rights << companies_update
#     essential_owner.rights << companies_delete
    #essential_accountant
#     essential_accountant.rights << companies_read
    #essential_auditor
#     essential_auditor.rights << companies_read
#basic_owner	
#    basic_owner.rights << companies_create
#    basic_owner.rights << companies_read
#    basic_owner.rights << companies_update
#    basic_owner.rights << companies_delete
    #basic_accountant
#    basic_accountant.rights << companies_read
    #basic_auditor
#    basic_auditor.rights << companies_read

    #premium_owner	
#     premium_owner.rights << companies_create
#     premium_owner.rights << companies_read
#     premium_owner.rights << companies_update
#     premium_owner.rights << companies_delete
    #premium_accountant
#     premium_accountant.rights << companies_read
    #premium_auditor
#     premium_auditor.rights << companies_read

    #enterprise_owner	
#    enterprise_owner.rights << companies_create
#    enterprise_owner.rights << companies_read
#    enterprise_owner.rights << companies_update
#    enterprise_owner.rights << companies_delete
    #enterprise_accountant
#    enterprise_accountant.rights << companies_read
    #enterprise_auditor
#    enterprise_auditor.rights << companies_read

#3.1)COMPANY SETTING
#    settings_read = Right.create!(:resource => 'settings', :operation => 'READ') 
#    settings_update = Right.create!(:resource => 'settings', :operation => 'UPDATE')
  
   #free_owner	
  #  free_owner.rights << settings_read
  #  free_owner.rights << settings_update
   
    #basic_owner	
#    basic_owner.rights << settings_read
#    basic_owner.rights << settings_update

    #basic_accountant
#    basic_accountant.rights << settings_read
    #basic_auditor
#    basic_auditor.rights << settings_read
   #essential_owner	
#    essential_owner.rights << settings_read
#    essential_owner.rights << settings_update
    #essential_accountant
#    essential_accountant.rights << settings_read
    #essential_auditor
#    essential_auditor.rights << settings_read
    #premium_owner	
#    premium_owner.rights << settings_read
#    premium_owner.rights << settings_update
    
    #premium_accountant
#    premium_accountant.rights << settings_read
    #premium_auditor
#    premium_auditor.rights << settings_read

    #enterprise_owner	
#    enterprise_owner.rights << settings_read
#    enterprise_owner.rights << settings_update

    #enterprise_accountant
#    enterprise_accountant.rights << settings_read
   #enterprise_auditor
#    enterprise_auditor.rights << settings_read

#Payroll rights for controller 
# DASHBOARD
#    payroll_dashboard_read = Right.create!(:resource => 'payroll_dashboard', :operation => 'READ') 
     payroll_dashboard_read = Right.find_by_resource_and_operation('payroll_dashboard','READ')  

    #premium_owner	
#    premium_owner.rights << payroll_dashboard_read
    #premium_accountant
#    premium_accountant.rights << payroll_dashboard_read
    #premium_staff
#    premium_staff.rights << payroll_dashboard_read
    #premium_auditor
#    premium_auditor.rights << payroll_dashboard_read
    #premium_employee
    premium_employee.rights << payroll_dashboard_read

    #enterprise_owner	
#    enterprise_owner.rights << payroll_dashboard_read
   #enterprise_accountant
#    enterprise_accountant.rights << payroll_dashboard_read
#   enterprise_staff
#    enterprise_staff.rights << payroll_dashboard_read
   #enterprise_auditor
#    enterprise_auditor.rights << payroll_dashboard_read
   #enterprise_employee
    enterprise_employee.rights << payroll_dashboard_read


 #1)ASSETS
 #   assets_create = Right.create!(:resource => 'assets', :operation => 'CREATE')
 #   assets_read = Right.create!(:resource => 'assets', :operation => 'READ') 
 #   assets_delete = Right.create!(:resource => 'assets', :operation => 'DELETE')
 #   assets_update = Right.create!(:resource => 'assets', :operation => 'UPDATE')
     assets_read = Right.find_by_resource_and_operation('assets','READ')  
     
   #premium_owner	
 #   premium_owner.rights << assets_create
 #   premium_owner.rights << assets_read
 #   premium_owner.rights << assets_update
 #   premium_owner.rights << assets_delete
    #premium_accountant
 #   premium_accountant.rights << assets_create
 #   premium_accountant.rights << assets_read
 #   premium_accountant.rights << assets_update
    #premium_staff
 #   premium_staff.rights << assets_read
    #premium_employee
    premium_employee.rights << assets_read

    #enterprise_owner	
 #   enterprise_owner.rights << assets_create
 #   enterprise_owner.rights << assets_read
 #   enterprise_owner.rights << assets_update
 #   enterprise_owner.rights << assets_delete
    #enterprise_accountant
 #   enterprise_accountant.rights << assets_create
 #   enterprise_accountant.rights << assets_read
 #   enterprise_accountant.rights << assets_update
    #enterprise_staff
 #   enterprise_staff.rights << assets_read
    #enterprise_employee
    enterprise_employee.rights << assets_read

#2)DEPARTMENTS
 #   departments_create = Right.create!(:resource => 'departments', :operation => 'CREATE')
 #   departments_read = Right.create!(:resource => 'departments', :operation => 'READ') 
 #   departments_delete = Right.create!(:resource => 'departments', :operation => 'DELETE')
 #   departments_update = Right.create!(:resource => 'departments', :operation => 'UPDATE')
     departments_read = Right.find_by_resource_and_operation('departments','READ')  
   #premium_owner	
 #   premium_owner.rights << departments_create
 #   premium_owner.rights << departments_read
 #   premium_owner.rights << departments_update
 #   premium_owner.rights << departments_delete
    #premium_accountant
 #   premium_accountant.rights << departments_read
    #premium_staff
#    premium_staff.rights << departments_read
    #premium_employee
    premium_employee.rights << departments_read

    #enterprise_owner	
#    enterprise_owner.rights << departments_create
#    enterprise_owner.rights << departments_read
#    enterprise_owner.rights << departments_update
#    enterprise_owner.rights << departments_delete
    #enterprise_accountant
#    enterprise_accountant.rights << departments_read
    #enterprise_staff
#    enterprise_staff.rights << departments_read
    #enterprise_employee
    enterprise_employee.rights << departments_read

#3)DESIGNATIONS
#    designations_create = Right.create!(:resource => 'designations', :operation => 'CREATE')
#    designations_read = Right.create!(:resource => 'designations', :operation => 'READ') 
#    designations_delete = Right.create!(:resource => 'designations', :operation => 'DELETE')
#    designations_update = Right.create!(:resource => 'designations', :operation => 'UPDATE')
     designations_read = Right.find_by_resource_and_operation('designations','READ')  
   #premium_owner	
#    premium_owner.rights << designations_create
#    premium_owner.rights << designations_read
#    premium_owner.rights << designations_update
#    premium_owner.rights << designations_delete
    #premium_accountant
#    premium_accountant.rights << designations_read
    #enterprise_staff
#    premium_staff.rights << designations_read
    #enterprise_employee
    premium_employee.rights << designations_read

    #enterprise_owner	
#    enterprise_owner.rights << designations_create
#    enterprise_owner.rights << designations_read
#    enterprise_owner.rights << designations_update
#    enterprise_owner.rights << designations_delete
    #enterprise_accountant
#    enterprise_accountant.rights << designations_read
    #enterprise_staff
#    enterprise_staff.rights << designations_read
    #enterprise_employee
    enterprise_employee.rights << designations_read

#4)HOLIDAY
#    holidays_create = Right.create!(:resource => 'holidays', :operation => 'CREATE')
#    holidays_read = Right.create!(:resource => 'holidays', :operation => 'READ') 
#    holidays_delete = Right.create!(:resource => 'holidays', :operation => 'DELETE')
#    holidays_update = Right.create!(:resource => 'holidays', :operation => 'UPDATE')
     holidays_read = Right.find_by_resource_and_operation('holidays','READ')  
   #premium_owner	
#    premium_owner.rights << holidays_create
#    premium_owner.rights << holidays_read
#    premium_owner.rights << holidays_update
#    premium_owner.rights << holidays_delete
    #premium_accountant
#    premium_accountant.rights << holidays_read
    #premium_staff
#    premium_staff.rights << holidays_read
    #premium_auditor
#    premium_auditor.rights << holidays_read
    #premium_employee
    premium_employee.rights << holidays_read

    #enterprise_owner	
#    enterprise_owner.rights << holidays_create
#    enterprise_owner.rights << holidays_read
#    enterprise_owner.rights << holidays_update
#    enterprise_owner.rights << holidays_delete
    #enterprise_accountant
#    enterprise_accountant.rights << holidays_read
    #enterprise_staff
#    enterprise_staff.rights << holidays_read
    #enterprise_auditor
#    enterprise_auditor.rights << holidays_read
    #enterprise_employee
    enterprise_employee.rights << holidays_read


#5)LEAVE TYPES
#    leave_types_create = Right.create!(:resource => 'leave_types', :operation => 'CREATE')
#    leave_types_read = Right.create!(:resource => 'leave_types', :operation => 'READ') 
#    leave_types_delete = Right.create!(:resource => 'leave_types', :operation => 'DELETE')
#    leave_types_update = Right.create!(:resource => 'leave_types', :operation => 'UPDATE')
     leave_types_read = Right.find_by_resource_and_operation('leave_types','READ')  
   #premium_owner	
#    premium_owner.rights << leave_types_create
#    premium_owner.rights << leave_types_read
#    premium_owner.rights << leave_types_update
#    premium_owner.rights << leave_types_delete
    #premium_accountant
#    premium_accountant.rights << leave_types_read
    #premium_staff
#    premium_staff.rights << leave_types_read
    #premium_employee
    premium_employee.rights << leave_types_read

    #enterprise_owner	
#    enterprise_owner.rights << leave_types_create
#    enterprise_owner.rights << leave_types_read
#    enterprise_owner.rights << leave_types_update
#    enterprise_owner.rights << leave_types_delete
    #enterprise_accountant
#    enterprise_accountant.rights << leave_types_read
    #enterprise_staff
#    enterprise_staff.rights << leave_types_read
    #enterprise_employee
    enterprise_employee.rights << leave_types_read

#6)ORGANISATION ANNOUNCEMENT
#    organization_announcements_create = Right.create!(:resource => 'organization_announcements', :operation => 'CREATE')
#    organization_announcements_read = Right.create!(:resource => 'organization_announcements', :operation => 'READ') 
#    organization_announcements_delete = Right.create!(:resource => 'organization_announcements', :operation => 'DELETE')
#    organization_announcements_update = Right.create!(:resource => 'organization_announcements', :operation => 'UPDATE')
     organization_announcements_read = Right.find_by_resource_and_operation('organization_announcements','READ')  
   #premium_owner	
#    premium_owner.rights << organization_announcements_create
#    premium_owner.rights << organization_announcements_read
#    premium_owner.rights << organization_announcements_update
#    premium_owner.rights << organization_announcements_delete
    #premium_accountant
#    premium_accountant.rights << organization_announcements_read
    #premium_staff
#    premium_staff.rights << organization_announcements_read
    #premium_employee
    premium_employee.rights << organization_announcements_read

    #enterprise_owner	
#    enterprise_owner.rights << organization_announcements_create
#    enterprise_owner.rights << organization_announcements_read
#    enterprise_owner.rights << organization_announcements_update
#    enterprise_owner.rights << organization_announcements_delete
    #enterprise_accountant
#    enterprise_accountant.rights << organization_announcements_read
    #enterprise_staff
#    enterprise_staff.rights << organization_announcements_read
    #enterprise_employee
    enterprise_employee.rights << organization_announcements_read

#7)MANAGE SALARY STRUCTURE
#    salary_structures_create = Right.create!(:resource => 'salary_structures', :operation => 'CREATE')
#    salary_structures_read = Right.create!(:resource => 'salary_structures', :operation => 'READ') 
#    salary_structures_delete = Right.create!(:resource => 'salary_structures', :operation => 'DELETE')
#    salary_structures_update = Right.create!(:resource => 'salary_structures', :operation => 'UPDATE')
     salary_structures_read = Right.find_by_resource_and_operation('salary_structures','READ')
   #premium_owner	
#    premium_owner.rights << salary_structures_create
#    premium_owner.rights << salary_structures_read
#    premium_owner.rights << salary_structures_update
#    premium_owner.rights << salary_structures_delete
    #premium_accountant
#    premium_accountant.rights << salary_structures_read
    #premium_staff
#    premium_staff.rights << salary_structures_read
    #premium_auditor
#    premium_auditor.rights << salary_structures_read
   #premium_employee
#    premium_employee.rights << salary_structures_read

    #enterprise_owner	
#    enterprise_owner.rights << salary_structures_create
#    enterprise_owner.rights << salary_structures_read
#    enterprise_owner.rights << salary_structures_update
#    enterprise_owner.rights << salary_structures_delete
    #enterprise_accountant
#    enterprise_accountant.rights << salary_structures_read
    #enterprise_staff
#    enterprise_staff.rights << salary_structures_read
    #enterprise_auditor
#    enterprise_auditor.rights << salary_structures_read
    #enterprise_employee
    enterprise_employee.rights << salary_structures_read

#8)PAYHEADS
#    payheads_create = Right.create!(:resource => 'payheads', :operation => 'CREATE')
#    payheads_read = Right.create!(:resource => 'payheads', :operation => 'READ') 
#    payheads_delete = Right.create!(:resource => 'payheads', :operation => 'DELETE')
#    payheads_update = Right.create!(:resource => 'payheads', :operation => 'UPDATE')

   #premium_owner	
#    premium_owner.rights << payheads_create
#    premium_owner.rights << payheads_read
#    premium_owner.rights << payheads_update
#    premium_owner.rights << payheads_delete
    #premium_accountant
#    premium_accountant.rights << payheads_read
   #premium_auditor
#    premium_auditor.rights << payheads_read

    #enterprise_owner	
#    enterprise_owner.rights << payheads_create
#    enterprise_owner.rights << payheads_read
#    enterprise_owner.rights << payheads_update
#    enterprise_owner.rights << payheads_delete
    #enterprise_accountant
#    enterprise_accountant.rights << payheads_read
    #enterprise_auditor
#    enterprise_auditor.rights << payheads_read

#9)LEAVE REQUESTS
#    leave_requests_create = Right.create!(:resource => 'leave_requests', :operation => 'CREATE')
#    leave_requests_read = Right.create!(:resource => 'leave_requests', :operation => 'READ') 
#    leave_requests_delete = Right.create!(:resource => 'leave_requests', :operation => 'DELETE')
#    leave_requests_update = Right.create!(:resource => 'leave_requests', :operation => 'UPDATE')
     leave_requests_create = Right.find_by_resource_and_operation('leave_requests','CREATE')
     leave_requests_read = Right.find_by_resource_and_operation('leave_requests','READ')
     leave_requests_update = Right.find_by_resource_and_operation('leave_requests','UPDATE')
   #premium_owner	
#    premium_owner.rights << leave_requests_create
#    premium_owner.rights << leave_requests_read
#    premium_owner.rights << leave_requests_update
#    premium_owner.rights << leave_requests_delete
    #premium_accountant
#    premium_accountant.rights << leave_requests_create
#    premium_accountant.rights << leave_requests_read
#    premium_accountant.rights << leave_requests_update
    #premium_staff
#    premium_staff.rights << leave_requests_create
#    premium_staff.rights << leave_requests_read
#    premium_staff.rights << leave_requests_update
    #premium_employee
    premium_employee.rights << leave_requests_create
    premium_employee.rights << leave_requests_read
    premium_employee.rights << leave_requests_update

    #enterprise_owner	
#    enterprise_owner.rights << leave_requests_create
#    enterprise_owner.rights << leave_requests_read
#    enterprise_owner.rights << leave_requests_update
#    enterprise_owner.rights << leave_requests_delete
    #enterprise_accountant
#    enterprise_accountant.rights << leave_requests_create
#    enterprise_accountant.rights << leave_requests_read
#    enterprise_accountant.rights << leave_requests_update
    #enterprise_staff
#    enterprise_staff.rights << leave_requests_create
#    enterprise_staff.rights << leave_requests_read
#    enterprise_staff.rights << leave_requests_update
    #enterprise_employee
    enterprise_employee.rights << leave_requests_create
    enterprise_employee.rights << leave_requests_read
    enterprise_employee.rights << leave_requests_update

#10)BOOK TIME
#    timesheets_create = Right.create!(:resource => 'timesheets', :operation => 'CREATE')
#    timesheets_read = Right.create!(:resource => 'timesheets', :operation => 'READ') 
#    timesheets_delete = Right.create!(:resource => 'timesheets', :operation => 'DELETE')
#    timesheets_update = Right.create!(:resource => 'timesheets', :operation => 'UPDATE
     timesheets_create = Right.find_by_resource_and_operation('timesheets','CREATE')
     timesheets_read = Right.find_by_resource_and_operation('timesheets','READ')
     timesheets_delete = Right.find_by_resource_and_operation('timesheets','DELETE')
     timesheets_update = Right.find_by_resource_and_operation('timesheets','UPDATE')
   #premium_owner	
#    premium_owner.rights << timesheets_create
#    premium_owner.rights << timesheets_read
#    premium_owner.rights << timesheets_update
#    premium_owner.rights << timesheets_delete
    #premium_accountant
#    premium_accountant.rights << timesheets_create
#    premium_accountant.rights << timesheets_read
#    premium_accountant.rights << timesheets_update
#    premium_accountant.rights << timesheets_delete
    #premium_staff
#    premium_staff.rights << timesheets_create
#    premium_staff.rights << timesheets_read
#    premium_staff.rights << timesheets_update
#    premium_staff.rights << timesheets_delete
    #premium_employee
    premium_employee.rights << timesheets_create
    premium_employee.rights << timesheets_read
    premium_employee.rights << timesheets_update
    premium_employee.rights << timesheets_delete

    #enterprise_owner	
#    enterprise_owner.rights << timesheets_create
#    enterprise_owner.rights << timesheets_read
#    enterprise_owner.rights << timesheets_update
#    enterprise_owner.rights << timesheets_delete
    #enterprise_accountant
#    enterprise_accountant.rights << timesheets_create
#    enterprise_accountant.rights << timesheets_read
#    enterprise_accountant.rights << timesheets_update
#    enterprise_accountant.rights << timesheets_delete
    #enterprise_staff
#    enterprise_staff.rights << timesheets_create
#    enterprise_staff.rights << timesheets_read
#    enterprise_staff.rights << timesheets_update
#    enterprise_staff.rights << timesheets_delete
    #enterprise_employee
    enterprise_employee.rights << timesheets_create
    enterprise_employee.rights << timesheets_read
    enterprise_employee.rights << timesheets_update
    enterprise_employee.rights << timesheets_delete


#11)POLICY DOCUMENTS
#    policy_documents_create = Right.create!(:resource => 'policy_documents', :operation => 'CREATE')
#    policy_documents_read = Right.create!(:resource => 'policy_documents', :operation => 'READ') 
#    policy_documents_delete = Right.create!(:resource => 'policy_documents', :operation => 'DELETE')
#    policy_documents_update = Right.create!(:resource => 'policy_documents', :operation => 'UPDATE')
     policy_documents_read = Right.find_by_resource_and_operation('policy_documents','READ')

   #premium_owner	
#    premium_owner.rights << policy_documents_create
#    premium_owner.rights << policy_documents_read
#    premium_owner.rights << policy_documents_update
#    premium_owner.rights << policy_documents_delete
    #premium_accountant
#    premium_accountant.rights << policy_documents_create
#    premium_accountant.rights << policy_documents_read
#    premium_accountant.rights << policy_documents_update
#    premium_accountant.rights << policy_documents_delete
    #premium_staff
#    premium_staff.rights << policy_documents_read
    #premium_employee
    premium_employee.rights << policy_documents_read

    #enterprise_owner	
#    enterprise_owner.rights << policy_documents_create
#    enterprise_owner.rights << policy_documents_read
#    enterprise_owner.rights << policy_documents_update
#    enterprise_owner.rights << policy_documents_delete
    #enterprise_accountant
#    enterprise_accountant.rights << policy_documents_create
#    enterprise_accountant.rights << policy_documents_read
#    enterprise_accountant.rights << policy_documents_update
#    enterprise_accountant.rights << policy_documents_delete
    #enterprise_staff
#    enterprise_staff.rights << policy_documents_read
    #enterprise_employee
    enterprise_employee.rights << policy_documents_read

#12)FOLDERS
#    folders_create = Right.create!(:resource => 'folders', :operation => 'CREATE')
#    folders_read = Right.create!(:resource => 'folders', :operation => 'READ') 
#    folders_delete = Right.create!(:resource => 'folders', :operation => 'DELETE')
#    folders_update = Right.create!(:resource => 'folders', :operation => 'UPDATE')
     folders_create = Right.find_by_resource_and_operation('folders','CREATE')
     folders_read = Right.find_by_resource_and_operation('folders','READ')
     folders_delete = Right.find_by_resource_and_operation('folders','DELETE')
     folders_update = Right.find_by_resource_and_operation('folders','UPDATE')

   #premium_owner	
#    premium_owner.rights << folders_create
#    premium_owner.rights << folders_read
#    premium_owner.rights << folders_update
#    premium_owner.rights << folders_delete
    #premium_accountant
#    premium_accountant.rights << folders_create
#    premium_accountant.rights << folders_read
#    premium_accountant.rights << folders_update
#    premium_accountant.rights << folders_delete
    #premium_staff
#    premium_staff.rights << folders_create
#    premium_staff.rights << folders_read
#    premium_staff.rights << folders_update
#    premium_staff.rights << folders_delete
    #premium_employee
    premium_employee.rights << folders_create
    premium_employee.rights << folders_read
    premium_employee.rights << folders_update
    premium_employee.rights << folders_delete

    #enterprise_owner	
#    enterprise_owner.rights << folders_create
#    enterprise_owner.rights << folders_read
#    enterprise_owner.rights << folders_update
#    enterprise_owner.rights << folders_delete
#    #enterprise_accountant
#    enterprise_accountant.rights << folders_create
#    enterprise_accountant.rights << folders_read
#    enterprise_accountant.rights << folders_update
#    enterprise_accountant.rights << folders_delete
    #enterprise_staff
#    enterprise_staff.rights << folders_create
#    enterprise_staff.rights << folders_read
#    enterprise_staff.rights << folders_update
#    enterprise_staff.rights << folders_delete
    #enterprise_employee
    enterprise_employee.rights << folders_create
    enterprise_employee.rights << folders_read
    enterprise_employee.rights << folders_update
    enterprise_employee.rights << folders_delete


#13)MY FILES
#    myfiles_create = Right.create!(:resource => 'myfiles', :operation => 'CREATE')
#    myfiles_read = Right.create!(:resource => 'myfiles', :operation => 'READ') 
#    myfiles_delete = Right.create!(:resource => 'myfiles', :operation => 'DELETE')
#    myfiles_update = Right.create!(:resource => 'myfiles', :operation => 'UPDATE')
     myfiles_create = Right.find_by_resource_and_operation('myfiles','CREATE')
     myfiles_read = Right.find_by_resource_and_operation('myfiles','READ')
     myfiles_delete = Right.find_by_resource_and_operation('myfiles','DELETE')
     myfiles_update = Right.find_by_resource_and_operation('myfiles','UPDATE')

   #premium_owner	
#    premium_owner.rights << myfiles_create
#    premium_owner.rights << myfiles_read
#    premium_owner.rights << myfiles_update
#    premium_owner.rights << myfiles_delete
#    #premium_accountant
#    premium_accountant.rights << myfiles_create
#    premium_accountant.rights << myfiles_read
#    premium_accountant.rights << myfiles_update
#    premium_accountant.rights << myfiles_delete
    #premium_staff
#    premium_staff.rights << myfiles_create
#    premium_staff.rights << myfiles_read
#    premium_staff.rights << myfiles_update
#    premium_staff.rights << myfiles_delete
    #premium_employee
    premium_employee.rights << myfiles_create
    premium_employee.rights << myfiles_read
    premium_employee.rights << myfiles_update
    premium_employee.rights << myfiles_delete

    #enterprise_owner	
#    enterprise_owner.rights << myfiles_create
#    enterprise_owner.rights << myfiles_read
#    enterprise_owner.rights << myfiles_update
#    enterprise_owner.rights << myfiles_delete
    #enterprise_accountant
#    enterprise_accountant.rights << myfiles_create
#    enterprise_accountant.rights << myfiles_read
#    enterprise_accountant.rights << myfiles_update
#    enterprise_accountant.rights << myfiles_delete
    #enterprise_staff
#    enterprise_staff.rights << myfiles_create
#    enterprise_staff.rights << myfiles_read
#    enterprise_staff.rights << myfiles_update
#    enterprise_staff.rights << myfiles_delete
    #enterprise_employee
    enterprise_employee.rights << myfiles_create
    enterprise_employee.rights << myfiles_read
    enterprise_employee.rights << myfiles_update
    enterprise_employee.rights << myfiles_delete


# Support
    supports_create = Right.create!(:resource => 'supports', :operation => 'CREATE')
    supports_read = Right.create!(:resource => 'supports', :operation => 'READ') 
    supports_delete = Right.create!(:resource => 'supports', :operation => 'DELETE')
    supports_update = Right.create!(:resource => 'supports', :operation => 'UPDATE')

   
  #essential_owner	
    essential_owner.rights << supports_create
    essential_owner.rights << supports_read
    essential_owner.rights << supports_update
    essential_owner.rights << supports_delete
    #basic_accountant
    essential_accountant.rights << supports_create
    essential_accountant.rights << supports_read
    essential_accountant.rights << supports_update
    essential_accountant.rights << supports_delete
    #essential_staff
    essential_staff.rights << supports_create
    essential_staff.rights << supports_read
    essential_staff.rights << supports_update
    essential_staff.rights << supports_delete

   #basic_owner	
    basic_owner.rights << supports_create
    basic_owner.rights << supports_read
    basic_owner.rights << supports_update
    basic_owner.rights << supports_delete
   #basic_accountant
    basic_accountant.rights << supports_create
    basic_accountant.rights << supports_read
    basic_accountant.rights << supports_update
    basic_accountant.rights << supports_delete
   #basic_staff
    basic_staff.rights << supports_create
    basic_staff.rights << supports_read
    basic_staff.rights << supports_update
    basic_staff.rights << supports_delete
    #premium_owner	
    premium_owner.rights << supports_create
    premium_owner.rights << supports_read
    premium_owner.rights << supports_update
    premium_owner.rights << supports_delete
    #premium_accountant
    premium_accountant.rights << supports_create
    premium_accountant.rights << supports_read
    premium_accountant.rights << supports_update
    premium_accountant.rights << supports_delete
    #premium_staff
    premium_staff.rights << supports_create
    premium_staff.rights << supports_read
    premium_staff.rights << supports_update
    premium_staff.rights << supports_delete
    #premium_employee
    premium_employee.rights << supports_create
    premium_employee.rights << supports_read
    premium_employee.rights << supports_update
    premium_employee.rights << supports_delete
    #premium_auditor
 #   premium_auditor.rights << supports_read

    #enterprise_owner	
    enterprise_owner.rights << supports_create
    enterprise_owner.rights << supports_read
    enterprise_owner.rights << supports_update
    enterprise_owner.rights << supports_delete
   #enterprise_accountant
    enterprise_accountant.rights << supports_create
    enterprise_accountant.rights << supports_read
    enterprise_accountant.rights << supports_update
    enterprise_accountant.rights << supports_delete
   #enterprise_staff
    enterprise_staff.rights << supports_create
    enterprise_staff.rights << supports_read
    enterprise_staff.rights << supports_update
    enterprise_staff.rights << supports_delete
    #enterprise_employee
    enterprise_employee.rights << supports_create
    enterprise_employee.rights << supports_read
    enterprise_employee.rights << supports_update
    enterprise_employee.rights << supports_delete
    #enterprise_auditor
#    enterprise_auditor.rights << supports_read

# Feedback
    feedbacks_create = Right.create!(:resource => 'feedbacks', :operation => 'CREATE')
    feedbacks_read = Right.create!(:resource => 'feedbacks', :operation => 'READ') 
    feedbacks_delete = Right.create!(:resource => 'feedbacks', :operation => 'DELETE')
    feedbacks_update = Right.create!(:resource => 'feedbacks', :operation => 'UPDATE')
   
  #essential_owner	
    essential_owner.rights << feedbacks_create
    essential_owner.rights << feedbacks_read
    essential_owner.rights << feedbacks_update
    essential_owner.rights << feedbacks_delete
    #basic_accountant
    essential_accountant.rights << feedbacks_create
    essential_accountant.rights << feedbacks_read
    essential_accountant.rights << feedbacks_update
    essential_accountant.rights << feedbacks_delete
   #essential_staff
    essential_staff.rights << feedbacks_create
    essential_staff.rights << feedbacks_read
    essential_staff.rights << feedbacks_update
    essential_staff.rights << feedbacks_delete

   #basic_owner	
    basic_owner.rights << feedbacks_create
    basic_owner.rights << feedbacks_read
    basic_owner.rights << feedbacks_update
    basic_owner.rights << feedbacks_delete
    #basic_accountant
    basic_accountant.rights << feedbacks_create
    basic_accountant.rights << feedbacks_read
    basic_accountant.rights << feedbacks_update
    basic_accountant.rights << feedbacks_delete
    #basic_staff
    basic_staff.rights << feedbacks_create
    basic_staff.rights << feedbacks_read
    basic_staff.rights << feedbacks_update
    basic_staff.rights << feedbacks_delete

    #premium_owner	

    premium_owner.rights << feedbacks_create
    premium_owner.rights << feedbacks_read
    premium_owner.rights << feedbacks_update
    premium_owner.rights << feedbacks_delete
   #premium_accountant
    premium_accountant.rights << feedbacks_create
    premium_accountant.rights << feedbacks_read
    premium_accountant.rights << feedbacks_update
    premium_accountant.rights << feedbacks_delete
  #premium_staff
    premium_staff.rights << feedbacks_create
    premium_staff.rights << feedbacks_read
    premium_staff.rights << feedbacks_update
    premium_staff.rights << feedbacks_delete
    #premium_employee
    premium_employee.rights << feedbacks_create
    premium_employee.rights << feedbacks_read
    premium_employee.rights << feedbacks_update
    premium_employee.rights << feedbacks_delete
    #premium_auditor
#    premium_auditor.rights << feedbacks_read

    #enterprise_owner	
    enterprise_owner.rights << feedbacks_create
    enterprise_owner.rights << feedbacks_read
    enterprise_owner.rights << feedbacks_update
    enterprise_owner.rights << feedbacks_delete
   #enterprise_accountant
    enterprise_accountant.rights << feedbacks_create
    enterprise_accountant.rights << feedbacks_read
    enterprise_accountant.rights << feedbacks_update
    enterprise_accountant.rights << feedbacks_delete
   #enterprise_staff
    enterprise_staff.rights << feedbacks_create
    enterprise_staff.rights << feedbacks_read
    enterprise_staff.rights << feedbacks_update
    enterprise_staff.rights << feedbacks_delete
    #enterprise_employee
    enterprise_employee.rights << feedbacks_create
    enterprise_employee.rights << feedbacks_read
    enterprise_employee.rights << feedbacks_update
    enterprise_employee.rights << feedbacks_delete
    #enterprise_auditor
#    enterprise_auditor.rights << feedbacks_read

# Attendance
#    attendances_create = Right.create!(:resource => 'attendances', :operation => 'CREATE')
#    attendances_read = Right.create!(:resource => 'attendances', :operation => 'READ') 
#    attendances_delete = Right.create!(:resource => 'attendances', :operation => 'DELETE')
#    attendances_update = Right.create!(:resource => 'attendances', :operation => 'UPDATE')
   
    #premium_owner	
#    premium_owner.rights << attendances_create
#    premium_owner.rights << attendances_read
#    premium_owner.rights << attendances_update
#    premium_owner.rights << attendances_delete
    #premium_accountant
#    premium_accountant.rights << attendances_create
#    premium_accountant.rights << attendances_read
#    premium_accountant.rights << attendances_update
#    premium_accountant.rights << attendances_delete
    #premium_auditor
#    premium_auditor.rights << attendances_read
   
   #enterprise_owner	
#    enterprise_owner.rights << attendances_create
#    enterprise_owner.rights << attendances_read
#    enterprise_owner.rights << attendances_update
#    enterprise_owner.rights << attendances_delete
    #enterprise_accountant
#    enterprise_accountant.rights << attendances_create
#    enterprise_accountant.rights << attendances_read
#    enterprise_accountant.rights << attendances_update
#    enterprise_accountant.rights << attendances_delete
    #enterprise_auditor
#    enterprise_auditor.rights << attendances_read

# Payroll details
#    payroll_details_create = Right.create!(:resource => 'payroll_details', :operation => 'CREATE')
#    payroll_details_read = Right.create!(:resource => 'payroll_details', :operation => 'READ') 
#    payroll_details_delete = Right.create!(:resource => 'payroll_details', :operation => 'DELETE')
#    payroll_details_update = Right.create!(:resource => 'payroll_details', :operation => 'UPDATE')
   
    #premium_owner	
#    premium_owner.rights << payroll_details_create
#    premium_owner.rights << payroll_details_read
#    premium_owner.rights << payroll_details_update
#    premium_owner.rights << payroll_details_delete
    #premium_accountant
#    premium_accountant.rights << payroll_details_create
#    premium_accountant.rights << payroll_details_read
#    premium_accountant.rights << payroll_details_update
#    premium_accountant.rights << payroll_details_delete
    #premium_auditor
#    premium_auditor.rights << payroll_details_read
   
   #enterprise_owner	
#    enterprise_owner.rights << payroll_details_create
#    enterprise_owner.rights << payroll_details_read
#    enterprise_owner.rights << payroll_details_update
#    enterprise_owner.rights << payroll_details_delete
    #enterprise_accountant
#    enterprise_accountant.rights << payroll_details_create
#    enterprise_accountant.rights << payroll_details_read
#    enterprise_accountant.rights << payroll_details_update
#    enterprise_accountant.rights << payroll_details_delete
    #enterprise_auditor
#    enterprise_auditor.rights << payroll_details_read
 
# Salary slip
    salary_slip_create = Right.create!(:resource => 'salary_slip', :operation => 'CREATE')
    salary_slip_read = Right.create!(:resource => 'salary_slip', :operation => 'READ') 
    salary_slip_delete = Right.create!(:resource => 'salary_slip', :operation => 'DELETE')
    salary_slip_update = Right.create!(:resource => 'salary_slip', :operation => 'UPDATE')
#     salary_slip_read = Right.find_by_resource_and_operation('salary_slip','READ')

    #premium_owner	
    premium_owner.rights << salary_slip_create
    premium_owner.rights << salary_slip_read
    premium_owner.rights << salary_slip_update
    premium_owner.rights << salary_slip_delete
    #premium_accountant
    premium_accountant.rights << salary_slip_create
    premium_accountant.rights << salary_slip_read
    premium_accountant.rights << salary_slip_update
    premium_accountant.rights << salary_slip_delete
    #premium_staff
    premium_staff.rights << salary_slip_read
   #premium_auditor
    premium_auditor.rights << salary_slip_read
   #premium_employee
    premium_employee.rights << salary_slip_read
   
   #enterprise_owner	
    enterprise_owner.rights << salary_slip_create
    enterprise_owner.rights << salary_slip_read
    enterprise_owner.rights << salary_slip_update
    enterprise_owner.rights << salary_slip_delete
    #enterprise_accountant
    enterprise_accountant.rights << salary_slip_create
    enterprise_accountant.rights << salary_slip_read
    enterprise_accountant.rights << salary_slip_update
    enterprise_accountant.rights << salary_slip_delete
   #enterprise_staff
    enterprise_staff.rights << salary_slip_read
   #enterprise_employee
    enterprise_employee.rights << salary_slip_read
    #enterprise_auditor
    enterprise_auditor.rights << salary_slip_read
   
# Auditor
#    auditors_create = Right.create!(:resource => 'auditors', :operation => 'CREATE')
#    auditors_read = Right.create!(:resource => 'auditors', :operation => 'READ') 
#    auditors_delete = Right.create!(:resource => 'auditors', :operation => 'DELETE')
#    auditors_update = Right.create!(:resource => 'auditors', :operation => 'UPDATE')
   
   #essential_owner	
#    essential_owner.rights << auditors_create
#    essential_owner.rights << auditors_read
#    essential_owner.rights << auditors_update
#    essential_owner.rights << auditors_delete 
 #basic_owner	
#    basic_owner.rights << auditors_create
#    basic_owner.rights << auditors_read
#    basic_owner.rights << auditors_update
#    basic_owner.rights << auditors_delete 
  #premium_owner	
#    premium_owner.rights << auditors_create
#    premium_owner.rights << auditors_read
#    premium_owner.rights << auditors_update
#    premium_owner.rights << auditors_delete
    
   #enterprise_owner	
#    enterprise_owner.rights << auditors_create
#    enterprise_owner.rights << auditors_read
#    enterprise_owner.rights << auditors_update
#    enterprise_owner.rights << auditors_delete
     
#Invitation details  
#    invitation_details_create = Right.create!(:resource => 'invitation_details', :operation => 'CREATE')
#    invitation_details_read = Right.create!(:resource => 'invitation_details', :operation => 'READ') 
#    invitation_details_delete = Right.create!(:resource => 'invitation_details', :operation => 'DELETE')
#    invitation_details_update = Right.create!(:resource => 'invitation_details', :operation => 'UPDATE')
   
   #essential_owner	
#    essential_owner.rights << invitation_details_create
#    essential_owner.rights << invitation_details_read
#    essential_owner.rights << invitation_details_update
#    essential_owner.rights << invitation_details_delete 
  #basic_owner	
#    basic_owner.rights << invitation_details_create
#    basic_owner.rights << invitation_details_read
#    basic_owner.rights << invitation_details_update
#    basic_owner.rights << invitation_details_delete 
  #premium_owner	
#    premium_owner.rights << invitation_details_create
#    premium_owner.rights << invitation_details_read
#    premium_owner.rights << invitation_details_update
#    premium_owner.rights << invitation_details_delete
    
   #enterprise_owner	
#    enterprise_owner.rights << invitation_details_create
#    enterprise_owner.rights << invitation_details_read
#    enterprise_owner.rights << invitation_details_update
#    enterprise_owner.rights << invitation_details_delete

#Dropbox (DB) rights
#      db_read = Right.create!(:resource => 'db', :operation => 'READ') 
#     db_read = Right.find_by_resource_and_operation('db','READ')
   #essential_owner	
#     essential_owner.rights << db_read
   #essential_accountant	
#    essential_accountant.rights << db_read
   #essential_staff
#    essential_staff.rights << db_read

   #basic_owner	
#    basic_owner.rights << db_read
  #basic_accountant	
#    basic_accountant.rights << db_read
   #basic_staff
#    basic_staff.rights << db_read

   #premium_owner	
#     premium_owner.rights << db_read
   #premium_accountant	
#    premium_accountant.rights << db_read
   #premium_staff
#    premium_staff.rights << db_read
   #premium_employee
#    premium_employee.rights << db_read

   #enterprise_owner	
#     enterprise_owner.rights << db_read
   #enterprise_accountant	
#    enterprise_accountant.rights << db_read
   #enterprise_staff
#    enterprise_staff.rights << db_read
   #enterprise_employee
#    enterprise_employee.rights << db_read


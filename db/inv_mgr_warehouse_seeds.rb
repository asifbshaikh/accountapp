ActiveRecord::Base.transaction do
  
  basic_plan = Plan.find_by_name('Basic')
  premium_plan = Plan.find_by_name('Premium')
  enterprise_plan = Plan.find_by_name('Enterprise')

  #Inventory manager role for  basic plan 
  basic_inventory_manager = Role.create!(:name => 'Inventory Manager')
  basic_plan.roles << basic_inventory_manager
  #Inventory manager role for  premium(proffessional) plan 
  premium_inventory_manager = Role.create!(:name => 'Inventory Manager')
  premium_plan.roles << premium_inventory_manager
 #Inventory manager role for  enterprise plan 
  enterprise_inventory_manager = Role.create!(:name => 'Inventory Manager')
  enterprise_plan.roles << enterprise_inventory_manager
    
 #Rights assignment to inventory manager

 #Dash board and inventory rights for inventory manager
  dashboard_read = Right.find_by_resource_and_operation('dashboard','READ')  

  basic_inventory_manager.rights << dashboard_read
  premium_inventory_manager.rights << dashboard_read
  enterprise_inventory_manager.rights << dashboard_read

# Products
    products_create = Right.find_by_resource_and_operation('products', 'CREATE')
    products_read = Right.find_by_resource_and_operation('products', 'READ')
    products_delete = Right.find_by_resource_and_operation('products', 'DELETE')
    products_update = Right.find_by_resource_and_operation('products', 'UPDATE')

    #basic_inventory_manager  
    basic_inventory_manager.rights << products_create
    basic_inventory_manager.rights << products_read
    basic_inventory_manager.rights << products_update
    basic_inventory_manager.rights << products_delete

    #premium_inventory_manager  
    premium_inventory_manager.rights << products_create
    premium_inventory_manager.rights << products_read
    premium_inventory_manager.rights << products_update
    premium_inventory_manager.rights << products_delete
    #enterprise_inventory_manager 
    enterprise_inventory_manager.rights << products_create
    enterprise_inventory_manager.rights << products_read
    enterprise_inventory_manager.rights << products_update
    enterprise_inventory_manager.rights << products_delete


# WAREHOUSES
    warehouses_create = Right.find_by_resource_and_operation('warehouses', 'CREATE')
    warehouses_read = Right.find_by_resource_and_operation('warehouses', 'READ')
    warehouses_delete = Right.find_by_resource_and_operation('warehouses', 'DELETE')
    warehouses_update = Right.find_by_resource_and_operation('warehouses', 'UPDATE')

    #basic_inventory_manager  
    basic_inventory_manager.rights << warehouses_create
    basic_inventory_manager.rights << warehouses_read
    basic_inventory_manager.rights << warehouses_update
    basic_inventory_manager.rights << warehouses_delete

    #premium_inventory_manager  
    premium_inventory_manager.rights << warehouses_create
    premium_inventory_manager.rights << warehouses_read
    premium_inventory_manager.rights << warehouses_update
    premium_inventory_manager.rights << warehouses_delete
    #enterprise_inventory_manager 
    enterprise_inventory_manager.rights << warehouses_create
    enterprise_inventory_manager.rights << warehouses_read
    enterprise_inventory_manager.rights << warehouses_update
    enterprise_inventory_manager.rights << warehouses_delete

  # STOCK ISSUE VOUCHERS
    stock_issue_vouchers_create = Right.find_by_resource_and_operation('stock_issue_vouchers', 'CREATE')
    stock_issue_vouchers_read = Right.find_by_resource_and_operation('stock_issue_vouchers','READ')
    stock_issue_vouchers_update = Right.find_by_resource_and_operation('stock_issue_vouchers','UPDATE')
    stock_issue_vouchers_delete = Right.find_by_resource_and_operation('stock_issue_vouchers','DELETE')

  #basic_inventory_manager  
    basic_inventory_manager.rights << stock_issue_vouchers_create
    basic_inventory_manager.rights << stock_issue_vouchers_read
    basic_inventory_manager.rights << stock_issue_vouchers_update
    basic_inventory_manager.rights << stock_issue_vouchers_delete
    #premium_inventory_manager  
    premium_inventory_manager.rights << stock_issue_vouchers_create
    premium_inventory_manager.rights << stock_issue_vouchers_read
    premium_inventory_manager.rights << stock_issue_vouchers_update
    premium_inventory_manager.rights << stock_issue_vouchers_delete
 
    #enterprise_inventory_manager 
    enterprise_inventory_manager.rights << stock_issue_vouchers_create
    enterprise_inventory_manager.rights << stock_issue_vouchers_read
    enterprise_inventory_manager.rights << stock_issue_vouchers_update
    enterprise_inventory_manager.rights << stock_issue_vouchers_delete
 

  # STOCK RECEIPT VOUCHERS
    stock_receipt_vouchers_create = Right.find_by_resource_and_operation('stock_receipt_vouchers','CREATE')
    stock_receipt_vouchers_read = Right.find_by_resource_and_operation('stock_receipt_vouchers','READ')
    stock_receipt_vouchers_update = Right.find_by_resource_and_operation('stock_receipt_vouchers','UPDATE')
    stock_receipt_vouchers_delete = Right.find_by_resource_and_operation('stock_receipt_vouchers','DELETE')

  #basic_inventory_manager  
    basic_inventory_manager.rights << stock_receipt_vouchers_create
    basic_inventory_manager.rights << stock_receipt_vouchers_read
    basic_inventory_manager.rights << stock_receipt_vouchers_update
    basic_inventory_manager.rights << stock_receipt_vouchers_delete
    #premium_inventory_manager  
    premium_inventory_manager.rights << stock_receipt_vouchers_create
    premium_inventory_manager.rights << stock_receipt_vouchers_read
    premium_inventory_manager.rights << stock_receipt_vouchers_update
    premium_inventory_manager.rights << stock_receipt_vouchers_delete
 
    #enterprise_inventory_manager 
    enterprise_inventory_manager.rights << stock_receipt_vouchers_create
    enterprise_inventory_manager.rights << stock_receipt_vouchers_read
    enterprise_inventory_manager.rights << stock_receipt_vouchers_update
    enterprise_inventory_manager.rights << stock_receipt_vouchers_delete

# STOCK WASTAGE VOUCHERS
    stock_wastage_vouchers_create = Right.find_by_resource_and_operation('stock_wastage_vouchers','CREATE')
    stock_wastage_vouchers_read = Right.find_by_resource_and_operation('stock_wastage_vouchers','READ')
    stock_wastage_vouchers_update = Right.find_by_resource_and_operation('stock_wastage_vouchers','UPDATE')
    stock_wastage_vouchers_delete = Right.find_by_resource_and_operation('stock_wastage_vouchers','DELETE')

  #basic_inventory_manager  
    basic_inventory_manager.rights << stock_wastage_vouchers_create
    basic_inventory_manager.rights << stock_wastage_vouchers_read
    basic_inventory_manager.rights << stock_wastage_vouchers_update
    basic_inventory_manager.rights << stock_wastage_vouchers_delete
    #premium_inventory_manager  
    premium_inventory_manager.rights << stock_wastage_vouchers_create
    premium_inventory_manager.rights << stock_wastage_vouchers_read
    premium_inventory_manager.rights << stock_wastage_vouchers_update
    premium_inventory_manager.rights << stock_wastage_vouchers_delete
 
    #enterprise_inventory_manager 
    enterprise_inventory_manager.rights << stock_wastage_vouchers_create
    enterprise_inventory_manager.rights << stock_wastage_vouchers_read
    enterprise_inventory_manager.rights << stock_wastage_vouchers_update
    enterprise_inventory_manager.rights << stock_wastage_vouchers_delete

# stock wastage r register
     # stock_wastage_register_read = Right.create!(:resource => 'stock_wastage_register', :operation => 'READ') 
      stock_wastage_register_read = Right.find_by_resource_and_operation('stock_wastage_register', 'READ')

    #basic_inventory_manager  
     basic_inventory_manager.rights << stock_wastage_register_read
     #premium_inventory_manager  
     premium_inventory_manager.rights << stock_wastage_register_read
     #enterprise_inventory_manager 
     enterprise_inventory_manager.rights << stock_wastage_register_read
  

 #low stock  register
     # low_stock_read = Right.create!(:resource => 'low_stock', :operation => 'READ') 
      low_stock_read = Right.find_by_resource_and_operation('low_stock', 'READ')

    #basic_inventory_manager  
     basic_inventory_manager.rights << low_stock_read
     #premium_inventory_manager  
     premium_inventory_manager.rights << low_stock_read
     #enterprise_inventory_manager 
     enterprise_inventory_manager.rights << low_stock_read
    



#Payroll rights
  #payroll_dashboard
  payroll_dashboard_read = Right.find_by_resource_and_operation('payroll_dashboard','READ')  

  basic_inventory_manager.rights << payroll_dashboard_read
  premium_inventory_manager.rights << payroll_dashboard_read
  enterprise_inventory_manager.rights << payroll_dashboard_read

  #Task
     tasks_create = Right.find_by_resource_and_operation('tasks','CREATE')  
     tasks_read = Right.find_by_resource_and_operation('tasks','READ')  
     tasks_delete = Right.find_by_resource_and_operation('tasks','DELETE')  
     tasks_update = Right.find_by_resource_and_operation('tasks','UPDATE') 

     #premium inventory manager
     premium_inventory_manager.rights << tasks_create
     premium_inventory_manager.rights << tasks_read
     premium_inventory_manager.rights << tasks_update
     premium_inventory_manager.rights << tasks_delete

     #enterprise Inventory manager
     enterprise_inventory_manager.rights << tasks_create
     enterprise_inventory_manager.rights << tasks_read
     enterprise_inventory_manager.rights << tasks_update
     enterprise_inventory_manager.rights << tasks_delete

    #Messages 
     messages_create = Right.find_by_resource_and_operation('messages','CREATE')  
     messages_read = Right.find_by_resource_and_operation('messages','READ')  
     messages_delete = Right.find_by_resource_and_operation('messages','DELETE')  
     messages_update = Right.find_by_resource_and_operation('messages','UPDATE')  
    
    #premium inv manager
     premium_inventory_manager.rights << messages_create
     premium_inventory_manager.rights << messages_read
     premium_inventory_manager.rights << messages_update
     premium_inventory_manager.rights << messages_delete
     #enterprise inv manager
     enterprise_inventory_manager.rights << messages_create
     enterprise_inventory_manager.rights << messages_read
     enterprise_inventory_manager.rights << messages_update
     enterprise_inventory_manager.rights << messages_delete
   
    #Documents
     documents_create = Right.find_by_resource_and_operation('documents','CREATE')  
     documents_read = Right.find_by_resource_and_operation('documents','READ')  
     documents_delete = Right.find_by_resource_and_operation('documents','DELETE')  
     documents_update = Right.find_by_resource_and_operation('documents','UPDATE')  
    
    #premium_inventory_manager
     premium_inventory_manager.rights << documents_create
     premium_inventory_manager.rights << documents_read
     premium_inventory_manager.rights << documents_update
     premium_inventory_manager.rights << documents_delete
    
    #enterprise_inventory_manager
     enterprise_inventory_manager.rights << documents_create
     enterprise_inventory_manager.rights << documents_read
     enterprise_inventory_manager.rights << documents_update
     enterprise_inventory_manager.rights << documents_delete

   #Notes
     notes_create = Right.find_by_resource_and_operation('notes','CREATE')  
     notes_read = Right.find_by_resource_and_operation('notes','READ')  
     notes_delete = Right.find_by_resource_and_operation('notes','DELETE')  
     notes_update = Right.find_by_resource_and_operation('notes','UPDATE')  

    #premium_inventory_manager
      premium_inventory_manager.rights << notes_create
      premium_inventory_manager.rights << notes_read
      premium_inventory_manager.rights << notes_update
      premium_inventory_manager.rights << notes_delete

    #enterprise_inventory_manager
      enterprise_inventory_manager.rights << notes_create
      enterprise_inventory_manager.rights << notes_read
      enterprise_inventory_manager.rights << notes_update
      enterprise_inventory_manager.rights << notes_delete
    
    #users
     users_read = Right.find_by_resource_and_operation('users','READ')  
     users_update = Right.find_by_resource_and_operation('users','UPDATE')  
  
    #premium_inventory_manager
     premium_inventory_manager.rights << users_read
     premium_inventory_manager.rights << users_update
    
    #enterprise_inventory_manager
     enterprise_inventory_manager.rights << users_read
     enterprise_inventory_manager.rights << users_update

     #Assets
     assets_read = Right.find_by_resource_and_operation('assets','READ')  
     #premium_inventory_manager
     premium_inventory_manager.rights << assets_read
     #enterprise_inventory_manager
     enterprise_inventory_manager.rights << assets_read
    
    #Department
    departments_read = Right.find_by_resource_and_operation('departments','READ')  
    #premium_inventory_manager
    premium_inventory_manager.rights << departments_read
    #enterprise_inventory_manager
    enterprise_inventory_manager.rights << departments_read
   
   #3)DESIGNATIONS
     designations_read = Right.find_by_resource_and_operation('designations','READ')  
    #premium_inventory_manager
    premium_inventory_manager.rights << designations_read
    #enterprise_inventory_manager
    enterprise_inventory_manager.rights << designations_read

#4)HOLIDAY
     holidays_read = Right.find_by_resource_and_operation('holidays','READ')  
     #premium_inventory_manager
     premium_inventory_manager.rights << holidays_read
     #enterprise_inventory_manager
     enterprise_inventory_manager.rights << holidays_read


#5)LEAVE TYPES
     leave_types_read = Right.find_by_resource_and_operation('leave_types','READ')  
     #premium_inventory_manager
     premium_inventory_manager.rights << leave_types_read
     #enterprise_inventory_manager
     enterprise_inventory_manager.rights << leave_types_read

#6)ORGANISATION ANNOUNCEMENT
     organisation_announcements_read = Right.find_by_resource_and_operation('organisation_announcements','READ')  
     #premium_inventory_manager
     premium_inventory_manager.rights << organisation_announcements_read
     #enterprise_inventory_manager
     enterprise_inventory_manager.rights << organisation_announcements_read

#7)MANAGE SALARY STRUCTURE
     salary_structures_read = Right.find_by_resource_and_operation('salary_structures','READ')
   #premium_inventory_manager
    premium_inventory_manager.rights << salary_structures_read
    #enterprise_inventory_manager
    enterprise_inventory_manager.rights << salary_structures_read


#9)LEAVE REQUESTS
     leave_requests_create = Right.find_by_resource_and_operation('leave_requests','CREATE')
     leave_requests_read = Right.find_by_resource_and_operation('leave_requests','READ')
     leave_requests_update = Right.find_by_resource_and_operation('leave_requests','UPDATE')
      #premium_inventory_manager
      premium_inventory_manager.rights << leave_requests_create
      premium_inventory_manager.rights << leave_requests_read
      premium_inventory_manager.rights << leave_requests_update

      #enterprise_inventory_manager
      enterprise_inventory_manager.rights << leave_requests_create
      enterprise_inventory_manager.rights << leave_requests_read
      enterprise_inventory_manager.rights << leave_requests_update

#10)BOOK TIME
     timesheets_create = Right.find_by_resource_and_operation('timesheets','CREATE')
     timesheets_read = Right.find_by_resource_and_operation('timesheets','READ')
     timesheets_delete = Right.find_by_resource_and_operation('timesheets','DELETE')
     timesheets_update = Right.find_by_resource_and_operation('timesheets','UPDATE')
      #premium_inventory_manager
      premium_inventory_manager.rights << timesheets_create
      premium_inventory_manager.rights << timesheets_read
      premium_inventory_manager.rights << timesheets_update
      premium_inventory_manager.rights << timesheets_delete

      #enterprise_inventory_manager
      enterprise_inventory_manager.rights << timesheets_create
      enterprise_inventory_manager.rights << timesheets_read
      enterprise_inventory_manager.rights << timesheets_update
      enterprise_inventory_manager.rights << timesheets_delete


#11)POLICY DOCUMENTS
     policy_documents_read = Right.find_by_resource_and_operation('policy_documents','READ')

     #premium_inventory_manager
     premium_inventory_manager.rights << policy_documents_read
     #enterprise_inventory_manager
     enterprise_inventory_manager.rights << policy_documents_read

#12)FOLDERS
     folders_create = Right.find_by_resource_and_operation('folders','CREATE')
     folders_read = Right.find_by_resource_and_operation('folders','READ')
     folders_delete = Right.find_by_resource_and_operation('folders','DELETE')
     folders_update = Right.find_by_resource_and_operation('folders','UPDATE')

      #premium_inventory_manager
      premium_inventory_manager.rights << folders_create
      premium_inventory_manager.rights << folders_read
      premium_inventory_manager.rights << folders_update
      premium_inventory_manager.rights << folders_delete

      #enterprise_inventory_manager
      enterprise_inventory_manager.rights << folders_create
      enterprise_inventory_manager.rights << folders_read
      enterprise_inventory_manager.rights << folders_update
      enterprise_inventory_manager.rights << folders_delete


#13)MY FILES
     myfiles_create = Right.find_by_resource_and_operation('myfiles','CREATE')
     myfiles_read = Right.find_by_resource_and_operation('myfiles','READ')
     myfiles_delete = Right.find_by_resource_and_operation('myfiles','DELETE')
     myfiles_update = Right.find_by_resource_and_operation('myfiles','UPDATE')

      #premium_inventory_manager
      premium_inventory_manager.rights << myfiles_create
      premium_inventory_manager.rights << myfiles_read
      premium_inventory_manager.rights << myfiles_update
      premium_inventory_manager.rights << myfiles_delete

      #enterprise_inventory_manager
      enterprise_inventory_manager.rights << myfiles_create
      enterprise_inventory_manager.rights << myfiles_read
      enterprise_inventory_manager.rights << myfiles_update
      enterprise_inventory_manager.rights << myfiles_delete


# Support
    supports_create = Right.find_by_resource_and_operation('supports','CREATE')
    supports_read = Right.find_by_resource_and_operation('supports','READ')
    supports_delete = Right.find_by_resource_and_operation('supports','DELETE')
    supports_update = Right.find_by_resource_and_operation('supports','UPDATE')

   #premium_inventory_manager
    premium_inventory_manager.rights << supports_create
    premium_inventory_manager.rights << supports_read
    premium_inventory_manager.rights << supports_update
    premium_inventory_manager.rights << supports_delete
   
    #enterprise_inventory_manager
    enterprise_inventory_manager.rights << supports_create
    enterprise_inventory_manager.rights << supports_read
    enterprise_inventory_manager.rights << supports_update
    enterprise_inventory_manager.rights << supports_delete
   


# Feedback
   feedbacks_create = Right.find_by_resource_and_operation('feedbacks','CREATE')
   feedbacks_read = Right.find_by_resource_and_operation('feedbacks','READ')
   feedbacks_delete = Right.find_by_resource_and_operation('feedbacks','DELETE')
   feedbacks_update = Right.find_by_resource_and_operation('feedbacks','UPDATE')
   
   
    #premium_inventory_manager
    premium_inventory_manager.rights << feedbacks_create
    premium_inventory_manager.rights << feedbacks_read
    premium_inventory_manager.rights << feedbacks_update
    premium_inventory_manager.rights << feedbacks_delete
  
    #enterprise_inventory_manager
    enterprise_inventory_manager.rights << feedbacks_create
    enterprise_inventory_manager.rights << feedbacks_read
    enterprise_inventory_manager.rights << feedbacks_update
    enterprise_inventory_manager.rights << feedbacks_delete
  
 
# Salary slip
  salary_slip_read = Right.find_by_resource_and_operation('salary_slip','READ')

 #premium_inventory_manager
  premium_inventory_manager.rights << salary_slip_read
 
  enterprise_inventory_manager.rights << salary_slip_read
   

#Dropbox (DB) rights

     db_read = Right.find_by_resource_and_operation('db','READ')
   #premium_inventory_manager
    premium_inventory_manager.rights << db_read
   #enterprise_inventory_manager
    enterprise_inventory_manager.rights << db_read

 #My organisation rights
  my_organisation_create = Right.find_by_resource_and_operation('my_organisation', 'CREATE')   
  my_organisation_read = Right.find_by_resource_and_operation('my_organisation', 'READ')
  my_organisation_update = Right.find_by_resource_and_operation('my_organisation', 'UPDATE')
  my_organisation_delete = Right.find_by_resource_and_operation('my_organisation', 'DELETE')

 #   premium_inventory_manager
    premium_inventory_manager.rights << my_organisation_read
 #  enterprise_inventory_manager
    enterprise_inventory_manager.rights << my_organisation_read

end
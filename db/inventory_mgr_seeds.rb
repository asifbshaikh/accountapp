ActiveRecord::Base.transaction do
  # trial_plan = Plan.create(:name => 'Trial',:price => 0,
  #   :description => 'Trial plan with multi user accounting, inventory managment, branches, payroll managment and dummy data for all vouchers.',
  #   :display_name => 'Trial', :user_count => 3, :storage_limit_mb => 1073741824)
  # #Roles for trail plan
  # trial_owner = Role.create!(:name => 'Owner')
  # trial_plan.roles << trial_owner
  # trial_accountant = Role.create!(:name => 'Accountant')
  # trial_plan.roles << trial_accountant
  # trial_staff = Role.create!(:name => 'Staff')
  # trial_plan.roles << trial_staff
  # trial_auditor = Role.create!(:name => 'Auditor')
  # trial_plan.roles << trial_auditor
  # trial_employee = Role.create!(:name => 'Employee')
  # trial_plan.roles << trial_employee
  # trial_inventory_manager = Role.create!(:name => 'Inventory Manager')
  # trial_plan.roles << trial_inventory_manager

  trial_plan = Plan.find_by_name('Trial')
  #Roles for trail plan
  trial_owner = Role.find_by_name_and_plan_id('Owner', trial_plan.id)
  trial_accountant = Role.find_by_name_and_plan_id('Accountant', trial_plan.id)
  trial_staff = Role.find_by_name_and_plan_id('Staff', trial_plan.id)
  trial_auditor = Role.find_by_name_and_plan_id('Auditor', trial_plan.id)
  trial_employee = Role.find_by_name_and_plan_id('Employee', trial_plan.id)
  trial_inventory_manager = Role.find_by_name_and_plan_id('Inventory Manager', trial_plan.id)

    # Dashboard rights
    dashboard_read = Right.find_by_resource_and_operation('dashboard','READ')  
    
      #trial_owner 
      # trial_owner.rights << dashboard_read
      # #trial_accountant
      # trial_accountant.rights << dashboard_read
      # #trial_staff
      # trial_staff.rights << dashboard_read
      # #trial_auditor
      # trial_auditor.rights << dashboard_read 
     trial_inventory_manager.rights << dashboard_read
     # free_owner.rights << tasks_delete
 #      tasks_create = Right.find_by_resource_and_operation( 'tasks',  'CREATE')
 #      tasks_read = Right.find_by_resource_and_operation( 'tasks',  'READ') 
 #      tasks_delete = Right.find_by_resource_and_operation( 'tasks',  'DELETE')
 #      tasks_update = Right.find_by_resource_and_operation( 'tasks',  'UPDATE')
     
 #    #trial_owner  
 #      trial_owner.rights << tasks_create
 #      trial_owner.rights << tasks_read
 #      trial_owner.rights << tasks_update
 #      trial_owner.rights << tasks_delete
 #      #basic_accountant
 #      trial_accountant.rights << tasks_create
 #      trial_accountant.rights << tasks_read
 #      trial_accountant.rights << tasks_update
 #      trial_accountant.rights << tasks_delete
 #      #trial_staff
 #      trial_staff.rights << tasks_create
 #      trial_staff.rights << tasks_read
 #      trial_staff.rights << tasks_update
 #      trial_staff.rights << tasks_delete
 #      #trial_auditor
 #      trial_auditor.rights << tasks_read 
 #      #trial_employee
 #      trial_employee.rights << tasks_create
 #      trial_employee.rights << tasks_read
 #      trial_employee.rights << tasks_update
 #      trial_employee.rights << tasks_delete

 #      #trial_inventory_manager
 #      trial_inventory_manager.rights << tasks_create
 #      trial_inventory_manager.rights << tasks_read
 #      trial_inventory_manager.rights << tasks_update
 #      trial_inventory_manager.rights << tasks_delete

    
 #      #messages_update = Right.create!(:resource => 'messages', :operation => 'UPDATE')
 #      messages_create = Right.find_by_resource_and_operation( 'messages',  'CREATE')
 #      messages_read = Right.find_by_resource_and_operation( 'messages',  'READ') 
 #      messages_delete = Right.find_by_resource_and_operation( 'messages',  'DELETE')
 #      messages_update = Right.find_by_resource_and_operation( 'messages',  'UPDATE')
      
 #      #trial_owner  
 #      trial_owner.rights << messages_create
 #      trial_owner.rights << messages_read
 #      trial_owner.rights << messages_update
 #      trial_owner.rights << messages_delete
 #      #trial_accountant
 #      trial_accountant.rights << messages_create
 #      trial_accountant.rights << messages_read
 #      trial_accountant.rights << messages_update
 #      trial_accountant.rights << messages_delete
 #      #trial_staff
 #      trial_staff.rights << messages_create
 #      trial_staff.rights << messages_read
 #      trial_staff.rights << messages_update
 #      trial_staff.rights << messages_delete
 #      #trial_auditor
 #      trial_auditor.rights << messages_read
 #      #trial_employee
 #      trial_employee.rights << messages_create
 #      trial_employee.rights << messages_read
 #      trial_employee.rights << messages_update
 #      trial_employee.rights << messages_delete
 #      #trial inv manager
 #      trial_inventory_manager.rights << messages_create
 #      trial_inventory_manager.rights << messages_read
 #      trial_inventory_manager.rights << messages_update
 #      trial_inventory_manager.rights << messages_delete

 #      #free_owner.rights << documents_delete
 #      documents_create = Right.find_by_resource_and_operation( 'documents',  'CREATE')
 #      documents_read = Right.find_by_resource_and_operation( 'documents',  'READ') 
 #      documents_delete = Right.find_by_resource_and_operation( 'documents',  'DELETE')
 #      documents_update = Right.find_by_resource_and_operation( 'documents',  'UPDATE')
      
 #       #trial_owner 
 #       trial_owner.rights << documents_create
 #       trial_owner.rights << documents_read
 #       trial_owner.rights << documents_update
 #       trial_owner.rights << documents_delete
 #      #trial_accountant
 #       trial_accountant.rights << documents_create
 #       trial_accountant.rights << documents_read
 #       trial_accountant.rights << documents_update
 #       trial_accountant.rights << documents_delete
 #       #trial_staff
 #       trial_staff.rights << documents_create
 #       trial_staff.rights << documents_read
 #       trial_staff.rights << documents_update
 #       trial_staff.rights << documents_delete
 #       #trial_auditor
 #       trial_auditor.rights << documents_read
 #       #trial_employee
 #        trial_employee.rights << documents_create
 #        trial_employee.rights << documents_read
 #        trial_employee.rights << documents_update
 #        trial_employee.rights << documents_delete

 #        #trial_inventory_manager
 #        trial_inventory_manager.rights << documents_create
 #        trial_inventory_manager.rights << documents_read
 #        trial_inventory_manager.rights << documents_update
 #        trial_inventory_manager.rights << documents_delete
    
 #      notes_create = Right.find_by_resource_and_operation( 'notes',  'CREATE')
 #      notes_read = Right.find_by_resource_and_operation( 'notes',  'READ') 
 #      notes_delete = Right.find_by_resource_and_operation( 'notes',  'DELETE')
 #      notes_update = Right.find_by_resource_and_operation( 'notes',  'UPDATE')

 #      #trial_owner  
 #       trial_owner.rights << notes_create
 #       trial_owner.rights << notes_read
 #       trial_owner.rights << notes_update
 #       trial_owner.rights << notes_delete
 #      #trial_accountant
 #       trial_accountant.rights << notes_create
 #       trial_accountant.rights << notes_read
 #       trial_accountant.rights << notes_update
 #       trial_accountant.rights << notes_delete
 #      #trial_staff
 #       trial_staff.rights << notes_create
 #       trial_staff.rights << notes_read
 #       trial_staff.rights << notes_update
 #       trial_staff.rights << notes_delete
 #      #trial_auditor
 #       trial_auditor.rights << notes_read
 #       #trial_employee
 #      trial_employee.rights << notes_create
 #      trial_employee.rights << notes_read
 #      trial_employee.rights << notes_update
 #      trial_employee.rights << notes_delete
 #      #trial_inventory_manager
 #      trial_inventory_manager.rights << notes_create
 #      trial_inventory_manager.rights << notes_read
 #      trial_inventory_manager.rights << notes_update
 #      trial_inventory_manager.rights << notes_delete

 #      invoices_create = Right.find_by_resource_and_operation( 'invoices',  'CREATE')
 #      invoices_read = Right.find_by_resource_and_operation( 'invoices',  'READ') 
 #      invoices_delete = Right.find_by_resource_and_operation( 'invoices',  'DELETE')
 #      invoices_update = Right.find_by_resource_and_operation( 'invoices',  'UPDATE')
   
 #     #trial_owner 
 #       trial_owner.rights << invoices_create
 #       trial_owner.rights << invoices_read
 #       trial_owner.rights << invoices_update
 #       trial_owner.rights << invoices_delete
 #      #trial_accountant
 #       trial_accountant.rights << invoices_create
 #       trial_accountant.rights << invoices_read
 #       trial_accountant.rights << invoices_update
 #       trial_accountant.rights << invoices_delete
 #      #trial_staff
 #       trial_staff.rights << invoices_create
 #       trial_staff.rights << invoices_read
 #       trial_staff.rights << invoices_update
 #       trial_staff.rights << invoices_delete
 #      #trial_auditor
 #       trial_auditor.rights << invoices_read
 #      receipt_vouchers_create = Right.find_by_resource_and_operation( 'receipt_vouchers',  'CREATE')
 #      receipt_vouchers_read = Right.find_by_resource_and_operation( 'receipt_vouchers',  'READ') 
 #      receipt_vouchers_delete = Right.find_by_resource_and_operation( 'receipt_vouchers',  'DELETE')
 #      receipt_vouchers_update = Right.find_by_resource_and_operation( 'receipt_vouchers',  'UPDATE')
     
 #     #trial_owner 
 #       trial_owner.rights << receipt_vouchers_create
 #       trial_owner.rights << receipt_vouchers_read
 #       trial_owner.rights << receipt_vouchers_update
 #       trial_owner.rights << receipt_vouchers_delete
 #      #trial_accountant
 #       trial_accountant.rights << receipt_vouchers_create
 #       trial_accountant.rights << receipt_vouchers_read
 #       trial_accountant.rights << receipt_vouchers_update
 #       trial_accountant.rights << receipt_vouchers_delete
 #      #trial_staff
 #       trial_staff.rights << receipt_vouchers_create
 #       trial_staff.rights << receipt_vouchers_read
 #       trial_staff.rights << receipt_vouchers_update
 #       trial_staff.rights << receipt_vouchers_delete
 #      #trial_auditor
 #      trial_auditor.rights << receipt_vouchers_read


 #      estimates_create = Right.find_by_resource_and_operation( 'estimates',  'CREATE')
 #      estimates_read = Right.find_by_resource_and_operation( 'estimates',  'READ') 
 #      estimates_delete = Right.find_by_resource_and_operation( 'estimates',  'DELETE')
 #      estimates_update = Right.find_by_resource_and_operation( 'estimates',  'UPDATE')
      
 #   #trial_owner 
 #       trial_owner.rights << estimates_create
 #       trial_owner.rights << estimates_read
 #       trial_owner.rights << estimates_update
 #       trial_owner.rights << estimates_delete
 #      #trial_accountant
 #       trial_accountant.rights << estimates_create
 #       trial_accountant.rights << estimates_read
 #       trial_accountant.rights << estimates_update
 #       trial_accountant.rights << estimates_delete
 #      #trial_staff
 #       trial_staff.rights << estimates_create
 #       trial_staff.rights << estimates_read
 #       trial_staff.rights << estimates_update
 #       trial_staff.rights << estimates_delete
 #      #trial_auditor
 #       trial_auditor.rights << estimates_read


 #      income_vouchers_create = Right.find_by_resource_and_operation( 'income_vouchers',  'CREATE')
 #      income_vouchers_read = Right.find_by_resource_and_operation( 'income_vouchers',  'READ') 
 #      income_vouchers_delete = Right.find_by_resource_and_operation( 'income_vouchers',  'DELETE')
 #      income_vouchers_update = Right.find_by_resource_and_operation( 'income_vouchers',  'UPDATE')
    
 #    #trial_owner  
 #       trial_owner.rights << income_vouchers_create
 #       trial_owner.rights << income_vouchers_read
 #       trial_owner.rights << income_vouchers_update
 #       trial_owner.rights << income_vouchers_delete
 #      #trial_accountant
 #       trial_accountant.rights << income_vouchers_create
 #       trial_accountant.rights << income_vouchers_read
 #       trial_accountant.rights << income_vouchers_update
 #       trial_accountant.rights << income_vouchers_delete
 #      #trial_staff
 #       trial_staff.rights << income_vouchers_create
 #       trial_staff.rights << income_vouchers_read
 #       trial_staff.rights << income_vouchers_update
 #       trial_staff.rights << income_vouchers_delete
 #      #trial_auditor
 #       trial_auditor.rights << income_vouchers_read

 #      expenses_create = Right.find_by_resource_and_operation( 'expenses',  'CREATE')
 #      expenses_read = Right.find_by_resource_and_operation( 'expenses',  'READ') 
 #      expenses_delete = Right.find_by_resource_and_operation( 'expenses',  'DELETE')
 #      expenses_update = Right.find_by_resource_and_operation( 'expenses',  'UPDATE')

 #     #trial_owner 
 #       trial_owner.rights << expenses_create
 #       trial_owner.rights << expenses_read
 #       trial_owner.rights << expenses_update
 #       trial_owner.rights << expenses_delete
 #     #trial_accountant
 #       trial_accountant.rights << expenses_create
 #       trial_accountant.rights << expenses_read
 #       trial_accountant.rights << expenses_update
 #       trial_accountant.rights << expenses_delete
 #     #trial_staff
 #       trial_staff.rights << expenses_create
 #       trial_staff.rights << expenses_read
 #       trial_staff.rights << expenses_update
 #       trial_staff.rights << expenses_delete
 #     #trial_auditor
 #       trial_auditor.rights << expenses_read#

 #      purchases_create = Right.find_by_resource_and_operation( 'purchases',  'CREATE')
 #      purchases_read = Right.find_by_resource_and_operation( 'purchases',  'READ') 
 #      purchases_delete = Right.find_by_resource_and_operation( 'purchases',  'DELETE')
 #      purchases_update = Right.find_by_resource_and_operation( 'purchases',  'UPDATE')
    
 #      #trial_owner  
 #       trial_owner.rights << purchases_create
 #       trial_owner.rights << purchases_read
 #       trial_owner.rights << purchases_update
 #       trial_owner.rights << purchases_delete
 #      #trial_accountant
 #       trial_accountant.rights << purchases_create
 #       trial_accountant.rights << purchases_read
 #       trial_accountant.rights << purchases_update
 #       trial_accountant.rights << purchases_delete
 #      #trial_staff
 #       trial_staff.rights << purchases_create
 #       trial_staff.rights << purchases_read
 #       trial_staff.rights << purchases_update
 #       trial_staff.rights << purchases_delete
 #      #trial_auditor
 #      trial_auditor.rights << purchases_read



 #      purchase_orders_create = Right.find_by_resource_and_operation( 'purchase_orders',  'CREATE')
 #      purchase_orders_read = Right.find_by_resource_and_operation( 'purchase_orders',  'READ') 
 #      purchase_orders_delete = Right.find_by_resource_and_operation( 'purchase_orders',  'DELETE')
 #      purchase_orders_update = Right.find_by_resource_and_operation( 'purchase_orders',  'UPDATE')
     
 #    #trial_owner  
 #       trial_owner.rights << purchase_orders_create
 #       trial_owner.rights << purchase_orders_read
 #       trial_owner.rights << purchase_orders_update
 #       trial_owner.rights << purchase_orders_delete
 #      #trial_accountant
 #       trial_accountant.rights << purchase_orders_create
 #       trial_accountant.rights << purchase_orders_read
 #       trial_accountant.rights << purchase_orders_update
 #       trial_accountant.rights << purchase_orders_delete
 #      #trial_staff
 #       trial_staff.rights << purchase_orders_create
 #       trial_staff.rights << purchase_orders_read
 #       trial_staff.rights << purchase_orders_update
 #       trial_staff.rights << purchase_orders_delete
 #      #trial_auditor
 #       trial_auditor.rights << purchase_orders_read



 #      payment_vouchers_create = Right.find_by_resource_and_operation( 'payment_vouchers',  'CREATE')
 #      payment_vouchers_read = Right.find_by_resource_and_operation( 'payment_vouchers',  'READ') 
 #      payment_vouchers_delete = Right.find_by_resource_and_operation( 'payment_vouchers',  'DELETE')
 #      payment_vouchers_update = Right.find_by_resource_and_operation( 'payment_vouchers',  'UPDATE')

 #   #trial_owner 
 #       trial_owner.rights << payment_vouchers_create
 #       trial_owner.rights << payment_vouchers_read
 #       trial_owner.rights << payment_vouchers_update
 #       trial_owner.rights << payment_vouchers_delete
 #      #trial_accountant
 #      trial_accountant.rights << payment_vouchers_create
 #      trial_accountant.rights << payment_vouchers_read
 #      trial_accountant.rights << payment_vouchers_update
 #      trial_accountant.rights << payment_vouchers_delete
 #      #trial_staff
 #      trial_staff.rights << payment_vouchers_create
 #      trial_staff.rights << payment_vouchers_read
 #      trial_staff.rights << payment_vouchers_update
 #      trial_staff.rights << payment_vouchers_delete
 #      # trial_auditor
 #      trial_auditor.rights << payment_vouchers_read


 #      withdrawals_create = Right.find_by_resource_and_operation( 'withdrawals',  'CREATE')
 #      withdrawals_read = Right.find_by_resource_and_operation( 'withdrawals',  'READ') 
 #      withdrawals_delete = Right.find_by_resource_and_operation( 'withdrawals',  'DELETE')
 #      withdrawals_update = Right.find_by_resource_and_operation( 'withdrawals',  'UPDATE')
     
 #   #trial_owner 
 #     trial_owner.rights << withdrawals_create
 #     trial_owner.rights << withdrawals_read
 #     trial_owner.rights << withdrawals_update
 #     trial_owner.rights << withdrawals_delete
 #      #trial_accountant
 #     trial_accountant.rights << withdrawals_create
 #     trial_accountant.rights << withdrawals_read
 #     trial_accountant.rights << withdrawals_update
 #     trial_accountant.rights << withdrawals_delete
 #      #trial_staff
 #     trial_staff.rights << withdrawals_create
 #     trial_staff.rights << withdrawals_read
 #     trial_staff.rights << withdrawals_update
 #     trial_staff.rights << withdrawals_delete
 #      #trial_auditor
 #     trial_auditor.rights << withdrawals_read


 #      deposits_create = Right.find_by_resource_and_operation( 'deposits',  'CREATE')
 #      deposits_read = Right.find_by_resource_and_operation( 'deposits',  'READ') 
 #      deposits_delete = Right.find_by_resource_and_operation( 'deposits',  'DELETE')
 #      deposits_update = Right.find_by_resource_and_operation( 'deposits',  'UPDATE')
    
 #    #trial_owner  
 #     trial_owner.rights << deposits_create
 #     trial_owner.rights << deposits_read
 #     trial_owner.rights << deposits_update
 #     trial_owner.rights << deposits_delete
 #      #trial_accountant
 #     trial_accountant.rights << deposits_create
 #     trial_accountant.rights << deposits_read
 #     trial_accountant.rights << deposits_update
 #     trial_accountant.rights << deposits_delete
 #      #trial_staff
 #     trial_staff.rights << deposits_create
 #     trial_staff.rights << deposits_read
 #     trial_staff.rights << deposits_update
 #     trial_staff.rights << deposits_delete
 #      #trial_auditor
 #     trial_auditor.rights << deposits_read


 #      transfer_cashes_create = Right.find_by_resource_and_operation( 'transfer_cashes',  'CREATE')
 #      transfer_cashes_read = Right.find_by_resource_and_operation( 'transfer_cashes',  'READ') 
 #      transfer_cashes_delete = Right.find_by_resource_and_operation( 'transfer_cashes',  'DELETE')
 #      transfer_cashes_update = Right.find_by_resource_and_operation( 'transfer_cashes',  'UPDATE')
     
 #    #trial_owner  
 #      trial_owner.rights << transfer_cashes_create
 #      trial_owner.rights << transfer_cashes_read
 #      trial_owner.rights << transfer_cashes_update
 #      trial_owner.rights << transfer_cashes_delete
 #      #trial_accountant
 #      trial_accountant.rights << transfer_cashes_create
 #      trial_accountant.rights << transfer_cashes_read
 #      trial_accountant.rights << transfer_cashes_update
 #      trial_accountant.rights << transfer_cashes_delete
 #      #trial_staff
 #      trial_staff.rights << transfer_cashes_create
 #      trial_staff.rights << transfer_cashes_read
 #      trial_staff.rights << transfer_cashes_update
 #      trial_staff.rights << transfer_cashes_delete
 #      #trial_auditor
 #      trial_auditor.rights << transfer_cashes_read



 #      journals_create = Right.find_by_resource_and_operation( 'journals',  'CREATE')
 #      journals_read = Right.find_by_resource_and_operation( 'journals',  'READ') 
 #      journals_delete = Right.find_by_resource_and_operation( 'journals',  'DELETE')
 #      journals_update = Right.find_by_resource_and_operation( 'journals',  'UPDATE')
    
 #   #trial_owner 
 #     trial_owner.rights << journals_create
 #     trial_owner.rights << journals_read
 #     trial_owner.rights << journals_update
 #     trial_owner.rights << journals_delete
 #      #trial_accountant
 #     trial_accountant.rights << journals_create
 #     trial_accountant.rights << journals_read
 #     trial_accountant.rights << journals_update
 #     trial_accountant.rights << journals_delete
 #      #trial_staff
 #     trial_staff.rights << journals_create
 #     trial_staff.rights << journals_read
 #     trial_staff.rights << journals_update
 #     trial_staff.rights << journals_delete
 #      #trial_auditor
 #      trial_auditor.rights << journals_read


 #      debit_notes_create = Right.find_by_resource_and_operation( 'debit_notes',  'CREATE')
 #      debit_notes_read = Right.find_by_resource_and_operation( 'debit_notes',  'READ') 
 #      debit_notes_delete = Right.find_by_resource_and_operation( 'debit_notes',  'DELETE')
 #      debit_notes_update = Right.find_by_resource_and_operation( 'debit_notes',  'UPDATE')
    
 #   #trial_owner 
 #      trial_owner.rights << debit_notes_create
 #      trial_owner.rights << debit_notes_read
 #      trial_owner.rights << debit_notes_update
 #      trial_owner.rights << debit_notes_delete
 #      #trial_accountant
 #      trial_accountant.rights << debit_notes_create
 #      trial_accountant.rights << debit_notes_read
 #      trial_accountant.rights << debit_notes_update
 #      trial_accountant.rights << debit_notes_delete
 #      #trial_staff
 #      trial_staff.rights << debit_notes_create
 #      trial_staff.rights << debit_notes_read
 #      trial_staff.rights << debit_notes_update
 #      trial_staff.rights << debit_notes_delete
 #      #trial_auditor
 #      trial_auditor.rights << debit_notes_read


 #      credit_notes_create = Right.find_by_resource_and_operation( 'credit_notes',  'CREATE')
 #      credit_notes_read = Right.find_by_resource_and_operation( 'credit_notes',  'READ') 
 #      credit_notes_delete = Right.find_by_resource_and_operation( 'credit_notes',  'DELETE')
 #      credit_notes_update = Right.find_by_resource_and_operation( 'credit_notes',  'UPDATE')
     
 #   #trial_owner 
 #      trial_owner.rights << credit_notes_create
 #      trial_owner.rights << credit_notes_read
 #      trial_owner.rights << credit_notes_update
 #      trial_owner.rights << credit_notes_delete
 #      #trial_accountant
 #      trial_accountant.rights << credit_notes_create
 #      trial_accountant.rights << credit_notes_read
 #      trial_accountant.rights << credit_notes_update
 #      trial_accountant.rights << credit_notes_delete
 #      #trial_staff
 #      trial_staff.rights << credit_notes_create
 #      trial_staff.rights << credit_notes_read
 #      trial_staff.rights << credit_notes_update
 #      trial_staff.rights << credit_notes_delete
 #      #trial_auditor
 #       trial_auditor.rights << credit_notes_read


 #      saccountings_create = Right.find_by_resource_and_operation( 'saccountings',  'CREATE')
 #      saccountings_read = Right.find_by_resource_and_operation( 'saccountings',  'READ') 
 #      saccountings_delete = Right.find_by_resource_and_operation( 'saccountings',  'DELETE')
 #      saccountings_update = Right.find_by_resource_and_operation( 'saccountings',  'UPDATE')
    
 #   #trial_owner 
 #      trial_owner.rights << saccountings_create
 #      trial_owner.rights << saccountings_read
 #      trial_owner.rights << saccountings_update
 #      trial_owner.rights << saccountings_delete
 #      #trial_accountant
 #      trial_accountant.rights << saccountings_create
 #      trial_accountant.rights << saccountings_read
 #      trial_accountant.rights << saccountings_update
 #      trial_accountant.rights << saccountings_delete
 #      #trial_staff
 #      trial_staff.rights << saccountings_create
 #      trial_staff.rights << saccountings_read
 #      trial_staff.rights << saccountings_update
 #      trial_staff.rights << saccountings_delete
 #      #trial_auditor
 #      trial_auditor.rights << saccountings_read

 #      horizontal_balance_sheet_read = Right.find_by_resource_and_operation( 'horizontal_balance_sheet',  'READ') 

 #     #trial_owner 
 #      trial_owner.rights << horizontal_balance_sheet_read
 #      #trial_accountant
 #      trial_accountant.rights << horizontal_balance_sheet_read
 #      #trial_auditor
 #      trial_auditor.rights << horizontal_balance_sheet_read  

 #      horizontal_profit_and_loss_read = Right.find_by_resource_and_operation( 'horizontal_profit_and_loss',  'READ') 
 #    #trial_owner  
 #      trial_owner.rights << horizontal_profit_and_loss_read
 #      #trial_accountant
 #      trial_accountant.rights << horizontal_profit_and_loss_read
 #      #trial_auditor
 #      trial_auditor.rights << horizontal_profit_and_loss_read   

 #      trial_balance_read = Right.find_by_resource_and_operation( 'trial_balance',  'READ') 
      
 #    #trial_owner  
 #       trial_owner.rights << trial_balance_read
 #      #trial_accountant
 #      trial_accountant.rights << trial_balance_read
 #      #trial_auditor
 #      trial_auditor.rights << trial_balance_read    

 #      bank_book_read = Right.find_by_resource_and_operation( 'bank_book',  'READ') 
      
 #  #trial_owner  #
 #      trial_owner.rights << bank_book_read
 #      #trial_accountant
 #      trial_accountant.rights << bank_book_read
 #      #trial_auditor
 #       trial_auditor.rights << bank_book_read
 #     #basic_owner #

 #      cash_book_read = Right.find_by_resource_and_operation( 'cash_book',  'READ') 
     
 #  #trial_owner  
 #      trial_owner.rights << cash_book_read
 #      #trial_accountant
 #      trial_accountant.rights << cash_book_read
 #      #trial_auditor
 #      trial_auditor.rights << cash_book_read
    
 #      credit_note_register_read = Right.find_by_resource_and_operation( 'credit_note_register',  'READ') 
 #   #trial_owner 
 #     trial_owner.rights << credit_note_register_read
 #      #trial_accountant
 #     trial_accountant.rights << credit_note_register_read
 #      #trial_auditor
 #     trial_auditor.rights << credit_note_register_read  


 #      debit_note_register_read = Right.find_by_resource_and_operation( 'debit_note_register',  'READ') 
 #   #trial_owner 
 #      trial_owner.rights << debit_note_register_read
 #      #trial_accountant
 #      trial_accountant.rights << debit_note_register_read
 #      #trial_auditor
 #      trial_auditor.rights << debit_note_register_read
 #      journal_register_read = Right.find_by_resource_and_operation( 'journal_register',  'READ') 
 #   #trial_owner 
 #       trial_owner.rights << journal_register_read
 #      #trial_accountant
 #      trial_accountant.rights << journal_register_read
 #      #trial_auditor
 #      trial_auditor.rights << journal_register_read

 #      bills_payable_read = Right.find_by_resource_and_operation( 'bills_payable',  'READ') 
    
 #    #trial_owner  
 #      trial_owner.rights << bills_payable_read
 #      #trial_accountant
 #      trial_accountant.rights << bills_payable_read
 #      #trial_auditor
 #      trial_auditor.rights << bills_payable_read 

 #      bills_receivable_read = Right.find_by_resource_and_operation( 'bills_receivable',  'READ') 
 #    #trial_owner  
 #      trial_owner.rights << bills_receivable_read
 #      #trial_accountant
 #      trial_accountant.rights << bills_receivable_read
 #      #trial_auditor
 #      trial_auditor.rights << bills_receivable_read 

 #      purchase_register_read = Right.find_by_resource_and_operation( 'purchase_register',  'READ') 
 #      #trial_owner  
 #      trial_owner.rights << purchase_register_read
 #      #trial_accountant
 #      trial_accountant.rights << purchase_register_read
 #      #trial_auditor
 #      trial_auditor.rights << purchase_register_read 

 #      sales_register_read = Right.find_by_resource_and_operation( 'sales_register',  'READ') 
 #     #trial_owner 
 #     trial_owner.rights << sales_register_read
 #      #trial_accountant
 #     trial_accountant.rights << sales_register_read
 #      #trial_auditor
 #     trial_auditor.rights << sales_register_read  

 #      sundry_creditor_read = Right.find_by_resource_and_operation( 'sundry_creditor',  'READ') 
 #     #trial_owner 
 #      trial_owner.rights << sundry_creditor_read
 #      #trial_accountant
 #      trial_accountant.rights << sundry_creditor_read
 #      #trial_auditor
 #      trial_auditor.rights << sundry_creditor_read

 #      account_books_and_registers_read = Right.find_by_resource_and_operation( 'account_books_and_registers',  'READ') 
 #    #trial_owner  
 #    trial_owner.rights << account_books_and_registers_read
 #      #  trial_accountant
 #     trial_accountant.rights << account_books_and_registers_read
 #      #  trial_auditor
 #    trial_auditor.rights << account_books_and_registers_read  

 #      daybook_read = Right.find_by_resource_and_operation( 'daybook',  'READ') 
 #    #trial_owner  
 #     trial_owner.rights << daybook_read
 #      #trial_accountant
 #     trial_accountant.rights << daybook_read
 #      #trial_auditor
 #     trial_auditor.rights << daybook_read  

 #      workstreams_read = Right.find_by_resource_and_operation( 'workstreams',  'READ') 
 #     #trial_owner 
 #     trial_owner.rights << workstreams_read
 #      #trial_accountant
 #     trial_accountant.rights << workstreams_read
 #      #trial_auditor
 #     trial_auditor.rights << workstreams_read  

 #      accounts_create = Right.find_by_resource_and_operation( 'accounts',  'CREATE')
 #      accounts_read = Right.find_by_resource_and_operation( 'accounts',  'READ') 
 #      accounts_delete = Right.find_by_resource_and_operation( 'accounts',  'DELETE')
 #      accounts_update = Right.find_by_resource_and_operation( 'accounts',  'UPDATE')
 #      #trial_owner  
 #     trial_owner.rights << accounts_create
 #     trial_owner.rights << accounts_read
 #     trial_owner.rights << accounts_update
 #     trial_owner.rights << accounts_delete
 #      #trial_accountant
 #     trial_accountant.rights << accounts_create
 #     trial_accountant.rights << accounts_read
 #     trial_accountant.rights << accounts_update
 #     trial_accountant.rights << accounts_delete
 #      #trial_staff
 #      #trial_auditor
 #     trial_auditor.rights << accounts_read

 #      account_heads_create = Right.find_by_resource_and_operation( 'account_heads',  'CREATE')
 #      account_heads_read = Right.find_by_resource_and_operation( 'account_heads',  'READ') 
 #      account_heads_delete = Right.find_by_resource_and_operation( 'account_heads',  'DELETE')
 #      account_heads_update = Right.find_by_resource_and_operation( 'account_heads',  'UPDATE')
 #   #trial_owner 
 #  trial_owner.rights << account_heads_create
 #  trial_owner.rights << account_heads_read
 #  trial_owner.rights << account_heads_update
 #  trial_owner.rights << account_heads_delete
 #      #trial_accountant
 #  trial_accountant.rights << account_heads_create
 #  trial_accountant.rights << account_heads_read
 #  trial_accountant.rights << account_heads_update
 #  trial_accountant.rights << account_heads_delete
 #      #trial_staff
 #  trial_staff.rights << account_heads_create
 #     trial_staff.rights << account_heads_read
 #  trial_staff.rights << account_heads_update
 #  trial_staff.rights << account_heads_delete
 #      #trial_auditor
 #  trial_auditor.rights << account_heads_read   

 #      users_create = Right.find_by_resource_and_operation( 'users',  'CREATE')
 #      users_read = Right.find_by_resource_and_operation( 'users',  'READ') 
 #      users_delete = Right.find_by_resource_and_operation( 'users',  'DELETE')
 #      users_update = Right.find_by_resource_and_operation( 'users',  'UPDATE')
 #   #trial_owner 
 #  trial_owner.rights << users_create
 #  trial_owner.rights << users_read
 #  trial_owner.rights << users_update
 #  trial_owner.rights << users_delete
 #      #trial_accountant
 #  trial_accountant.rights << users_create
 #  trial_accountant.rights << users_read
 #  trial_accountant.rights << users_update
 #  trial_accountant.rights << users_delete
 #      #trial_staff
 #  trial_staff.rights << users_read
 #      #trial_auditor
 #  trial_auditor.rights << users_read  
 #  #trial_employee
 #    trial_employee.rights << users_read
 #    trial_employee.rights << users_update  
 # #trial_inventory_manager
 #  trial_inventory_manager.rights << users_read
 #  trial_inventory_manager.rights << users_update


 #      companies_create = Right.find_by_resource_and_operation( 'companies',  'CREATE')
 #      companies_read = Right.find_by_resource_and_operation( 'companies',  'READ') 
 #      companies_delete = Right.find_by_resource_and_operation( 'companies',  'DELETE')
 #      companies_update = Right.find_by_resource_and_operation( 'companies',  'UPDATE')
 #      #trial_owner  
 #    trial_owner.rights << companies_create
 #    trial_owner.rights << companies_read
 #    trial_owner.rights << companies_update
 #    trial_owner.rights << companies_delete
 #    #trial_accountant
 #    trial_accountant.rights << companies_read
 #    #trial_auditor
 #    trial_auditor.rights << companies_read
 #      settings_read = Right.find_by_resource_and_operation( 'settings',  'READ') 
 #      settings_update = Right.find_by_resource_and_operation( 'settings',  'UPDATE')
 #  #trial_owner  
 #  trial_owner.rights << settings_read
 #  trial_owner.rights << settings_update

 #      #trial_accountant
 #  trial_accountant.rights << settings_read
 #      #trial_auditor
 #  trial_auditor.rights << settings_read

 #  # Support
 #      supports_create = Right.find_by_resource_and_operation('supports',  'CREATE')
 #      supports_read = Right.find_by_resource_and_operation('supports',  'READ') 
 #      supports_delete = Right.find_by_resource_and_operation('supports',  'DELETE')
 #      supports_update = Right.find_by_resource_and_operation('supports',  'UPDATE')

     
 #    #trial_owner  
 #      trial_owner.rights << supports_create
 #      trial_owner.rights << supports_read
 #      trial_owner.rights << supports_update
 #      trial_owner.rights << supports_delete
 #      #trial_accountant
 #      trial_accountant.rights << supports_create
 #      trial_accountant.rights << supports_read
 #      trial_accountant.rights << supports_update
 #      trial_accountant.rights << supports_delete
 #      #trial_staff
 #      trial_staff.rights << supports_create
 #      trial_staff.rights << supports_read
 #      trial_staff.rights << supports_update
 #      trial_staff.rights << supports_delete
 #      #trial_employee
 #      trial_employee.rights << supports_create
 #      trial_employee.rights << supports_read
 #      trial_employee.rights << supports_update
 #      trial_employee.rights << supports_delete
 #      #trial_inventory_manager
 #      trial_inventory_manager.rights << supports_create
 #      trial_inventory_manager.rights << supports_read
 #      trial_inventory_manager.rights << supports_update
 #      trial_inventory_manager.rights << supports_delete
 #      # Feedback
 #      feedbacks_create = Right.find_by_resource_and_operation('feedbacks', 'CREATE')
 #      feedbacks_read = Right.find_by_resource_and_operation('feedbacks', 'READ') 
 #      feedbacks_delete = Right.find_by_resource_and_operation('feedbacks', 'DELETE')
 #      feedbacks_update = Right.find_by_resource_and_operation('feedbacks', 'UPDATE')
     
 #    #trial_owner  
 #      trial_owner.rights << feedbacks_create
 #      trial_owner.rights << feedbacks_read
 #      trial_owner.rights << feedbacks_update
 #      trial_owner.rights << feedbacks_delete
 #      #basic_accountant
 #      trial_accountant.rights << feedbacks_create
 #      trial_accountant.rights << feedbacks_read
 #      trial_accountant.rights << feedbacks_update
 #      trial_accountant.rights << feedbacks_delete
 #     #trial_staff
 #      trial_staff.rights << feedbacks_create
 #      trial_staff.rights << feedbacks_read
 #      trial_staff.rights << feedbacks_update
 #      trial_staff.rights << feedbacks_delete

 #      #trial_employee
 #      trial_employee.rights << feedbacks_create
 #      trial_employee.rights << feedbacks_read
 #      trial_employee.rights << feedbacks_update
 #      trial_employee.rights << feedbacks_delete
 #      #trial_inventory_manager
 #      trial_inventory_manager.rights << feedbacks_create
 #      trial_inventory_manager.rights << feedbacks_read
 #      trial_inventory_manager.rights << feedbacks_update
 #      trial_inventory_manager.rights << feedbacks_delete
 #      # Salary slip
 #      salary_slip_create = Right.find_by_resource_and_operation('salary_slip', 'CREATE')
 #      salary_slip_read = Right.find_by_resource_and_operation('salary_slip', 'READ') 
 #      salary_slip_delete = Right.find_by_resource_and_operation('salary_slip', 'DELETE')
 #      salary_slip_update = Right.find_by_resource_and_operation('salary_slip', 'UPDATE')
 #      #trial_owner  
 #      trial_owner.rights << salary_slip_create
 #      trial_owner.rights << salary_slip_read
 #      trial_owner.rights << salary_slip_update
 #      trial_owner.rights << salary_slip_delete
 #      #trial_accountant
 #      trial_accountant.rights << salary_slip_create
 #      trial_accountant.rights << salary_slip_read
 #      trial_accountant.rights << salary_slip_update
 #      trial_accountant.rights << salary_slip_delete
 #      #trial_staff
 #      trial_staff.rights << salary_slip_read
 #     #trial_auditor
 #      trial_auditor.rights << salary_slip_read
 #     #trial_employee
 #      trial_employee.rights << salary_slip_read
 #      trial_inventory_manager.rights << salary_slip_read

 #      # Payroll rights for controller 
 #      payroll_dashboard_read = Right.find_by_resource_and_operation('payroll_dashboard','READ')  

 #      #trial_owner  
 #      trial_owner.rights << payroll_dashboard_read
 #      #trial_accountant
 #      trial_accountant.rights << payroll_dashboard_read
 #      #trial_staff
 #      trial_staff.rights << payroll_dashboard_read
 #      #trial_auditor
 #      trial_auditor.rights << payroll_dashboard_read
 #      #trial_employee
 #      trial_employee.rights << payroll_dashboard_read
 #      #trial_inventory_manager
 #      trial_inventory_manager.rights << payroll_dashboard_read

 #      #Assets
 #       assets_read = Right.find_by_resource_and_operation('assets','READ') 
 #       assets_create = Right.find_by_resource_and_operation('assets','CREATE') 
 #       assets_update = Right.find_by_resource_and_operation('assets','UPDATE') 
 #       assets_delete = Right.find_by_resource_and_operation('assets','DELETE') 

 #       #trial_owner 
 #       trial_owner.rights << assets_create
 #       trial_owner.rights << assets_read
 #       trial_owner.rights << assets_update
 #       trial_owner.rights << assets_delete
 #       #trial_accountant
 #       trial_accountant.rights << assets_create
 #       trial_accountant.rights << assets_read
 #       trial_accountant.rights << assets_update
 #       #trial_staff
 #       trial_staff.rights << assets_read
 #       #trial_employee
 #       trial_employee.rights << assets_read
 #       #trial_inventory_manager
 #       trial_inventory_manager.rights << assets_read

 #       #Departments
 #        departments_read = Right.find_by_resource_and_operation('departments','READ')
 #        departments_create = Right.find_by_resource_and_operation('departments','CREATE')
 #        departments_update = Right.find_by_resource_and_operation('departments','UPDATE')
 #        departments_delete = Right.find_by_resource_and_operation('departments','DELETE')
 #        #trial_owner 
 #        trial_owner.rights << departments_create
 #        trial_owner.rights << departments_read
 #        trial_owner.rights << departments_update
 #        trial_owner.rights << departments_delete
 #        #trial_accountant
 #        trial_accountant.rights << departments_read
 #        #trial_staff
 #        trial_staff.rights << departments_read
 #        #trial_employee
 #        trial_employee.rights << departments_read
 #        #trial_inventory_manager
 #        trial_inventory_manager.rights << departments_read

 #        #Designation
 #        designations_read = Right.find_by_resource_and_operation('designations','READ')  
 #        designations_create = Right.find_by_resource_and_operation('designations','CREATE')  
 #        designations_update = Right.find_by_resource_and_operation('designations','UPDATE')  
 #        designations_delete = Right.find_by_resource_and_operation('designations','DELETE')  
 #        #trial_owner 
 #        trial_owner.rights << designations_create
 #        trial_owner.rights << designations_read
 #        trial_owner.rights << designations_update
 #        trial_owner.rights << designations_delete
 #        #trial_accountant
 #        trial_accountant.rights << designations_read
 #        #trial_staff
 #        trial_staff.rights << designations_read
 #        #trial_employee
 #        trial_employee.rights << designations_read
 #        #trial_inventory_manager
 #        trial_inventory_manager.rights << designations_read
 #        #Holidays
 #        holidays_read = Right.find_by_resource_and_operation('holidays','READ')  
 #        holidays_create = Right.find_by_resource_and_operation('holidays','CREATE')  
 #        holidays_update = Right.find_by_resource_and_operation('holidays','UPDATE')  
 #        holidays_delete = Right.find_by_resource_and_operation('holidays','DELETE')  
 #        #trial_owner 
 #        trial_owner.rights << holidays_create
 #        trial_owner.rights << holidays_read
 #        trial_owner.rights << holidays_update
 #        trial_owner.rights << holidays_delete
 #        #trial_accountant
 #        trial_accountant.rights << holidays_read
 #        #trial_staff
 #        trial_staff.rights << holidays_read
 #        #trial_auditor
 #        trial_auditor.rights << holidays_read
 #        #trial_employee
 #        trial_employee.rights << holidays_read
 #        #trial_inventory_manager
 #        trial_inventory_manager.rights << holidays_read

 #        #Organisation anounsments
 #        organisation_announcements_read = Right.find_by_resource_and_operation('organisation_announcements','READ')  
 #        organisation_announcements_create = Right.find_by_resource_and_operation('organisation_announcements','CREATE')  
 #        organisation_announcements_update = Right.find_by_resource_and_operation('organisation_announcements','UPDATE')  
 #        organisation_announcements_delete = Right.find_by_resource_and_operation('organisation_announcements','DELETE')  
 #        #trial_owner 
 #        trial_owner.rights << organisation_announcements_create
 #        trial_owner.rights << organisation_announcements_read
 #        trial_owner.rights << organisation_announcements_update
 #        trial_owner.rights << organisation_announcements_delete
 #        #trial_accountant
 #        trial_accountant.rights << organisation_announcements_read
 #        #trial_staff
 #        trial_staff.rights << organisation_announcements_read
 #        #trial_employee
 #        trial_employee.rights << organisation_announcements_read
 #        #trial_inventory_manager
 #        trial_inventory_manager.rights << organisation_announcements_read

 #        #Salary structure
 #        salary_structures_read = Right.find_by_resource_and_operation('salary_structures','READ')
 #        salary_structures_create = Right.find_by_resource_and_operation('salary_structures','CREATE')
 #        salary_structures_update = Right.find_by_resource_and_operation('salary_structures','UPDATE')
 #        salary_structures_delete = Right.find_by_resource_and_operation('salary_structures','DELETE')
 #        #trial_owner 
 #        trial_owner.rights << salary_structures_create
 #        trial_owner.rights << salary_structures_read
 #        trial_owner.rights << salary_structures_update
 #        trial_owner.rights << salary_structures_delete
 #        #trial_accountant
 #        trial_accountant.rights << salary_structures_read
 #        #trial_staff
 #        trial_staff.rights << salary_structures_read
 #        #trial_auditor
 #        trial_auditor.rights << salary_structures_read
 #       #trial_employee
 #        trial_employee.rights << salary_structures_read
 #        #trial_inventory_manager
 #        trial_inventory_manager.rights << salary_structures_read
        
 #        #Leave request
 #        leave_requests_create = Right.find_by_resource_and_operation('leave_requests','CREATE')
 #        leave_requests_read = Right.find_by_resource_and_operation('leave_requests','READ')
 #        leave_requests_update = Right.find_by_resource_and_operation('leave_requests','UPDATE')
 #        leave_requests_delete = Right.find_by_resource_and_operation('leave_requests','DELETE')
 #        #trial_owner 
 #        trial_owner.rights << leave_requests_create
 #        trial_owner.rights << leave_requests_read
 #        trial_owner.rights << leave_requests_update
 #        trial_owner.rights << leave_requests_delete
 #        #trial_accountantthe village movie
 #        trial_accountant.rights << leave_requests_create
 #        trial_accountant.rights << leave_requests_read
 #        trial_accountant.rights << leave_requests_update
 #        #trial_staff
 #        trial_staff.rights << leave_requests_create
 #        trial_staff.rights << leave_requests_read
 #        trial_staff.rights << leave_requests_update
 #        #trial_employee
 #        trial_employee.rights << leave_requests_create
 #        trial_employee.rights << leave_requests_read
 #        trial_employee.rights << leave_requests_update
 #        #trial_inventory_manager
 #        trial_inventory_manager.rights << leave_requests_create
 #        trial_inventory_manager.rights << leave_requests_read
 #        trial_inventory_manager.rights << leave_requests_update

 #        #Timesheets
 #        timesheets_create = Right.find_by_resource_and_operation('timesheets','CREATE')
 #        timesheets_read = Right.find_by_resource_and_operation('timesheets','READ')
 #        timesheets_delete = Right.find_by_resource_and_operation('timesheets','DELETE')
 #        timesheets_update = Right.find_by_resource_and_operation('timesheets','UPDATE')
 #        #trial_owner 
 #        trial_owner.rights << timesheets_create
 #        trial_owner.rights << timesheets_read
 #        trial_owner.rights << timesheets_update
 #        trial_owner.rights << timesheets_delete
 #        #trial_accountant
 #        trial_accountant.rights << timesheets_create
 #        trial_accountant.rights << timesheets_read
 #        trial_accountant.rights << timesheets_update
 #        trial_accountant.rights << timesheets_delete
 #        #trial_staff
 #    #    trial_staff.rights << timesheets_create
 #        trial_staff.rights << timesheets_read
 #        trial_staff.rights << timesheets_update
 #    #    trial_staff.rights << timesheets_delete
 #        #trial_employee
 #        # trial_employee.rights << timesheets_create
 #        trial_employee.rights << timesheets_read
 #        trial_employee.rights << timesheets_update
 #        # trial_employee.rights << timesheets_delete
 #        #trial_inventory_manager
 #        trial_inventory_manager.rights << timesheets_create
 #        trial_inventory_manager.rights << timesheets_read
 #        trial_inventory_manager.rights << timesheets_update
 #        trial_inventory_manager.rights << timesheets_delete
 #        #Policy documents
 #        policy_documents_read = Right.find_by_resource_and_operation('policy_documents','READ')
 #        policy_documents_create = Right.find_by_resource_and_operation('policy_documents','CREATE')
 #        policy_documents_update = Right.find_by_resource_and_operation('policy_documents','UPDATE')
 #        policy_documents_delete = Right.find_by_resource_and_operation('policy_documents','DELETE')

 #       #trial_owner 
 #        trial_owner.rights << policy_documents_create
 #        trial_owner.rights << policy_documents_read
 #        trial_owner.rights << policy_documents_update
 #        trial_owner.rights << policy_documents_delete
 #        #trial_accountant
 #        trial_accountant.rights << policy_documents_create
 #        trial_accountant.rights << policy_documents_read
 #        trial_accountant.rights << policy_documents_update
 #        trial_accountant.rights << policy_documents_delete
 #        #trial_staff
 #        trial_staff.rights << policy_documents_read
 #        #trial_employee
 #        trial_employee.rights << policy_documents_read
 #        #trial_inventory_manager
 #        trial_inventory_manager.rights << policy_documents_read

 #        #Folder
 #        folders_create = Right.find_by_resource_and_operation('folders','CREATE')
 #        folders_read = Right.find_by_resource_and_operation('folders','READ')
 #        folders_delete = Right.find_by_resource_and_operation('folders','DELETE')
 #        folders_update = Right.find_by_resource_and_operation('folders','UPDATE')

 #       #trial_owner 
 #        trial_owner.rights << folders_create
 #        trial_owner.rights << folders_read
 #        trial_owner.rights << folders_update
 #        trial_owner.rights << folders_delete
 #        #trial_accountant
 #        trial_accountant.rights << folders_create
 #        trial_accountant.rights << folders_read
 #        trial_accountant.rights << folders_update
 #        trial_accountant.rights << folders_delete
 #        #trial_staff
 #        trial_staff.rights << folders_create
 #        trial_staff.rights << folders_read
 #        trial_staff.rights << folders_update
 #        trial_staff.rights << folders_delete
 #        #trial_employee
 #        trial_employee.rights << folders_create
 #        trial_employee.rights << folders_read
 #        trial_employee.rights << folders_update
 #        trial_employee.rights << folders_delete
 #        #trial_inventory_manager
 #        trial_inventory_manager.rights << folders_create
 #        trial_inventory_manager.rights << folders_read
 #        trial_inventory_manager.rights << folders_update
 #        trial_inventory_manager.rights << folders_delete

 #        #My files
 #        myfiles_create = Right.find_by_resource_and_operation('myfiles','CREATE')
 #        myfiles_read = Right.find_by_resource_and_operation('myfiles','READ')
 #        myfiles_delete = Right.find_by_resource_and_operation('myfiles','DELETE')
 #        myfiles_update = Right.find_by_resource_and_operation('myfiles','UPDATE')

 #       #trial_owner 
 #        trial_owner.rights << myfiles_create
 #        trial_owner.rights << myfiles_read
 #        trial_owner.rights << myfiles_update
 #        trial_owner.rights << myfiles_delete
 #        #trial_accountant
 #        trial_accountant.rights << myfiles_create
 #        trial_accountant.rights << myfiles_read
 #        trial_accountant.rights << myfiles_update
 #        trial_accountant.rights << myfiles_delete
 #        #trial_staff
 #        trial_staff.rights << myfiles_create
 #        trial_staff.rights << myfiles_read
 #        trial_staff.rights << myfiles_update
 #        trial_staff.rights << myfiles_delete
 #        #trial_employee
 #        trial_employee.rights << myfiles_create
 #        trial_employee.rights << myfiles_read
 #        trial_employee.rights << myfiles_update
 #        trial_employee.rights << myfiles_delete
 #        #trial_inventory_manager
 #        trial_inventory_manager.rights << myfiles_create
 #        trial_inventory_manager.rights << myfiles_read
 #        trial_inventory_manager.rights << myfiles_update
 #        trial_inventory_manager.rights << myfiles_delete

 #        #Billing history
 #        billing_history_read = Right.find_by_resource_and_operation('billing_history','READ')
 #        trial_owner.rights << billing_history_read

 #        #Payroll register
 #        # payroll_register_read = Right.find_by_resource_and_operation('payroll_register', 'READ') 
 #        # trial_owner.rights << payroll_register_read
 #        # trial_accountant.rights << payroll_register_read
 #        # trial_auditor.rights << payroll_register_read

 #        #Attendance register
 #        # attendance_register_read = Right.find_by_resource_and_operation('attendance_register', 'READ')
 #        # trial_owne.rightsr << attendance_register_read
 #        # trial_accountant.rights << attendance_register_read
 #        # trial_auditor.rights << attendance_register_read

 #        # Employee breackups
 #        # employee_breakup_read = Right.find_by_resource_and_operation('employee_breakup', 'READ')
 #        # trial_owner.rights << employee_breakup_read
 #        # trial_accountant.rights << employee_breakup_read
 #        # trial_auditor.rights << employee_breakup_read

 #        #My organization
 #        my_organisation_create = Right.find_by_resource_and_operation('my_organisation', 'CREATE')
 #        my_organisation_read = Right.find_by_resource_and_operation('my_organisation', 'READ') 
 #        my_organisation_delete = Right.find_by_resource_and_operation('my_organisation', 'DELETE')
 #        my_organisation_update = Right.find_by_resource_and_operation('my_organisation', 'UPDATE')

 #        trial_owner.rights << my_organisation_create
 #        trial_owner.rights << my_organisation_read
 #        trial_owner.rights << my_organisation_update
 #        trial_owner.rights << my_organisation_delete
 #        trial_accountant.rights << my_organisation_read
 #        #   trial_staff
 #        trial_staff.rights << my_organisation_read
 #        #  trial_employee
 #        trial_employee.rights << my_organisation_read
 #        #trial_inventory_manager
 #        trial_inventory_manager.rights << my_organisation_read
 #        #Projects
 #        projects_create = Right.find_by_resource_and_operation('projects', 'CREATE')
 #        projects_read = Right.find_by_resource_and_operation('projects', 'READ') 
 #        projects_delete = Right.find_by_resource_and_operation('projects', 'DELETE')
 #        projects_update = Right.find_by_resource_and_operation('projects', 'UPDATE')

 #        trial_owner.rights << projects_create
 #        trial_owner.rights << projects_read
 #        trial_owner.rights << projects_update
 #        trial_owner.rights << projects_delete
 #        #trial_accountant
 #        trial_accountant.rights << projects_create
 #        trial_accountant.rights << projects_read
 #        trial_accountant.rights << projects_update
 #        trial_accountant.rights << projects_delete
 #        #trial_staff
 #        trial_staff.rights << projects_read
 #        #trial_auditor
 #        trial_auditor.rights << projects_read

 #        #Billing History
 #        billing_history_read = Right.find_by_resource_and_operation('billing_history', 'READ')

 #        trial_owner.rights << billing_history_read

 #        #Invoice setting
 #        # invoice_settings_create = Right.find_by_resource_and_operation('invoice_settings', 'CREATE')
 #        invoice_settings_read = Right.find_by_resource_and_operation('invoice_settings', 'READ') 
 #        # invoice_settings_delete = Right.find_by_resource_and_operation('invoice_settings', 'DELETE')
 #        invoice_settings_update = Right.find_by_resource_and_operation('invoice_settings', 'UPDATE')

 #        #trial_owner 
 #        # trial_owner.rights << invoice_settings_create
 #        trial_owner.rights << invoice_settings_read
 #        trial_owner.rights << invoice_settings_update
 #        # trial_owner.rights << invoice_settings_delete

 #        #Branches
 #        branches_create = Right.find_by_resource_and_operation('branches', 'CREATE')
 #        branches_read = Right.find_by_resource_and_operation('branches', 'READ') 
 #        branches_delete = Right.find_by_resource_and_operation('branches', 'DELETE')
 #        branches_update = Right.find_by_resource_and_operation('branches', 'UPDATE')

 #        trial_owner.rights << branches_create
 #        trial_owner.rights << branches_read
 #        trial_owner.rights << branches_update
 #        trial_owner.rights << branches_delete

 #        #Product
 #        product_create = Right.find_by_resource_and_operation('products', 'CREATE')
 #        product_read = Right.find_by_resource_and_operation('products', 'READ') 
 #        product_delete = Right.find_by_resource_and_operation('products', 'DELETE')
 #        product_update = Right.find_by_resource_and_operation('products', 'UPDATE')

 #        #trial_owner 
 #        trial_owner.rights << product_create
 #        trial_owner.rights << product_read
 #        trial_owner.rights << product_update
 #        trial_owner.rights << product_delete
 #        #trial_accountant
 #        trial_accountant.rights << product_create
 #        trial_accountant.rights << product_read
 #        trial_accountant.rights << product_update
 #        trial_accountant.rights << product_delete
 #        #trial_staff
 #        trial_staff.rights << product_read
 #        #trial_auditor
 #        trial_auditor.rights << product_read

 #        #Stock wastage voucher
 #        stock_wastage_vouchers_create = Right.find_by_resource_and_operation('stock_wastage_vouchers', 'CREATE')
 #        stock_wastage_vouchers_read = Right.find_by_resource_and_operation('stock_wastage_vouchers', 'READ') 
 #        stock_wastage_vouchers_delete = Right.find_by_resource_and_operation('stock_wastage_vouchers', 'DELETE')
 #        stock_wastage_vouchers_update = Right.find_by_resource_and_operation('stock_wastage_vouchers', 'UPDATE')

 #        #trial_owner
 #        trial_owner.rights << stock_wastage_vouchers_create
 #        trial_owner.rights << stock_wastage_vouchers_read
 #        trial_owner.rights << stock_wastage_vouchers_update
 #        trial_owner.rights << stock_wastage_vouchers_delete

 #        #trial_accountant
 #        trial_accountant.rights << stock_wastage_vouchers_create
 #        trial_accountant.rights << stock_wastage_vouchers_read
 #        trial_accountant.rights << stock_wastage_vouchers_update
 #        trial_accountant.rights << stock_wastage_vouchers_delete

 #        #trial_staff
 #        trial_staff.rights << stock_wastage_vouchers_create
 #        trial_staff.rights << stock_wastage_vouchers_read
 #        trial_staff.rights << stock_wastage_vouchers_update
 #        trial_staff.rights << stock_wastage_vouchers_delete

 #        #trial_auditor
 #        trial_auditor.rights << stock_wastage_vouchers_read
 #        #trial_inventory_manager 
 #        trial_inventory_manager.rights << stock_wastage_vouchers_create
 #        trial_inventory_manager.rights << stock_wastage_vouchers_read
 #        trial_inventory_manager.rights << stock_wastage_vouchers_update
 #        trial_inventory_manager.rights << stock_wastage_vouchers_delete

 #        #warehouse
 #        warehouses_create = Right.find_by_resource_and_operation('warehouses', 'CREATE')
 #        warehouses_read = Right.find_by_resource_and_operation('warehouses', 'READ')
 #        warehouses_delete = Right.find_by_resource_and_operation('warehouses', 'DELETE')
 #        warehouses_update = Right.find_by_resource_and_operation('warehouses', 'UPDATE')

 #        #trial_owner 
 #        trial_owner.rights << warehouses_create
 #        trial_owner.rights << warehouses_read
 #        trial_owner.rights << warehouses_update
 #        trial_owner.rights << warehouses_delete
 #        #trial_accountant
 #        trial_accountant.rights << warehouses_create
 #        trial_accountant.rights << warehouses_read
 #        trial_accountant.rights << warehouses_update
 #        trial_accountant.rights << warehouses_delete
 #        #trial_staff
 #        trial_staff.rights << warehouses_create
 #        trial_staff.rights << warehouses_read
 #        trial_staff.rights << warehouses_update
 #        trial_staff.rights << warehouses_delete
 #        #trial_inventory_manager 
 #        trial_inventory_manager.rights << warehouses_create
 #        trial_inventory_manager.rights << warehouses_read
 #        trial_inventory_manager.rights << warehouses_update
 #        trial_inventory_manager.rights << warehouses_delete
 #        #trial_auditor
 #        trial_auditor.rights << warehouses_read

 #        #Stock issue vouchers
 #        stock_issue_vouchers_create = Right.find_by_resource_and_operation('stock_issue_vouchers', 'CREATE')
 #        stock_issue_vouchers_read = Right.find_by_resource_and_operation('stock_issue_vouchers','READ')
 #        stock_issue_vouchers_update = Right.find_by_resource_and_operation('stock_issue_vouchers','UPDATE')
 #        stock_issue_vouchers_delete = Right.find_by_resource_and_operation('stock_issue_vouchers','DELETE')

 #        #trial_owner 
 #        trial_owner.rights << stock_issue_vouchers_create
 #        trial_owner.rights << stock_issue_vouchers_read
 #        trial_owner.rights << stock_issue_vouchers_update
 #        trial_owner.rights << stock_issue_vouchers_delete
 #        #trial_accountant
 #        trial_accountant.rights << stock_issue_vouchers_create
 #        trial_accountant.rights << stock_issue_vouchers_read
 #        trial_accountant.rights << stock_issue_vouchers_update
 #        trial_accountant.rights << stock_issue_vouchers_delete
 #        #trial_staff
 #        trial_staff.rights << stock_issue_vouchers_create
 #        trial_staff.rights << stock_issue_vouchers_read
 #        trial_staff.rights << stock_issue_vouchers_update
 #        trial_staff.rights << stock_issue_vouchers_delete
 #        #trial_auditor
 #        trial_auditor.rights << stock_issue_vouchers_read
 #        #trial_inventory_manager
 #        trial_inventory_manager.rights << stock_issue_vouchers_create
 #        trial_inventory_manager.rights << stock_issue_vouchers_read
 #        trial_inventory_manager.rights << stock_issue_vouchers_update
 #        trial_inventory_manager.rights << stock_issue_vouchers_delete

 #        #stock receipt vouchers
 #        stock_receipt_vouchers_create = Right.find_by_resource_and_operation('stock_receipt_vouchers','CREATE')
 #        stock_receipt_vouchers_read = Right.find_by_resource_and_operation('stock_receipt_vouchers','READ')
 #        stock_receipt_vouchers_update = Right.find_by_resource_and_operation('stock_receipt_vouchers','UPDATE')
 #        stock_receipt_vouchers_delete = Right.find_by_resource_and_operation('stock_receipt_vouchers','DELETE')

 #        #trial_owner  
 #        trial_owner.rights << stock_receipt_vouchers_create
 #        trial_owner.rights << stock_receipt_vouchers_read
 #        trial_owner.rights << stock_receipt_vouchers_update
 #        trial_owner.rights << stock_receipt_vouchers_delete
 #        #trial_accountant
 #        trial_accountant.rights << stock_receipt_vouchers_create
 #        trial_accountant.rights << stock_receipt_vouchers_read
 #        trial_accountant.rights << stock_receipt_vouchers_update
 #        trial_accountant.rights << stock_receipt_vouchers_delete
 #        #trial_staff
 #        trial_staff.rights << stock_receipt_vouchers_create
 #        trial_staff.rights << stock_receipt_vouchers_read
 #        trial_staff.rights << stock_receipt_vouchers_update
 #        trial_staff.rights << stock_receipt_vouchers_delete
 #        #trial_auditor
 #        trial_auditor.rights << stock_receipt_vouchers_read
 #        #trial_inventory_manager 
 #        trial_inventory_manager.rights << stock_receipt_vouchers_create
 #        trial_inventory_manager.rights << stock_receipt_vouchers_read
 #        trial_inventory_manager.rights << stock_receipt_vouchers_update
 #        trial_inventory_manager.rights << stock_receipt_vouchers_delete

 #        #stock wastage register
 #        stock_wastage_register_read = Right.find_by_resource_and_operation('stock_wastage_register', 'READ')
 #        trial_owner.rights << stock_wastage_register_read
 #        trial_accountant.rights << stock_wastage_register_read
 #        trial_auditor.rights << stock_wastage_register_read
 #        trial_inventory_manager.rights << stock_wastage_register_read

 #        low_stock_read = Right.find_by_resource_and_operation('low_stock', 'READ')
 #        trial_owner.rights << low_stock_read
 #        trial_accountant.rights << low_stock_read
 #        trial_auditor.rights << low_stock_read
 #        trial_inventory_manager.rights << low_stock_read

 #        #Leave types
 #        leave_types_create = Right.find_by_resource_and_operation('leave_types', 'CREATE')
 #        leave_types_read = Right.find_by_resource_and_operation('leave_types', 'READ') 
 #        leave_types_delete = Right.find_by_resource_and_operation('leave_types', 'DELETE')
 #        leave_types_update = Right.find_by_resource_and_operation('leave_types', 'UPDATE')

 #        #trial_owner 
 #        trial_owner.rights << leave_types_create
 #        trial_owner.rights << leave_types_read
 #        trial_owner.rights << leave_types_update
 #        trial_owner.rights << leave_types_delete
 #        #trial_accountant
 #        trial_accountant.rights << leave_types_read
 #        #trial_staff
 #        trial_staff.rights << leave_types_read
 #        #trial_inventory_manager
 #        trial_inventory_manager.rights << leave_types_read

 #        #dropbox
 #        db_read = Right.find_by_resource_and_operation('db','READ')
 #        #trial_owner  
 #        trial_owner.rights << db_read
 #        #trial_accountant 
 #        trial_accountant.rights << db_read
 #        #trial_staff
 #        trial_staff.rights << db_read
 #        #trial_employee
 #        trial_employee.rights << db_read
 #        #trial_inventory_manager
 #        trial_inventory_manager.rights << db_read

 #        #Taxes
 #        duties_and_taxes_read = Right.find_by_resource_and_operation('duties_and_taxes', 'READ') 
 #        duties_and_taxes_create = Right.find_by_resource_and_operation('duties_and_taxes', 'CREATE')
 #        duties_and_taxes_delete = Right.find_by_resource_and_operation('duties_and_taxes', 'DELETE')
 #        duties_and_taxes_update = Right.find_by_resource_and_operation('duties_and_taxes', 'UPDATE')

 #        #trial_owner 
 #        trial_owner.rights << duties_and_taxes_create
 #        trial_owner.rights << duties_and_taxes_read
 #        trial_owner.rights << duties_and_taxes_update
 #        trial_owner.rights << duties_and_taxes_delete
 #        #trial_accountant
 #        trial_accountant.rights << duties_and_taxes_create
 #        trial_accountant.rights << duties_and_taxes_read
 #        trial_accountant.rights << duties_and_taxes_update
 #        trial_accountant.rights << duties_and_taxes_delete
 #        #trial_staff
 #        #trial_auditor
 #        trial_auditor.rights << duties_and_taxes_read

 #        #Plan properties
 #        PlanProperty.create!(:plan_id => trial_plan.id, :name => 'inventoriable', :value => '1', :datatype => 'boolean')
 #        PlanProperty.create!(:plan_id => trial_plan.id, :name => 'payroll', :value => '1', :datatype => 'boolean')
 #        PlanProperty.create!(:plan_id => trial_plan.id, :name => 'free_plan', :value => '0', :datatype => 'boolean')
 #        PlanProperty.create!(:plan_id => trial_plan.id, :name => 'foreign_plan', :value => '0', :datatype => 'boolean')

 #        #Auditor
 #        auditors_create = Right.find_by_resource_and_operation('auditors', 'CREATE')
 #        auditors_read = Right.find_by_resource_and_operation('auditors', 'READ') 
 #        auditors_delete = Right.find_by_resource_and_operation('auditors', 'DELETE')
 #        auditors_update = Right.find_by_resource_and_operation('auditors', 'UPDATE')

 #        #trial_owner 
 #        trial_owner.rights << auditors_create
 #        trial_owner.rights << auditors_read
 #        trial_owner.rights << auditors_update
 #        trial_owner.rights << auditors_delete

 #        #Billing
 #        billing_read = Right.find_by_resource_and_operation('billing', 'READ')
 #        #trial_owner 
 #        trial_owner.rights << billing_read

 #        # Payroll details
 #        payroll_details_create = Right.find_by_resource_and_operation('payroll_details', 'CREATE')
 #        payroll_details_read = Right.find_by_resource_and_operation('payroll_details', 'READ') 
 #        # payroll_details_delete = Right.find_by_resource_and_operation('payroll_details', 'DELETE')
 #        payroll_details_update = Right.find_by_resource_and_operation('payroll_details', 'UPDATE')

 #        #trial_owner  
 #        trial_owner.rights << payroll_details_create
 #        trial_owner.rights << payroll_details_read
 #        trial_owner.rights << payroll_details_update
 #        # trial_owner.rights << payroll_details_delete
 #        #trial_accountant
 #        trial_accountant.rights << payroll_details_create
 #        trial_accountant.rights << payroll_details_read
 #        trial_accountant.rights << payroll_details_update
 #        # trial_accountant.rights << payroll_details_delete
 #        #trial_auditor
 #        trial_auditor.rights << payroll_details_read
 #      #Invitation details  
 #      invitation_details_create = Right.find_by_resource_and_operation('invitation_details', 'CREATE')
 #      invitation_details_read = Right.find_by_resource_and_operation('invitation_details', 'READ') 
 #      invitation_details_delete = Right.find_by_resource_and_operation('invitation_details', 'DELETE')
 #      invitation_details_update = Right.find_by_resource_and_operation('invitation_details', 'UPDATE')
      
 #      #trial_owner  
 #      trial_owner.rights << invitation_details_create
 #      trial_owner.rights << invitation_details_read
 #      trial_owner.rights << invitation_details_update
 #      trial_owner.rights << invitation_details_delete 

 #      # Attendance
 #      attendances_create = Right.find_by_resource_and_operation('attendances', 'CREATE')
 #      attendances_read = Right.find_by_resource_and_operation('attendances', 'READ') 
 #      attendances_delete = Right.find_by_resource_and_operation('attendances', 'DELETE')
 #      attendances_update = Right.find_by_resource_and_operation('attendances', 'UPDATE')
 #      #trial_owner  
 #      trial_owner.rights << attendances_create
 #      trial_owner.rights << attendances_read
 #      trial_owner.rights << attendances_update
 #      trial_owner.rights << attendances_delete
 #      #trial_accountant
 #      trial_accountant.rights << attendances_create
 #      trial_accountant.rights << attendances_read
 #      trial_accountant.rights << attendances_update
 #      trial_accountant.rights << attendances_delete
 #      #trial_auditor
 #      trial_auditor.rights << attendances_read

 #      # Custom fields
 #      custom_fields_create = Right.find_by_resource_and_operation('custom_fields', 'CREATE')
 #      custom_fields_read = Right.find_by_resource_and_operation('custom_fields', 'READ') 
 #      custom_fields_delete = Right.find_by_resource_and_operation('custom_fields', 'DELETE')
 #      custom_fields_update = Right.find_by_resource_and_operation('custom_fields', 'UPDATE')

 #      #   trial_owner 
 #      trial_owner.rights << custom_fields_create
 #      trial_owner.rights << custom_fields_read
 #      trial_owner.rights << custom_fields_update
 #      trial_owner.rights << custom_fields_delete
 #      #   trial_accountant
 #      trial_accountant.rights << custom_fields_create
 #      trial_accountant.rights << custom_fields_read
 #      trial_accountant.rights << custom_fields_update
 #      trial_accountant.rights << custom_fields_delete

 #      # Leave approvals
 #      leaves_approval_create = Right.find_by_resource_and_operation('leave_approval', 'CREATE')
 #      leaves_approval_read = Right.find_by_resource_and_operation('leave_approval', 'READ') 
 #      leaves_approval_delete = Right.find_by_resource_and_operation('leave_approval', 'DELETE')
 #      leaves_approval_update = Right.find_by_resource_and_operation('leave_approval', 'UPDATE')
 #      # trial_owner
 #      trial_owner.rights << leaves_approval_create
 #      trial_owner.rights << leaves_approval_read
 #      trial_owner.rights << leaves_approval_update
 #      trial_owner.rights << leaves_approval_delete
 #      # trial_accountant
 #      trial_accountant.rights << leaves_approval_create
 #      trial_accountant.rights << leaves_approval_read
 #      trial_accountant.rights << leaves_approval_update
 #      trial_accountant.rights << leaves_approval_delete
 #      # trial_staff
 #      trial_staff.rights << leaves_approval_create
 #      trial_staff.rights << leaves_approval_read
 #      trial_staff.rights << leaves_approval_update
 #      trial_staff.rights << leaves_approval_delete

 #      # Leave cards
 #      leaves_create = Right.find_by_resource_and_operation('leave_cards', 'CREATE')
 #      leaves_read = Right.find_by_resource_and_operation('leave_cards', 'READ') 
 #      leaves_delete = Right.find_by_resource_and_operation('leave_cards', 'DELETE')
 #      leaves_update = Right.find_by_resource_and_operation('leave_cards', 'UPDATE')
 #      #trial_owner 
 #      trial_owner.rights << leaves_create
 #      trial_owner.rights << leaves_read
 #      trial_owner.rights << leaves_update
 #      trial_owner.rights << leaves_delete
 #      #trial_accountant
 #      trial_accountant.rights << leaves_create
 #      trial_accountant.rights << leaves_read
 #      trial_accountant.rights << leaves_update
 #      trial_accountant.rights << leaves_delete
 #      #trial_staff
 #      trial_staff.rights << leaves_create
 #      trial_staff.rights << leaves_read
 #      trial_staff.rights << leaves_update
 #      trial_staff.rights << leaves_delete
 #      #trial_employee
 #      trial_employee.rights << leaves_create
 #      trial_employee.rights << leaves_read
 #      trial_employee.rights << leaves_update
 #      trial_employee.rights << leaves_delete

 #      # Payheads
 #      payheads_create = Right.find_by_resource_and_operation('payheads', 'CREATE')
 #      payheads_read = Right.find_by_resource_and_operation('payheads', 'READ') 
 #      payheads_delete = Right.find_by_resource_and_operation('payheads', 'DELETE')
 #      payheads_update = Right.find_by_resource_and_operation('payheads', 'UPDATE')
 #      #trial_owner  
 #      trial_owner.rights << payheads_create
 #      trial_owner.rights << payheads_read
 #      trial_owner.rights << payheads_update
 #      trial_owner.rights << payheads_delete
 #      #trial_accountant
 #      trial_accountant.rights << payheads_read
 #      #trial_auditor
 #      trial_auditor.rights << payheads_read
end
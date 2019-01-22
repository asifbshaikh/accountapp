ActiveRecord::Base.transaction do

  premium_plan = Plan.find_by_name('Premium')
  enterprise_plan = Plan.find_by_name('Enterprise')
  trial_plan = Plan.find_by_name('Trial')
  
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

  trial_owner = Role.find_by_name_and_plan_id('Owner', trial_plan)
  trial_accountant = Role.find_by_name_and_plan_id('Accountant', trial_plan)
  trial_auditor = Role.find_by_name_and_plan_id('Auditor', trial_plan)
  trial_staff = Role.find_by_name_and_plan_id('Staff', trial_plan)
  trial_employee = Role.find_by_name_and_plan_id('Employee', trial_plan)



 #salary structure history
     salary_structure_histories_create = Right.create!(:resource => 'salary_structure_histories', :operation => 'CREATE') 
     salary_structure_histories_read = Right.create!(:resource => 'salary_structure_histories', :operation => 'READ') 
     salary_structure_histories_update = Right.create!(:resource => 'salary_structure_histories', :operation => 'UPDATE') 
     salary_structure_histories_delete = Right.create!(:resource => 'salary_structure_histories', :operation => 'DELETE') 
     
     
     #premium_owner 
        premium_owner.rights << salary_structure_histories_create
        premium_owner.rights << salary_structure_histories_read
        premium_owner.rights << salary_structure_histories_update
        premium_owner.rights << salary_structure_histories_delete
        #premium_accountant
        premium_accountant.rights << salary_structure_histories_read
      
      #enterprise_owner 
        enterprise_owner.rights << salary_structure_histories_create
        enterprise_owner.rights << salary_structure_histories_read
        enterprise_owner.rights << salary_structure_histories_update
        enterprise_owner.rights << salary_structure_histories_delete
        #enterprise_accountant
        enterprise_accountant.rights << salary_structure_histories_read
      
      #trial_owner 
        trial_owner.rights << salary_structure_histories_create
        trial_owner.rights << salary_structure_histories_read
        trial_owner.rights << salary_structure_histories_update
        trial_owner.rights << salary_structure_histories_delete
        #trial_accountant
        trial_accountant.rights << salary_structure_histories_read



  professional_plan = Plan.create(:name => 'Professional',:price => 750,
    :description => 'Professional plan with multi user accounting, payroll managment.',
    :display_name => 'Professional', :user_count => 10, :storage_limit_mb => 1073741824)
  #Roles for trail plan
  professional_owner = Role.create!(:name => 'Owner')
  professional_plan.roles << professional_owner
  professional_accountant = Role.create!(:name => 'Accountant')
  professional_plan.roles << professional_accountant
  professional_staff = Role.create!(:name => 'Staff')
  professional_plan.roles << professional_staff
  professional_auditor = Role.create!(:name => 'Auditor')
  professional_plan.roles << professional_auditor
  professional_employee = Role.create!(:name => 'Employee')
  professional_plan.roles << professional_employee

    # Dashboard rights
    dashboard_read = Right.find_by_resource_and_operation('dashboard','READ')  
    
      #professional_owner 
      professional_owner.rights << dashboard_read
      #professional_accountant
      professional_accountant.rights << dashboard_read
      #professional_staff
      professional_staff.rights << dashboard_read
      #professional_auditor
      professional_auditor.rights << dashboard_read 
    
     # free_owner.rights << tasks_delete
      tasks_create = Right.find_by_resource_and_operation( 'tasks',  'CREATE')
      tasks_read = Right.find_by_resource_and_operation( 'tasks',  'READ') 
      tasks_delete = Right.find_by_resource_and_operation( 'tasks',  'DELETE')
      tasks_update = Right.find_by_resource_and_operation( 'tasks',  'UPDATE')
     
    #professional_owner  
      professional_owner.rights << tasks_create
      professional_owner.rights << tasks_read
      professional_owner.rights << tasks_update
      professional_owner.rights << tasks_delete
      #basic_accountant
      professional_accountant.rights << tasks_create
      professional_accountant.rights << tasks_read
      professional_accountant.rights << tasks_update
      professional_accountant.rights << tasks_delete
      #professional_staff
      professional_staff.rights << tasks_create
      professional_staff.rights << tasks_read
      professional_staff.rights << tasks_update
      professional_staff.rights << tasks_delete
      #professional_auditor
      professional_auditor.rights << tasks_read 
      #professional_employee
      professional_employee.rights << tasks_create
      professional_employee.rights << tasks_read
      professional_employee.rights << tasks_update
      professional_employee.rights << tasks_delete


    
      #messages_update = Right.create!(:resource => 'messages', :operation => 'UPDATE')
      messages_create = Right.find_by_resource_and_operation( 'messages',  'CREATE')
      messages_read = Right.find_by_resource_and_operation( 'messages',  'READ') 
      messages_delete = Right.find_by_resource_and_operation( 'messages',  'DELETE')
      messages_update = Right.find_by_resource_and_operation( 'messages',  'UPDATE')
      
      #professional_owner  
      professional_owner.rights << messages_create
      professional_owner.rights << messages_read
      professional_owner.rights << messages_update
      professional_owner.rights << messages_delete
      #professional_accountant
      professional_accountant.rights << messages_create
      professional_accountant.rights << messages_read
      professional_accountant.rights << messages_update
      professional_accountant.rights << messages_delete
      #professional_staff
      professional_staff.rights << messages_create
      professional_staff.rights << messages_read
      professional_staff.rights << messages_update
      professional_staff.rights << messages_delete
      #professional_auditor
      professional_auditor.rights << messages_read
      #professional_employee
      professional_employee.rights << messages_create
      professional_employee.rights << messages_read
      professional_employee.rights << messages_update
      professional_employee.rights << messages_delete
      #trial inv manager

      #free_owner.rights << documents_delete
      documents_create = Right.find_by_resource_and_operation( 'documents',  'CREATE')
      documents_read = Right.find_by_resource_and_operation( 'documents',  'READ') 
      documents_delete = Right.find_by_resource_and_operation( 'documents',  'DELETE')
      documents_update = Right.find_by_resource_and_operation( 'documents',  'UPDATE')
      
       #professional_owner 
       professional_owner.rights << documents_create
       professional_owner.rights << documents_read
       professional_owner.rights << documents_update
       professional_owner.rights << documents_delete
      #professional_accountant
       professional_accountant.rights << documents_create
       professional_accountant.rights << documents_read
       professional_accountant.rights << documents_update
       professional_accountant.rights << documents_delete
       #professional_staff
       professional_staff.rights << documents_create
       professional_staff.rights << documents_read
       professional_staff.rights << documents_update
       professional_staff.rights << documents_delete
       #professional_auditor
       professional_auditor.rights << documents_read
       #professional_employee
        professional_employee.rights << documents_create
        professional_employee.rights << documents_read
        professional_employee.rights << documents_update
        professional_employee.rights << documents_delete

    
      notes_create = Right.find_by_resource_and_operation( 'notes',  'CREATE')
      notes_read = Right.find_by_resource_and_operation( 'notes',  'READ') 
      notes_delete = Right.find_by_resource_and_operation( 'notes',  'DELETE')
      notes_update = Right.find_by_resource_and_operation( 'notes',  'UPDATE')

      #professional_owner  
       professional_owner.rights << notes_create
       professional_owner.rights << notes_read
       professional_owner.rights << notes_update
       professional_owner.rights << notes_delete
      #professional_accountant
       professional_accountant.rights << notes_create
       professional_accountant.rights << notes_read
       professional_accountant.rights << notes_update
       professional_accountant.rights << notes_delete
      #professional_staff
       professional_staff.rights << notes_create
       professional_staff.rights << notes_read
       professional_staff.rights << notes_update
       professional_staff.rights << notes_delete
      #professional_auditor
       professional_auditor.rights << notes_read
       #professional_employee
      professional_employee.rights << notes_create
      professional_employee.rights << notes_read
      professional_employee.rights << notes_update
      professional_employee.rights << notes_delete

      invoices_create = Right.find_by_resource_and_operation( 'invoices',  'CREATE')
      invoices_read = Right.find_by_resource_and_operation( 'invoices',  'READ') 
      invoices_delete = Right.find_by_resource_and_operation( 'invoices',  'DELETE')
      invoices_update = Right.find_by_resource_and_operation( 'invoices',  'UPDATE')
   
     #professional_owner 
       professional_owner.rights << invoices_create
       professional_owner.rights << invoices_read
       professional_owner.rights << invoices_update
       professional_owner.rights << invoices_delete
      #professional_accountant
       professional_accountant.rights << invoices_create
       professional_accountant.rights << invoices_read
       professional_accountant.rights << invoices_update
       professional_accountant.rights << invoices_delete
      #professional_staff
       professional_staff.rights << invoices_create
       professional_staff.rights << invoices_read
       professional_staff.rights << invoices_update
       professional_staff.rights << invoices_delete
      #professional_auditor
       professional_auditor.rights << invoices_read
      receipt_vouchers_create = Right.find_by_resource_and_operation( 'receipt_vouchers',  'CREATE')
      receipt_vouchers_read = Right.find_by_resource_and_operation( 'receipt_vouchers',  'READ') 
      receipt_vouchers_delete = Right.find_by_resource_and_operation( 'receipt_vouchers',  'DELETE')
      receipt_vouchers_update = Right.find_by_resource_and_operation( 'receipt_vouchers',  'UPDATE')
     
     #professional_owner 
       professional_owner.rights << receipt_vouchers_create
       professional_owner.rights << receipt_vouchers_read
       professional_owner.rights << receipt_vouchers_update
       professional_owner.rights << receipt_vouchers_delete
      #professional_accountant
       professional_accountant.rights << receipt_vouchers_create
       professional_accountant.rights << receipt_vouchers_read
       professional_accountant.rights << receipt_vouchers_update
       professional_accountant.rights << receipt_vouchers_delete
      #professional_staff
       professional_staff.rights << receipt_vouchers_create
       professional_staff.rights << receipt_vouchers_read
       professional_staff.rights << receipt_vouchers_update
       professional_staff.rights << receipt_vouchers_delete
      #professional_auditor
      professional_auditor.rights << receipt_vouchers_read


      estimates_create = Right.find_by_resource_and_operation( 'estimates',  'CREATE')
      estimates_read = Right.find_by_resource_and_operation( 'estimates',  'READ') 
      estimates_delete = Right.find_by_resource_and_operation( 'estimates',  'DELETE')
      estimates_update = Right.find_by_resource_and_operation( 'estimates',  'UPDATE')
      
   #professional_owner 
       professional_owner.rights << estimates_create
       professional_owner.rights << estimates_read
       professional_owner.rights << estimates_update
       professional_owner.rights << estimates_delete
      #professional_accountant
       professional_accountant.rights << estimates_create
       professional_accountant.rights << estimates_read
       professional_accountant.rights << estimates_update
       professional_accountant.rights << estimates_delete
      #professional_staff
       professional_staff.rights << estimates_create
       professional_staff.rights << estimates_read
       professional_staff.rights << estimates_update
       professional_staff.rights << estimates_delete
      #professional_auditor
       professional_auditor.rights << estimates_read


      income_vouchers_create = Right.find_by_resource_and_operation( 'income_vouchers',  'CREATE')
      income_vouchers_read = Right.find_by_resource_and_operation( 'income_vouchers',  'READ') 
      income_vouchers_delete = Right.find_by_resource_and_operation( 'income_vouchers',  'DELETE')
      income_vouchers_update = Right.find_by_resource_and_operation( 'income_vouchers',  'UPDATE')
    
    #professional_owner  
       professional_owner.rights << income_vouchers_create
       professional_owner.rights << income_vouchers_read
       professional_owner.rights << income_vouchers_update
       professional_owner.rights << income_vouchers_delete
      #professional_accountant
       professional_accountant.rights << income_vouchers_create
       professional_accountant.rights << income_vouchers_read
       professional_accountant.rights << income_vouchers_update
       professional_accountant.rights << income_vouchers_delete
      #professional_staff
       professional_staff.rights << income_vouchers_create
       professional_staff.rights << income_vouchers_read
       professional_staff.rights << income_vouchers_update
       professional_staff.rights << income_vouchers_delete
      #professional_auditor
       professional_auditor.rights << income_vouchers_read

      expenses_create = Right.find_by_resource_and_operation( 'expenses',  'CREATE')
      expenses_read = Right.find_by_resource_and_operation( 'expenses',  'READ') 
      expenses_delete = Right.find_by_resource_and_operation( 'expenses',  'DELETE')
      expenses_update = Right.find_by_resource_and_operation( 'expenses',  'UPDATE')

     #professional_owner 
       professional_owner.rights << expenses_create
       professional_owner.rights << expenses_read
       professional_owner.rights << expenses_update
       professional_owner.rights << expenses_delete
     #professional_accountant
       professional_accountant.rights << expenses_create
       professional_accountant.rights << expenses_read
       professional_accountant.rights << expenses_update
       professional_accountant.rights << expenses_delete
     #professional_staff
       professional_staff.rights << expenses_create
       professional_staff.rights << expenses_read
       professional_staff.rights << expenses_update
       professional_staff.rights << expenses_delete
     #professional_auditor
       professional_auditor.rights << expenses_read#

      purchases_create = Right.find_by_resource_and_operation( 'purchases',  'CREATE')
      purchases_read = Right.find_by_resource_and_operation( 'purchases',  'READ') 
      purchases_delete = Right.find_by_resource_and_operation( 'purchases',  'DELETE')
      purchases_update = Right.find_by_resource_and_operation( 'purchases',  'UPDATE')
    
      #professional_owner  
       professional_owner.rights << purchases_create
       professional_owner.rights << purchases_read
       professional_owner.rights << purchases_update
       professional_owner.rights << purchases_delete
      #professional_accountant
       professional_accountant.rights << purchases_create
       professional_accountant.rights << purchases_read
       professional_accountant.rights << purchases_update
       professional_accountant.rights << purchases_delete
      #professional_staff
       professional_staff.rights << purchases_create
       professional_staff.rights << purchases_read
       professional_staff.rights << purchases_update
       professional_staff.rights << purchases_delete
      #professional_auditor
      professional_auditor.rights << purchases_read



      purchase_orders_create = Right.find_by_resource_and_operation( 'purchase_orders',  'CREATE')
      purchase_orders_read = Right.find_by_resource_and_operation( 'purchase_orders',  'READ') 
      purchase_orders_delete = Right.find_by_resource_and_operation( 'purchase_orders',  'DELETE')
      purchase_orders_update = Right.find_by_resource_and_operation( 'purchase_orders',  'UPDATE')
     
    #professional_owner  
       professional_owner.rights << purchase_orders_create
       professional_owner.rights << purchase_orders_read
       professional_owner.rights << purchase_orders_update
       professional_owner.rights << purchase_orders_delete
      #professional_accountant
       professional_accountant.rights << purchase_orders_create
       professional_accountant.rights << purchase_orders_read
       professional_accountant.rights << purchase_orders_update
       professional_accountant.rights << purchase_orders_delete
      #professional_staff
       professional_staff.rights << purchase_orders_create
       professional_staff.rights << purchase_orders_read
       professional_staff.rights << purchase_orders_update
       professional_staff.rights << purchase_orders_delete
      #professional_auditor
       professional_auditor.rights << purchase_orders_read



      payment_vouchers_create = Right.find_by_resource_and_operation( 'payment_vouchers',  'CREATE')
      payment_vouchers_read = Right.find_by_resource_and_operation( 'payment_vouchers',  'READ') 
      payment_vouchers_delete = Right.find_by_resource_and_operation( 'payment_vouchers',  'DELETE')
      payment_vouchers_update = Right.find_by_resource_and_operation( 'payment_vouchers',  'UPDATE')

   #professional_owner 
       professional_owner.rights << payment_vouchers_create
       professional_owner.rights << payment_vouchers_read
       professional_owner.rights << payment_vouchers_update
       professional_owner.rights << payment_vouchers_delete
      #professional_accountant
      professional_accountant.rights << payment_vouchers_create
      professional_accountant.rights << payment_vouchers_read
      professional_accountant.rights << payment_vouchers_update
      professional_accountant.rights << payment_vouchers_delete
      #professional_staff
      professional_staff.rights << payment_vouchers_create
      professional_staff.rights << payment_vouchers_read
      professional_staff.rights << payment_vouchers_update
      professional_staff.rights << payment_vouchers_delete
      # professional_auditor
      professional_auditor.rights << payment_vouchers_read


      withdrawals_create = Right.find_by_resource_and_operation( 'withdrawals',  'CREATE')
      withdrawals_read = Right.find_by_resource_and_operation( 'withdrawals',  'READ') 
      withdrawals_delete = Right.find_by_resource_and_operation( 'withdrawals',  'DELETE')
      withdrawals_update = Right.find_by_resource_and_operation( 'withdrawals',  'UPDATE')
     
   #professional_owner 
     professional_owner.rights << withdrawals_create
     professional_owner.rights << withdrawals_read
     professional_owner.rights << withdrawals_update
     professional_owner.rights << withdrawals_delete
      #professional_accountant
     professional_accountant.rights << withdrawals_create
     professional_accountant.rights << withdrawals_read
     professional_accountant.rights << withdrawals_update
     professional_accountant.rights << withdrawals_delete
      #professional_staff
     professional_staff.rights << withdrawals_create
     professional_staff.rights << withdrawals_read
     professional_staff.rights << withdrawals_update
     professional_staff.rights << withdrawals_delete
      #professional_auditor
     professional_auditor.rights << withdrawals_read


      deposits_create = Right.find_by_resource_and_operation( 'deposits',  'CREATE')
      deposits_read = Right.find_by_resource_and_operation( 'deposits',  'READ') 
      deposits_delete = Right.find_by_resource_and_operation( 'deposits',  'DELETE')
      deposits_update = Right.find_by_resource_and_operation( 'deposits',  'UPDATE')
    
    #professional_owner  
     professional_owner.rights << deposits_create
     professional_owner.rights << deposits_read
     professional_owner.rights << deposits_update
     professional_owner.rights << deposits_delete
      #professional_accountant
     professional_accountant.rights << deposits_create
     professional_accountant.rights << deposits_read
     professional_accountant.rights << deposits_update
     professional_accountant.rights << deposits_delete
      #professional_staff
     professional_staff.rights << deposits_create
     professional_staff.rights << deposits_read
     professional_staff.rights << deposits_update
     professional_staff.rights << deposits_delete
      #professional_auditor
     professional_auditor.rights << deposits_read


      transfer_cashes_create = Right.find_by_resource_and_operation( 'transfer_cashes',  'CREATE')
      transfer_cashes_read = Right.find_by_resource_and_operation( 'transfer_cashes',  'READ') 
      transfer_cashes_delete = Right.find_by_resource_and_operation( 'transfer_cashes',  'DELETE')
      transfer_cashes_update = Right.find_by_resource_and_operation( 'transfer_cashes',  'UPDATE')
     
    #professional_owner  
      professional_owner.rights << transfer_cashes_create
      professional_owner.rights << transfer_cashes_read
      professional_owner.rights << transfer_cashes_update
      professional_owner.rights << transfer_cashes_delete
      #professional_accountant
      professional_accountant.rights << transfer_cashes_create
      professional_accountant.rights << transfer_cashes_read
      professional_accountant.rights << transfer_cashes_update
      professional_accountant.rights << transfer_cashes_delete
      #professional_staff
      professional_staff.rights << transfer_cashes_create
      professional_staff.rights << transfer_cashes_read
      professional_staff.rights << transfer_cashes_update
      professional_staff.rights << transfer_cashes_delete
      #professional_auditor
      professional_auditor.rights << transfer_cashes_read



      journals_create = Right.find_by_resource_and_operation( 'journals',  'CREATE')
      journals_read = Right.find_by_resource_and_operation( 'journals',  'READ') 
      journals_delete = Right.find_by_resource_and_operation( 'journals',  'DELETE')
      journals_update = Right.find_by_resource_and_operation( 'journals',  'UPDATE')
    
   #professional_owner 
     professional_owner.rights << journals_create
     professional_owner.rights << journals_read
     professional_owner.rights << journals_update
     professional_owner.rights << journals_delete
      #professional_accountant
     professional_accountant.rights << journals_create
     professional_accountant.rights << journals_read
     professional_accountant.rights << journals_update
     professional_accountant.rights << journals_delete
      #professional_staff
     professional_staff.rights << journals_create
     professional_staff.rights << journals_read
     professional_staff.rights << journals_update
     professional_staff.rights << journals_delete
      #professional_auditor
      professional_auditor.rights << journals_read


      debit_notes_create = Right.find_by_resource_and_operation( 'debit_notes',  'CREATE')
      debit_notes_read = Right.find_by_resource_and_operation( 'debit_notes',  'READ') 
      debit_notes_delete = Right.find_by_resource_and_operation( 'debit_notes',  'DELETE')
      debit_notes_update = Right.find_by_resource_and_operation( 'debit_notes',  'UPDATE')
    
   #professional_owner 
      professional_owner.rights << debit_notes_create
      professional_owner.rights << debit_notes_read
      professional_owner.rights << debit_notes_update
      professional_owner.rights << debit_notes_delete
      #professional_accountant
      professional_accountant.rights << debit_notes_create
      professional_accountant.rights << debit_notes_read
      professional_accountant.rights << debit_notes_update
      professional_accountant.rights << debit_notes_delete
      #professional_staff
      professional_staff.rights << debit_notes_create
      professional_staff.rights << debit_notes_read
      professional_staff.rights << debit_notes_update
      professional_staff.rights << debit_notes_delete
      #professional_auditor
      professional_auditor.rights << debit_notes_read


      credit_notes_create = Right.find_by_resource_and_operation( 'credit_notes',  'CREATE')
      credit_notes_read = Right.find_by_resource_and_operation( 'credit_notes',  'READ') 
      credit_notes_delete = Right.find_by_resource_and_operation( 'credit_notes',  'DELETE')
      credit_notes_update = Right.find_by_resource_and_operation( 'credit_notes',  'UPDATE')
     
   #professional_owner 
      professional_owner.rights << credit_notes_create
      professional_owner.rights << credit_notes_read
      professional_owner.rights << credit_notes_update
      professional_owner.rights << credit_notes_delete
      #professional_accountant
      professional_accountant.rights << credit_notes_create
      professional_accountant.rights << credit_notes_read
      professional_accountant.rights << credit_notes_update
      professional_accountant.rights << credit_notes_delete
      #professional_staff
      professional_staff.rights << credit_notes_create
      professional_staff.rights << credit_notes_read
      professional_staff.rights << credit_notes_update
      professional_staff.rights << credit_notes_delete
      #professional_auditor
       professional_auditor.rights << credit_notes_read


      saccountings_create = Right.find_by_resource_and_operation( 'saccountings',  'CREATE')
      saccountings_read = Right.find_by_resource_and_operation( 'saccountings',  'READ') 
      saccountings_delete = Right.find_by_resource_and_operation( 'saccountings',  'DELETE')
      saccountings_update = Right.find_by_resource_and_operation( 'saccountings',  'UPDATE')
    
   #professional_owner 
      professional_owner.rights << saccountings_create
      professional_owner.rights << saccountings_read
      professional_owner.rights << saccountings_update
      professional_owner.rights << saccountings_delete
      #professional_accountant
      professional_accountant.rights << saccountings_create
      professional_accountant.rights << saccountings_read
      professional_accountant.rights << saccountings_update
      professional_accountant.rights << saccountings_delete
      #professional_staff
      professional_staff.rights << saccountings_create
      professional_staff.rights << saccountings_read
      professional_staff.rights << saccountings_update
      professional_staff.rights << saccountings_delete
      #professional_auditor
      professional_auditor.rights << saccountings_read

      horizontal_balance_sheet_read = Right.find_by_resource_and_operation( 'horizontal_balance_sheet',  'READ') 

     #professional_owner 
      professional_owner.rights << horizontal_balance_sheet_read
      #professional_accountant
      professional_accountant.rights << horizontal_balance_sheet_read
      #professional_auditor
      professional_auditor.rights << horizontal_balance_sheet_read  

      horizontal_profit_and_loss_read = Right.find_by_resource_and_operation( 'horizontal_profit_and_loss',  'READ') 
    #professional_owner  
      professional_owner.rights << horizontal_profit_and_loss_read
      #professional_accountant
      professional_accountant.rights << horizontal_profit_and_loss_read
      #professional_auditor
      professional_auditor.rights << horizontal_profit_and_loss_read   

      trial_balance_read = Right.find_by_resource_and_operation( 'trial_balance',  'READ') 
      
    #professional_owner  
       professional_owner.rights << trial_balance_read
      #professional_accountant
      professional_accountant.rights << trial_balance_read
      #professional_auditor
      professional_auditor.rights << trial_balance_read    

      bank_book_read = Right.find_by_resource_and_operation( 'bank_book',  'READ') 
      
  #professional_owner  #
      professional_owner.rights << bank_book_read
      #professional_accountant
      professional_accountant.rights << bank_book_read
      #professional_auditor
       professional_auditor.rights << bank_book_read
     #basic_owner #

      cash_book_read = Right.find_by_resource_and_operation( 'cash_book',  'READ') 
     
  #professional_owner  
      professional_owner.rights << cash_book_read
      #professional_accountant
      professional_accountant.rights << cash_book_read
      #professional_auditor
      professional_auditor.rights << cash_book_read
    
      credit_note_register_read = Right.find_by_resource_and_operation( 'credit_note_register',  'READ') 
   #professional_owner 
     professional_owner.rights << credit_note_register_read
      #professional_accountant
     professional_accountant.rights << credit_note_register_read
      #professional_auditor
     professional_auditor.rights << credit_note_register_read  


      debit_note_register_read = Right.find_by_resource_and_operation( 'debit_note_register',  'READ') 
   #professional_owner 
      professional_owner.rights << debit_note_register_read
      #professional_accountant
      professional_accountant.rights << debit_note_register_read
      #professional_auditor
      professional_auditor.rights << debit_note_register_read
      journal_register_read = Right.find_by_resource_and_operation( 'journal_register',  'READ') 
   #professional_owner 
       professional_owner.rights << journal_register_read
      #professional_accountant
      professional_accountant.rights << journal_register_read
      #professional_auditor
      professional_auditor.rights << journal_register_read

      bills_payable_read = Right.find_by_resource_and_operation( 'bills_payable',  'READ') 
    
    #professional_owner  
      professional_owner.rights << bills_payable_read
      #professional_accountant
      professional_accountant.rights << bills_payable_read
      #professional_auditor
      professional_auditor.rights << bills_payable_read 

      bills_receivable_read = Right.find_by_resource_and_operation( 'bills_receivable',  'READ') 
    #professional_owner  
      professional_owner.rights << bills_receivable_read
      #professional_accountant
      professional_accountant.rights << bills_receivable_read
      #professional_auditor
      professional_auditor.rights << bills_receivable_read 

      purchase_register_read = Right.find_by_resource_and_operation( 'purchase_register',  'READ') 
      #professional_owner  
      professional_owner.rights << purchase_register_read
      #professional_accountant
      professional_accountant.rights << purchase_register_read
      #professional_auditor
      professional_auditor.rights << purchase_register_read 

      sales_register_read = Right.find_by_resource_and_operation( 'sales_register',  'READ') 
     #professional_owner 
     professional_owner.rights << sales_register_read
      #professional_accountant
     professional_accountant.rights << sales_register_read
      #professional_auditor
     professional_auditor.rights << sales_register_read  

      sundry_creditor_read = Right.find_by_resource_and_operation( 'sundry_creditor',  'READ') 
     #professional_owner 
      professional_owner.rights << sundry_creditor_read
      #professional_accountant
      professional_accountant.rights << sundry_creditor_read
      #professional_auditor
      professional_auditor.rights << sundry_creditor_read

      account_books_and_registers_read = Right.find_by_resource_and_operation( 'account_books_and_registers',  'READ') 
    #professional_owner  
    professional_owner.rights << account_books_and_registers_read
      #  professional_accountant
     professional_accountant.rights << account_books_and_registers_read
      #  professional_auditor
    professional_auditor.rights << account_books_and_registers_read  

      daybook_read = Right.find_by_resource_and_operation( 'daybook',  'READ') 
    #professional_owner  
     professional_owner.rights << daybook_read
      #professional_accountant
     professional_accountant.rights << daybook_read
      #professional_auditor
     professional_auditor.rights << daybook_read  

      workstreams_read = Right.find_by_resource_and_operation( 'workstreams',  'READ') 
     #professional_owner 
     professional_owner.rights << workstreams_read
      #professional_accountant
     professional_accountant.rights << workstreams_read
      #professional_auditor
     professional_auditor.rights << workstreams_read  

      accounts_create = Right.find_by_resource_and_operation( 'accounts',  'CREATE')
      accounts_read = Right.find_by_resource_and_operation( 'accounts',  'READ') 
      accounts_delete = Right.find_by_resource_and_operation( 'accounts',  'DELETE')
      accounts_update = Right.find_by_resource_and_operation( 'accounts',  'UPDATE')
      #professional_owner  
     professional_owner.rights << accounts_create
     professional_owner.rights << accounts_read
     professional_owner.rights << accounts_update
     professional_owner.rights << accounts_delete
      #professional_accountant
     professional_accountant.rights << accounts_create
     professional_accountant.rights << accounts_read
     professional_accountant.rights << accounts_update
     professional_accountant.rights << accounts_delete
      #professional_staff
      #professional_auditor
     professional_auditor.rights << accounts_read

      account_heads_create = Right.find_by_resource_and_operation( 'account_heads',  'CREATE')
      account_heads_read = Right.find_by_resource_and_operation( 'account_heads',  'READ') 
      account_heads_delete = Right.find_by_resource_and_operation( 'account_heads',  'DELETE')
      account_heads_update = Right.find_by_resource_and_operation( 'account_heads',  'UPDATE')
   #professional_owner 
  professional_owner.rights << account_heads_create
  professional_owner.rights << account_heads_read
  professional_owner.rights << account_heads_update
  professional_owner.rights << account_heads_delete
      #professional_accountant
  professional_accountant.rights << account_heads_create
  professional_accountant.rights << account_heads_read
  professional_accountant.rights << account_heads_update
  professional_accountant.rights << account_heads_delete
      #professional_staff
  professional_staff.rights << account_heads_create
     professional_staff.rights << account_heads_read
  professional_staff.rights << account_heads_update
  professional_staff.rights << account_heads_delete
      #professional_auditor
  professional_auditor.rights << account_heads_read   

      users_create = Right.find_by_resource_and_operation( 'users',  'CREATE')
      users_read = Right.find_by_resource_and_operation( 'users',  'READ') 
      users_delete = Right.find_by_resource_and_operation( 'users',  'DELETE')
      users_update = Right.find_by_resource_and_operation( 'users',  'UPDATE')
   #professional_owner 
  professional_owner.rights << users_create
  professional_owner.rights << users_read
  professional_owner.rights << users_update
  professional_owner.rights << users_delete
      #professional_accountant
  professional_accountant.rights << users_create
  professional_accountant.rights << users_read
  professional_accountant.rights << users_update
  professional_accountant.rights << users_delete
      #professional_staff
  professional_staff.rights << users_read
      #professional_auditor
  professional_auditor.rights << users_read  
  #professional_employee
    professional_employee.rights << users_read
    professional_employee.rights << users_update  


      companies_create = Right.find_by_resource_and_operation( 'companies',  'CREATE')
      companies_read = Right.find_by_resource_and_operation( 'companies',  'READ') 
      companies_delete = Right.find_by_resource_and_operation( 'companies',  'DELETE')
      companies_update = Right.find_by_resource_and_operation( 'companies',  'UPDATE')
      #professional_owner  
    professional_owner.rights << companies_create
    professional_owner.rights << companies_read
    professional_owner.rights << companies_update
    professional_owner.rights << companies_delete
    #professional_accountant
    professional_accountant.rights << companies_read
    #professional_auditor
    professional_auditor.rights << companies_read
      settings_read = Right.find_by_resource_and_operation( 'settings',  'READ') 
      settings_update = Right.find_by_resource_and_operation( 'settings',  'UPDATE')
  #professional_owner  
  professional_owner.rights << settings_read
  professional_owner.rights << settings_update

      #professional_accountant
  professional_accountant.rights << settings_read
      #professional_auditor
  professional_auditor.rights << settings_read

  # Support
      supports_create = Right.find_by_resource_and_operation('supports',  'CREATE')
      supports_read = Right.find_by_resource_and_operation('supports',  'READ') 
      supports_delete = Right.find_by_resource_and_operation('supports',  'DELETE')
      supports_update = Right.find_by_resource_and_operation('supports',  'UPDATE')

     
    #professional_owner  
      professional_owner.rights << supports_create
      professional_owner.rights << supports_read
      professional_owner.rights << supports_update
      professional_owner.rights << supports_delete
      #professional_accountant
      professional_accountant.rights << supports_create
      professional_accountant.rights << supports_read
      professional_accountant.rights << supports_update
      professional_accountant.rights << supports_delete
      #professional_staff
      professional_staff.rights << supports_create
      professional_staff.rights << supports_read
      professional_staff.rights << supports_update
      professional_staff.rights << supports_delete
      #professional_employee
      professional_employee.rights << supports_create
      professional_employee.rights << supports_read
      professional_employee.rights << supports_update
      professional_employee.rights << supports_delete
      # Feedback
      feedbacks_create = Right.find_by_resource_and_operation('feedbacks', 'CREATE')
      feedbacks_read = Right.find_by_resource_and_operation('feedbacks', 'READ') 
      feedbacks_delete = Right.find_by_resource_and_operation('feedbacks', 'DELETE')
      feedbacks_update = Right.find_by_resource_and_operation('feedbacks', 'UPDATE')
     
    #professional_owner  
      professional_owner.rights << feedbacks_create
      professional_owner.rights << feedbacks_read
      professional_owner.rights << feedbacks_update
      professional_owner.rights << feedbacks_delete
      #basic_accountant
      professional_accountant.rights << feedbacks_create
      professional_accountant.rights << feedbacks_read
      professional_accountant.rights << feedbacks_update
      professional_accountant.rights << feedbacks_delete
     #professional_staff
      professional_staff.rights << feedbacks_create
      professional_staff.rights << feedbacks_read
      professional_staff.rights << feedbacks_update
      professional_staff.rights << feedbacks_delete

      #professional_employee
      professional_employee.rights << feedbacks_create
      professional_employee.rights << feedbacks_read
      professional_employee.rights << feedbacks_update
      professional_employee.rights << feedbacks_delete
      # Salary slip
      salary_slip_create = Right.find_by_resource_and_operation('salary_slip', 'CREATE')
      salary_slip_read = Right.find_by_resource_and_operation('salary_slip', 'READ') 
      salary_slip_delete = Right.find_by_resource_and_operation('salary_slip', 'DELETE')
      salary_slip_update = Right.find_by_resource_and_operation('salary_slip', 'UPDATE')
      #professional_owner  
      professional_owner.rights << salary_slip_create
      professional_owner.rights << salary_slip_read
      professional_owner.rights << salary_slip_update
      professional_owner.rights << salary_slip_delete
      #professional_accountant
      professional_accountant.rights << salary_slip_create
      professional_accountant.rights << salary_slip_read
      professional_accountant.rights << salary_slip_update
      professional_accountant.rights << salary_slip_delete
      #professional_staff
      professional_staff.rights << salary_slip_read
     #professional_auditor
      professional_auditor.rights << salary_slip_read
     #professional_employee
      professional_employee.rights << salary_slip_read

      # Payroll rights for controller 
      payroll_dashboard_read = Right.find_by_resource_and_operation('payroll_dashboard','READ')  

      #professional_owner  
      professional_owner.rights << payroll_dashboard_read
      #professional_accountant
      professional_accountant.rights << payroll_dashboard_read
      #professional_staff
      professional_staff.rights << payroll_dashboard_read
      #professional_auditor
      professional_auditor.rights << payroll_dashboard_read
      #professional_employee
      professional_employee.rights << payroll_dashboard_read

      #Assets
       assets_read = Right.find_by_resource_and_operation('assets','READ') 
       assets_create = Right.find_by_resource_and_operation('assets','CREATE') 
       assets_update = Right.find_by_resource_and_operation('assets','UPDATE') 
       assets_delete = Right.find_by_resource_and_operation('assets','DELETE') 

       #professional_owner 
       professional_owner.rights << assets_create
       professional_owner.rights << assets_read
       professional_owner.rights << assets_update
       professional_owner.rights << assets_delete
       #professional_accountant
       professional_accountant.rights << assets_create
       professional_accountant.rights << assets_read
       professional_accountant.rights << assets_update
       #professional_staff
       professional_staff.rights << assets_read
       #professional_employee
       professional_employee.rights << assets_read

       #Departments
        departments_read = Right.find_by_resource_and_operation('departments','READ')
        departments_create = Right.find_by_resource_and_operation('departments','CREATE')
        departments_update = Right.find_by_resource_and_operation('departments','UPDATE')
        departments_delete = Right.find_by_resource_and_operation('departments','DELETE')
        #professional_owner 
        professional_owner.rights << departments_create
        professional_owner.rights << departments_read
        professional_owner.rights << departments_update
        professional_owner.rights << departments_delete
        #professional_accountant
        professional_accountant.rights << departments_read
        #professional_staff
        professional_staff.rights << departments_read
        #professional_employee
        professional_employee.rights << departments_read

        #Designation
        designations_read = Right.find_by_resource_and_operation('designations','READ')  
        designations_create = Right.find_by_resource_and_operation('designations','CREATE')  
        designations_update = Right.find_by_resource_and_operation('designations','UPDATE')  
        designations_delete = Right.find_by_resource_and_operation('designations','DELETE')  
        #professional_owner 
        professional_owner.rights << designations_create
        professional_owner.rights << designations_read
        professional_owner.rights << designations_update
        professional_owner.rights << designations_delete
        #professional_accountant
        professional_accountant.rights << designations_read
        #professional_staff
        professional_staff.rights << designations_read
        #professional_employee
        professional_employee.rights << designations_read
        #Holidays
        holidays_read = Right.find_by_resource_and_operation('holidays','READ')  
        holidays_create = Right.find_by_resource_and_operation('holidays','CREATE')  
        holidays_update = Right.find_by_resource_and_operation('holidays','UPDATE')  
        holidays_delete = Right.find_by_resource_and_operation('holidays','DELETE')  
        #professional_owner 
        professional_owner.rights << holidays_create
        professional_owner.rights << holidays_read
        professional_owner.rights << holidays_update
        professional_owner.rights << holidays_delete
        #professional_accountant
        professional_accountant.rights << holidays_read
        #professional_staff
        professional_staff.rights << holidays_read
        #professional_auditor
        professional_auditor.rights << holidays_read
        #professional_employee
        professional_employee.rights << holidays_read

        #Organisation anounsments
        organisation_announcements_read = Right.find_by_resource_and_operation('organisation_announcements','READ')  
        organisation_announcements_create = Right.find_by_resource_and_operation('organisation_announcements','CREATE')  
        organisation_announcements_update = Right.find_by_resource_and_operation('organisation_announcements','UPDATE')  
        organisation_announcements_delete = Right.find_by_resource_and_operation('organisation_announcements','DELETE')  
        #professional_owner 
        professional_owner.rights << organisation_announcements_create
        professional_owner.rights << organisation_announcements_read
        professional_owner.rights << organisation_announcements_update
        professional_owner.rights << organisation_announcements_delete
        #professional_accountant
        professional_accountant.rights << organisation_announcements_read
        #professional_staff
        professional_staff.rights << organisation_announcements_read
        #professional_employee
        professional_employee.rights << organisation_announcements_read

        #Salary structure
        salary_structures_read = Right.find_by_resource_and_operation('salary_structures','READ')
        salary_structures_create = Right.find_by_resource_and_operation('salary_structures','CREATE')
        salary_structures_update = Right.find_by_resource_and_operation('salary_structures','UPDATE')
        salary_structures_delete = Right.find_by_resource_and_operation('salary_structures','DELETE')
        #professional_owner 
        professional_owner.rights << salary_structures_create
        professional_owner.rights << salary_structures_read
        professional_owner.rights << salary_structures_update
        professional_owner.rights << salary_structures_delete
        #professional_accountant
        professional_accountant.rights << salary_structures_read
        #professional_staff
        professional_staff.rights << salary_structures_read
        #professional_auditor
        professional_auditor.rights << salary_structures_read
       #professional_employee
        professional_employee.rights << salary_structures_read
        
        #Leave request
        leave_requests_create = Right.find_by_resource_and_operation('leave_requests','CREATE')
        leave_requests_read = Right.find_by_resource_and_operation('leave_requests','READ')
        leave_requests_update = Right.find_by_resource_and_operation('leave_requests','UPDATE')
        leave_requests_delete = Right.find_by_resource_and_operation('leave_requests','DELETE')
        #professional_owner 
        professional_owner.rights << leave_requests_create
        professional_owner.rights << leave_requests_read
        professional_owner.rights << leave_requests_update
        professional_owner.rights << leave_requests_delete
        #professional_accountantthe village movie
        professional_accountant.rights << leave_requests_create
        professional_accountant.rights << leave_requests_read
        professional_accountant.rights << leave_requests_update
        #professional_staff
        professional_staff.rights << leave_requests_create
        professional_staff.rights << leave_requests_read
        professional_staff.rights << leave_requests_update
        #professional_employee
        professional_employee.rights << leave_requests_create
        professional_employee.rights << leave_requests_read
        professional_employee.rights << leave_requests_update

        #Timesheets
        timesheets_create = Right.find_by_resource_and_operation('timesheets','CREATE')
        timesheets_read = Right.find_by_resource_and_operation('timesheets','READ')
        timesheets_delete = Right.find_by_resource_and_operation('timesheets','DELETE')
        timesheets_update = Right.find_by_resource_and_operation('timesheets','UPDATE')
        #professional_owner 
        professional_owner.rights << timesheets_create
        professional_owner.rights << timesheets_read
        professional_owner.rights << timesheets_update
        professional_owner.rights << timesheets_delete
        #professional_accountant
        professional_accountant.rights << timesheets_create
        professional_accountant.rights << timesheets_read
        professional_accountant.rights << timesheets_update
        professional_accountant.rights << timesheets_delete
        #professional_staff
    #    professional_staff.rights << timesheets_create
        professional_staff.rights << timesheets_read
        professional_staff.rights << timesheets_update
    #    professional_staff.rights << timesheets_delete
        #professional_employee
        # professional_employee.rights << timesheets_create
        professional_employee.rights << timesheets_read
        professional_employee.rights << timesheets_update
        # professional_employee.rights << timesheets_delete
        #Policy documents
        policy_documents_read = Right.find_by_resource_and_operation('policy_documents','READ')
        policy_documents_create = Right.find_by_resource_and_operation('policy_documents','CREATE')
        policy_documents_update = Right.find_by_resource_and_operation('policy_documents','UPDATE')
        policy_documents_delete = Right.find_by_resource_and_operation('policy_documents','DELETE')

       #professional_owner 
        professional_owner.rights << policy_documents_create
        professional_owner.rights << policy_documents_read
        professional_owner.rights << policy_documents_update
        professional_owner.rights << policy_documents_delete
        #professional_accountant
        professional_accountant.rights << policy_documents_create
        professional_accountant.rights << policy_documents_read
        professional_accountant.rights << policy_documents_update
        professional_accountant.rights << policy_documents_delete
        #professional_staff
        professional_staff.rights << policy_documents_read
        #professional_employee
        professional_employee.rights << policy_documents_read

        #Folder
        folders_create = Right.find_by_resource_and_operation('folders','CREATE')
        folders_read = Right.find_by_resource_and_operation('folders','READ')
        folders_delete = Right.find_by_resource_and_operation('folders','DELETE')
        folders_update = Right.find_by_resource_and_operation('folders','UPDATE')

       #professional_owner 
        professional_owner.rights << folders_create
        professional_owner.rights << folders_read
        professional_owner.rights << folders_update
        professional_owner.rights << folders_delete
        #professional_accountant
        professional_accountant.rights << folders_create
        professional_accountant.rights << folders_read
        professional_accountant.rights << folders_update
        professional_accountant.rights << folders_delete
        #professional_staff
        professional_staff.rights << folders_create
        professional_staff.rights << folders_read
        professional_staff.rights << folders_update
        professional_staff.rights << folders_delete
        #professional_employee
        professional_employee.rights << folders_create
        professional_employee.rights << folders_read
        professional_employee.rights << folders_update
        professional_employee.rights << folders_delete

        #My files
        myfiles_create = Right.find_by_resource_and_operation('myfiles','CREATE')
        myfiles_read = Right.find_by_resource_and_operation('myfiles','READ')
        myfiles_delete = Right.find_by_resource_and_operation('myfiles','DELETE')
        myfiles_update = Right.find_by_resource_and_operation('myfiles','UPDATE')

       #professional_owner 
        professional_owner.rights << myfiles_create
        professional_owner.rights << myfiles_read
        professional_owner.rights << myfiles_update
        professional_owner.rights << myfiles_delete
        #professional_accountant
        professional_accountant.rights << myfiles_create
        professional_accountant.rights << myfiles_read
        professional_accountant.rights << myfiles_update
        professional_accountant.rights << myfiles_delete
        #professional_staff
        professional_staff.rights << myfiles_create
        professional_staff.rights << myfiles_read
        professional_staff.rights << myfiles_update
        professional_staff.rights << myfiles_delete
        #professional_employee
        professional_employee.rights << myfiles_create
        professional_employee.rights << myfiles_read
        professional_employee.rights << myfiles_update
        professional_employee.rights << myfiles_delete

        #Billing history
        billing_history_read = Right.find_by_resource_and_operation('billing_history','READ')
        professional_owner.rights << billing_history_read

        #Payroll register
        # payroll_register_read = Right.find_by_resource_and_operation('payroll_register', 'READ') 
        # professional_owner.rights << payroll_register_read
        # professional_accountant.rights << payroll_register_read
        # professional_auditor.rights << payroll_register_read

        #Attendance register
        # attendance_register_read = Right.find_by_resource_and_operation('attendance_register', 'READ')
        # trial_owne.rightsr << attendance_register_read
        # professional_accountant.rights << attendance_register_read
        # professional_auditor.rights << attendance_register_read

        # Employee breackups
        # employee_breakup_read = Right.find_by_resource_and_operation('employee_breakup', 'READ')
        # professional_owner.rights << employee_breakup_read
        # professional_accountant.rights << employee_breakup_read
        # professional_auditor.rights << employee_breakup_read

        #My organization
        my_organisation_create = Right.find_by_resource_and_operation('my_organisation', 'CREATE')
        my_organisation_read = Right.find_by_resource_and_operation('my_organisation', 'READ') 
        my_organisation_delete = Right.find_by_resource_and_operation('my_organisation', 'DELETE')
        my_organisation_update = Right.find_by_resource_and_operation('my_organisation', 'UPDATE')

        professional_owner.rights << my_organisation_create
        professional_owner.rights << my_organisation_read
        professional_owner.rights << my_organisation_update
        professional_owner.rights << my_organisation_delete
        professional_accountant.rights << my_organisation_read
        #   professional_staff
        professional_staff.rights << my_organisation_read
        #  professional_employee
        professional_employee.rights << my_organisation_read
        #Projects
        projects_create = Right.find_by_resource_and_operation('projects', 'CREATE')
        projects_read = Right.find_by_resource_and_operation('projects', 'READ') 
        projects_delete = Right.find_by_resource_and_operation('projects', 'DELETE')
        projects_update = Right.find_by_resource_and_operation('projects', 'UPDATE')

        professional_owner.rights << projects_create
        professional_owner.rights << projects_read
        professional_owner.rights << projects_update
        professional_owner.rights << projects_delete
        #professional_accountant
        professional_accountant.rights << projects_create
        professional_accountant.rights << projects_read
        professional_accountant.rights << projects_update
        professional_accountant.rights << projects_delete
        #professional_staff
        professional_staff.rights << projects_read
        #professional_auditor
        professional_auditor.rights << projects_read

        #Billing History
        billing_history_read = Right.find_by_resource_and_operation('billing_history', 'READ')

        professional_owner.rights << billing_history_read

        #Invoice setting
        # invoice_settings_create = Right.find_by_resource_and_operation('invoice_settings', 'CREATE')
        invoice_settings_read = Right.find_by_resource_and_operation('invoice_settings', 'READ') 
        # invoice_settings_delete = Right.find_by_resource_and_operation('invoice_settings', 'DELETE')
        invoice_settings_update = Right.find_by_resource_and_operation('invoice_settings', 'UPDATE')

        #professional_owner 
        # professional_owner.rights << invoice_settings_create
        professional_owner.rights << invoice_settings_read
        professional_owner.rights << invoice_settings_update
        # professional_owner.rights << invoice_settings_delete

        #Product
        product_create = Right.find_by_resource_and_operation('products', 'CREATE')
        product_read = Right.find_by_resource_and_operation('products', 'READ') 
        product_delete = Right.find_by_resource_and_operation('products', 'DELETE')
        product_update = Right.find_by_resource_and_operation('products', 'UPDATE')

        #professional_owner 
        professional_owner.rights << product_create
        professional_owner.rights << product_read
        professional_owner.rights << product_update
        professional_owner.rights << product_delete
        #professional_accountant
        professional_accountant.rights << product_create
        professional_accountant.rights << product_read
        professional_accountant.rights << product_update
        professional_accountant.rights << product_delete
        #professional_staff
        professional_staff.rights << product_read
        #professional_auditor
        professional_auditor.rights << product_read

        #Leave types
        leave_types_create = Right.find_by_resource_and_operation('leave_types', 'CREATE')
        leave_types_read = Right.find_by_resource_and_operation('leave_types', 'READ') 
        leave_types_delete = Right.find_by_resource_and_operation('leave_types', 'DELETE')
        leave_types_update = Right.find_by_resource_and_operation('leave_types', 'UPDATE')

        #professional_owner 
        professional_owner.rights << leave_types_create
        professional_owner.rights << leave_types_read
        professional_owner.rights << leave_types_update
        professional_owner.rights << leave_types_delete
        #professional_accountant
        professional_accountant.rights << leave_types_read
        #professional_staff
        professional_staff.rights << leave_types_read

        #dropbox
        db_read = Right.find_by_resource_and_operation('db','READ')
        #professional_owner  
        professional_owner.rights << db_read
        #professional_accountant 
        professional_accountant.rights << db_read
        #professional_staff
        professional_staff.rights << db_read
        #professional_employee
        professional_employee.rights << db_read

        #Taxes
        duties_and_taxes_read = Right.find_by_resource_and_operation('duties_and_taxes', 'READ') 
        duties_and_taxes_create = Right.find_by_resource_and_operation('duties_and_taxes', 'CREATE')
        duties_and_taxes_delete = Right.find_by_resource_and_operation('duties_and_taxes', 'DELETE')
        duties_and_taxes_update = Right.find_by_resource_and_operation('duties_and_taxes', 'UPDATE')

        #professional_owner 
        professional_owner.rights << duties_and_taxes_create
        professional_owner.rights << duties_and_taxes_read
        professional_owner.rights << duties_and_taxes_update
        professional_owner.rights << duties_and_taxes_delete
        #professional_accountant
        professional_accountant.rights << duties_and_taxes_create
        professional_accountant.rights << duties_and_taxes_read
        professional_accountant.rights << duties_and_taxes_update
        professional_accountant.rights << duties_and_taxes_delete
        #professional_staff
        #professional_auditor
        professional_auditor.rights << duties_and_taxes_read

        #Plan properties
        PlanProperty.create!(:plan_id => professional_plan.id, :name => 'inventoriable', :value => '0', :datatype => 'boolean')
        PlanProperty.create!(:plan_id => professional_plan.id, :name => 'payroll', :value => '1', :datatype => 'boolean')
        PlanProperty.create!(:plan_id => professional_plan.id, :name => 'free_plan', :value => '0', :datatype => 'boolean')
        PlanProperty.create!(:plan_id => professional_plan.id, :name => 'foreign_plan', :value => '0', :datatype => 'boolean')

        #Auditor
        auditors_create = Right.find_by_resource_and_operation('auditors', 'CREATE')
        auditors_read = Right.find_by_resource_and_operation('auditors', 'READ') 
        auditors_delete = Right.find_by_resource_and_operation('auditors', 'DELETE')
        auditors_update = Right.find_by_resource_and_operation('auditors', 'UPDATE')

        #professional_owner 
        professional_owner.rights << auditors_create
        professional_owner.rights << auditors_read
        professional_owner.rights << auditors_update
        professional_owner.rights << auditors_delete

        #Billing
        billing_read = Right.find_by_resource_and_operation('billing', 'READ')
        #professional_owner 
        professional_owner.rights << billing_read

        # Payroll details
        payroll_details_create = Right.find_by_resource_and_operation('payroll_details', 'CREATE')
        payroll_details_read = Right.find_by_resource_and_operation('payroll_details', 'READ') 
        # payroll_details_delete = Right.find_by_resource_and_operation('payroll_details', 'DELETE')
        payroll_details_update = Right.find_by_resource_and_operation('payroll_details', 'UPDATE')

        #professional_owner  
        professional_owner.rights << payroll_details_create
        professional_owner.rights << payroll_details_read
        professional_owner.rights << payroll_details_update
        # professional_owner.rights << payroll_details_delete
        #professional_accountant
        professional_accountant.rights << payroll_details_create
        professional_accountant.rights << payroll_details_read
        professional_accountant.rights << payroll_details_update
        # professional_accountant.rights << payroll_details_delete
        #professional_auditor
        professional_auditor.rights << payroll_details_read
      #Invitation details  
      invitation_details_create = Right.find_by_resource_and_operation('invitation_details', 'CREATE')
      invitation_details_read = Right.find_by_resource_and_operation('invitation_details', 'READ') 
      invitation_details_delete = Right.find_by_resource_and_operation('invitation_details', 'DELETE')
      invitation_details_update = Right.find_by_resource_and_operation('invitation_details', 'UPDATE')
      
      #professional_owner  
      professional_owner.rights << invitation_details_create
      professional_owner.rights << invitation_details_read
      professional_owner.rights << invitation_details_update
      professional_owner.rights << invitation_details_delete 

      # Attendance
      attendances_create = Right.find_by_resource_and_operation('attendances', 'CREATE')
      attendances_read = Right.find_by_resource_and_operation('attendances', 'READ') 
      attendances_delete = Right.find_by_resource_and_operation('attendances', 'DELETE')
      attendances_update = Right.find_by_resource_and_operation('attendances', 'UPDATE')
      #professional_owner  
      professional_owner.rights << attendances_create
      professional_owner.rights << attendances_read
      professional_owner.rights << attendances_update
      professional_owner.rights << attendances_delete
      #professional_accountant
      professional_accountant.rights << attendances_create
      professional_accountant.rights << attendances_read
      professional_accountant.rights << attendances_update
      professional_accountant.rights << attendances_delete
      #professional_auditor
      professional_auditor.rights << attendances_read

      # Custom fields
      custom_fields_create = Right.find_by_resource_and_operation('custom_fields', 'CREATE')
      custom_fields_read = Right.find_by_resource_and_operation('custom_fields', 'READ') 
      custom_fields_delete = Right.find_by_resource_and_operation('custom_fields', 'DELETE')
      custom_fields_update = Right.find_by_resource_and_operation('custom_fields', 'UPDATE')

      #   professional_owner 
      professional_owner.rights << custom_fields_create
      professional_owner.rights << custom_fields_read
      professional_owner.rights << custom_fields_update
      professional_owner.rights << custom_fields_delete
      #   professional_accountant
      professional_accountant.rights << custom_fields_create
      professional_accountant.rights << custom_fields_read
      professional_accountant.rights << custom_fields_update
      professional_accountant.rights << custom_fields_delete

      # Leave approvals
      leaves_approval_create = Right.find_by_resource_and_operation('leave_approval', 'CREATE')
      leaves_approval_read = Right.find_by_resource_and_operation('leave_approval', 'READ') 
      leaves_approval_delete = Right.find_by_resource_and_operation('leave_approval', 'DELETE')
      leaves_approval_update = Right.find_by_resource_and_operation('leave_approval', 'UPDATE')
      # professional_owner
      professional_owner.rights << leaves_approval_create
      professional_owner.rights << leaves_approval_read
      professional_owner.rights << leaves_approval_update
      professional_owner.rights << leaves_approval_delete
      # professional_accountant
      professional_accountant.rights << leaves_approval_create
      professional_accountant.rights << leaves_approval_read
      professional_accountant.rights << leaves_approval_update
      professional_accountant.rights << leaves_approval_delete
      # professional_staff
      professional_staff.rights << leaves_approval_create
      professional_staff.rights << leaves_approval_read
      professional_staff.rights << leaves_approval_update
      professional_staff.rights << leaves_approval_delete

      # Leave cards
      leaves_create = Right.find_by_resource_and_operation('leave_cards', 'CREATE')
      leaves_read = Right.find_by_resource_and_operation('leave_cards', 'READ') 
      leaves_delete = Right.find_by_resource_and_operation('leave_cards', 'DELETE')
      leaves_update = Right.find_by_resource_and_operation('leave_cards', 'UPDATE')
      #professional_owner 
      professional_owner.rights << leaves_create
      professional_owner.rights << leaves_read
      professional_owner.rights << leaves_update
      professional_owner.rights << leaves_delete
      #professional_accountant
      professional_accountant.rights << leaves_create
      professional_accountant.rights << leaves_read
      professional_accountant.rights << leaves_update
      professional_accountant.rights << leaves_delete
      #professional_staff
      professional_staff.rights << leaves_create
      professional_staff.rights << leaves_read
      professional_staff.rights << leaves_update
      professional_staff.rights << leaves_delete
      #professional_employee
      professional_employee.rights << leaves_create
      professional_employee.rights << leaves_read
      professional_employee.rights << leaves_update
      professional_employee.rights << leaves_delete

      # Payheads
      payheads_create = Right.find_by_resource_and_operation('payheads', 'CREATE')
      payheads_read = Right.find_by_resource_and_operation('payheads', 'READ') 
      payheads_delete = Right.find_by_resource_and_operation('payheads', 'DELETE')
      payheads_update = Right.find_by_resource_and_operation('payheads', 'UPDATE')
      #professional_owner  
      professional_owner.rights << payheads_create
      professional_owner.rights << payheads_read
      professional_owner.rights << payheads_update
      professional_owner.rights << payheads_delete
      #professional_accountant
      professional_accountant.rights << payheads_read
      #professional_auditor
      professional_auditor.rights << payheads_read

      #salary structure history
      salary_structure_histories_create = Right.find_by_resource_and_operation('salary_structure_histories', 'CREATE') 
      salary_structure_histories_read = Right.find_by_resource_and_operation('salary_structure_histories', 'READ') 
      salary_structure_histories_update = Right.find_by_resource_and_operation('salary_structure_histories', 'UPDATE') 
      salary_structure_histories_delete = Right.find_by_resource_and_operation('salary_structure_histories', 'DELETE') 
      
      #professional_owner 
      professional_owner.rights << salary_structure_histories_create
      professional_owner.rights << salary_structure_histories_read
      professional_owner.rights << salary_structure_histories_update
      professional_owner.rights << salary_structure_histories_delete
      #professional_accountant
      professional_accountant.rights << salary_structure_histories_read
end
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first
ActiveRecord::Base.transaction do
  global_plan = Plan.create(:name => 'Global',:price => 375, :description => 'Global plan with multi user accounting, inventory managment and payroll.', :display_name => 'Global')

 #Global plan roles 
  global_owner = Role.create!(:name => 'Owner')
  global_plan.roles << global_owner
  global_accountant = Role.create!(:name => 'Accountant')
  global_plan.roles << global_accountant
  global_staff = Role.create!(:name => 'Staff')
  global_plan.roles << global_staff
  global_auditor = Role.create!(:name => 'Auditor')
  global_plan.roles << global_auditor
  global_employee = Role.create!(:name => 'Employee')
  global_plan.roles << global_employee

  # Dashboard rights
  dashboard_read = Right.find_by_resource_and_operation('dashboard','READ')  
  
    #global_owner 
    global_owner.rights << dashboard_read
    #global_accountant
    global_accountant.rights << dashboard_read
    #global_staff
    global_staff.rights << dashboard_read
    #global_auditor
    global_auditor.rights << dashboard_read 
  
   # free_owner.rights << tasks_delete
    tasks_create = Right.find_by_resource_and_operation( 'tasks',  'CREATE')
    tasks_read = Right.find_by_resource_and_operation( 'tasks',  'READ') 
    tasks_delete = Right.find_by_resource_and_operation( 'tasks',  'DELETE')
    tasks_update = Right.find_by_resource_and_operation( 'tasks',  'UPDATE')
   
  #global_owner  
    global_owner.rights << tasks_create
    global_owner.rights << tasks_read
    global_owner.rights << tasks_update
    global_owner.rights << tasks_delete
    #basic_accountant
    global_accountant.rights << tasks_create
    global_accountant.rights << tasks_read
    global_accountant.rights << tasks_update
    global_accountant.rights << tasks_delete
    #global_staff
    global_staff.rights << tasks_create
    global_staff.rights << tasks_read
    global_staff.rights << tasks_update
    global_staff.rights << tasks_delete
    #global_auditor
    global_auditor.rights << tasks_read 
    #global_employee
    global_employee.rights << tasks_create
    global_employee.rights << tasks_read
    global_employee.rights << tasks_update
    global_employee.rights << tasks_delete

  
    #messages_update = Right.create!(:resource => 'messages', :operation => 'UPDATE')
    messages_create = Right.find_by_resource_and_operation( 'messages',  'CREATE')
    messages_read = Right.find_by_resource_and_operation( 'messages',  'READ') 
    messages_delete = Right.find_by_resource_and_operation( 'messages',  'DELETE')
    messages_update = Right.find_by_resource_and_operation( 'messages',  'UPDATE')
    
    #global_owner  
    global_owner.rights << messages_create
    global_owner.rights << messages_read
    global_owner.rights << messages_update
    global_owner.rights << messages_delete
    #global_accountant
    global_accountant.rights << messages_create
    global_accountant.rights << messages_read
    global_accountant.rights << messages_update
    global_accountant.rights << messages_delete
    #global_staff
    global_staff.rights << messages_create
    global_staff.rights << messages_read
    global_staff.rights << messages_update
    global_staff.rights << messages_delete
    #global_auditor
    global_auditor.rights << messages_read
    #global_employee
    global_employee.rights << messages_create
    global_employee.rights << messages_read
    global_employee.rights << messages_update
    global_employee.rights << messages_delete

    #free_owner.rights << documents_delete
    documents_create = Right.find_by_resource_and_operation( 'documents',  'CREATE')
    documents_read = Right.find_by_resource_and_operation( 'documents',  'READ') 
    documents_delete = Right.find_by_resource_and_operation( 'documents',  'DELETE')
    documents_update = Right.find_by_resource_and_operation( 'documents',  'UPDATE')
    
     #global_owner 
     global_owner.rights << documents_create
     global_owner.rights << documents_read
     global_owner.rights << documents_update
     global_owner.rights << documents_delete
    #global_accountant
     global_accountant.rights << documents_create
     global_accountant.rights << documents_read
     global_accountant.rights << documents_update
     global_accountant.rights << documents_delete
     #global_staff
     global_staff.rights << documents_create
     global_staff.rights << documents_read
     global_staff.rights << documents_update
     global_staff.rights << documents_delete
     #global_auditor
     global_auditor.rights << documents_read
     #global_employee
      global_employee.rights << documents_create
      global_employee.rights << documents_read
      global_employee.rights << documents_update
      global_employee.rights << documents_delete
  
    notes_create = Right.find_by_resource_and_operation( 'notes',  'CREATE')
    notes_read = Right.find_by_resource_and_operation( 'notes',  'READ') 
    notes_delete = Right.find_by_resource_and_operation( 'notes',  'DELETE')
    notes_update = Right.find_by_resource_and_operation( 'notes',  'UPDATE')

    #global_owner  
     global_owner.rights << notes_create
     global_owner.rights << notes_read
     global_owner.rights << notes_update
     global_owner.rights << notes_delete
    #global_accountant
     global_accountant.rights << notes_create
     global_accountant.rights << notes_read
     global_accountant.rights << notes_update
     global_accountant.rights << notes_delete
    #global_staff
     global_staff.rights << notes_create
     global_staff.rights << notes_read
     global_staff.rights << notes_update
     global_staff.rights << notes_delete
    #global_auditor
     global_auditor.rights << notes_read
     #global_employee
    global_employee.rights << notes_create
    global_employee.rights << notes_read
    global_employee.rights << notes_update
    global_employee.rights << notes_delete


    invoices_create = Right.find_by_resource_and_operation( 'invoices',  'CREATE')
    invoices_read = Right.find_by_resource_and_operation( 'invoices',  'READ') 
    invoices_delete = Right.find_by_resource_and_operation( 'invoices',  'DELETE')
    invoices_update = Right.find_by_resource_and_operation( 'invoices',  'UPDATE')
 
   #global_owner 
     global_owner.rights << invoices_create
     global_owner.rights << invoices_read
     global_owner.rights << invoices_update
     global_owner.rights << invoices_delete
    #global_accountant
     global_accountant.rights << invoices_create
     global_accountant.rights << invoices_read
     global_accountant.rights << invoices_update
     global_accountant.rights << invoices_delete
    #global_staff
     global_staff.rights << invoices_create
     global_staff.rights << invoices_read
     global_staff.rights << invoices_update
     global_staff.rights << invoices_delete
    #global_auditor
     global_auditor.rights << invoices_read
    receipt_vouchers_create = Right.find_by_resource_and_operation( 'receipt_vouchers',  'CREATE')
    receipt_vouchers_read = Right.find_by_resource_and_operation( 'receipt_vouchers',  'READ') 
    receipt_vouchers_delete = Right.find_by_resource_and_operation( 'receipt_vouchers',  'DELETE')
    receipt_vouchers_update = Right.find_by_resource_and_operation( 'receipt_vouchers',  'UPDATE')
   
   #global_owner 
     global_owner.rights << receipt_vouchers_create
     global_owner.rights << receipt_vouchers_read
     global_owner.rights << receipt_vouchers_update
     global_owner.rights << receipt_vouchers_delete
    #global_accountant
     global_accountant.rights << receipt_vouchers_create
     global_accountant.rights << receipt_vouchers_read
     global_accountant.rights << receipt_vouchers_update
     global_accountant.rights << receipt_vouchers_delete
    #global_staff
     global_staff.rights << receipt_vouchers_create
     global_staff.rights << receipt_vouchers_read
     global_staff.rights << receipt_vouchers_update
     global_staff.rights << receipt_vouchers_delete
    #global_auditor
    global_auditor.rights << receipt_vouchers_read


    estimates_create = Right.find_by_resource_and_operation( 'estimates',  'CREATE')
    estimates_read = Right.find_by_resource_and_operation( 'estimates',  'READ') 
    estimates_delete = Right.find_by_resource_and_operation( 'estimates',  'DELETE')
    estimates_update = Right.find_by_resource_and_operation( 'estimates',  'UPDATE')
    
 #global_owner 
     global_owner.rights << estimates_create
     global_owner.rights << estimates_read
     global_owner.rights << estimates_update
     global_owner.rights << estimates_delete
    #global_accountant
     global_accountant.rights << estimates_create
     global_accountant.rights << estimates_read
     global_accountant.rights << estimates_update
     global_accountant.rights << estimates_delete
    #global_staff
     global_staff.rights << estimates_create
     global_staff.rights << estimates_read
     global_staff.rights << estimates_update
     global_staff.rights << estimates_delete
    #global_auditor
     global_auditor.rights << estimates_read


    income_vouchers_create = Right.find_by_resource_and_operation( 'income_vouchers',  'CREATE')
    income_vouchers_read = Right.find_by_resource_and_operation( 'income_vouchers',  'READ') 
    income_vouchers_delete = Right.find_by_resource_and_operation( 'income_vouchers',  'DELETE')
    income_vouchers_update = Right.find_by_resource_and_operation( 'income_vouchers',  'UPDATE')
  
  #global_owner  
     global_owner.rights << income_vouchers_create
     global_owner.rights << income_vouchers_read
     global_owner.rights << income_vouchers_update
     global_owner.rights << income_vouchers_delete
    #global_accountant
     global_accountant.rights << income_vouchers_create
     global_accountant.rights << income_vouchers_read
     global_accountant.rights << income_vouchers_update
     global_accountant.rights << income_vouchers_delete
    #global_staff
     global_staff.rights << income_vouchers_create
     global_staff.rights << income_vouchers_read
     global_staff.rights << income_vouchers_update
     global_staff.rights << income_vouchers_delete
    #global_auditor
     global_auditor.rights << income_vouchers_read

    expenses_create = Right.find_by_resource_and_operation( 'expenses',  'CREATE')
    expenses_read = Right.find_by_resource_and_operation( 'expenses',  'READ') 
    expenses_delete = Right.find_by_resource_and_operation( 'expenses',  'DELETE')
    expenses_update = Right.find_by_resource_and_operation( 'expenses',  'UPDATE')

   #global_owner 
     global_owner.rights << expenses_create
     global_owner.rights << expenses_read
     global_owner.rights << expenses_update
     global_owner.rights << expenses_delete
   #global_accountant
     global_accountant.rights << expenses_create
     global_accountant.rights << expenses_read
     global_accountant.rights << expenses_update
     global_accountant.rights << expenses_delete
   #global_staff
     global_staff.rights << expenses_create
     global_staff.rights << expenses_read
     global_staff.rights << expenses_update
     global_staff.rights << expenses_delete
   #global_auditor
     global_auditor.rights << expenses_read#

    purchases_create = Right.find_by_resource_and_operation( 'purchases',  'CREATE')
    purchases_read = Right.find_by_resource_and_operation( 'purchases',  'READ') 
    purchases_delete = Right.find_by_resource_and_operation( 'purchases',  'DELETE')
    purchases_update = Right.find_by_resource_and_operation( 'purchases',  'UPDATE')
  
    #global_owner  
     global_owner.rights << purchases_create
     global_owner.rights << purchases_read
     global_owner.rights << purchases_update
     global_owner.rights << purchases_delete
    #global_accountant
     global_accountant.rights << purchases_create
     global_accountant.rights << purchases_read
     global_accountant.rights << purchases_update
     global_accountant.rights << purchases_delete
    #global_staff
     global_staff.rights << purchases_create
     global_staff.rights << purchases_read
     global_staff.rights << purchases_update
     global_staff.rights << purchases_delete
    #global_auditor
    global_auditor.rights << purchases_read



    purchase_orders_create = Right.find_by_resource_and_operation( 'purchase_orders',  'CREATE')
    purchase_orders_read = Right.find_by_resource_and_operation( 'purchase_orders',  'READ') 
    purchase_orders_delete = Right.find_by_resource_and_operation( 'purchase_orders',  'DELETE')
    purchase_orders_update = Right.find_by_resource_and_operation( 'purchase_orders',  'UPDATE')
   
  #global_owner  
     global_owner.rights << purchase_orders_create
     global_owner.rights << purchase_orders_read
     global_owner.rights << purchase_orders_update
     global_owner.rights << purchase_orders_delete
    #global_accountant
     global_accountant.rights << purchase_orders_create
     global_accountant.rights << purchase_orders_read
     global_accountant.rights << purchase_orders_update
     global_accountant.rights << purchase_orders_delete
    #global_staff
     global_staff.rights << purchase_orders_create
     global_staff.rights << purchase_orders_read
     global_staff.rights << purchase_orders_update
     global_staff.rights << purchase_orders_delete
    #global_auditor
     global_auditor.rights << purchase_orders_read



    payment_vouchers_create = Right.find_by_resource_and_operation( 'payment_vouchers',  'CREATE')
    payment_vouchers_read = Right.find_by_resource_and_operation( 'payment_vouchers',  'READ') 
    payment_vouchers_delete = Right.find_by_resource_and_operation( 'payment_vouchers',  'DELETE')
    payment_vouchers_update = Right.find_by_resource_and_operation( 'payment_vouchers',  'UPDATE')

 #global_owner 
     global_owner.rights << payment_vouchers_create
     global_owner.rights << payment_vouchers_read
     global_owner.rights << payment_vouchers_update
     global_owner.rights << payment_vouchers_delete
    #global_accountant
    global_accountant.rights << payment_vouchers_create
    global_accountant.rights << payment_vouchers_read
    global_accountant.rights << payment_vouchers_update
    global_accountant.rights << payment_vouchers_delete
    #global_staff
    global_staff.rights << payment_vouchers_create
    global_staff.rights << payment_vouchers_read
    global_staff.rights << payment_vouchers_update
    global_staff.rights << payment_vouchers_delete
    # global_auditor
    global_auditor.rights << payment_vouchers_read


    withdrawals_create = Right.find_by_resource_and_operation( 'withdrawals',  'CREATE')
    withdrawals_read = Right.find_by_resource_and_operation( 'withdrawals',  'READ') 
    withdrawals_delete = Right.find_by_resource_and_operation( 'withdrawals',  'DELETE')
    withdrawals_update = Right.find_by_resource_and_operation( 'withdrawals',  'UPDATE')
   
 #global_owner 
   global_owner.rights << withdrawals_create
   global_owner.rights << withdrawals_read
   global_owner.rights << withdrawals_update
   global_owner.rights << withdrawals_delete
    #global_accountant
   global_accountant.rights << withdrawals_create
   global_accountant.rights << withdrawals_read
   global_accountant.rights << withdrawals_update
   global_accountant.rights << withdrawals_delete
    #global_staff
   global_staff.rights << withdrawals_create
   global_staff.rights << withdrawals_read
   global_staff.rights << withdrawals_update
   global_staff.rights << withdrawals_delete
    #global_auditor
   global_auditor.rights << withdrawals_read


    deposits_create = Right.find_by_resource_and_operation( 'deposits',  'CREATE')
    deposits_read = Right.find_by_resource_and_operation( 'deposits',  'READ') 
    deposits_delete = Right.find_by_resource_and_operation( 'deposits',  'DELETE')
    deposits_update = Right.find_by_resource_and_operation( 'deposits',  'UPDATE')
  
  #global_owner  
   global_owner.rights << deposits_create
   global_owner.rights << deposits_read
   global_owner.rights << deposits_update
   global_owner.rights << deposits_delete
    #global_accountant
   global_accountant.rights << deposits_create
   global_accountant.rights << deposits_read
   global_accountant.rights << deposits_update
   global_accountant.rights << deposits_delete
    #global_staff
   global_staff.rights << deposits_create
   global_staff.rights << deposits_read
   global_staff.rights << deposits_update
   global_staff.rights << deposits_delete
    #global_auditor
   global_auditor.rights << deposits_read


    transfer_cashes_create = Right.find_by_resource_and_operation( 'transfer_cashes',  'CREATE')
    transfer_cashes_read = Right.find_by_resource_and_operation( 'transfer_cashes',  'READ') 
    transfer_cashes_delete = Right.find_by_resource_and_operation( 'transfer_cashes',  'DELETE')
    transfer_cashes_update = Right.find_by_resource_and_operation( 'transfer_cashes',  'UPDATE')
   
  #global_owner  
    global_owner.rights << transfer_cashes_create
    global_owner.rights << transfer_cashes_read
    global_owner.rights << transfer_cashes_update
    global_owner.rights << transfer_cashes_delete
    #global_accountant
    global_accountant.rights << transfer_cashes_create
    global_accountant.rights << transfer_cashes_read
    global_accountant.rights << transfer_cashes_update
    global_accountant.rights << transfer_cashes_delete
    #global_staff
    global_staff.rights << transfer_cashes_create
    global_staff.rights << transfer_cashes_read
    global_staff.rights << transfer_cashes_update
    global_staff.rights << transfer_cashes_delete
    #global_auditor
    global_auditor.rights << transfer_cashes_read



    journals_create = Right.find_by_resource_and_operation( 'journals',  'CREATE')
    journals_read = Right.find_by_resource_and_operation( 'journals',  'READ') 
    journals_delete = Right.find_by_resource_and_operation( 'journals',  'DELETE')
    journals_update = Right.find_by_resource_and_operation( 'journals',  'UPDATE')
  
 #global_owner 
   global_owner.rights << journals_create
   global_owner.rights << journals_read
   global_owner.rights << journals_update
   global_owner.rights << journals_delete
    #global_accountant
   global_accountant.rights << journals_create
   global_accountant.rights << journals_read
   global_accountant.rights << journals_update
   global_accountant.rights << journals_delete
    #global_staff
   global_staff.rights << journals_create
   global_staff.rights << journals_read
   global_staff.rights << journals_update
   global_staff.rights << journals_delete
    #global_auditor
    global_auditor.rights << journals_read


    debit_notes_create = Right.find_by_resource_and_operation( 'debit_notes',  'CREATE')
    debit_notes_read = Right.find_by_resource_and_operation( 'debit_notes',  'READ') 
    debit_notes_delete = Right.find_by_resource_and_operation( 'debit_notes',  'DELETE')
    debit_notes_update = Right.find_by_resource_and_operation( 'debit_notes',  'UPDATE')
  
 #global_owner 
    global_owner.rights << debit_notes_create
    global_owner.rights << debit_notes_read
    global_owner.rights << debit_notes_update
    global_owner.rights << debit_notes_delete
    #global_accountant
    global_accountant.rights << debit_notes_create
    global_accountant.rights << debit_notes_read
    global_accountant.rights << debit_notes_update
    global_accountant.rights << debit_notes_delete
    #global_staff
    global_staff.rights << debit_notes_create
    global_staff.rights << debit_notes_read
    global_staff.rights << debit_notes_update
    global_staff.rights << debit_notes_delete
    #global_auditor
    global_auditor.rights << debit_notes_read


    credit_notes_create = Right.find_by_resource_and_operation( 'credit_notes',  'CREATE')
    credit_notes_read = Right.find_by_resource_and_operation( 'credit_notes',  'READ') 
    credit_notes_delete = Right.find_by_resource_and_operation( 'credit_notes',  'DELETE')
    credit_notes_update = Right.find_by_resource_and_operation( 'credit_notes',  'UPDATE')
   
 #global_owner 
    global_owner.rights << credit_notes_create
    global_owner.rights << credit_notes_read
    global_owner.rights << credit_notes_update
    global_owner.rights << credit_notes_delete
    #global_accountant
    global_accountant.rights << credit_notes_create
    global_accountant.rights << credit_notes_read
    global_accountant.rights << credit_notes_update
    global_accountant.rights << credit_notes_delete
    #global_staff
    global_staff.rights << credit_notes_create
    global_staff.rights << credit_notes_read
    global_staff.rights << credit_notes_update
    global_staff.rights << credit_notes_delete
    #global_auditor
     global_auditor.rights << credit_notes_read


    saccountings_create = Right.find_by_resource_and_operation( 'saccountings',  'CREATE')
    saccountings_read = Right.find_by_resource_and_operation( 'saccountings',  'READ') 
    saccountings_delete = Right.find_by_resource_and_operation( 'saccountings',  'DELETE')
    saccountings_update = Right.find_by_resource_and_operation( 'saccountings',  'UPDATE')
  
 #global_owner 
    global_owner.rights << saccountings_create
    global_owner.rights << saccountings_read
    global_owner.rights << saccountings_update
    global_owner.rights << saccountings_delete
    #global_accountant
    global_accountant.rights << saccountings_create
    global_accountant.rights << saccountings_read
    global_accountant.rights << saccountings_update
    global_accountant.rights << saccountings_delete
    #global_staff
    global_staff.rights << saccountings_create
    global_staff.rights << saccountings_read
    global_staff.rights << saccountings_update
    global_staff.rights << saccountings_delete
    #global_auditor
    global_auditor.rights << saccountings_read

    horizontal_balance_sheet_read = Right.find_by_resource_and_operation( 'horizontal_balance_sheet',  'READ') 

   #global_owner 
    global_owner.rights << horizontal_balance_sheet_read
    #global_accountant
    global_accountant.rights << horizontal_balance_sheet_read
    #global_auditor
    global_auditor.rights << horizontal_balance_sheet_read  

    horizontal_profit_and_loss_read = Right.find_by_resource_and_operation( 'horizontal_profit_and_loss',  'READ') 
  #global_owner  
    global_owner.rights << horizontal_profit_and_loss_read
    #global_accountant
    global_accountant.rights << horizontal_profit_and_loss_read
    #global_auditor
    global_auditor.rights << horizontal_profit_and_loss_read   

    trial_balance_read = Right.find_by_resource_and_operation( 'trial_balance',  'READ') 
    
  #global_owner  
     global_owner.rights << trial_balance_read
    #global_accountant
    global_accountant.rights << trial_balance_read
    #global_auditor
    global_auditor.rights << trial_balance_read    

    bank_book_read = Right.find_by_resource_and_operation( 'bank_book',  'READ') 
    
#global_owner  #
    global_owner.rights << bank_book_read
    #global_accountant
    global_accountant.rights << bank_book_read
    #global_auditor
     global_auditor.rights << bank_book_read
   #basic_owner #

    cash_book_read = Right.find_by_resource_and_operation( 'cash_book',  'READ') 
   
#global_owner  
    global_owner.rights << cash_book_read
    #global_accountant
    global_accountant.rights << cash_book_read
    #global_auditor
    global_auditor.rights << cash_book_read
  
    credit_note_register_read = Right.find_by_resource_and_operation( 'credit_note_register',  'READ') 
 #global_owner 
   global_owner.rights << credit_note_register_read
    #global_accountant
   global_accountant.rights << credit_note_register_read
    #global_auditor
   global_auditor.rights << credit_note_register_read  


    debit_note_register_read = Right.find_by_resource_and_operation( 'debit_note_register',  'READ') 
 #global_owner 
    global_owner.rights << debit_note_register_read
    #global_accountant
    global_accountant.rights << debit_note_register_read
    #global_auditor
    global_auditor.rights << debit_note_register_read
    journal_register_read = Right.find_by_resource_and_operation( 'journal_register',  'READ') 
 #global_owner 
     global_owner.rights << journal_register_read
    #global_accountant
    global_accountant.rights << journal_register_read
    #global_auditor
    global_auditor.rights << journal_register_read

    bills_payable_read = Right.find_by_resource_and_operation( 'bills_payable',  'READ') 
  
  #global_owner  
    global_owner.rights << bills_payable_read
    #global_accountant
    global_accountant.rights << bills_payable_read
    #global_auditor
    global_auditor.rights << bills_payable_read 

    bills_receivable_read = Right.find_by_resource_and_operation( 'bills_receivable',  'READ') 
  #global_owner  
    global_owner.rights << bills_receivable_read
    #global_accountant
    global_accountant.rights << bills_receivable_read
    #global_auditor
    global_auditor.rights << bills_receivable_read 

    purchase_register_read = Right.find_by_resource_and_operation( 'purchase_register',  'READ') 
    #global_owner  
    global_owner.rights << purchase_register_read
    #global_accountant
    global_accountant.rights << purchase_register_read
    #global_auditor
    global_auditor.rights << purchase_register_read 

    sales_register_read = Right.find_by_resource_and_operation( 'sales_register',  'READ') 
   #global_owner 
   global_owner.rights << sales_register_read
    #global_accountant
   global_accountant.rights << sales_register_read
    #global_auditor
   global_auditor.rights << sales_register_read  

    sundry_creditor_read = Right.find_by_resource_and_operation( 'sundry_creditor',  'READ') 
   #global_owner 
    global_owner.rights << sundry_creditor_read
    #global_accountant
    global_accountant.rights << sundry_creditor_read
    #global_auditor
    global_auditor.rights << sundry_creditor_read

    account_books_and_registers_read = Right.find_by_resource_and_operation( 'account_books_and_registers',  'READ') 
  #global_owner  
  global_owner.rights << account_books_and_registers_read
    #  global_accountant
   global_accountant.rights << account_books_and_registers_read
    #  global_auditor
  global_auditor.rights << account_books_and_registers_read  

    daybook_read = Right.find_by_resource_and_operation( 'daybook',  'READ') 
  #global_owner  
   global_owner.rights << daybook_read
    #global_accountant
   global_accountant.rights << daybook_read
    #global_auditor
   global_auditor.rights << daybook_read  

    workstreams_read = Right.find_by_resource_and_operation( 'workstreams',  'READ') 
   #global_owner 
   global_owner.rights << workstreams_read
    #global_accountant
   global_accountant.rights << workstreams_read
    #global_auditor
   global_auditor.rights << workstreams_read  

    accounts_create = Right.find_by_resource_and_operation( 'accounts',  'CREATE')
    accounts_read = Right.find_by_resource_and_operation( 'accounts',  'READ') 
    accounts_delete = Right.find_by_resource_and_operation( 'accounts',  'DELETE')
    accounts_update = Right.find_by_resource_and_operation( 'accounts',  'UPDATE')
    #global_owner  
   global_owner.rights << accounts_create
   global_owner.rights << accounts_read
   global_owner.rights << accounts_update
   global_owner.rights << accounts_delete
    #global_accountant
   global_accountant.rights << accounts_create
   global_accountant.rights << accounts_read
   global_accountant.rights << accounts_update
   global_accountant.rights << accounts_delete
    #global_staff
    #global_auditor
   global_auditor.rights << accounts_read

    account_heads_create = Right.find_by_resource_and_operation( 'account_heads',  'CREATE')
    account_heads_read = Right.find_by_resource_and_operation( 'account_heads',  'READ') 
    account_heads_delete = Right.find_by_resource_and_operation( 'account_heads',  'DELETE')
    account_heads_update = Right.find_by_resource_and_operation( 'account_heads',  'UPDATE')
 #global_owner 
global_owner.rights << account_heads_create
global_owner.rights << account_heads_read
global_owner.rights << account_heads_update
global_owner.rights << account_heads_delete
    #global_accountant
global_accountant.rights << account_heads_create
global_accountant.rights << account_heads_read
global_accountant.rights << account_heads_update
global_accountant.rights << account_heads_delete
    #global_staff
global_staff.rights << account_heads_create
   global_staff.rights << account_heads_read
global_staff.rights << account_heads_update
global_staff.rights << account_heads_delete
    #global_auditor
global_auditor.rights << account_heads_read   

    users_create = Right.find_by_resource_and_operation( 'users',  'CREATE')
    users_read = Right.find_by_resource_and_operation( 'users',  'READ') 
    users_delete = Right.find_by_resource_and_operation( 'users',  'DELETE')
    users_update = Right.find_by_resource_and_operation( 'users',  'UPDATE')
 #global_owner 
global_owner.rights << users_create
global_owner.rights << users_read
global_owner.rights << users_update
global_owner.rights << users_delete
    #global_accountant
global_accountant.rights << users_create
global_accountant.rights << users_read
global_accountant.rights << users_update
global_accountant.rights << users_delete
    #global_staff
global_staff.rights << users_read
    #global_auditor
global_auditor.rights << users_read  
#global_employee
  global_employee.rights << users_read
  global_employee.rights << users_update  

    companies_create = Right.find_by_resource_and_operation( 'companies',  'CREATE')
    companies_read = Right.find_by_resource_and_operation( 'companies',  'READ') 
    companies_delete = Right.find_by_resource_and_operation( 'companies',  'DELETE')
    companies_update = Right.find_by_resource_and_operation( 'companies',  'UPDATE')
    #global_owner  
  global_owner.rights << companies_create
  global_owner.rights << companies_read
  global_owner.rights << companies_update
  global_owner.rights << companies_delete
  #global_accountant
  global_accountant.rights << companies_read
  #global_auditor
  global_auditor.rights << companies_read
    settings_read = Right.find_by_resource_and_operation( 'settings',  'READ') 
    settings_update = Right.find_by_resource_and_operation( 'settings',  'UPDATE')
#global_owner  
global_owner.rights << settings_read
global_owner.rights << settings_update

    #global_accountant
global_accountant.rights << settings_read
    #global_auditor
global_auditor.rights << settings_read

# Support
    supports_create = Right.find_by_resource_and_operation('supports',  'CREATE')
    supports_read = Right.find_by_resource_and_operation('supports',  'READ') 
    supports_delete = Right.find_by_resource_and_operation('supports',  'DELETE')
    supports_update = Right.find_by_resource_and_operation('supports',  'UPDATE')

   
  #global_owner  
    global_owner.rights << supports_create
    global_owner.rights << supports_read
    global_owner.rights << supports_update
    global_owner.rights << supports_delete
    #global_accountant
    global_accountant.rights << supports_create
    global_accountant.rights << supports_read
    global_accountant.rights << supports_update
    global_accountant.rights << supports_delete
    #global_staff
    global_staff.rights << supports_create
    global_staff.rights << supports_read
    global_staff.rights << supports_update
    global_staff.rights << supports_delete
    #global_employee
    global_employee.rights << supports_create
    global_employee.rights << supports_read
    global_employee.rights << supports_update
    global_employee.rights << supports_delete

    # Feedback
    feedbacks_create = Right.find_by_resource_and_operation('feedbacks', 'CREATE')
    feedbacks_read = Right.find_by_resource_and_operation('feedbacks', 'READ') 
    feedbacks_delete = Right.find_by_resource_and_operation('feedbacks', 'DELETE')
    feedbacks_update = Right.find_by_resource_and_operation('feedbacks', 'UPDATE')
   
  #global_owner  
    global_owner.rights << feedbacks_create
    global_owner.rights << feedbacks_read
    global_owner.rights << feedbacks_update
    global_owner.rights << feedbacks_delete
    #basic_accountant
    global_accountant.rights << feedbacks_create
    global_accountant.rights << feedbacks_read
    global_accountant.rights << feedbacks_update
    global_accountant.rights << feedbacks_delete
   #global_staff
    global_staff.rights << feedbacks_create
    global_staff.rights << feedbacks_read
    global_staff.rights << feedbacks_update
    global_staff.rights << feedbacks_delete

    #global_employee
    global_employee.rights << feedbacks_create
    global_employee.rights << feedbacks_read
    global_employee.rights << feedbacks_update
    global_employee.rights << feedbacks_delete

    # Salary slip
    salary_slip_create = Right.find_by_resource_and_operation('salary_slip', 'CREATE')
    salary_slip_read = Right.find_by_resource_and_operation('salary_slip', 'READ') 
    salary_slip_delete = Right.find_by_resource_and_operation('salary_slip', 'DELETE')
    salary_slip_update = Right.find_by_resource_and_operation('salary_slip', 'UPDATE')
    #global_owner  
    global_owner.rights << salary_slip_create
    global_owner.rights << salary_slip_read
    global_owner.rights << salary_slip_update
    global_owner.rights << salary_slip_delete
    #global_accountant
    global_accountant.rights << salary_slip_create
    global_accountant.rights << salary_slip_read
    global_accountant.rights << salary_slip_update
    global_accountant.rights << salary_slip_delete
    #global_staff
    global_staff.rights << salary_slip_read
   #global_auditor
    global_auditor.rights << salary_slip_read
   #global_employee
    global_employee.rights << salary_slip_read

    # Payroll rights for controller 
    payroll_dashboard_read = Right.find_by_resource_and_operation('payroll_dashboard','READ')  

    #global_owner  
    global_owner.rights << payroll_dashboard_read
    #global_accountant
    global_accountant.rights << payroll_dashboard_read
    #global_staff
    global_staff.rights << payroll_dashboard_read
    #global_auditor
    global_auditor.rights << payroll_dashboard_read
    #global_employee
    global_employee.rights << payroll_dashboard_read

    #Assets
     assets_read = Right.find_by_resource_and_operation('assets','READ') 
     assets_create = Right.find_by_resource_and_operation('assets','CREATE') 
     assets_update = Right.find_by_resource_and_operation('assets','UPDATE') 
     assets_delete = Right.find_by_resource_and_operation('assets','DELETE') 

     #global_owner 
     global_owner.rights << assets_create
     global_owner.rights << assets_read
     global_owner.rights << assets_update
     global_owner.rights << assets_delete
     #global_accountant
     global_accountant.rights << assets_create
     global_accountant.rights << assets_read
     global_accountant.rights << assets_update
     #global_staff
     global_staff.rights << assets_read
     #global_employee
     global_employee.rights << assets_read

     #Departments
      departments_read = Right.find_by_resource_and_operation('departments','READ')
      departments_create = Right.find_by_resource_and_operation('departments','CREATE')
      departments_update = Right.find_by_resource_and_operation('departments','UPDATE')
      departments_delete = Right.find_by_resource_and_operation('departments','DELETE')
      #global_owner 
      global_owner.rights << departments_create
      global_owner.rights << departments_read
      global_owner.rights << departments_update
      global_owner.rights << departments_delete
      #global_accountant
      global_accountant.rights << departments_read
      #global_staff
      global_staff.rights << departments_read
      #global_employee
      global_employee.rights << departments_read

      #Designation
      designations_read = Right.find_by_resource_and_operation('designations','READ')  
      designations_create = Right.find_by_resource_and_operation('designations','CREATE')  
      designations_update = Right.find_by_resource_and_operation('designations','UPDATE')  
      designations_delete = Right.find_by_resource_and_operation('designations','DELETE')  
      #global_owner 
      global_owner.rights << designations_create
      global_owner.rights << designations_read
      global_owner.rights << designations_update
      global_owner.rights << designations_delete
      #global_accountant
      global_accountant.rights << designations_read
      #enterprise_staff
      global_staff.rights << designations_read
      #enterprise_employee
      global_employee.rights << designations_read

      #Holidays
      holidays_read = Right.find_by_resource_and_operation('holidays','READ')  
      holidays_create = Right.find_by_resource_and_operation('holidays','CREATE')  
      holidays_update = Right.find_by_resource_and_operation('holidays','UPDATE')  
      holidays_delete = Right.find_by_resource_and_operation('holidays','DELETE')  
      #global_owner 
      global_owner.rights << holidays_create
      global_owner.rights << holidays_read
      global_owner.rights << holidays_update
      global_owner.rights << holidays_delete
      #global_accountant
      global_accountant.rights << holidays_read
      #global_staff
      global_staff.rights << holidays_read
      #global_auditor
      global_auditor.rights << holidays_read
      #global_employee
      global_employee.rights << holidays_read

      #Organisation anounsments
      organisation_announcements_read = Right.find_by_resource_and_operation('organization_announcements','READ')  
      organisation_announcements_create = Right.find_by_resource_and_operation('organization_announcements','CREATE')  
      organisation_announcements_update = Right.find_by_resource_and_operation('organization_announcements','UPDATE')  
      organisation_announcements_delete = Right.find_by_resource_and_operation('organization_announcements','DELETE')  
      #global_owner 
      global_owner.rights << organisation_announcements_create
      global_owner.rights << organisation_announcements_read
      global_owner.rights << organisation_announcements_update
      global_owner.rights << organisation_announcements_delete
      #global_accountant
      global_accountant.rights << organisation_announcements_read
      #global_staff
      global_staff.rights << organisation_announcements_read
      #global_employee
      global_employee.rights << organisation_announcements_read

      #Salary structure
      salary_structures_read = Right.find_by_resource_and_operation('salary_structures','READ')
      salary_structures_create = Right.find_by_resource_and_operation('salary_structures','CREATE')
      salary_structures_update = Right.find_by_resource_and_operation('salary_structures','UPDATE')
      salary_structures_delete = Right.find_by_resource_and_operation('salary_structures','DELETE')
      #global_owner 
      global_owner.rights << salary_structures_create
      global_owner.rights << salary_structures_read
      global_owner.rights << salary_structures_update
      global_owner.rights << salary_structures_delete
      #global_accountant
      global_accountant.rights << salary_structures_read
      #global_staff
      global_staff.rights << salary_structures_read
      #global_auditor
      global_auditor.rights << salary_structures_read
     #global_employee
      global_employee.rights << salary_structures_read

      #Leave request
      leave_requests_create = Right.find_by_resource_and_operation('leave_requests','CREATE')
      leave_requests_read = Right.find_by_resource_and_operation('leave_requests','READ')
      leave_requests_update = Right.find_by_resource_and_operation('leave_requests','UPDATE')
      leave_requests_delete = Right.find_by_resource_and_operation('leave_requests','DELETE')
      #global_owner 
      global_owner.rights << leave_requests_create
      global_owner.rights << leave_requests_read
      global_owner.rights << leave_requests_update
      global_owner.rights << leave_requests_delete
      #global_accountantthe village movie
      global_accountant.rights << leave_requests_create
      global_accountant.rights << leave_requests_read
      global_accountant.rights << leave_requests_update
      #global_staff
      global_staff.rights << leave_requests_create
      global_staff.rights << leave_requests_read
      global_staff.rights << leave_requests_update
      #global_employee
      global_employee.rights << leave_requests_create
      global_employee.rights << leave_requests_read
      global_employee.rights << leave_requests_update

      #Timesheets
      timesheets_create = Right.find_by_resource_and_operation('timesheets','CREATE')
      timesheets_read = Right.find_by_resource_and_operation('timesheets','READ')
      timesheets_delete = Right.find_by_resource_and_operation('timesheets','DELETE')
      timesheets_update = Right.find_by_resource_and_operation('timesheets','UPDATE')
      #global_owner 
      global_owner.rights << timesheets_create
      global_owner.rights << timesheets_read
      global_owner.rights << timesheets_update
      global_owner.rights << timesheets_delete
      #global_accountant
      global_accountant.rights << timesheets_create
      global_accountant.rights << timesheets_read
      global_accountant.rights << timesheets_update
      global_accountant.rights << timesheets_delete
      #global_staff
  #    global_staff.rights << timesheets_create
      global_staff.rights << timesheets_read
      global_staff.rights << timesheets_update
  #    global_staff.rights << timesheets_delete
      #global_employee
      # global_employee.rights << timesheets_create
      global_employee.rights << timesheets_read
      global_employee.rights << timesheets_update
      # global_employee.rights << timesheets_delete

      #Policy documents
      policy_documents_read = Right.find_by_resource_and_operation('policy_documents','READ')
      policy_documents_create = Right.find_by_resource_and_operation('policy_documents','CREATE')
      policy_documents_update = Right.find_by_resource_and_operation('policy_documents','UPDATE')
      policy_documents_delete = Right.find_by_resource_and_operation('policy_documents','DELETE')

     #global_owner 
      global_owner.rights << policy_documents_create
      global_owner.rights << policy_documents_read
      global_owner.rights << policy_documents_update
      global_owner.rights << policy_documents_delete
      #global_accountant
      global_accountant.rights << policy_documents_create
      global_accountant.rights << policy_documents_read
      global_accountant.rights << policy_documents_update
      global_accountant.rights << policy_documents_delete
      #global_staff
      global_staff.rights << policy_documents_read
      #global_employee
      global_employee.rights << policy_documents_read

      #Folder
      folders_create = Right.find_by_resource_and_operation('folders','CREATE')
      folders_read = Right.find_by_resource_and_operation('folders','READ')
      folders_delete = Right.find_by_resource_and_operation('folders','DELETE')
      folders_update = Right.find_by_resource_and_operation('folders','UPDATE')

     #global_owner 
      global_owner.rights << folders_create
      global_owner.rights << folders_read
      global_owner.rights << folders_update
      global_owner.rights << folders_delete
      #global_accountant
      global_accountant.rights << folders_create
      global_accountant.rights << folders_read
      global_accountant.rights << folders_update
      global_accountant.rights << folders_delete
      #global_staff
      global_staff.rights << folders_create
      global_staff.rights << folders_read
      global_staff.rights << folders_update
      global_staff.rights << folders_delete
      #global_employee
      global_employee.rights << folders_create
      global_employee.rights << folders_read
      global_employee.rights << folders_update
      global_employee.rights << folders_delete

      #My files
      myfiles_create = Right.find_by_resource_and_operation('myfiles','CREATE')
      myfiles_read = Right.find_by_resource_and_operation('myfiles','READ')
      myfiles_delete = Right.find_by_resource_and_operation('myfiles','DELETE')
      myfiles_update = Right.find_by_resource_and_operation('myfiles','UPDATE')

     #global_owner 
      global_owner.rights << myfiles_create
      global_owner.rights << myfiles_read
      global_owner.rights << myfiles_update
      global_owner.rights << myfiles_delete
      #global_accountant
      global_accountant.rights << myfiles_create
      global_accountant.rights << myfiles_read
      global_accountant.rights << myfiles_update
      global_accountant.rights << myfiles_delete
      #global_staff
      global_staff.rights << myfiles_create
      global_staff.rights << myfiles_read
      global_staff.rights << myfiles_update
      global_staff.rights << myfiles_delete
      #global_employee
      global_employee.rights << myfiles_create
      global_employee.rights << myfiles_read
      global_employee.rights << myfiles_update
      global_employee.rights << myfiles_delete

      #Plan properties
      free_plan = Plan.find_by_name("Free")
      basic_plan = Plan.find_by_name("Basic")
      premium_plan = Plan.find_by_name("Premium")
      enterprise_plan = Plan.find_by_name("Enterprise")
      essential_plan = Plan.find_by_name("Essential")
      plan_inventoriable = PlanProperty.create!(:plan_id => global_plan.id, :name => 'inventoriable', :value => '1', :datatype => 'boolean')
      plan_payroll = PlanProperty.create!(:plan_id => global_plan.id, :name => 'payroll', :value => '1', :datatype => 'boolean')
      plan_payroll = PlanProperty.create!(:plan_id => global_plan.id, :name => 'free_plan', :value => '1', :datatype => 'boolean')

      PlanProperty.create!(:plan_id => free_plan.id, :name => 'foreign_plan', :value => '0', :datatype => 'boolean')
      PlanProperty.create!(:plan_id => basic_plan.id, :name => 'foreign_plan', :value => '0', :datatype => 'boolean')
      PlanProperty.create!(:plan_id => premium_plan.id, :name => 'foreign_plan', :value => '0', :datatype => 'boolean')
      PlanProperty.create!(:plan_id => essential_plan.id, :name => 'foreign_plan', :value => '0', :datatype => 'boolean')
      PlanProperty.create!(:plan_id => global_plan.id, :name => 'foreign_plan', :value => '0', :datatype => 'boolean')

      # Financial year(By considering all our previous registration is from India, start date keep to 1st April and last date to 31st March)
      sd = Date.new(2012, 04, 01)
      ed = Date.new(2013, 03, 31)
      FinancialYear.all.each do |fy|
        fy.start_date = sd
        fy.end_date = ed
        fy.save
      end
end
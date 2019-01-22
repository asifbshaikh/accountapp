ActiveRecord::Base.transaction do
  professional_plan = Plan.find_by_name('Professional')
  enterprise_plan = Plan.find_by_name('Enterprise')
  trial_plan = Plan.find_by_name('Trial')
  smb_plan = Plan.find_by_name('SMB')
  essential_plan = Plan.find_by_name('Essential')
  free_plan = Plan.find_by_name('PWYW')


  #professional_inventory_manager = Role.find_by_name_and_plan_id('Inventory Manager', professional_plan)
  enterprise_inventory_manager = Role.find_by_name_and_plan_id('Inventory Manager', enterprise_plan)
  trial_inventory_manager = Role.find_by_name_and_plan_id('Inventory Manager', trial_plan)
  smb_inventory_manager = Role.find_by_name_and_plan_id('Inventory Manager', smb_plan)


  #enterprise plan roles
  enterprise_hr = Role.create!(:name => 'HR', :desc => "HR role has access to Employee and Payroll features only.")
  enterprise_plan.roles << enterprise_hr
  enterprise_sales = Role.create!(:name => 'Sales', :desc => "Sales has access to the Income menu, sales reports.")
  enterprise_plan.roles << enterprise_sales

  smb_hr = Role.create!(:name => 'HR', :desc => "HR role has access to Employee and Payroll features only.")
  smb_plan.roles << smb_hr
  smb_sales = Role.create!(:name => 'Sales', :desc => "Sales has access to the Income menu, sales reports.")
  smb_plan.roles << smb_sales

  trial_hr = Role.create!(:name => 'HR', :desc => "HR role has access to Employee and Payroll features only.")
  trial_plan.roles << trial_hr
  trial_sales = Role.create!(:name => 'Sales', :desc => "Sales has access to the Income menu, sales reports.")
  trial_plan.roles << trial_sales


# DASHBOARD
    dashboard_read = Right.find_by_resource_and_operation('dashboard', 'READ')

    enterprise_hr.rights << dashboard_read
    enterprise_sales.rights << dashboard_read

    smb_hr.rights << dashboard_read
    smb_sales.rights << dashboard_read

    trial_hr.rights << dashboard_read
    trial_sales.rights << dashboard_read


    tasks_create = Right.find_by_resource_and_operation( 'tasks',  'CREATE')
    tasks_read = Right.find_by_resource_and_operation( 'tasks',  'READ')
    tasks_delete = Right.find_by_resource_and_operation( 'tasks',  'DELETE')
    tasks_update = Right.find_by_resource_and_operation( 'tasks',  'UPDATE')

    enterprise_hr.rights << tasks_create
    enterprise_hr.rights << tasks_read
    enterprise_hr.rights << tasks_update
    enterprise_hr.rights << tasks_delete

    enterprise_sales.rights << tasks_create
    enterprise_sales.rights << tasks_read
    enterprise_sales.rights << tasks_update
    enterprise_sales.rights << tasks_delete

    smb_hr.rights << tasks_create
    smb_hr.rights << tasks_read
    smb_hr.rights << tasks_update
    smb_hr.rights << tasks_delete

    smb_sales.rights << tasks_create
    smb_sales.rights << tasks_read
    smb_sales.rights << tasks_update
    smb_sales.rights << tasks_delete

    trial_hr.rights << tasks_create
    trial_hr.rights << tasks_read
    trial_hr.rights << tasks_update
    trial_hr.rights << tasks_delete

    trial_sales.rights << tasks_create
    trial_sales.rights << tasks_read
    trial_sales.rights << tasks_update
    trial_sales.rights << tasks_delete

    messages_create = Right.find_by_resource_and_operation( 'messages',  'CREATE')
    messages_read = Right.find_by_resource_and_operation( 'messages',  'READ')
    messages_delete = Right.find_by_resource_and_operation( 'messages',  'DELETE')
    messages_update = Right.find_by_resource_and_operation( 'messages',  'UPDATE')


    enterprise_hr.rights << messages_create
    enterprise_hr.rights << messages_read
    enterprise_hr.rights << messages_update
    enterprise_hr.rights << messages_delete

    enterprise_sales.rights << messages_create
    enterprise_sales.rights << messages_read
    enterprise_sales.rights << messages_update
    enterprise_sales.rights << messages_delete

    smb_hr.rights << messages_create
    smb_hr.rights << messages_read
    smb_hr.rights << messages_update
    smb_hr.rights << messages_delete

    smb_sales.rights << messages_create
    smb_sales.rights << messages_read
    smb_sales.rights << messages_update
    smb_sales.rights << messages_delete

    trial_hr.rights << messages_create
    trial_hr.rights << messages_read
    trial_hr.rights << messages_update
    trial_hr.rights << messages_delete

    trial_sales.rights << messages_create
    trial_sales.rights << messages_read
    trial_sales.rights << messages_update
    trial_sales.rights << messages_delete


    invoices_create = Right.find_by_resource_and_operation( 'invoices',  'CREATE')
    invoices_read = Right.find_by_resource_and_operation( 'invoices',  'READ')
    invoices_delete = Right.find_by_resource_and_operation( 'invoices',  'DELETE')
    invoices_update = Right.find_by_resource_and_operation( 'invoices',  'UPDATE')

    enterprise_sales.rights << invoices_create
    enterprise_sales.rights << invoices_read
    enterprise_sales.rights << invoices_update
    enterprise_sales.rights << invoices_delete

    smb_sales.rights << invoices_create
    smb_sales.rights << invoices_read
    smb_sales.rights << invoices_update
    smb_sales.rights << invoices_delete

    trial_sales.rights << invoices_create
    trial_sales.rights << invoices_read
    trial_sales.rights << invoices_update
    trial_sales.rights << invoices_delete

    receipt_vouchers_create = Right.find_by_resource_and_operation( 'receipt_vouchers',  'CREATE')
    receipt_vouchers_read = Right.find_by_resource_and_operation( 'receipt_vouchers',  'READ')
    receipt_vouchers_delete = Right.find_by_resource_and_operation( 'receipt_vouchers',  'DELETE')
    receipt_vouchers_update = Right.find_by_resource_and_operation( 'receipt_vouchers',  'UPDATE')

    enterprise_sales.rights << receipt_vouchers_create
    enterprise_sales.rights << receipt_vouchers_read
    enterprise_sales.rights << receipt_vouchers_update
    enterprise_sales.rights << receipt_vouchers_delete

    smb_sales.rights << receipt_vouchers_create
    smb_sales.rights << receipt_vouchers_read
    smb_sales.rights << receipt_vouchers_update
    smb_sales.rights << receipt_vouchers_delete

    trial_sales.rights << receipt_vouchers_create
    trial_sales.rights << receipt_vouchers_read
    trial_sales.rights << receipt_vouchers_update
    trial_sales.rights << receipt_vouchers_delete

    estimates_create = Right.find_by_resource_and_operation( 'estimates',  'CREATE')
    estimates_read = Right.find_by_resource_and_operation( 'estimates',  'READ')
    estimates_delete = Right.find_by_resource_and_operation( 'estimates',  'DELETE')
    estimates_update = Right.find_by_resource_and_operation( 'estimates',  'UPDATE')

    enterprise_sales.rights << estimates_create
    enterprise_sales.rights << estimates_read
    enterprise_sales.rights << estimates_update
    enterprise_sales.rights << estimates_delete

    smb_sales.rights << estimates_create
    smb_sales.rights << estimates_read
    smb_sales.rights << estimates_update
    smb_sales.rights << estimates_delete

    trial_sales.rights << estimates_create
    trial_sales.rights << estimates_read
    trial_sales.rights << estimates_update
    trial_sales.rights << estimates_delete

    invoice_return_read=Right.find_by_resource_and_operation('invoice_returns', 'READ')
    invoice_return_create=Right.find_by_resource_and_operation('invoice_returns', 'CREATE')
    invoice_return_delete=Right.find_by_resource_and_operation('invoice_returns', 'DELETE')
    invoice_return_update=Right.find_by_resource_and_operation('invoice_returns', 'UPDATE')

    enterprise_sales.rights << invoice_return_read
    enterprise_sales.rights << invoice_return_create
    enterprise_sales.rights << invoice_return_update
    enterprise_sales.rights << invoice_return_delete

    smb_sales.rights << invoice_return_read
    smb_sales.rights << invoice_return_create
    smb_sales.rights << invoice_return_update
    smb_sales.rights << invoice_return_delete

    trial_sales.rights << invoice_return_read
    trial_sales.rights << invoice_return_create
    trial_sales.rights << invoice_return_update
    trial_sales.rights << invoice_return_delete

    sales_orders_create = Right.find_by_resource_and_operation('sales_orders', 'CREATE')
    sales_orders_read = Right.find_by_resource_and_operation('sales_orders', 'READ')
    sales_orders_delete = Right.find_by_resource_and_operation('sales_orders', 'DELETE')
    sales_orders_update = Right.find_by_resource_and_operation('sales_orders', 'UPDATE')

    enterprise_sales.rights << sales_orders_create
    enterprise_sales.rights << sales_orders_read
    enterprise_sales.rights << sales_orders_update
    enterprise_sales.rights << sales_orders_delete

    smb_sales.rights << sales_orders_create
    smb_sales.rights << sales_orders_read
    smb_sales.rights << sales_orders_update
    smb_sales.rights << sales_orders_delete

    trial_sales.rights << sales_orders_create
    trial_sales.rights << sales_orders_read
    trial_sales.rights << sales_orders_update
    trial_sales.rights << sales_orders_delete

    #delivery challan rights and roles
    delivery_challans_create = Right.find_by_resource_and_operation('delivery_challans', 'CREATE')
    delivery_challans_read = Right.find_by_resource_and_operation('delivery_challans', 'READ')
    delivery_challans_delete = Right.find_by_resource_and_operation('delivery_challans', 'DELETE')
    delivery_challans_update = Right.find_by_resource_and_operation('delivery_challans', 'UPDATE')

    enterprise_sales.rights << delivery_challans_create
    enterprise_sales.rights << delivery_challans_read
    enterprise_sales.rights << delivery_challans_update
    enterprise_sales.rights << delivery_challans_delete

    smb_sales.rights << delivery_challans_create
    smb_sales.rights << delivery_challans_read
    smb_sales.rights << delivery_challans_update
    smb_sales.rights << delivery_challans_delete

    trial_sales.rights << delivery_challans_create
    trial_sales.rights << delivery_challans_read
    trial_sales.rights << delivery_challans_update
    trial_sales.rights << delivery_challans_delete

    customers_create = Right.find_by_resource_and_operation('customers', 'CREATE')
    customers_read = Right.find_by_resource_and_operation('customers', 'READ')
    customers_update = Right.find_by_resource_and_operation('customers', 'UPDATE')

    enterprise_sales.rights << customers_create
    enterprise_sales.rights << customers_read
    enterprise_sales.rights << customers_update

    smb_sales.rights << customers_create
    smb_sales.rights << customers_read
    smb_sales.rights << customers_update

    trial_sales.rights << customers_create
    trial_sales.rights << customers_read
    trial_sales.rights << customers_update

    users_create = Right.find_by_resource_and_operation('users', 'CREATE')
    users_read = Right.find_by_resource_and_operation('users', 'READ')
    users_delete = Right.find_by_resource_and_operation('users', 'DELETE')
    users_update = Right.find_by_resource_and_operation('users', 'UPDATE')


    enterprise_hr.rights << users_create
    enterprise_hr.rights << users_read
    enterprise_hr.rights << users_update
    enterprise_hr.rights << users_delete

    smb_hr.rights << users_create
    smb_hr.rights << users_read
    smb_hr.rights << users_update
    smb_hr.rights << users_delete

    trial_hr.rights << users_create
    trial_hr.rights << users_read
    trial_hr.rights << users_update
    trial_hr.rights << users_delete

    salary_slip_create = Right.find_by_resource_and_operation('salary_slip', 'CREATE')
    salary_slip_read = Right.find_by_resource_and_operation('salary_slip', 'READ')
    salary_slip_delete = Right.find_by_resource_and_operation('salary_slip', 'DELETE')
    salary_slip_update = Right.find_by_resource_and_operation('salary_slip', 'UPDATE')

    enterprise_hr.rights << salary_slip_create
    enterprise_hr.rights << salary_slip_read
    enterprise_hr.rights << salary_slip_update
    enterprise_hr.rights << salary_slip_delete

    smb_hr.rights << salary_slip_create
    smb_hr.rights << salary_slip_read
    smb_hr.rights << salary_slip_update
    smb_hr.rights << salary_slip_delete

    trial_hr.rights << salary_slip_create
    trial_hr.rights << salary_slip_read
    trial_hr.rights << salary_slip_update
    trial_hr.rights << salary_slip_delete


    salary_structures_read = Right.find_by_resource_and_operation('salary_structures','READ')
    salary_structures_create = Right.find_by_resource_and_operation('salary_structures','CREATE')
    salary_structures_update = Right.find_by_resource_and_operation('salary_structures','UPDATE')
    salary_structures_delete = Right.find_by_resource_and_operation('salary_structures','DELETE')

    enterprise_hr.rights << salary_structures_read
    enterprise_hr.rights << salary_structures_create
    enterprise_hr.rights << salary_structures_update
    enterprise_hr.rights << salary_structures_delete

    smb_hr.rights << salary_structures_read
    smb_hr.rights << salary_structures_create
    smb_hr.rights << salary_structures_update
    smb_hr.rights << salary_structures_delete

    trial_hr.rights << salary_structures_read
    trial_hr.rights << salary_structures_create
    trial_hr.rights << salary_structures_update
    trial_hr.rights << salary_structures_delete


    leave_requests_create = Right.find_by_resource_and_operation('leave_requests','CREATE')
    leave_requests_read = Right.find_by_resource_and_operation('leave_requests','READ')
    leave_requests_update = Right.find_by_resource_and_operation('leave_requests','UPDATE')
    leave_requests_delete = Right.find_by_resource_and_operation('leave_requests','DELETE')

    enterprise_hr.rights << leave_requests_create
    enterprise_hr.rights << leave_requests_read
    enterprise_hr.rights << leave_requests_update
    enterprise_hr.rights << leave_requests_delete

    smb_hr.rights << leave_requests_create
    smb_hr.rights << leave_requests_read
    smb_hr.rights << leave_requests_update
    smb_hr.rights << leave_requests_delete

    trial_hr.rights << leave_requests_create
    trial_hr.rights << leave_requests_read
    trial_hr.rights << leave_requests_update
    trial_hr.rights << leave_requests_delete

    #Leave types
    leave_types_create = Right.find_by_resource_and_operation('leave_types', 'CREATE')
    leave_types_read = Right.find_by_resource_and_operation('leave_types', 'READ')
    leave_types_delete = Right.find_by_resource_and_operation('leave_types', 'DELETE')
    leave_types_update = Right.find_by_resource_and_operation('leave_types', 'UPDATE')

    enterprise_hr.rights << leave_types_create
    enterprise_hr.rights << leave_types_read
    enterprise_hr.rights << leave_types_update
    enterprise_hr.rights << leave_types_delete

    smb_hr.rights << leave_types_create
    smb_hr.rights << leave_types_read
    smb_hr.rights << leave_types_update
    smb_hr.rights << leave_types_delete

    trial_hr.rights << leave_types_create
    trial_hr.rights << leave_types_read
    trial_hr.rights << leave_types_update
    trial_hr.rights << leave_types_delete


    # Payroll details
    payroll_details_create = Right.find_by_resource_and_operation('payroll_details', 'CREATE')
    payroll_details_read = Right.find_by_resource_and_operation('payroll_details', 'READ')
    # payroll_details_delete = Right.find_by_resource_and_operation('payroll_details', 'DELETE')
    payroll_details_update = Right.find_by_resource_and_operation('payroll_details', 'UPDATE')

    enterprise_hr.rights << payroll_details_create
    enterprise_hr.rights << payroll_details_read
    enterprise_hr.rights << payroll_details_update
    #enterprise_hr.rights << payroll_details_delete

    smb_hr.rights << payroll_details_create
    smb_hr.rights << payroll_details_read
    smb_hr.rights << payroll_details_update
    #smb_hr.rights << payroll_details_delete

    trial_hr.rights << payroll_details_create
    trial_hr.rights << payroll_details_read
    trial_hr.rights << payroll_details_update
    #trial_hr.rights << payroll_details_delete


    attendances_create = Right.find_by_resource_and_operation('attendances', 'CREATE')
    attendances_read = Right.find_by_resource_and_operation('attendances', 'READ')
    attendances_delete = Right.find_by_resource_and_operation('attendances', 'DELETE')
    attendances_update = Right.find_by_resource_and_operation('attendances', 'UPDATE')

    enterprise_hr.rights << attendances_create
    enterprise_hr.rights << attendances_read
    enterprise_hr.rights << attendances_update
    enterprise_hr.rights << attendances_delete

    smb_hr.rights << attendances_create
    smb_hr.rights << attendances_read
    smb_hr.rights << attendances_update
    smb_hr.rights << attendances_delete

    trial_hr.rights << attendances_create
    trial_hr.rights << attendances_read
    trial_hr.rights << attendances_update
    trial_hr.rights << attendances_delete


    leaves_approval_create = Right.find_by_resource_and_operation('leave_approval', 'CREATE')
    leaves_approval_read = Right.find_by_resource_and_operation('leave_approval', 'READ')
    leaves_approval_delete = Right.find_by_resource_and_operation('leave_approval', 'DELETE')
    leaves_approval_update = Right.find_by_resource_and_operation('leave_approval', 'UPDATE')

    enterprise_hr.rights << leaves_approval_create
    enterprise_hr.rights << leaves_approval_read
    enterprise_hr.rights << leaves_approval_update
    enterprise_hr.rights << leaves_approval_delete

    smb_hr.rights << leaves_approval_create
    smb_hr.rights << leaves_approval_read
    smb_hr.rights << leaves_approval_update
    smb_hr.rights << leaves_approval_delete

    trial_hr.rights << leaves_approval_create
    trial_hr.rights << leaves_approval_read
    trial_hr.rights << leaves_approval_update
    trial_hr.rights << leaves_approval_delete


    leaves_create = Right.find_by_resource_and_operation('leave_cards', 'CREATE')
    leaves_read = Right.find_by_resource_and_operation('leave_cards', 'READ')
    leaves_delete = Right.find_by_resource_and_operation('leave_cards', 'DELETE')
    leaves_update = Right.find_by_resource_and_operation('leave_cards', 'UPDATE')

    enterprise_hr.rights << leaves_create
    enterprise_hr.rights << leaves_read
    enterprise_hr.rights << leaves_update
    enterprise_hr.rights << leaves_delete

    smb_hr.rights << leaves_create
    smb_hr.rights << leaves_read
    smb_hr.rights << leaves_update
    smb_hr.rights << leaves_delete

    trial_hr.rights << leaves_create
    trial_hr.rights << leaves_read
    trial_hr.rights << leaves_update
    trial_hr.rights << leaves_delete


    payheads_create = Right.find_by_resource_and_operation('payheads', 'CREATE')
    payheads_read = Right.find_by_resource_and_operation('payheads', 'READ')
    payheads_delete = Right.find_by_resource_and_operation('payheads', 'DELETE')
    payheads_update = Right.find_by_resource_and_operation('payheads', 'UPDATE')

    enterprise_hr.rights << leaves_create
    enterprise_hr.rights << leaves_read
    enterprise_hr.rights << leaves_update
    enterprise_hr.rights << leaves_delete

    smb_hr.rights << leaves_create
    smb_hr.rights << leaves_read
    smb_hr.rights << leaves_update
    smb_hr.rights << leaves_delete

    trial_hr.rights << leaves_create
    trial_hr.rights << leaves_read
    trial_hr.rights << leaves_update
    trial_hr.rights << leaves_delete


    salary_structure_histories_create = Right.find_by_resource_and_operation('salary_structure_histories', 'CREATE')
    salary_structure_histories_read = Right.find_by_resource_and_operation('salary_structure_histories', 'READ')
    salary_structure_histories_update = Right.find_by_resource_and_operation('salary_structure_histories', 'UPDATE')
    salary_structure_histories_delete = Right.find_by_resource_and_operation('salary_structure_histories', 'DELETE')

    enterprise_hr.rights << salary_structure_histories_create
    enterprise_hr.rights << salary_structure_histories_read
    enterprise_hr.rights << salary_structure_histories_update
    enterprise_hr.rights << salary_structure_histories_delete

    smb_hr.rights << salary_structure_histories_create
    smb_hr.rights << salary_structure_histories_read
    smb_hr.rights << salary_structure_histories_update
    smb_hr.rights << salary_structure_histories_delete

    trial_hr.rights << salary_structure_histories_create
    trial_hr.rights << salary_structure_histories_read
    trial_hr.rights << salary_structure_histories_update
    trial_hr.rights << salary_structure_histories_delete


    payroll_execution_job_create = Right.find_by_resource_and_operation('payroll_execution_jobs',  'CREATE')
    payroll_execution_job_read = Right.find_by_resource_and_operation('payroll_execution_jobs',  'READ')

    enterprise_hr.rights << payroll_execution_job_create
    enterprise_hr.rights << payroll_execution_job_read

    smb_hr.rights << payroll_execution_job_create
    smb_hr.rights << payroll_execution_job_read

    trial_hr.rights << payroll_execution_job_create
    trial_hr.rights << payroll_execution_job_read


    #Holidays
    holidays_read = Right.find_by_resource_and_operation('holidays','READ')
    holidays_create = Right.find_by_resource_and_operation('holidays','CREATE')
    holidays_update = Right.find_by_resource_and_operation('holidays','UPDATE')
    holidays_delete = Right.find_by_resource_and_operation('holidays','DELETE')

    enterprise_hr.rights << holidays_read
    enterprise_hr.rights << holidays_create
    enterprise_hr.rights << holidays_update
    enterprise_hr.rights << holidays_delete

    smb_hr.rights << holidays_read
    smb_hr.rights << holidays_create
    smb_hr.rights << holidays_update
    smb_hr.rights << holidays_delete

    trial_hr.rights << holidays_read
    trial_hr.rights << holidays_create
    trial_hr.rights << holidays_update
    trial_hr.rights << holidays_delete


   #Departments
    departments_read = Right.find_by_resource_and_operation('departments','READ')
    departments_create = Right.find_by_resource_and_operation('departments','CREATE')
    departments_update = Right.find_by_resource_and_operation('departments','UPDATE')
    departments_delete = Right.find_by_resource_and_operation('departments','DELETE')

    enterprise_hr.rights << departments_read
    enterprise_hr.rights << departments_create
    enterprise_hr.rights << departments_update
    enterprise_hr.rights << departments_delete

    smb_hr.rights << departments_read
    smb_hr.rights << departments_create
    smb_hr.rights << departments_update
    smb_hr.rights << departments_delete

    trial_hr.rights << departments_read
    trial_hr.rights << departments_create
    trial_hr.rights << departments_update
    trial_hr.rights << departments_delete


    #designations
    designations_read = Right.find_by_resource_and_operation('designations','READ')
    designations_create = Right.find_by_resource_and_operation('designations','CREATE')
    designations_update = Right.find_by_resource_and_operation('designations','UPDATE')
    designations_delete = Right.find_by_resource_and_operation('designations','DELETE')

    enterprise_hr.rights << designations_read
    enterprise_hr.rights << designations_create
    enterprise_hr.rights << designations_update
    enterprise_hr.rights << designations_delete

    smb_hr.rights << designations_read
    smb_hr.rights << designations_create
    smb_hr.rights << designations_update
    smb_hr.rights << designations_delete

    trial_hr.rights << designations_read
    trial_hr.rights << designations_create
    trial_hr.rights << designations_update
    trial_hr.rights << designations_delete

    #  #4) Payment advice
   payment_advice_read = Right.create!(:resource => 'payment_advice', :operation => 'READ')

    enterprise_hr.rights << payment_advice_read
    smb_hr.rights << payment_advice_read
    trial_hr.rights << payment_advice_read


# # 3) Employee breakup
   employee_breakup_read = Right.create!(:resource => 'employee_breakup', :operation => 'READ')

    enterprise_hr.rights << employee_breakup_read
    smb_hr.rights << employee_breakup_read
    trial_hr.rights << employee_breakup_read


   timesheets_read = Right.find_by_resource_and_operation('timesheets','READ')
    enterprise_hr.rights << timesheets_read
    smb_hr.rights << timesheets_read
    trial_hr.rights << timesheets_read

    enterprise_sales.rights << timesheets_read
    smb_sales.rights << timesheets_read
    trial_sales.rights << timesheets_read


    workstreams_read = Right.find_by_resource_and_operation( 'workstreams',  'READ')
    enterprise_hr.rights << workstreams_read
    smb_hr.rights << workstreams_read
    trial_hr.rights << workstreams_read

    enterprise_sales.rights << workstreams_read
    smb_sales.rights << workstreams_read
    trial_sales.rights << workstreams_read


   credit_note_register_read = Right.find_by_resource_and_operation( 'credit_note_register',  'READ')

    enterprise_sales.rights << credit_note_register_read
    smb_sales.rights << credit_note_register_read
    trial_sales.rights << credit_note_register_read


   debit_note_register_read = Right.find_by_resource_and_operation( 'debit_note_register',  'READ')
    enterprise_sales.rights << debit_note_register_read
    smb_sales.rights << debit_note_register_read
    trial_sales.rights << debit_note_register_read


   sales_register_read = Right.find_by_resource_and_operation( 'sales_register',  'READ')
    enterprise_sales.rights << sales_register_read
    smb_sales.rights << sales_register_read
    trial_sales.rights << sales_register_read


  bills_receivable_read = Right.find_by_resource_and_operation( 'bills_receivable',  'READ')
    enterprise_sales.rights << bills_receivable_read
    smb_sales.rights << bills_receivable_read
    trial_sales.rights << bills_receivable_read


 customer_statement_read = Right.find_by_resource_and_operation('customer_statements', 'READ')
    enterprise_sales.rights << customer_statement_read
    smb_sales.rights << customer_statement_read
    trial_sales.rights << customer_statement_read


 invoice_settlement_read = Right.find_by_resource_and_operation("invoice_settlement", "READ")
    enterprise_sales.rights << invoice_settlement_read
    smb_sales.rights << invoice_settlement_read
    trial_sales.rights << invoice_settlement_read

end

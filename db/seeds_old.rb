ActiveRecord::Base.transaction do
  
  smb_plan = Plan.find_by_name('SMB')
  professional_plan = Plan.find_by_name('Professional')
  enterprise_plan = Plan.find_by_name('Enterprise')
  trial_plan = Plan.find_by_name('Trial')

  professional_owner = Role.find_by_name_and_plan_id('Owner', professional_plan)
  professional_accountant = Role.find_by_name_and_plan_id('Accountant', professional_plan)
  professional_auditor = Role.find_by_name_and_plan_id('Auditor', professional_plan)

  enterprise_owner = Role.find_by_name_and_plan_id('Owner', enterprise_plan)
  enterprise_accountant = Role.find_by_name_and_plan_id('Accountant', enterprise_plan)
  enterprise_auditor = Role.find_by_name_and_plan_id('Auditor', enterprise_plan)

  trial_owner = Role.find_by_name_and_plan_id('Owner', trial_plan)
  trial_accountant = Role.find_by_name_and_plan_id('Accountant', trial_plan)
  trial_auditor = Role.find_by_name_and_plan_id('Auditor', trial_plan)

  smb_owner = Role.find_by_name_and_plan_id('Owner', smb_plan)
  smb_accountant = Role.find_by_name_and_plan_id('Accountant', smb_plan)
  smb_auditor = Role.find_by_name_and_plan_id('Auditor', smb_plan)



  #rights to create GST invoices
  Right.create!(:resource => 'gst_credit_notes', :operation => 'READ')
  Right.create!(:resource => 'gst_credit_notes', :operation => 'CREATE')
  Right.create!(:resource => 'gst_credit_notes', :operation => 'UPDATE')
  Right.create!(:resource => 'gst_credit_notes', :operation => 'DELETE')
  Right.create!(:resource => 'gst_debit_notes', :operation => 'READ')
  Right.create!(:resource => 'gst_debit_notes', :operation => 'CREATE')
  Right.create!(:resource => 'gst_debit_notes', :operation => 'UPDATE')
  Right.create!(:resource => 'gst_debit_notes', :operation => 'DELETE')
  Right.create!(:resource => 'gstr2_filings', :operation => 'READ')
  Right.create!(:resource => 'gstr2_filings', :operation => 'CREATE')
  Right.create!(:resource => 'gstr2_filings', :operation => 'UPDATE')
  Right.create!(:resource => 'gstr2_filings', :operation => 'DELETE')


  # Right.create!(:resource => 'gst_authorizer', :operation => 'READ')
  # Right.create!(:resource => 'gst_authorizer', :operation => 'CREATE')
  # Right.create!(:resource => 'gst_authorizer', :operation => 'UPDATE')
  # Right.create!(:resource => 'gst_authorizer', :operation => 'DELETE')
  # Right.create!(:resource => 'gstr1_filings', :operation => 'READ')
  # Right.create!(:resource => 'gstr1_filings', :operation => 'CREATE')
  # Right.create!(:resource => 'gstr1_filings', :operation => 'UPDATE')
  # Right.create!(:resource => 'gstr1_filings', :operation => 'DELETE')

  # #rights to create GSTR1 summaris
  # Right.create!(:resource => 'gstr1_summaries', :operation => 'READ')
  # Right.create!(:resource => 'gst_authorizer', :operation => 'CREATE')
  # Right.create!(:resource => 'gst_authorizer', :operation => 'UPDATE')
  # Right.create!(:resource => 'gst_authorizer', :operation => 'DELETE')

  #gst invoices section
  # gstr1_filings_read = Right.find_by_resource_and_operation('gstr1_filings','READ')
  # gstr1_filings_create = Right.find_by_resource_and_operation('gstr1_filings','CREATE')
  # gstr1_filings_update = Right.find_by_resource_and_operation('gstr1_filings','UPDATE')  
  # gstr1_filings_delete = Right.find_by_resource_and_operation('gstr1_filings','DELETE')


  #rights to create login_requests
  # Right.create!(:resource => 'login_requests', :operation => 'READ')
  # Right.create!(:resource => 'login_requests', :operation => 'CREATE')

  #gst invoices section
  # login_requests_read = Right.find_by_resource_and_operation('login_requests','READ')
  # login_requests_create = Right.find_by_resource_and_operation('login_requests','CREATE')


  #rights to view GST returns screen
  # Right.create!(:resource => 'gst_returns', :operation => 'READ')


  #gst invoices section
  # gst_returns_read = Right.find_by_resource_and_operation('gst_returns','READ')
  # gst_authorizer_read = Right.find_by_resource_and_operation('gst_authorizer','READ')
  # gst_authorizer_create = Right.find_by_resource_and_operation('gst_authorizer','CREATE')
  # gst_authorizer_update = Right.find_by_resource_and_operation('gst_authorizer','UPDATE')  
  # gst_authorizer_delete = Right.find_by_resource_and_operation('gst_authorizer','DELETE')
  gstr2_filings_read = Right.find_by_resource_and_operation('gstr2_filings','READ')
  gstr2_filings_create = Right.find_by_resource_and_operation('gstr2_filings','CREATE')
  gstr2_filings_update = Right.find_by_resource_and_operation('gstr2_filings','UPDATE')  
  gstr2_filings_delete = Right.find_by_resource_and_operation('gstr2_filings','DELETE')

  #gst credit note
  gst_credit_notes_read = Right.find_by_resource_and_operation('gst_credit_notes','READ')
  gst_credit_notes_create = Right.find_by_resource_and_operation('gst_credit_notes','CREATE')
  gst_credit_notes_update = Right.find_by_resource_and_operation('gst_credit_notes','UPDATE')  
  gst_credit_notes_delete = Right.find_by_resource_and_operation('gst_credit_notes','DELETE')

  #gst debit note
  gst_debit_notes_read = Right.find_by_resource_and_operation('gst_debit_notes','READ')
  gst_debit_notes_create = Right.find_by_resource_and_operation('gst_debit_notes','CREATE')
  gst_debit_notes_update = Right.find_by_resource_and_operation('gst_debit_notes','UPDATE')  
  gst_debit_notes_delete = Right.find_by_resource_and_operation('gst_debit_notes','DELETE')


  #gst advance receipt

  gstr_advance_receipt_create = Right.create!(:resource => 'gstr_advance_receipt', :operation => 'CREATE')
  gstr_advance_receipt_read = Right.create!(:resource => 'gstr_advance_receipt', :operation => 'READ') 
  gstr_advance_receipt_delete = Right.create!(:resource => 'gstr_advance_receipt', :operation => 'DELETE')
  gstr_advance_receipt_update = Right.create!(:resource => 'gstr_advance_receipt', :operation => 'UPDATE')


  # enterprise
  # enterprise_owner.rights << gstr1_filings_read
  # enterprise_owner.rights << gstr1_filings_create
  # enterprise_owner.rights << gstr1_filings_update
  # enterprise_owner.rights << gstr1_filings_delete
  # enterprise_owner.rights << gst_authorizer_read
  # enterprise_owner.rights << gst_authorizer_create
  # enterprise_owner.rights << gst_authorizer_update
  # enterprise_owner.rights << gst_authorizer_delete
  enterprise_owner.rights << gstr2_filings_read
  enterprise_owner.rights << gstr2_filings_create
  enterprise_owner.rights << gstr2_filings_update
  enterprise_owner.rights << gstr2_filings_delete

  enterprise_owner.rights << gst_credit_notes_read
  enterprise_owner.rights << gst_credit_notes_create
  enterprise_owner.rights << gst_credit_notes_update
  enterprise_owner.rights << gst_credit_notes_delete

  enterprise_owner.rights << gst_debit_notes_read
  enterprise_owner.rights << gst_debit_notes_create
  enterprise_owner.rights << gst_debit_notes_update
  enterprise_owner.rights << gst_debit_notes_delete

  enterprise_owner.rights << gstr_advance_receipt_read
  enterprise_owner.rights << gstr_advance_receipt_create
  enterprise_owner.rights << gstr_advance_receipt_update
  enterprise_owner.rights << gstr_advance_receipt_delete

  # enterprise_accountant.rights << gstr1_filings_read
  # enterprise_accountant.rights << gstr1_filings_create
  # enterprise_accountant.rights << gstr1_filings_update
  # enterprise_accountant.rights << gstr1_filings_delete
  # enterprise_accountant.rights << gst_authorizer_read
  # enterprise_accountant.rights << gst_authorizer_create
  # enterprise_accountant.rights << gst_authorizer_update
  # enterprise_accountant.rights << gst_authorizer_delete
  enterprise_accountant.rights << gstr2_filings_read
  enterprise_accountant.rights << gstr2_filings_create
  enterprise_accountant.rights << gstr2_filings_update
  enterprise_accountant.rights << gstr2_filings_delete



  enterprise_accountant.rights << gst_credit_notes_read
  enterprise_accountant.rights << gst_credit_notes_create
  enterprise_accountant.rights << gst_credit_notes_update
  enterprise_accountant.rights << gst_credit_notes_delete


  enterprise_accountant.rights << gst_debit_notes_read
  enterprise_accountant.rights << gst_debit_notes_create
  enterprise_accountant.rights << gst_debit_notes_update
  enterprise_accountant.rights << gst_debit_notes_delete

  enterprise_accountant.rights << gstr_advance_receipt_read
  enterprise_accountant.rights << gstr_advance_receipt_create
  enterprise_accountant.rights << gstr_advance_receipt_update
  enterprise_accountant.rights << gstr_advance_receipt_delete
 




  # enterprise_auditor.rights << gstr1_filings_read
  # enterprise_auditor.rights << gstr1_filings_create
  # enterprise_auditor.rights << gstr1_filings_update
  # enterprise_auditor.rights << gstr1_filings_delete
  # enterprise_auditor.rights << gst_authorizer_read
  # enterprise_auditor.rights << gst_authorizer_create
  # enterprise_auditor.rights << gst_authorizer_update
  # enterprise_auditor.rights << gst_authorizer_delete
  enterprise_auditor.rights << gstr2_filings_read
  enterprise_auditor.rights << gstr2_filings_create
  enterprise_auditor.rights << gstr2_filings_update
  enterprise_auditor.rights << gstr2_filings_delete

  enterprise_auditor.rights << gst_credit_notes_read
  enterprise_auditor.rights << gst_credit_notes_create
  enterprise_auditor.rights << gst_credit_notes_update
  enterprise_auditor.rights << gst_credit_notes_delete

  enterprise_auditor.rights << gst_debit_notes_read
  enterprise_auditor.rights << gst_debit_notes_create
  enterprise_auditor.rights << gst_debit_notes_update
  enterprise_auditor.rights << gst_debit_notes_delete

  enterprise_auditor.rights << gstr_advance_receipt_read
  enterprise_auditor.rights << gstr_advance_receipt_create
  enterprise_auditor.rights << gstr_advance_receipt_update
  enterprise_auditor.rights << gstr_advance_receipt_delete




  # enterprise_owner.rights << gst_returns_read
  # enterprise_accountant.rights << gst_returns_read
  # enterprise_auditor.rights << gst_returns_read


  # enterprise_owner.rights << login_requests_read
  # enterprise_owner.rights << login_requests_create

  # enterprise_accountant.rights << login_requests_read
  # enterprise_accountant.rights << login_requests_create


  # enterprise_auditor.rights << login_requests_read
  # enterprise_auditor.rights << login_requests_create


  #Trial plan
  # trial_owner.rights << gst_authorizer_read
  # trial_owner.rights << gst_authorizer_create
  # trial_owner.rights << gst_authorizer_update
  # trial_owner.rights << gst_authorizer_delete
  trial_owner.rights << gstr2_filings_read
  trial_owner.rights << gstr2_filings_create
  trial_owner.rights << gstr2_filings_update
  trial_owner.rights << gstr2_filings_delete
  # trial_owner.rights << gstr1_filings_read
  # trial_owner.rights << gstr1_filings_create
  # trial_owner.rights << gstr1_filings_update
  # trial_owner.rights << gstr1_filings_delete
  trial_owner.rights << gst_credit_notes_read
  trial_owner.rights << gst_credit_notes_create
  trial_owner.rights << gst_credit_notes_update
  trial_owner.rights << gst_credit_notes_delete

  trial_owner.rights << gst_debit_notes_read
  trial_owner.rights << gst_debit_notes_create
  trial_owner.rights << gst_debit_notes_update
  trial_owner.rights << gst_debit_notes_delete


  trial_owner.rights << gstr_advance_receipt_read
  trial_owner.rights << gstr_advance_receipt_create
  trial_owner.rights << gstr_advance_receipt_update
  trial_owner.rights << gstr_advance_receipt_delete


  # trial_accountant.rights << gstr1_filings_read
  # trial_accountant.rights << gstr1_filings_create
  # trial_accountant.rights << gstr1_filings_update
  # trial_accountant.rights << gstr1_filings_delete
  # trial_accountant.rights << gst_authorizer_read
  # trial_accountant.rights << gst_authorizer_create
  # trial_accountant.rights << gst_authorizer_update
  # trial_accountant.rights << gst_authorizer_delete
  trial_accountant.rights << gstr2_filings_read
  trial_accountant.rights << gstr2_filings_create
  trial_accountant.rights << gstr2_filings_update
  trial_accountant.rights << gstr2_filings_delete

  trial_accountant.rights << gst_credit_notes_read
  trial_accountant.rights << gst_credit_notes_create
  trial_accountant.rights << gst_credit_notes_update
  trial_accountant.rights << gst_credit_notes_delete

  trial_accountant.rights << gst_debit_notes_read
  trial_accountant.rights << gst_debit_notes_create
  trial_accountant.rights << gst_debit_notes_update
  trial_accountant.rights << gst_debit_notes_delete


  trial_accountant.rights << gstr_advance_receipt_read
  trial_accountant.rights << gstr_advance_receipt_create
  trial_accountant.rights << gstr_advance_receipt_update
  trial_accountant.rights << gstr_advance_receipt_delete


  # trial_auditor.rights << gstr1_filings_read
  # trial_auditor.rights << gstr1_filings_create
  # trial_auditor.rights << gstr1_filings_update
  # trial_auditor.rights << gstr1_filings_delete

  # trial_owner.rights << gst_returns_read
  # trial_accountant.rights << gst_returns_read
  # trial_auditor.rights << gst_returns_read


  # trial_owner.rights << login_requests_read
  # trial_owner.rights << login_requests_create

  # trial_accountant.rights << login_requests_read
  # trial_accountant.rights << login_requests_create


  # trial_auditor.rights << login_requests_read
  # trial_auditor.rights << login_requests_create
  # trial_auditor.rights << gst_authorizer_read
  # trial_auditor.rights << gst_authorizer_create
  # trial_auditor.rights << gst_authorizer_update
  # trial_auditor.rights << gst_authorizer_delete
  trial_auditor.rights << gstr2_filings_read
  trial_auditor.rights << gstr2_filings_create
  trial_auditor.rights << gstr2_filings_update
  trial_auditor.rights << gstr2_filings_delete

  trial_auditor.rights << gst_credit_notes_read
  trial_auditor.rights << gst_credit_notes_create
  trial_auditor.rights << gst_credit_notes_update
  trial_auditor.rights << gst_credit_notes_delete

  trial_auditor.rights << gst_debit_notes_read
  trial_auditor.rights << gst_debit_notes_create
  trial_auditor.rights << gst_debit_notes_update
  trial_auditor.rights << gst_debit_notes_delete
  
  trial_auditor.rights << gstr_advance_receipt_read
  trial_auditor.rights << gstr_advance_receipt_create
  trial_auditor.rights << gstr_advance_receipt_update
  trial_auditor.rights << gstr_advance_receipt_delete



  #professional plan
  # professional_owner.rights << gstr1_filings_read
  # professional_owner.rights << gstr1_filings_create
  # professional_owner.rights << gstr1_filings_update
  # professional_owner.rights << gstr1_filings_delete
  # professional_owner.rights << gst_authorizer_read
  # professional_owner.rights << gst_authorizer_create
  # professional_owner.rights << gst_authorizer_update
  # professional_owner.rights << gst_authorizer_delete
  professional_owner.rights << gstr2_filings_read
  professional_owner.rights << gstr2_filings_create
  professional_owner.rights << gstr2_filings_update
  professional_owner.rights << gstr2_filings_delete

  professional_owner.rights << gst_credit_notes_read
  professional_owner.rights << gst_credit_notes_create
  professional_owner.rights << gst_credit_notes_update
  professional_owner.rights << gst_credit_notes_delete

  professional_owner.rights << gst_debit_notes_read
  professional_owner.rights << gst_debit_notes_create
  professional_owner.rights << gst_debit_notes_update
  professional_owner.rights << gst_debit_notes_delete

  professional_owner.rights << gstr_advance_receipt_read
  professional_owner.rights << gstr_advance_receipt_create
  professional_owner.rights << gstr_advance_receipt_update
  professional_owner.rights << gstr_advance_receipt_delete

  # professional_accountant.rights << gstr1_filings_read
  # professional_accountant.rights << gstr1_filings_create
  # professional_accountant.rights << gstr1_filings_update
  # professional_accountant.rights << gstr1_filings_delete
  # professional_accountant.rights << gst_authorizer_read
  # professional_accountant.rights << gst_authorizer_create
  # professional_accountant.rights << gst_authorizer_update
  # professional_accountant.rights << gst_authorizer_delete
  professional_accountant.rights << gst_credit_notes_read
  professional_accountant.rights << gst_credit_notes_create
  professional_accountant.rights << gst_credit_notes_update
  professional_accountant.rights << gst_credit_notes_delete

  professional_accountant.rights << gst_debit_notes_read
  professional_accountant.rights << gst_debit_notes_create
  professional_accountant.rights << gst_debit_notes_update
  professional_accountant.rights << gst_debit_notes_delete

  professional_accountant.rights << gstr2_filings_read
  professional_accountant.rights << gstr2_filings_create
  professional_accountant.rights << gstr2_filings_update
  professional_accountant.rights << gstr2_filings_delete

  professional_accountant.rights << gstr_advance_receipt_read
  professional_accountant.rights << gstr_advance_receipt_create
  professional_accountant.rights << gstr_advance_receipt_update
  professional_accountant.rights << gstr_advance_receipt_delete


  # professional_auditor.rights << gstr1_filings_read
  # professional_auditor.rights << gstr1_filings_create
  # professional_auditor.rights << gstr1_filings_update
  # professional_auditor.rights << gstr1_filings_delete

  # professional_owner.rights << gst_returns_read
  # professional_accountant.rights << gst_returns_read
  # professional_auditor.rights << gst_returns_read


  # professional_owner.rights << login_requests_read
  # professional_owner.rights << login_requests_create

  # professional_accountant.rights << login_requests_read
  # professional_accountant.rights << login_requests_create


  # professional_auditor.rights << login_requests_read
  # professional_auditor.rights << login_requests_create
  # professional_auditor.rights << gst_authorizer_read
  # professional_auditor.rights << gst_authorizer_create
  # professional_auditor.rights << gst_authorizer_update
  # professional_auditor.rights << gst_authorizer_delete
  professional_auditor.rights << gstr2_filings_read
  professional_auditor.rights << gstr2_filings_create
  professional_auditor.rights << gstr2_filings_update
  professional_auditor.rights << gstr2_filings_delete

  professional_auditor.rights << gst_credit_notes_read
  professional_auditor.rights << gst_credit_notes_create
  professional_auditor.rights << gst_credit_notes_update
  professional_auditor.rights << gst_credit_notes_delete

  professional_auditor.rights << gst_debit_notes_read
  professional_auditor.rights << gst_debit_notes_create
  professional_auditor.rights << gst_debit_notes_update
  professional_auditor.rights << gst_debit_notes_delete

  professional_auditor.rights << gstr_advance_receipt_read
  professional_auditor.rights << gstr_advance_receipt_create
  professional_auditor.rights << gstr_advance_receipt_update
  professional_auditor.rights << gstr_advance_receipt_delete



  #smb plan
  # smb_owner.rights << gstr1_filings_read
  # smb_owner.rights << gstr1_filings_create
  # smb_owner.rights << gstr1_filings_update
  # smb_owner.rights << gstr1_filings_delete
  # smb_owner.rights << gst_authorizer_read
  # smb_owner.rights << gst_authorizer_create
  # smb_owner.rights << gst_authorizer_update
  # smb_owner.rights << gst_authorizer_delete
  smb_owner.rights << gst_credit_notes_read
  smb_owner.rights << gst_credit_notes_create
  smb_owner.rights << gst_credit_notes_update
  smb_owner.rights << gst_credit_notes_delete

  smb_owner.rights << gst_debit_notes_read
  smb_owner.rights << gst_debit_notes_create
  smb_owner.rights << gst_debit_notes_update
  smb_owner.rights << gst_debit_notes_delete

  smb_owner.rights << gstr2_filings_read
  smb_owner.rights << gstr2_filings_create
  smb_owner.rights << gstr2_filings_update
  smb_owner.rights << gstr2_filings_delete

   smb_owner.rights << gstr_advance_receipt_read
   smb_owner.rights << gstr_advance_receipt_create
   smb_owner.rights << gstr_advance_receipt_update
   smb_owner.rights << gstr_advance_receipt_delete



  # smb_accountant.rights << gstr1_filings_read
  # smb_accountant.rights << gstr1_filings_create
  # smb_accountant.rights << gstr1_filings_update
  # smb_accountant.rights << gstr1_filings_delete
  # smb_accountant.rights << gst_authorizer_read
  # smb_accountant.rights << gst_authorizer_create
  # smb_accountant.rights << gst_authorizer_update
  # smb_accountant.rights << gst_authorizer_delete
  smb_accountant.rights << gstr2_filings_read
  smb_accountant.rights << gstr2_filings_create
  smb_accountant.rights << gstr2_filings_update
  smb_accountant.rights << gstr2_filings_delete

  smb_accountant.rights << gst_credit_notes_read
  smb_accountant.rights << gst_credit_notes_create
  smb_accountant.rights << gst_credit_notes_update
  smb_accountant.rights << gst_credit_notes_delete

  smb_accountant.rights << gst_debit_notes_read
  smb_accountant.rights << gst_debit_notes_create
  smb_accountant.rights << gst_debit_notes_update
  smb_accountant.rights << gst_debit_notes_delete

  smb_accountant.rights << gstr_advance_receipt_read
  smb_accountant.rights << gstr_advance_receipt_create
  smb_accountant.rights << gstr_advance_receipt_update
  smb_accountant.rights << gstr_advance_receipt_delete



  smb_accountant.rights << gstr_advance_receipt_read
  smb_accountant.rights << gstr_advance_receipt_create
  smb_accountant.rights << gstr_advance_receipt_update
  smb_accountant.rights << gstr_advance_receipt_delete



  # smb_auditor.rights << gstr1_filings_read
  # smb_auditor.rights << gstr1_filings_create
  # smb_auditor.rights << gstr1_filings_update
  # smb_auditor.rights << gstr1_filings_delete

  # smb_owner.rights << gst_returns_read
  # smb_accountant.rights << gst_returns_read
  # smb_auditor.rights << gst_returns_read
  # smb_auditor.rights << gst_authorizer_read
  # smb_auditor.rights << gst_authorizer_create
  # smb_auditor.rights << gst_authorizer_update
  # smb_auditor.rights << gst_authorizer_delete
  smb_auditor.rights << gst_credit_notes_read
  smb_auditor.rights << gst_credit_notes_create
  smb_auditor.rights << gst_credit_notes_update
  smb_auditor.rights << gst_credit_notes_delete

  smb_auditor.rights << gst_debit_notes_read
  smb_auditor.rights << gst_debit_notes_create
  smb_auditor.rights << gst_debit_notes_update
  smb_auditor.rights << gst_debit_notes_delete

  smb_auditor.rights << gstr2_filings_read
  smb_auditor.rights << gstr2_filings_create
  smb_auditor.rights << gstr2_filings_update
  smb_auditor.rights << gstr2_filings_delete

   smb_auditor.rights << gstr_advance_receipt_read
   smb_auditor.rights << gstr_advance_receipt_create
   smb_auditor.rights << gstr_advance_receipt_update
   smb_auditor.rights << gstr_advance_receipt_delete




  # smb_owner.rights << login_requests_read
  # smb_owner.rights << login_requests_create

  # smb_accountant.rights << login_requests_read
  # smb_accountant.rights << login_requests_create


  # smb_auditor.rights << login_requests_read
  # smb_auditor.rights << login_requests_create


  # GstReturnType.create!(:gst_category_id=>1, :return_type=>"GSTR1", :filing_frequency => "Monthly", 
  #   :description => "Monthly return for outward supplies made (contains the details of interstate as well as intrastate B2B and B2C sales including purchases under reverse charge and inter state stock transfers made during the tax period).")
  # GstReturnType.create!(:gst_category_id=>1, :return_type=>"GSTR1A", :filing_frequency => "Monthly",
  #  :description => "An amendment form that is used to correct the GSTR-1 document including any mismatches between the GSTR-1 of a taxpayer and the GSTR-2 of his/her customers. This can be filed between 15th and 17th of the following month.")
  # GstReturnType.create!(:gst_category_id=>1, :return_type=>"GSTR2", :filing_frequency => "Monthly", 
  #   :description => "Monthly return for inward supplies received (contains tax payer info, period of return and final invoice-level purchase information related to the tax period, listed separately for goods and services).")
  # GstReturnType.create!(:gst_category_id=>1, :return_type=>"GSTR2A", :filing_frequency => "Monthly",
  #  :description => "An auto drafted tax return for purchases and inward supplies made by a taxpayer that is automatically compiled by the GSTN based on the information present within the GSTR-1 of his/her suppliers.")
  # GstReturnType.create!(:gst_category_id=>1, :return_type=>"GSTR3", :filing_frequency => "Monthly", 
  #   :description => "Consolidated monthly tax return (contains The taxpayer basic information (name, GSTIN, etc), period to which the return pertains, turnover details, final aggregate-level inward and outward supply details, tax liability under CGST, SGST, IGST, and additional tax (+1% tax), details about your ITC, cash, and liability ledgers, details of other payments such as interests, penalties, and fees).")
  # # GstReturnType.create!(:gst_category_id=>1, :return_type=>"GSTR3A", :filing_frequency => "Monthly", 
  # #   :description => "It is a tax notice issued by the tax authority to a defaulter who has failed to file monthly GST returns on time.")
  # # GstReturnType.create!(:gst_category_id=>1, :return_type=>"GSTR3B", :filing_frequency => "Monthly",
  # #  :description => "Temporary consolidated summary return of inward and outward supplies that the Government of India has introduced as a relaxation for businesses that have recently transitioned to GST. Hence, in the months of July and August 2017, the tax payments will be based on a simple return called the GSTR-3B instead. ")
  # GstReturnType.create!(:gst_category_id=>3, :return_type=>"GSTR9", :filing_frequency => "Annual", 
  #   :description => "Annual consolidated tax return (It contains the taxpayer income and expenditure in detail. These are then regrouped according to the monthly returns filed by the tax payer)")

  #For Composition scheme
  # GstReturnType.create!(:gst_category_id=>3, :return_type=>"GSTR3", :filing_frequency => "Monthly", 
  #   :description => "")
  # GstReturnType.create!(:gst_category_id=>3, :return_type=>"GSTR3B", :filing_frequency => "Monthly",
  #  :description => "")

  #seeds for GSP tables
  # karvy_development_gsp = Gsp.create!(name: "karvy", url: "http://gsp.karvygst.com/", env: "development", version: "v0.3")
  # vayana_development_gsp = Gsp.create!(name: "vayana", url: "https://yoda.api.vayanagsp.in/gus/", env: "development", version: "v0.3")
  
end
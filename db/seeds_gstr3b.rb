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

  #Right.create!(:resource => 'goods_and_services_tax', :operation => 'READ')
  #Right.create!(:resource => 'goods_and_services_tax', :operation => 'DELETE')

  #rights to create GST invoices
  Right.create!(:resource => 'gstr3b_reports', :operation => 'READ')
  Right.create!(:resource => 'gstr3b_reports', :operation => 'CREATE')
  Right.create!(:resource => 'gstr3b_reports', :operation => 'UPDATE')
  Right.create!(:resource => 'gstr3b_reports', :operation => 'DELETE')


  #gst invoices section
  gstr3b_reports_read = Right.find_by_resource_and_operation('gstr3b_reports','READ')
  gstr3b_reports_create = Right.find_by_resource_and_operation('gstr3b_reports','CREATE')
  gstr3b_reports_update = Right.find_by_resource_and_operation('gstr3b_reports','UPDATE')  
  gstr3b_reports_delete = Right.find_by_resource_and_operation('gstr3b_reports','DELETE')

  # enterprise
  enterprise_owner.rights << gstr3b_reports_read
  enterprise_owner.rights << gstr3b_reports_create
  enterprise_owner.rights << gstr3b_reports_update
  enterprise_owner.rights << gstr3b_reports_delete

  enterprise_accountant.rights << gstr3b_reports_read
  enterprise_accountant.rights << gstr3b_reports_create
  enterprise_accountant.rights << gstr3b_reports_update
  enterprise_accountant.rights << gstr3b_reports_delete

  enterprise_auditor.rights << gstr3b_reports_read
  enterprise_auditor.rights << gstr3b_reports_create
  enterprise_auditor.rights << gstr3b_reports_update
  enterprise_auditor.rights << gstr3b_reports_delete


  #Trial plan
  trial_owner.rights << gstr3b_reports_read
  trial_owner.rights << gstr3b_reports_create
  trial_owner.rights << gstr3b_reports_update
  trial_owner.rights << gstr3b_reports_delete

  trial_accountant.rights << gstr3b_reports_read
  trial_accountant.rights << gstr3b_reports_create
  trial_accountant.rights << gstr3b_reports_update
  trial_accountant.rights << gstr3b_reports_delete

  trial_auditor.rights << gstr3b_reports_read
  trial_auditor.rights << gstr3b_reports_create
  trial_auditor.rights << gstr3b_reports_update
  trial_auditor.rights << gstr3b_reports_delete


  #professional plan
  professional_owner.rights << gstr3b_reports_read
  professional_owner.rights << gstr3b_reports_create
  professional_owner.rights << gstr3b_reports_update
  professional_owner.rights << gstr3b_reports_delete

  professional_accountant.rights << gstr3b_reports_read
  professional_accountant.rights << gstr3b_reports_create
  professional_accountant.rights << gstr3b_reports_update
  professional_accountant.rights << gstr3b_reports_delete

  professional_auditor.rights << gstr3b_reports_read
  professional_auditor.rights << gstr3b_reports_create
  professional_auditor.rights << gstr3b_reports_update
  professional_auditor.rights << gstr3b_reports_delete


  #smb plan
  smb_owner.rights << gstr3b_reports_read
  smb_owner.rights << gstr3b_reports_create
  smb_owner.rights << gstr3b_reports_update
  smb_owner.rights << gstr3b_reports_delete

  smb_accountant.rights << gstr3b_reports_read
  smb_accountant.rights << gstr3b_reports_create
  smb_accountant.rights << gstr3b_reports_update
  smb_accountant.rights << gstr3b_reports_delete

  smb_auditor.rights << gstr3b_reports_read
  smb_auditor.rights << gstr3b_reports_create
  smb_auditor.rights << gstr3b_reports_update
  smb_auditor.rights << gstr3b_reports_delete




  #rights to create GST invoices
  Right.create!(:resource => 'gstr1_filings', :operation => 'READ')
  Right.create!(:resource => 'gstr1_filings', :operation => 'CREATE')
  Right.create!(:resource => 'gstr1_filings', :operation => 'UPDATE')
  Right.create!(:resource => 'gstr1_filings', :operation => 'DELETE')


  #gst invoices section
  gstr1_filings_read = Right.find_by_resource_and_operation('gstr1_filings','READ')
  gstr1_filings_create = Right.find_by_resource_and_operation('gstr1_filings','CREATE')
  gstr1_filings_update = Right.find_by_resource_and_operation('gstr1_filings','UPDATE')  
  gstr1_filings_delete = Right.find_by_resource_and_operation('gstr1_filings','DELETE')

  # enterprise
  enterprise_owner.rights << gstr1_filings_read
  enterprise_owner.rights << gstr1_filings_create
  enterprise_owner.rights << gstr1_filings_update
  enterprise_owner.rights << gstr1_filings_delete

  enterprise_accountant.rights << gstr1_filings_read
  enterprise_accountant.rights << gstr1_filings_create
  enterprise_accountant.rights << gstr1_filings_update
  enterprise_accountant.rights << gstr1_filings_delete

  enterprise_auditor.rights << gstr1_filings_read
  enterprise_auditor.rights << gstr1_filings_create
  enterprise_auditor.rights << gstr1_filings_update
  enterprise_auditor.rights << gstr1_filings_delete


  #Trial plan
  trial_owner.rights << gstr1_filings_read
  trial_owner.rights << gstr1_filings_create
  trial_owner.rights << gstr1_filings_update
  trial_owner.rights << gstr1_filings_delete

  trial_accountant.rights << gstr1_filings_read
  trial_accountant.rights << gstr1_filings_create
  trial_accountant.rights << gstr1_filings_update
  trial_accountant.rights << gstr1_filings_delete

  trial_auditor.rights << gstr1_filings_read
  trial_auditor.rights << gstr1_filings_create
  trial_auditor.rights << gstr1_filings_update
  trial_auditor.rights << gstr1_filings_delete


  #professional plan
  professional_owner.rights << gstr1_filings_read
  professional_owner.rights << gstr1_filings_create
  professional_owner.rights << gstr1_filings_update
  professional_owner.rights << gstr1_filings_delete

  professional_accountant.rights << gstr1_filings_read
  professional_accountant.rights << gstr1_filings_create
  professional_accountant.rights << gstr1_filings_update
  professional_accountant.rights << gstr1_filings_delete

  professional_auditor.rights << gstr1_filings_read
  professional_auditor.rights << gstr1_filings_create
  professional_auditor.rights << gstr1_filings_update
  professional_auditor.rights << gstr1_filings_delete


  #smb plan
  smb_owner.rights << gstr1_filings_read
  smb_owner.rights << gstr1_filings_create
  smb_owner.rights << gstr1_filings_update
  smb_owner.rights << gstr1_filings_delete

  smb_accountant.rights << gstr1_filings_read
  smb_accountant.rights << gstr1_filings_create
  smb_accountant.rights << gstr1_filings_update
  smb_accountant.rights << gstr1_filings_delete

  smb_auditor.rights << gstr1_filings_read
  smb_auditor.rights << gstr1_filings_create
  smb_auditor.rights << gstr1_filings_update
  smb_auditor.rights << gstr1_filings_delete

end

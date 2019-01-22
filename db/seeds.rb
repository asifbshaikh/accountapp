ActiveRecord::Base.transaction do
  
  smb_plan = Plan.find_by_name('SMB')
  professional_plan = Plan.find_by_name('Professional')
  enterprise_plan = Plan.find_by_name('Enterprise')
  trial_plan = Plan.find_by_name('Trial')

  professional_owner = Role.find_by_name_and_plan_id('Owner', professional_plan)
  professional_accountant = Role.find_by_name_and_plan_id('Accountant', professional_plan)
  professional_auditor = Role.find_by_name_and_plan_id('Auditor', professional_plan)
  professional_inventory_mgr = Role.find_by_name_and_plan_id('Inventory Manager', professional_plan)

  enterprise_owner = Role.find_by_name_and_plan_id('Owner', enterprise_plan)
  enterprise_accountant = Role.find_by_name_and_plan_id('Accountant', enterprise_plan)
  enterprise_auditor = Role.find_by_name_and_plan_id('Auditor', enterprise_plan)
  enterprise_inventory_mgr = Role.find_by_name_and_plan_id('Inventory Manager', professional_plan)

  trial_owner = Role.find_by_name_and_plan_id('Owner', trial_plan)
  trial_accountant = Role.find_by_name_and_plan_id('Accountant', trial_plan)
  trial_auditor = Role.find_by_name_and_plan_id('Auditor', trial_plan)
  trial_inventory_mgr = Role.find_by_name_and_plan_id('Inventory Manager', professional_plan)

  smb_owner = Role.find_by_name_and_plan_id('Owner', smb_plan)
  smb_accountant = Role.find_by_name_and_plan_id('Accountant', smb_plan)
  smb_auditor = Role.find_by_name_and_plan_id('Auditor', smb_plan)
  smb_inventory_mgr = Role.find_by_name_and_plan_id('Inventory Manager', professional_plan)



  #rights to create GST invoices
Right.create!(:resource => 'product_catalog', :operation => 'READ')
Right.create!(:resource => 'invoice_report', :operation => 'READ')



  #gst invoices section
  product_catalog_read = Right.find_by_resource_and_operation('product_catalog','READ')
  invoice_report_read = Right.find_by_resource_and_operation('invoice_report','READ')


 


  # enterprise
  enterprise_owner.rights << product_catalog_read
  enterprise_accountant.rights << product_catalog_read
  enterprise_auditor.rights << product_catalog_read
  enterprise_inventory_mgr.rights << product_catalog_read


  enterprise_owner.rights << invoice_report_read
  enterprise_accountant.rights << invoice_report_read
  enterprise_auditor.rights << invoice_report_read
  enterprise_inventory_mgr.rights << invoice_report_read

  #Trial plan
  trial_owner.rights << product_catalog_read
  trial_accountant.rights << product_catalog_read
  trial_auditor.rights << product_catalog_read
  trial_inventory_mgr.rights << product_catalog_read

  trial_owner.rights << invoice_report_read
  trial_accountant.rights << invoice_report_read
  trial_auditor.rights << invoice_report_read
  trial_inventory_mgr.rights << invoice_report_read

  #professional plan
  professional_owner.rights << product_catalog_read
  professional_accountant.rights << product_catalog_read
  professional_auditor.rights << product_catalog_read
  professional_inventory_mgr.rights << product_catalog_read

  professional_owner.rights << invoice_report_read
  professional_accountant.rights << invoice_report_read
  professional_auditor.rights << invoice_report_read
  professional_inventory_mgr.rights << invoice_report_read


  #smb plan
  smb_owner.rights << product_catalog_read
  smb_accountant.rights << product_catalog_read
  smb_auditor.rights << product_catalog_read
  smb_inventory_mgr.rights << product_catalog_read

  smb_owner.rights << invoice_report_read
  smb_accountant.rights << invoice_report_read
  smb_auditor.rights << invoice_report_read
  smb_inventory_mgr.rights << invoice_report_read

end

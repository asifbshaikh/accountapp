ActiveRecord::Base.transaction do

  smb_plan = Plan.find_by_name('SMB')
  professional_plan = Plan.find_by_name('Professional')
  enterprise_plan = Plan.find_by_name('Enterprise')
  trial_plan = Plan.find_by_name('Trial')

  professional_owner = Role.find_by_name_and_plan_id('Owner', professional_plan)
  professional_accountant = Role.find_by_name_and_plan_id('Accountant', professional_plan)
 

  enterprise_owner = Role.find_by_name_and_plan_id('Owner', enterprise_plan)
  enterprise_accountant = Role.find_by_name_and_plan_id('Accountant', enterprise_plan)
  

  trial_owner = Role.find_by_name_and_plan_id('Owner', trial_plan)
  trial_accountant = Role.find_by_name_and_plan_id('Accountant', trial_plan)
 
  smb_owner = Role.find_by_name_and_plan_id('Owner', smb_plan)
  smb_accountant = Role.find_by_name_and_plan_id('Accountant', smb_plan)
  

  Right.create!(:resource => 'goods_and_services_tax', :operation => 'READ')
  Right.create!(:resource => 'goods_and_services_tax', :operation => 'DELETE')

  #rights to create GST invoices
  Right.create!(:resource => 'gst_invoices', :operation => 'READ')
  Right.create!(:resource => 'gst_invoices', :operation => 'CREATE')
  Right.create!(:resource => 'gst_invoices', :operation => 'UPDATE')
  Right.create!(:resource => 'gst_invoices', :operation => 'DELETE')

  # #rights to create GSTR1 summaris
  # Right.create!(:resource => 'gstr1_summaries', :operation => 'READ')
  # Right.create!(:resource => 'gst_authorizer', :operation => 'CREATE')
  # Right.create!(:resource => 'gst_authorizer', :operation => 'UPDATE')
  # Right.create!(:resource => 'gst_authorizer', :operation => 'DELETE')

  gstr_advance_receipt_create = Right.create!(:resource => 'gstr_advance_receipt', :operation => 'CREATE')
  gstr_advance_receipt_read = Right.create!(:resource => 'gstr_advance_receipt', :operation => 'READ') 
  gstr_advance_receipt_delete = Right.create!(:resource => 'gstr_advance_receipt', :operation => 'DELETE')
  gstr_advance_receipt_update = Right.create!(:resource => 'gstr_advance_receipt', :operation => 'UPDATE')

  enterprise_owner.rights << goods_and_services_tax_read
  enterprise_owner.rights << goods_and_services_tax_delete
  
  enterprise_accountant.rights << goods_and_services_tax_read
  enterprise_accountant.rights << goods_and_services_tax_delete

  # enterprise
  enterprise_owner.rights << gst_authorizer_read
  enterprise_owner.rights << gst_authorizer_create
  enterprise_owner.rights << gst_authorizer_update
  enterprise_owner.rights << gst_authorizer_delete

  enterprise_accountant.rights << gst_authorizer_read
  enterprise_accountant.rights << gst_authorizer_create
  enterprise_accountant.rights << gst_authorizer_update
  enterprise_accountant.rights << gst_authorizer_delete

  professional_auditor.rights << goods_and_services_tax_read
  professional_auditor.rights << goods_and_services_tax_delete

      professional_owner.rights << gstr_advance_receipt_create
      professional_owner.rights << gstr_advance_receipt_read
      professional_owner.rights << gstr_advance_receipt_update
      professional_owner.rights << gstr_advance_receipt_delete
  #    professional_accountant
      professional_accountant.rights << gstr_advance_receipt_create
      professional_accountant.rights << gstr_advance_receipt_read
      professional_accountant.rights << gstr_advance_receipt_update
      professional_accountant.rights << gstr_advance_receipt_delete
 

  # enterprise_owner   
      enterprise_owner.rights << gstr_advance_receipt_create
      enterprise_owner.rights << gstr_advance_receipt_read
      enterprise_owner.rights << gstr_advance_receipt_update
      enterprise_owner.rights << gstr_advance_receipt_delete
  # enterprise_accountant
      enterprise_accountant.rights << gstr_advance_receipt_create
      enterprise_accountant.rights << gstr_advance_receipt_read
      enterprise_accountant.rights << gstr_advance_receipt_update
      enterprise_accountant.rights << gstr_advance_receipt_delete
   
  # trial_owner    
     trial_owner.rights << gstr_advance_receipt_create
     trial_owner.rights << gstr_advance_receipt_read
     trial_owner.rights << gstr_advance_receipt_update
     trial_owner.rights << gstr_advance_receipt_delete
  # trial_accountant
     trial_accountant.rights << gstr_advance_receipt_create
     trial_accountant.rights << gstr_advance_receipt_read
     trial_accountant.rights << gstr_advance_receipt_update
     trial_accountant.rights << gstr_advance_receipt_delete
 

  trial_owner.rights << goods_and_services_tax_read
  trial_owner.rights << goods_and_services_tax_delete
  
  trial_accountant.rights << goods_and_services_tax_read
  trial_accountant.rights << goods_and_services_tax_delete

  # smb_owner 
     smb_owner.rights << gstr_advance_receipt_create
     smb_owner.rights << gstr_advance_receipt_read
     smb_owner.rights << gstr_advance_receipt_update
     smb_owner.rights << gstr_advance_receipt_delete
  # smb_accountant
     smb_accountant.rights << gstr_advance_receipt_create
     smb_accountant.rights << gstr_advance_receipt_read
     smb_accountant.rights << gstr_advance_receipt_update

  trial_accountant.rights << gst_authorizer_read
  trial_accountant.rights << gst_authorizer_create
  trial_accountant.rights << gst_authorizer_update
  trial_accountant.rights << gst_authorizer_delete



  enterprise_accountant.rights << gst_invoices_read
  enterprise_accountant.rights << gst_invoices_create
  enterprise_accountant.rights << gst_invoices_update
  enterprise_accountant.rights << gst_invoices_delete

  enterprise_staff.rights << gst_invoices_read
  enterprise_staff.rights << gst_invoices_create
  enterprise_staff.rights << gst_invoices_update
  enterprise_staff.rights << gst_invoices_delete

  enterprise_sales.rights << gst_invoices_read
  enterprise_sales.rights << gst_invoices_create
  enterprise_sales.rights << gst_invoices_update
  enterprise_sales.rights << gst_invoices_delete

  #Trial plan
  trial_owner.rights << gst_invoices_read
  trial_owner.rights << gst_invoices_create
  trial_owner.rights << gst_invoices_update
  trial_owner.rights << gst_invoices_delete

  trial_accountant.rights << gst_invoices_read
  trial_accountant.rights << gst_invoices_create
  trial_accountant.rights << gst_invoices_update
  trial_accountant.rights << gst_invoices_delete

  trial_staff.rights << gst_invoices_read
  trial_staff.rights << gst_invoices_create
  trial_staff.rights << gst_invoices_update
  trial_staff.rights << gst_invoices_delete

  trial_sales.rights << gst_invoices_read
  trial_sales.rights << gst_invoices_create
  trial_sales.rights << gst_invoices_update
  trial_sales.rights << gst_invoices_delete

  #professional plan
  professional_owner.rights << gst_invoices_read
  professional_owner.rights << gst_invoices_create
  professional_owner.rights << gst_invoices_update
  professional_owner.rights << gst_invoices_delete

  professional_accountant.rights << gst_invoices_read
  professional_accountant.rights << gst_invoices_create
  professional_accountant.rights << gst_invoices_update
  professional_accountant.rights << gst_invoices_delete

  professional_staff.rights << gst_invoices_read
  professional_staff.rights << gst_invoices_create
  professional_staff.rights << gst_invoices_update
  professional_staff.rights << gst_invoices_delete

  professional_sales.rights << gst_invoices_read
  professional_sales.rights << gst_invoices_create
  professional_sales.rights << gst_invoices_update
  professional_sales.rights << gst_invoices_delete

  #smb plan
  smb_owner.rights << gst_invoices_read
  smb_owner.rights << gst_invoices_create
  smb_owner.rights << gst_invoices_update
  smb_owner.rights << gst_invoices_delete

  smb_accountant.rights << gst_invoices_read
  smb_accountant.rights << gst_invoices_create
  smb_accountant.rights << gst_invoices_update
  smb_accountant.rights << gst_invoices_delete

  smb_staff.rights << gst_invoices_read
  smb_staff.rights << gst_invoices_create
  smb_staff.rights << gst_invoices_update
  smb_staff.rights << gst_invoices_delete

  smb_sales.rights << gst_invoices_read
  smb_sales.rights << gst_invoices_create
  smb_sales.rights << gst_invoices_update
  smb_sales.rights << gst_invoices_delete


end

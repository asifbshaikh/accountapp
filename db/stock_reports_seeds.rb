ActiveRecord::Base.transaction do
  professional_plan = Plan.find_by_name('Professional')
  enterprise_plan = Plan.find_by_name('Enterprise')
  trial_plan = Plan.find_by_name('Trial')
  smb_plan = Plan.find_by_name('SMB')
  free_plan = Plan.find_by_name('Free')
  basic_plan = Plan.find_by_name('Basic')


  free_owner = Role.find_by_name_and_plan_id('Owner', free_plan)

  professional_owner = Role.find_by_name_and_plan_id('Owner', professional_plan)
  professional_accountant = Role.find_by_name_and_plan_id('Accountant', professional_plan)
  professional_auditor = Role.find_by_name_and_plan_id('Auditor', professional_plan)
  professional_staff = Role.find_by_name_and_plan_id('Staff', professional_plan)
  professional_employee = Role.find_by_name_and_plan_id('Employee', professional_plan)

  enterprise_owner = Role.find_by_name_and_plan_id('Owner', enterprise_plan)
  enterprise_accountant = Role.find_by_name_and_plan_id('Accountant', enterprise_plan)
  enterprise_auditor = Role.find_by_name_and_plan_id('Auditor', enterprise_plan)
  enterprise_staff = Role.find_by_name_and_plan_id('Staff', enterprise_plan)
  enterprise_employee = Role.find_by_name_and_plan_id('Employee', enterprise_plan)
  enterprise_inventory_manager = Role.find_by_name_and_plan_id('Inventory Manager', enterprise_plan)

  trial_owner = Role.find_by_name_and_plan_id('Owner', trial_plan)
  trial_accountant = Role.find_by_name_and_plan_id('Accountant', trial_plan)
  trial_auditor = Role.find_by_name_and_plan_id('Auditor', trial_plan)
  trial_staff = Role.find_by_name_and_plan_id('Staff', trial_plan)
  trial_employee = Role.find_by_name_and_plan_id('Employee', trial_plan)
  trial_inventory_manager = Role.find_by_name_and_plan_id('Inventory Manager', trial_plan)
  
  smb_owner = Role.find_by_name_and_plan_id('Owner', smb_plan)
  smb_accountant = Role.find_by_name_and_plan_id('Accountant', smb_plan)
  smb_auditor = Role.find_by_name_and_plan_id('Auditor', smb_plan)
  smb_staff = Role.find_by_name_and_plan_id('Staff', smb_plan)
  smb_employee = Role.find_by_name_and_plan_id('Employee', smb_plan)
  smb_inventory_manager = Role.find_by_name_and_plan_id('Inventory Manager', smb_plan)
# newrights
  basic_owner = Role.find_by_name_and_plan_id('Owner', basic_plan)
  basic_accountant = Role.find_by_name_and_plan_id('Accountant', basic_plan)
  basic_auditor = Role.find_by_name_and_plan_id('Auditor', basic_plan)
  basic_staff = Role.find_by_name_and_plan_id('Staff', basic_plan)
  basic_employee = Role.find_by_name_and_plan_id('Employee', basic_plan)
  basic_inventory_manager = Role.find_by_name_and_plan_id('Inventory Manager', basic_plan)




 #warehouse wise stock report
     # warehouse_wise_stock_read = Right.create!(:resource => 'warehouse_wise_stock', :operation => 'READ') 
     warehouse_wise_stock_read = Right.find_by_resource_and_operation('warehouse_wise_stock', 'READ')
     
     #free_owner 
     free_owner.rights << warehouse_wise_stock_read

   #essential_owner  
    essential_owner.rights << warehouse_wise_stock_read
     #essential_accountant
    essential_accountant.rights << warehouse_wise_stock_read
     #essential_auditor
    essential_auditor.rights << warehouse_wise_stock_read  

   #basic_owner  
     basic_owner.rights << warehouse_wise_stock_read
     #basic_accountant
     basic_accountant.rights << warehouse_wise_stock_read
     #basic_auditor
     basic_auditor.rights << warehouse_wise_stock_read
     #premium_owner  
     premium_owner.rights << warehouse_wise_stock_read
     #premium_accountant
     premium_accountant.rights << warehouse_wise_stock_read
     #premium_auditor
     premium_auditor.rights << warehouse_wise_stock_read
     #enterprise_owner 
     enterprise_owner.rights << warehouse_wise_stock_read
     #enterprise_accountant
     enterprise_accountant.rights << warehouse_wise_stock_read
     #enterprise_auditor
     enterprise_auditor.rights << warehouse_wise_stock_read


     #product wise stock report
     product_wise_stock_read = Right.create!(:resource => 'product_wise_stock', :operation => 'READ') 

     #free_owner 
     free_owner.rights << product_wise_stock_read

   #essential_owner  
    essential_owner.rights << product_wise_stock_read
     #essential_accountant
    essential_accountant.rights << product_wise_stock_read
     #essential_auditor
    essential_auditor.rights << product_wise_stock_read  

   #basic_owner  
     basic_owner.rights << product_wise_stock_read
     #basic_accountant
     basic_accountant.rights << product_wise_stock_read
     #basic_auditor
     basic_auditor.rights << product_wise_stock_read
     #premium_owner  
     premium_owner.rights << product_wise_stock_read
     #premium_accountant
     premium_accountant.rights << product_wise_stock_read
     #premium_auditor
     premium_auditor.rights << product_wise_stock_read
     #enterprise_owner 
     enterprise_owner.rights << product_wise_stock_read
     #enterprise_accountant
     enterprise_accountant.rights << product_wise_stock_read
     #enterprise_auditor
     enterprise_auditor.rights << product_wise_stock_read

# stock movement report
     stock_movement_read = Right.create!(:resource => 'stock_movement', :operation => 'READ') 

     #free_owner 
     free_owner.rights << stock_movement_read

   #essential_owner  
    essential_owner.rights << stock_movement_read
     #essential_accountant
    essential_accountant.rights << stock_movement_read
     #essential_auditor
    essential_auditor.rights << stock_movement_read  

   #basic_owner  
     basic_owner.rights << stock_movement_read
     #basic_accountant
     basic_accountant.rights << stock_movement_read
     #basic_auditor
     basic_auditor.rights << stock_movement_read
     #premium_owner  
     premium_owner.rights << stock_movement_read
     #premium_accountant
     premium_accountant.rights << stock_movement_read
     #premium_auditor
     premium_auditor.rights << stock_movement_read
     #enterprise_owner 
     enterprise_owner.rights << stock_movement_read
     #enterprise_accountant
     enterprise_accountant.rights << stock_movement_read
     #enterprise_auditor
     enterprise_auditor.rights << stock_movement_read
end
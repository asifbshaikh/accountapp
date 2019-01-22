ActiveRecord::Base.transaction do
  professional_plan = Plan.find_by_name('Professional')
  enterprise_plan = Plan.find_by_name('Enterprise')
  trial_plan = Plan.find_by_name('Trial')
  smb_plan = Plan.find_by_name('SMB')
  free_plan = Plan.find_by_name('Free')

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

#company_Assets
        company_assets_create = Right.create!(:resource => 'company_assets', :operation => 'CREATE')
        company_assets_read = Right.create!(:resource => 'company_assets', :operation => 'READ') 
        company_assets_delete = Right.create!(:resource => 'company_assets', :operation => 'DELETE')
        company_assets_update = Right.create!(:resource => 'company_assets', :operation => 'UPDATE')
#    
         free_owner.rights << company_assets_create
         free_owner.rights << company_assets_read
         free_owner.rights << company_assets_update
         free_owner.rights << company_assets_delete
       #professional_owner 
        professional_owner.rights << company_assets_create
        professional_owner.rights << company_assets_read
        professional_owner.rights << company_assets_update
        professional_owner.rights << company_assets_delete
        #professional_accountant
        professional_accountant.rights << company_assets_create
        professional_accountant.rights << company_assets_read
        professional_accountant.rights << company_assets_update
        #professional_staff
        professional_staff.rights << company_assets_read
        #professional_employee
        professional_employee.rights << company_assets_read
        
#       #enterprise_owner 
        enterprise_owner.rights << company_assets_create
        enterprise_owner.rights << company_assets_read
        enterprise_owner.rights << company_assets_update
        enterprise_owner.rights << company_assets_delete
        #enterprise_accountant
        enterprise_accountant.rights << company_assets_create
        enterprise_accountant.rights << company_assets_read
        enterprise_accountant.rights << company_assets_update
        #enterprise_staff
        enterprise_staff.rights << company_assets_read
        #enterprise_employee
        enterprise_employee.rights << company_assets_read
        #enterprise_inventory_manager
        enterprise_inventory_manager.rights << company_assets_read

 
 #       #trial_owner 
        trial_owner.rights << company_assets_create
        trial_owner.rights << company_assets_read
        trial_owner.rights << company_assets_update
        trial_owner.rights << company_assets_delete
        #trial_accountant
        trial_accountant.rights << company_assets_create
        trial_accountant.rights << company_assets_read
        trial_accountant.rights << company_assets_update
        #trial_staff
        trial_staff.rights << company_assets_read
        #trial_employee
        trial_employee.rights << company_assets_read
        #trial_inventory_manager
        trial_inventory_manager.rights << company_assets_read

#       #smb_owner 
        smb_owner.rights << company_assets_create
        smb_owner.rights << company_assets_read
        smb_owner.rights << company_assets_update
        smb_owner.rights << company_assets_delete
        #smb_accountant
        smb_accountant.rights << company_assets_create
        smb_accountant.rights << company_assets_read
        smb_accountant.rights << company_assets_update
        #smb_staff
        smb_staff.rights << company_assets_read
        #smb_employee
        smb_employee.rights << company_assets_read
        #smb_inventory_manager
        smb_inventory_manager.rights << company_assets_read

      
end
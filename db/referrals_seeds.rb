ActiveRecord::Base.transaction do
  professional_plan = Plan.find_by_name('Professional')
  enterprise_plan = Plan.find_by_name('Enterprise')
  trial_plan = Plan.find_by_name('Trial')
  smb_plan = Plan.find_by_name('SMB')
  free_plan = Plan.find_by_name('PWYW')
 
  professional_owner = Role.find_by_name_and_plan_id('Owner', professional_plan)
  professional_accountant = Role.find_by_name_and_plan_id('Accountant', professional_plan)
  

  enterprise_owner = Role.find_by_name_and_plan_id('Owner', enterprise_plan)
  enterprise_accountant = Role.find_by_name_and_plan_id('Accountant', enterprise_plan)
  

  trial_owner = Role.find_by_name_and_plan_id('Owner', trial_plan)
  trial_accountant = Role.find_by_name_and_plan_id('Accountant', trial_plan)
  
  
  smb_owner = Role.find_by_name_and_plan_id('Owner', smb_plan)
  smb_accountant = Role.find_by_name_and_plan_id('Accountant', smb_plan)
    
  free_owner = Role.find_by_name_and_plan_id('Owner', free_plan)

#referral rights and roles
  pbreferrals_create = Right.create!(:resource => 'pbreferrals', :operation => 'CREATE')
  pbreferrals_read = Right.create!(:resource => 'pbreferrals', :operation => 'READ')
  pbreferrals_delete = Right.create!(:resource=>'pbreferrals', :operation=>'DELETE')
  pbreferrals_update = Right.create!(:resource => 'pbreferrals', :operation => 'UPDATE')

  #enterprise_owner  
  enterprise_owner.rights << pbreferrals_create
  enterprise_owner.rights << pbreferrals_read
  enterprise_owner.rights << pbreferrals_update
  enterprise_owner.rights << pbreferrals_delete
  # enterprise_accountant
  enterprise_accountant.rights << pbreferrals_create
  enterprise_accountant.rights << pbreferrals_read
  enterprise_accountant.rights << pbreferrals_update
  enterprise_accountant.rights << pbreferrals_delete
  
 #trial_owner  
  trial_owner.rights << pbreferrals_create
  trial_owner.rights << pbreferrals_read
  trial_owner.rights << pbreferrals_update
  trial_owner.rights << pbreferrals_delete
  # trial_accountant
  trial_accountant.rights << pbreferrals_create
  trial_accountant.rights << pbreferrals_read
  trial_accountant.rights << pbreferrals_update
  trial_accountant.rights << pbreferrals_delete
  
#smb_owner  
  smb_owner.rights << pbreferrals_create
  smb_owner.rights << pbreferrals_read
  smb_owner.rights << pbreferrals_update
  smb_owner.rights << pbreferrals_delete
  # smb_accountant
  smb_accountant.rights << pbreferrals_create
  smb_accountant.rights << pbreferrals_read
  smb_accountant.rights << pbreferrals_update
  smb_accountant.rights << pbreferrals_delete

 #professional_owner  
  professional_owner.rights << pbreferrals_create
  professional_owner.rights << pbreferrals_read
  professional_owner.rights << pbreferrals_update
  professional_owner.rights << pbreferrals_delete
  # professional_accountant
  professional_accountant.rights << pbreferrals_create
  professional_accountant.rights << pbreferrals_read
  professional_accountant.rights << pbreferrals_update
  professional_accountant.rights << pbreferrals_delete
  
 #free_owner  
  free_owner.rights << pbreferrals_create
  free_owner.rights << pbreferrals_read
  free_owner.rights << pbreferrals_update
  free_owner.rights << pbreferrals_delete
  
end
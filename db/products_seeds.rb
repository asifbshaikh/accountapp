ActiveRecord::Base.transaction do
  essential_plan = Plan.find_by_name('Essential')
  free_plan = Plan.find_by_name('Free')

  free_owner = Role.find_by_name_and_plan_id('Owner', free_plan)

  essential_owner = Role.find_by_name_and_plan_id('Owner', essential_plan)
  essential_accountant = Role.find_by_name_and_plan_id('Accountant', essential_plan)
  essential_staff = Role.find_by_name_and_plan_id('Staff', essential_plan)

  products_create = Right.create!(:resource => 'products', :operation => 'CREATE')
  products_read = Right.create!(:resource => 'products', :operation => 'READ') 
  products_delete = Right.create!(:resource => 'products', :operation => 'DELETE')
  products_update = Right.create!(:resource => 'products', :operation => 'UPDATE')

  #free_owner 
  free_owner.rights << products_create
  free_owner.rights << products_read
  free_owner.rights << products_update
  free_owner.rights << products_delete

  #essential_owner 
  essential_owner.rights << products_create
  essential_owner.rights << products_read
  essential_owner.rights << products_update
  essential_owner.rights << products_delete
  #essential_accountant 
  essential_accountant.rights << products_create
  essential_accountant.rights << products_read
  essential_accountant.rights << products_update
  essential_accountant.rights << products_delete

  #essential_staff 
  essential_staff.rights << products_create
  essential_staff.rights << products_read
  essential_staff.rights << products_update
  essential_staff.rights << products_delete
end
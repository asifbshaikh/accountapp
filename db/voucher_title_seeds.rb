ActiveRecord::Base.transaction do
  ent_plan = Plan.find_by_name('Enterprise')
  professional_plan = Plan.find_by_name('Professional')
  professional_owner = Role.find_by_name_and_plan_id('Owner', professional_plan)
  professional_accountant = Role.find_by_name_and_plan_id('Accountant', professional_plan)


    #ent_voucher_title = Role.find_by_name_and_plan_id('Owner', ent_plan)




    voucher_title_create = Right.find_by_resource_and_operation('voucher_titles','CREATE')
    voucher_title_read = Right.find_by_resource_and_operation('voucher_titles','READ')
    voucher_title_update = Right.find_by_resource_and_operation('voucher_titles','UPDATE')
    voucher_title_delete = Right.find_by_resource_and_operation('voucher_titles','DELETE')

    professional_owner.rights << voucher_title_create
    professional_owner.rights << voucher_title_read
    professional_owner.rights << voucher_title_update
    professional_owner.rights << voucher_title_delete

    professional_accountant.rights << voucher_title_create
    professional_accountant.rights << voucher_title_read
    professional_accountant.rights << voucher_title_update
    professional_accountant.rights << voucher_title_delete



end

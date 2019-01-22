ActiveRecord::Base.transaction do
    basic_plan = Plan.find_by_name('Basic')
    premium_plan = Plan.find_by_name('Premium')
    enterprise_plan = Plan.find_by_name('Enterprise')
    essential_plan = Plan.find_by_name('Essential')

    basic_owner = Role.find_by_name_and_plan_id('Owner', basic_plan)
    premium_owner = Role.find_by_name_and_plan_id('Owner', premium_plan)
    enterprise_owner = Role.find_by_name_and_plan_id('Owner', enterprise_plan)
    essential_owner = Role.find_by_name_and_plan_id('Owner', essential_plan)

    billing_history_read = Right.create!(:resource => 'billing_history', :operation => 'READ')

    basic_owner.rights << billing_history_read
    premium_owner.rights << billing_history_read
    enterprise_owner.rights << billing_history_read
    essential_owner.rights << billing_history_read
  end
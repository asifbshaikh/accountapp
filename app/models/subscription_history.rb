class SubscriptionHistory < ActiveRecord::Base

  class << self
    def create_subscription_history(subscription )
      SubscriptionHistory.create!(
        :company_id => subscription.company_id,
        :plan_id => subscription.plan_id,
        :start_date => subscription.start_date,
        :end_date => subscription.end_date,
        :renewal_date => subscription.renewal_date,
        :first_subscription_date => subscription.first_subscription_date,
        :ip_address => subscription.ip_address,
        :amount => subscription.amount,
        :allocated_storage_mb => subscription.allocated_storage_mb,
        :allocated_user_count => subscription.allocated_user_count
      )
    end
  end
end

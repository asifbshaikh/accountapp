class AddRegisteredReferralCountToUserReferrals < ActiveRecord::Migration
  def change
    add_column :user_referrals, :registered_referral_count, :integer, :default=> 0
  end
end

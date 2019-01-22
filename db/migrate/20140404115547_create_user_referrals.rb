class CreateUserReferrals < ActiveRecord::Migration
  def change
    create_table :user_referrals do |t|
      t.integer :company_id
      t.integer :user_id
      t.integer :referral_count, :default => 0
      t.integer :paid_referral_count, :default => 0
      t.decimal :referral_balance, :precision => 18, :scale => 2, :default => 0

      t.timestamps
    end
  end
end

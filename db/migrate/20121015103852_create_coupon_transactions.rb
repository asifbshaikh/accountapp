class CreateCouponTransactions < ActiveRecord::Migration
  def self.up
    create_table :coupon_transactions do |t|
      t.integer :coupon_id
      t.integer :company_id
      t.integer :user_id
      t.datetime :used

      t.timestamps
    end
  end

  def self.down
    drop_table :coupon_transactions
  end
end

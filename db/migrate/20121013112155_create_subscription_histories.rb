class CreateSubscriptionHistories < ActiveRecord::Migration
  def self.up
    create_table :subscription_histories do |t|
      t.integer :company_id
      t.integer :plan_id
      t.datetime :start_date
      t.datetime :end_date
      t.datetime :renewal_date
      t.datetime :first_subscription_date
      t.string :ip_address
      t.decimal :amount, :precision => 18, :scale => 2
      t.decimal :allocated_storage_mb
      t.integer :allocated_user_count

      t.timestamps
    end
  end

  def self.down
    drop_table :subscription_histories
  end
end

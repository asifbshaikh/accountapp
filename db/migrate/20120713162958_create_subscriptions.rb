class CreateSubscriptions < ActiveRecord::Migration
  def self.up
    create_table :subscriptions do |t|
      t.integer :company_id
      t.integer :plan_id
      t.datetime :start_date
      t.datetime :end_date
      t.string :status
      t.datetime :renewal_date
      t.datetime :first_subscription_date
      t.string :ip_address
      t.decimal :amount, :precision => 18, :sclae => 2, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :subscriptions
  end
end

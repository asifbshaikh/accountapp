class CreateCoupons < ActiveRecord::Migration
  def self.up
    create_table :coupons do |t|
      t.string :name
      t.string :coupon_code
      t.string :coupon_type
      t.decimal :discount
      t.decimal :total_amount
      t.date :date_start
      t.date :date_end
      t.integer :uses_per_coupon
      t.integer :uses_per_customer
      t.string :status

      t.timestamps
    end
  end

  def self.down
    drop_table :coupons
  end
end

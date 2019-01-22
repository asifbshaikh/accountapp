class CreateLineItems < ActiveRecord::Migration
  def self.up
    create_table :line_items do |t|
      t.integer :voucher_id
      t.integer :account_id
      t.text :description
      t.integer :quantity
      t.decimal :unit_cost
      t.decimal :amount
      t.text :purchase_order_number

      t.timestamps
    end
  end

  def self.down
    drop_table :line_items
  end
end

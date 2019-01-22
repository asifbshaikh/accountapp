class CreatePurchaseOrderLineItems < ActiveRecord::Migration
  def self.up
    create_table :purchase_order_line_items do |t|
      t.integer :purchase_order_id
      t.integer :account_id
      t.decimal :quantity, :precision => 10, :scale => 2
      t.decimal :unit_rate, :precision => 18, :scale => 2
      t.string :cost_center
      t.decimal :tax
      t.decimal :amount, :precision => 18, :scale => 2
      t.text :description
      t.boolean :deleted
      t.boolean :deleted_by

      t.timestamps
    end
  end

  def self.down
    drop_table :purchase_order_line_items
  end
end

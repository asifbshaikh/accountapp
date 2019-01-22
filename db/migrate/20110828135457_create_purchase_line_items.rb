class CreatePurchaseLineItems < ActiveRecord::Migration
  def self.up
    create_table :purchase_line_items do |t|
      t.integer :purchase_id, :null => false
      t.integer :account_id, :null => false
      t.decimal :quantity , :precision => 10, :scale => 2, :default => 0
      t.decimal :unit_rate, :precision => 18, :scale => 2, :default => 0
      t.string :purchase_order_reference
      t.string :cost_center
      t.string :tax, :precision => 18, :scale => 2, :default => 0
      t.decimal :amount, :precision => 18, :scale => 2, :default => 0
			t.text		:description
      t.boolean :deleted
      t.integer :deleted_by
      t.integer :approved_by

      t.timestamps
    end
  end

  def self.down
    drop_table :purchase_line_items
  end
end

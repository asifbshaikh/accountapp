class CreateInventorySettings < ActiveRecord::Migration
  def change
    create_table :inventory_settings do |t|
      t.integer :company_id, :null => false
      t.boolean :purchase_effects_inventory, :null => false, :default => false
      t.string :inventory_model, :limit => 20
      t.timestamps
    end
  end
end

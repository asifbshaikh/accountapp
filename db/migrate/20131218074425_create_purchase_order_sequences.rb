class CreatePurchaseOrderSequences < ActiveRecord::Migration
  def change
    create_table :purchase_order_sequences do |t|
      t.integer :company_id, :null=>false
      t.integer :purchase_order_sequence, :default=>0

      t.timestamps
    end
  end
end

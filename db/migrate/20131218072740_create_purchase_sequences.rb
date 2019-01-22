class CreatePurchaseSequences < ActiveRecord::Migration
  def change
    create_table :purchase_sequences do |t|
      t.integer :company_id, :null => false
      t.integer :purchase_sequence, :default=>0

      t.timestamps
    end
  end
end

class CreatePurchaseReturnSequences < ActiveRecord::Migration
  def change
    create_table :purchase_return_sequences do |t|
      t.integer :company_id, :null=>false
      t.integer :purchase_return_sequence, :default=>0

      t.timestamps
    end
  end
end

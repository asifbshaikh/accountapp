class CreatePurchaseDebitAllocations < ActiveRecord::Migration
  def change
    create_table :purchase_debit_allocations do |t|
      t.integer :purchase_id
      t.integer :debit_note_id
      t.decimal :amount, :precision=>18, :scale=>2
      t.boolean :deleted, :default=>false

      t.timestamps
    end
  end
end

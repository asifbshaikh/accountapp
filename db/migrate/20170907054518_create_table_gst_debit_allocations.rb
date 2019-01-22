class CreateTableGstDebitAllocations < ActiveRecord::Migration
  def change
    create_table :gst_debit_allocations do |t|
      t.integer :purchase_id
      t.integer :gst_debit_note_id
      t.decimal :amount, :precision=>18, :scale=>2
      t.boolean :deleted, :default=>false

      t.timestamps
    end
  end
end

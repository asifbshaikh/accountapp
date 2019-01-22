class CreateInvoiceCreditAllocations < ActiveRecord::Migration
  def change
    create_table :invoice_credit_allocations do |t|
      t.integer :invoice_id
      t.integer :credit_note_id
      t.decimal :amount, :precision=>18, :scale=>2
      t.boolean :deleted, :default=>false

      t.timestamps
    end
  end
end

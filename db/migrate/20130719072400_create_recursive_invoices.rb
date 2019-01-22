class CreateRecursiveInvoices < ActiveRecord::Migration
  def self.up
    create_table :recursive_invoices do |t|
      t.integer :invoice_id
      t.integer :recursion_id

      t.timestamps
    end
  end

  def self.down
    drop_table :recursive_invoices
  end
end

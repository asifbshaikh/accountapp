class CreateInvoiceReturnLineItems < ActiveRecord::Migration
  def change
    create_table :invoice_return_line_items do |t|
      t.integer :invoice_return_id, :false=>true
      t.integer :account_id
      t.decimal :quantity, :precision=>10, :scale=>2, :default=>0.0
      t.decimal :unit_rate, :precision=>18, :scale=>2, :default=>0.0
      t.boolean :tax, :default=>false
      t.decimal :amount, :precision=>18, :scale=>2, :default=>0.0
      t.string :line_type
      t.integer :product_id
      t.integer :tax_account_id
      t.decimal :discount_percent
      t.integer :invoice_line_item_id

      t.timestamps
    end
  end
end

class CreateInvoiceReturnTaxes < ActiveRecord::Migration
  def change
    create_table :invoice_return_taxes do |t|
      t.integer :invoice_return_line_item_id, :null=>false
      t.integer :account_id, :null=>false

      t.timestamps
    end
  end
end

class CreateExpenseTaxes < ActiveRecord::Migration
  def change
    create_table :expense_taxes do |t|
      t.integer :expense_line_item_id, :null=>false
      t.integer :account_id, :null=>false

      t.timestamps
    end
  end
end

class AddItcToExpenses < ActiveRecord::Migration
  def change
    add_column :expense_line_items, :eligibility, :string
    add_column :expense_line_items, :igst, :decimal
    add_column :expense_line_items, :cgst, :decimal
    add_column :expense_line_items, :sgst, :decimal

  end
end

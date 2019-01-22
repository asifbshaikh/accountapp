class AddTaxToExpenseLineItems < ActiveRecord::Migration
  def self.up
    add_column :expense_line_items, :tax, :boolean
  end

  def self.down
    remove_column :expense_line_items, :tax
  end
end

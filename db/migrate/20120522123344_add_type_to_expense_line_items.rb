class AddTypeToExpenseLineItems < ActiveRecord::Migration
  def self.up
    add_column :expense_line_items, :type, :string
  end

  def self.down
    remove_column :expense_line_items, :type
  end
end

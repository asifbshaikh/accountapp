class CreateExpenseLineItems < ActiveRecord::Migration
  def self.up
    create_table :expense_line_items do |t|
      t.integer :expense_id, :null => false
      t.integer :account_id, :null => false
      t.decimal :amount, :precision => 18, :scale => 2, :default => 0
			t.string	:description

      t.timestamps
    end
  end

  def self.down
    drop_table :expense_line_items
  end
end

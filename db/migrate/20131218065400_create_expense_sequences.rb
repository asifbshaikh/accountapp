class CreateExpenseSequences < ActiveRecord::Migration
  def change
    create_table :expense_sequences do |t|
      t.integer :company_id, :null => false
      t.integer :expense_sequence, :default=>0

      t.timestamps
    end
  end
end

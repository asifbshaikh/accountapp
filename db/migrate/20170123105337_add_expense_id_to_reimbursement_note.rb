class AddExpenseIdToReimbursementNote < ActiveRecord::Migration
  def up
    add_column :reimbursement_notes, :expense_id, :integer
  end

  def down
    remove_column :reimbursement_notes, :expense_id, :integer
  end
end

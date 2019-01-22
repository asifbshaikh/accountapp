class ReimbursementNoteTableChanges < ActiveRecord::Migration
  def up
  	remove_column :reimbursement_notes, :to_account_id
  	add_column :reimbursement_note_line_items, :expense_account_id, :integer, :null => false
  end

  def down
  end
end

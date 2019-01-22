class ReimbursementNoteLineItem < ActiveRecord::Migration
  def up
    create_table :reimbursement_note_line_items do |t|
      t.integer :reimbursement_note_id, :null => false
      t.text :description
      t.decimal :amount, :null => false, :precision => 18, :scale => 2, :default => 0

      t.timestamps
    end
  end

  def down
    drop_table :reimbursement_note_line_items
  end
end

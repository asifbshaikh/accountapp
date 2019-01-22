class ReimbursementNote < ActiveRecord::Migration
  def up
    create_table :reimbursement_notes do |t|
      t.integer :company_id, :null => false
      t.string :reimbursement_note_number, :null => false
      t.date :transaction_date, :null => false
      t.integer :from_account_id, :null => false
      t.integer :to_account_id, :null => false
      t.integer :branch_id
      t.text :description
      t.decimal :amount, :null => false, :precision => 18, :scale => 2, :default => 0
      t.boolean :submitted, :default => false
      t.integer :created_by, :null => false
      t.boolean :deleted, :default => false
      t.integer :deleted_by
      t.datetime :deleted_datetime
      t.string :deleted_reason
      t.integer :restored_by
      t.datetime :restored_datetime

      t.timestamps
    end
  end

  def down
    drop_table :reimbursement_notes
  end
end

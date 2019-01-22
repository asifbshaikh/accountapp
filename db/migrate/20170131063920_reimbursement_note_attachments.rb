class ReimbursementNoteAttachments < ActiveRecord::Migration
  def up
    create_table :reimbursement_note_attachments do |t|
      t.integer :company_id, :null => false
      t.integer :user_id, :null => false
      t.string :reimbursement_note_id, :null => false
      t.string :uploaded_file_file_name
      t.string :uploaded_file_content_type
      t.integer :uploaded_file_file_size
      t.datetime  :uploaded_file_updated_at
      t.timestamps
    end
  end

  def down
    drop_table :reimbursement_note_attachments
  end
end

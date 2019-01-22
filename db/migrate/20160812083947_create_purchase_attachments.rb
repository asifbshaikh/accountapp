class CreatePurchaseAttachments < ActiveRecord::Migration
  def change
    create_table :purchase_attachments do |t|
 
	  t.integer :company_id, :null => false
      t.integer :user_id, :null => false
      t.string :purchase_id, :null => false
      t.string :uploaded_file_file_name
   	  t.string :uploaded_file_content_type
      t.integer :uploaded_file_file_size
      t.datetime  :uploaded_file_updated_at
      t.timestamps

    end
  end
end

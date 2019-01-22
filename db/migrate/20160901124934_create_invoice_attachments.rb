class CreateInvoiceAttachments < ActiveRecord::Migration
  def change
    create_table :invoice_attachments do |t|
      t.integer :company_id, :null => false
      t.integer :created_by, :null => false
      t.string :invoice_id, :null => false
      t.string :uploaded_file_file_name
   	  t.string :uploaded_file_content_type
      t.integer :uploaded_file_file_size
      t.datetime  :uploaded_file_updated_at
      t.timestamps
    end
  end
end

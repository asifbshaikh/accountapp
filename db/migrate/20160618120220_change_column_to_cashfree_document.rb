class ChangeColumnToCashfreeDocument < ActiveRecord::Migration
  def up
  	rename_column :cashfree_documents, :file_file_name,:uploaded_file_one_file_name 
  	rename_column :cashfree_documents, :file_content_type,:uploaded_file_one_content_type
  	rename_column :cashfree_documents, :file_file_size,:uploaded_file_one_file_size
  	rename_column :cashfree_documents, :file_updated_at,:uploaded_file_one_updated_at 
 end


  def down
  	 
end
  	 
end
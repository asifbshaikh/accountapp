class AddColumnsToCasfreeDocument < ActiveRecord::Migration
  def change
  	add_column :cashfree_documents,:uploaded_file_two_file_name ,:string
  	add_column :cashfree_documents, :uploaded_file_two_content_type, :string
  	add_column :cashfree_documents, :uploaded_file_two_file_size, :integer
  	add_column :cashfree_documents, :uploaded_file_two_updated_at ,:datetime

  	add_column :cashfree_documents, :uploaded_file_three_file_name , :string
  	add_column :cashfree_documents, :uploaded_file_three_content_type, :string
  	add_column :cashfree_documents, :uploaded_file_three_file_size, :integer
  	add_column :cashfree_documents, :uploaded_file_three_updated_at ,:datetime



  end
end

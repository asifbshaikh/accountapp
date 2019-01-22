class CreateCashfreeDocument < ActiveRecord::Migration
  def change
    create_table :cashfree_documents do |t|

    	t.integer :company_id
    	t.integer :created_by
    	t.string :file_file_name
    	t.string :file_content_type
    	t.integer :file_file_size
    	t.datetime :file_updated_at
    	
      t.timestamps
    end
  end
end

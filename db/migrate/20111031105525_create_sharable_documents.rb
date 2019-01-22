class CreateSharableDocuments < ActiveRecord::Migration
  def self.up
    create_table :sharable_documents do |t|
      t.integer :company_id
      t.integer :user_id
      t.integer :folder_id
      t.timestamps
    end
    add_index :sharable_documents, :user_id
    add_index :sharable_documents, :folder_id
  end

  def self.down
    drop_table :sharable_documents
  end
end

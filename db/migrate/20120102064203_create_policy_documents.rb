class CreatePolicyDocuments < ActiveRecord::Migration
  def self.up
    create_table :policy_documents do |t|
      t.integer :company_id, :null => false
      t.integer :user_id, :null => false

      t.timestamps
    end
    add_index :policy_documents, :user_id
    add_index :policy_documents, :company_id
  end

  def self.down
    drop_table :policy_documents
  end
end

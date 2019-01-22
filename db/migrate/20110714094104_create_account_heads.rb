class CreateAccountHeads < ActiveRecord::Migration
  def self.up
    create_table :account_heads do |t|
      t.integer :company_id, :null => false
      t.integer :parent_id
      t.string :name, :null => false
      t.string :desc
      t.string :relevance, :limit => 100
      t.integer :created_by, :null => false
      t.integer :approved_by	
      t.boolean :deleted, :default => false
      t.integer :deleted_by
      t.datetime :deleted_datetime
      t.string :deleted_reason
      t.integer :restored_by
      t.datetime :restored_datetime
      t.timestamps
    end
  end

  def self.down
    drop_table :account_heads
  end
end

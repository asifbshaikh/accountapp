class CreateBranches < ActiveRecord::Migration
  def self.up
    create_table :branches do |t|
      t.integer :company_id, :null => false
      t.string :name, :null => false
      t.string :phone, :limit => 15
      t.string :fax, :limit => 15
      t.integer :created_by, :null => false
      t.boolean :deleted, :null=> false, :default => false
    
      t.timestamps

    end
  end

  def self.down
    drop_table :branches
  end
end

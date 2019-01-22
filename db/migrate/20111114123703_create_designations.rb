class CreateDesignations < ActiveRecord::Migration
  def self.up
    create_table :designations do |t|
      t.integer :company_id, :null => false
      t.string :title, :null => false
      t.text :description, :limit => 500
      t.timestamps
    end
  end

  def self.down
    drop_table :designations
  end
end

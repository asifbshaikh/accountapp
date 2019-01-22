class CreateMasterObjectives < ActiveRecord::Migration
  def self.up
    create_table :master_objectives do |t|
      t.integer :company_id, :null => false
      t.integer :department_id, :null => false
      t.integer :created_by, :null => false
      t.string :objective_name
      t.text :details
 
      t.timestamps
    end
  end

  def self.down
    drop_table :master_objectives
  end
end

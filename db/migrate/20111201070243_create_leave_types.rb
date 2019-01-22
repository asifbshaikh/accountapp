class CreateLeaveTypes < ActiveRecord::Migration
  def self.up
    create_table :leave_types do |t|
      t.integer :company_id, :null => false
      t.integer :created_by, :null => false
      t.string :leave_type
      t.integer :allowed_leaves
      t.text :description
      

      t.timestamps
    end
  end

  def self.down
    drop_table :leave_types
  end
end

class CreateLeaves < ActiveRecord::Migration
  def self.up
    create_table :leaves do |t|
      t.integer :company_id, :null => false
      t.integer :user_id, :null => false
      t.integer :leave_type_id, :null => false
      t.date :year
      t.integer :leaves_count
      t.integer :leaves_utilized

      t.timestamps
    end
  end

  def self.down
    drop_table :leaves
  end
end

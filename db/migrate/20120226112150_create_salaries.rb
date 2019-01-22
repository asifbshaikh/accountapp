class CreateSalaries < ActiveRecord::Migration
  def self.up
    create_table :salaries do |t|
      t.integer :company_id, :null => false
      t.integer :user_id, :null => false
      t.integer :attendance_id, :null => false
      t.integer :payhead_id, :null => false
      t.decimal :amount, :precision=> 18, :scale=>2
      t.date :month

      t.timestamps
    end
  end

  def self.down
    drop_table :salaries
  end
end

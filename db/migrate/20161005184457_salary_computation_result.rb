class SalaryComputationResult < ActiveRecord::Migration
  def self.up
    create_table :salary_computation_results do |t|
      t.integer :company_id, :null => false, :index => true
      t.integer :user_id, :null=> false, :index => true
      t.integer :attendance_id, :null => false
      t.integer :payhead_id, :null => false
      t.decimal :amount, precision: 18, scale: 2
      t.date :month, :null=> false, :index => true
      t.integer :processed_by
      t.integer :status, :null => false, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :salary_computation_results
  end
end

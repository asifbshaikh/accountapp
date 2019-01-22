class CreateSalaryStructures < ActiveRecord::Migration
  def self.up
    create_table :salary_structures do |t|
      
      t.integer :company_id
      t.integer :for_employee
      t.integer :created_by
      t.integer :pay_head
      t.integer :pay_head_type
      t.date :effective_from_date
      t.decimal :amount, :precision => 18, :scale=> 2
      t.decimal :total, :precision => 18, :scale => 2
      

      t.timestamps
    end
  end

  def self.down
    drop_table :salary_structures
  end
end

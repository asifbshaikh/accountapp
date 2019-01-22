class CreateSalaryStructureHistories < ActiveRecord::Migration
  def self.up
    create_table :salary_structure_histories do |t|
      t.integer :salary_structure_id
      t.integer :company_id
      t.integer :for_employee
      t.integer :created_by
      t.date :effective_from_date
      t.date :updated_on_date

      t.timestamps
    end
  end

  def self.down
    drop_table :salary_structure_histories
  end
end

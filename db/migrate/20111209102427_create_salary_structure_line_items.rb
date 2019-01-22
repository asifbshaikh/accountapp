class CreateSalaryStructureLineItems < ActiveRecord::Migration
  def self.up
    create_table :salary_structure_line_items do |t|
      t.integer :salary_structure_id, :null => false
      t.integer :payhead_id, :null => false
      t.decimal :amount, :precision => 18, :scale => 2, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :salary_structure_line_items
  end
end

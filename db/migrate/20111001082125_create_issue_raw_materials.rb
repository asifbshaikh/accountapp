class CreateIssueRawMaterials < ActiveRecord::Migration
  def self.up
    create_table :issue_raw_materials do |t|
      t.integer :company_id, :null => false
      t.integer :inventory_id, :null => false
      t.integer :issued_to, :null => false
      t.date :issue_date
      t.integer :quantity

      t.timestamps
    end
  end

  def self.down
    drop_table :issue_raw_materials
  end
end

class CreateProjects < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
      t.integer :company_id, :null => false
      t.integer :created_by, :null => false
      t.string :name
      t.date :start_date
      t.date :end_date
      t.decimal :estimated_cost, :precision => 18, :scale => 2, :default => 0
      t.text :description
      t.boolean :status, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :projects
  end
end

class CreateSupports < ActiveRecord::Migration
  def self.up
    create_table :supports do |t|
      t.integer :company_id, :null => false
      t.string :subject
      t.text :description
      t.integer :created_by, :null => false
      t.date :created_date
      t.string :assigned_to
      t.integer :status_id, :null => false
      t.date :completed_date
      t.string :ticket_number, :null => false
      t.boolean :deleted, :default => false
      t.integer :deleted_by
      t.datetime :deleted_datetime
      t.string :deleted_reason
      t.integer :restored_by
      t.datetime :restored_datetime
      
      t.timestamps
    end
  end

  def self.down
    drop_table :supports
  end
end

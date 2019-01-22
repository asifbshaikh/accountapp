class CreateEstimates < ActiveRecord::Migration
  def self.up
    create_table :estimates do |t|
      t.integer :company_id, :null => false
      t.integer :account_id, :null => false
      t.integer :created_by, :null => false
      t.string :estimate_number
      t.date :estimate_date, :null => false
      t.text :customer_notes
      t.text :terms_and_conditions
      t.string :status
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
    drop_table :estimates
  end
end

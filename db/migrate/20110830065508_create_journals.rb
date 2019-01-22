class CreateJournals < ActiveRecord::Migration
  def self.up
    create_table :journals do |t|
      t.integer :company_id, :null => false
      t.integer :account_id, :null => false
      t.integer :created_by, :null => false
      t.date :date
      t.string :voucher_number, :limit => 25
      t.text :description
      t.string :tags
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
    drop_table :journals
  end
end

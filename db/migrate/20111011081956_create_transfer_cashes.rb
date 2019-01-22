class CreateTransferCashes< ActiveRecord::Migration
  def self.up
    create_table :transfer_cashes do |t|
      t.integer :company_id, :null => false
      t.integer :created_by, :null => false
      t.date :transaction_date, :null => false
      t.decimal :amount, :precision => 18, :scale => 2, :default => 0
      t.integer :transferred_from_id, :null => false
      t.integer :transferred_to_id, :null => false
      t.string :description
      t.string :voucher_number
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
    drop_table :transfer_cashes
  end
end

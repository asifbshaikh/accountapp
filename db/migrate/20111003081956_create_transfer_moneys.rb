class CreateTransferMoneys < ActiveRecord::Migration
  def self.up
    create_table :transfer_moneys do |t|
      t.integer :company_id, :null => false
			t.string :voucher_number, :null => false 
      t.date :transaction_date, :null => false
      t.decimal :amount, :precision => 18, :scale => 2, :null => false, :default => 0
      t.integer :from_account_id, :null => false
      t.integer :to_account_id, :null => false
      t.string :description
      t.integer :created_by, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :transfer_moneys
  end
end

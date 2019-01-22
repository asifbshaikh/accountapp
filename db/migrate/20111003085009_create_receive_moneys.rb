class CreateReceiveMoneys < ActiveRecord::Migration
  def self.up
    create_table :receive_moneys do |t|
      t.integer :company_id
			t.string :voucher_number, :null => false
      t.date :received_date, :null => false
      t.decimal :amount, :precision => 18, :scale => 2, :null => false, :default => 0
      t.string :receipt_mode
      t.integer :from_account_id, :null => false
      t.integer :deposit_to_account_id, :null => false
      t.string :description
      t.binary :send_thank_you_mail
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :receive_moneys
  end
end

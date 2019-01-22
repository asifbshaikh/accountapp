class CreateMakePayments < ActiveRecord::Migration
  def self.up
    create_table :make_payments do |t|
      t.date :payment_date
      t.decimal :amount, :precision => 10, :scale => 2
      t.string :payment_mode
      t.integer :from_account_id
      t.integer :paid_to_account_id
      t.string :bill_ref
      t.string :description
      t.binary :send_notification
      t.integer :company_id
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :make_payments
  end
end

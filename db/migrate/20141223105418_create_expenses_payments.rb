class CreateExpensesPayments < ActiveRecord::Migration
  def change
    create_table :expenses_payments do |t|
      t.integer :payment_voucher_id
      t.integer :expense_id
      t.decimal :amount, :scale=>2, :precision=>18, :default=>0
      t.decimal :tds_amount, :scale=>2, :precision=>18, :default=>0
      t.boolean :deleted, :default=>false

      t.timestamps
    end
  end
end

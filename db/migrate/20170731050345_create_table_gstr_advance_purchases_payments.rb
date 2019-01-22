class CreateTableGstrAdvancePurchasesPayments < ActiveRecord::Migration
  def change
    create_table :gstr_advance_purchases_payments do |t|
      t.integer :gstr_advance_payment_id
      t.integer :purchase_id
      t.decimal :amount, :scale=>2, :precision=>18, :default=>0
      t.boolean :deleted, :default=>false

      t.timestamps
    end
  end
end

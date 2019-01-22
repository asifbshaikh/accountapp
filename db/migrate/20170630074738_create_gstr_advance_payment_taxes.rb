class CreateGstrAdvancePaymentTaxes < ActiveRecord::Migration
  def change
    
  	create_table :gstr_advance_payment_taxes do |t|
      t.integer :gstr_advance_payment_line_item_id
      t.integer :account_id

      t.timestamps
  end
  end
end

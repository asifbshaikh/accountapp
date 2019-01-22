class CreateGstrAdvancePaymentHistories < ActiveRecord::Migration
  def change
    create_table :gstr_advance_payment_histories do |t|
  		t.integer :gstr_advance_payment_id
  		t.integer :company_id
  		t.text :description
  		t.integer :created_by
  		t.datetime :payment_date
  		t.timestamps
  	end
  end
end

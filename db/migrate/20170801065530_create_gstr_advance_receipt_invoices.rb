class CreateGstrAdvanceReceiptInvoices < ActiveRecord::Migration
  def change
  	create_table :gstr_advance_receipt_invoices do |t|
  		t.integer :gstr_advance_receipt_id
  		t.integer :invoice_id
  		t.decimal :amount, :scale=>4 , :precision=>18, :null =>true
  		t.boolean :deleted, :default=>false

  		t.timestamps

  	end
  end

 
end

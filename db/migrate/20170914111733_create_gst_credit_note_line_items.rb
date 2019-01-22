class CreateGstCreditNoteLineItems < ActiveRecord::Migration
  def up
  	create_table :gst_credit_note_line_items do |t|
      t.integer :gst_credit_note_id
      t.integer :account_id
      t.integer :from_account_id, :null=>true
      t.decimal :quantity, :precision=>10, :scale=>2, :default=>0.0
      t.decimal :unit_rate, :precision=>18, :scale=>2, :default=>0.0
      t.boolean :tax, :default=>false
      t.decimal :amount, :precision=>18, :scale=>2, :default=>0.0
      t.string :line_type
      t.integer :product_id
      t.integer :tax_account_id
      t.decimal :discount_percent, :precision=>10, :scale=>2
      t.timestamps
    end
  end

  def down
  end
end

class CreateGstCreditAllocation < ActiveRecord::Migration
  def up
  	create_table :gst_credit_allocations do |t|
      t.integer :invoice_id, :null => false
      t.integer :gst_credit_note_id, :null => false
      t.decimal :amount, :precision => 18, :scale => 2, :default => 0, :null => false
      t.boolean :deleted, :default => 0
      t.timestamps
    end
  end

  def down
  end
end

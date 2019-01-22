class CreateInvoiceSettings < ActiveRecord::Migration
  def self.up
    create_table :invoice_settings do |t|
      t.integer :company_id, :null => false
      t.integer :invoice_sequence, :default => 0
      t.integer :invoice_no_strategy, :null => false, :default => 0
      t.string :invoice_prefix, :null => true
      t.timestamps
    end
  end

  def self.down
    drop_table :invoice_settings
  end
end

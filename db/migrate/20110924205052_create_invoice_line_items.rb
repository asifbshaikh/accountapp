class CreateInvoiceLineItems < ActiveRecord::Migration
  def self.up
    create_table :invoice_line_items do |t|
      t.integer :invoice_id, :null => false
      t.integer :account_id, :null => false
      t.decimal :quantity, :precision => 10, :scale => 2
      t.decimal :unit_rate, :precision => 18, :scale => 2
      t.decimal :discount_percent, :precision => 4, :scale => 2
      t.string :cost_center
      t.decimal :tax
      t.decimal :amount, :precision => 18, :scale => 2, :default => 0
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :invoice_line_items
  end
end

class CreateBillingLineItems < ActiveRecord::Migration
  def self.up
    create_table :billing_line_items do |t|
      t.integer :company_id, :null => false
      t.integer :billing_invoice_id, :null => false
      t.string :line_item, :null => false
      t.decimal :amount, :precision => 18, :scale => 2, :default => 0
    end
  end

  def self.down
    drop_table :billing_line_items
  end
end

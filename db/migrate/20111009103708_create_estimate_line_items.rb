class CreateEstimateLineItems < ActiveRecord::Migration
  def self.up
    create_table :estimate_line_items do |t|
      t.integer :estimate_id, :null => false
      t.integer :account_id, :null => false
      t.decimal :quantity, :precision => 10, :scale => 2
      t.decimal :unit_rate, :precision => 18, :scale => 2
      t.decimal :discount, :precision => 4, :scale => 2
      t.decimal :tax
      t.decimal :amount, :precision => 18, :scale => 2, :default => 0
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :estimate_line_items
  end
end

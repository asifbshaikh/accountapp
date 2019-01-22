class AddSettledAmountToPurchases < ActiveRecord::Migration
  def change
    add_column :purchases, :settled_amount, :decimal, :precision => 18, :scale => 2, :default => 0.00
  end
end

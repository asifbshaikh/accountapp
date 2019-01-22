class AddColumnToPurchases < ActiveRecord::Migration
  def change
    add_column :purchases, :total_amount, :decimal,:precision => 18, :scale => 2, :default => 0
  end
end

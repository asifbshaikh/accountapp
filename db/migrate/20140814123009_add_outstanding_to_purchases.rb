class AddOutstandingToPurchases < ActiveRecord::Migration
  def change
    add_column :purchases, :outstanding, :decimal, :precision => 18, :scale => 2
  end
end

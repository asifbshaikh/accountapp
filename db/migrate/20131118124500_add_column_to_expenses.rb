class AddColumnToExpenses < ActiveRecord::Migration
  def change
    add_column :expenses, :total_amount, :decimal,:precision => 18, :scale => 2, :default => 0
  end
end

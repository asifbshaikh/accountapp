class AddCorrelateToLedgers < ActiveRecord::Migration
  def change
    add_column :ledgers, :correlate, :string
  end
end

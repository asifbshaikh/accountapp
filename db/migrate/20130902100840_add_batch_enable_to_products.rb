class AddBatchEnableToProducts < ActiveRecord::Migration
  def change
    add_column :products, :batch_enable, :boolean, :default => false
  end
end

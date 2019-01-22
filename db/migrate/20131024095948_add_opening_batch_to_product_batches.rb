class AddOpeningBatchToProductBatches < ActiveRecord::Migration
  def change
    add_column :product_batches, :opening_batch, :boolean, :default => false
  end
end

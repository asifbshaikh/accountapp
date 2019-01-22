class AddReferenceToProductBatches < ActiveRecord::Migration
  def change
    add_column :product_batches, :reference, :string
  end
end

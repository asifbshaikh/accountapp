class AddCompanyIdToProductBatches < ActiveRecord::Migration
  def change
    add_column :product_batches, :company_id, :integer
  end
end

class AddProductIdToEstimateLineItems < ActiveRecord::Migration
  def self.up
    add_column :estimate_line_items, :product_id, :integer
  end

  def self.down
    remove_column :estimate_line_items, :product_id
  end
end

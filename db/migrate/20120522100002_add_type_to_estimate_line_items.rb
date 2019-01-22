class AddTypeToEstimateLineItems < ActiveRecord::Migration
  def self.up
    add_column :estimate_line_items, :type, :string
  end

  def self.down
    remove_column :estimate_line_items, :type
  end
end

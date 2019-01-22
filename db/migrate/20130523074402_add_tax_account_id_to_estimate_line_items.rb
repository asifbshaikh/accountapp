class AddTaxAccountIdToEstimateLineItems < ActiveRecord::Migration
  def self.up
    add_column :estimate_line_items, :tax_account_id, :integer
  end

  def self.down
    remove_column :estimate_line_items, :tax_account_id
  end
end

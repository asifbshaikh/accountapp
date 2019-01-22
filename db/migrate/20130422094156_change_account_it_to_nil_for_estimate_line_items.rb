class ChangeAccountItToNilForEstimateLineItems < ActiveRecord::Migration
  def self.up
    change_column_null :estimate_line_items, :account_id, true
  end

  def self.down
    change_column_null :estimate_line_items, :account_id, false
  end
end

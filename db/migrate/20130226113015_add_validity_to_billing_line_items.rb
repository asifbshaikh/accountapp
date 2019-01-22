class AddValidityToBillingLineItems < ActiveRecord::Migration
  def self.up
    add_column :billing_line_items, :validity, :decimal, :precision => 10, :scale => 2
  end

  def self.down
    remove_column :billing_line_items, :validity
  end
end

class AddStatusIdToPurchases < ActiveRecord::Migration
  def self.up
    add_column :purchases, :status_id, :integer
  end

  def self.down
    remove_column :purchases, :status_id
  end
end

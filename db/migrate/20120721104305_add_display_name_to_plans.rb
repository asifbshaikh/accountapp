class AddDisplayNameToPlans < ActiveRecord::Migration
  def self.up
    add_column :plans, :display_name, :string
  end

  def self.down
    remove_column :plans, :display_name
  end
end

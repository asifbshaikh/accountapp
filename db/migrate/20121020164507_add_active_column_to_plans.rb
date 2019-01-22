class AddActiveColumnToPlans < ActiveRecord::Migration
  def self.up
    add_column :plans, :active, :boolean, :default => false
  end

  def self.down
    remove_column :plans, :active
  end
end

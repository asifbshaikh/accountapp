class AddOptionalToPayheads < ActiveRecord::Migration
  def self.up
    add_column :payheads, :optional, :boolean, :default=> false
  end

  def self.down
    remove_column :payheads, :optional
  end
end

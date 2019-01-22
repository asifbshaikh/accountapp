class AddCarryToLeaveTypes < ActiveRecord::Migration
  def self.up
    add_column :leave_types, :carry, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :leave_types, :carry
  end
end

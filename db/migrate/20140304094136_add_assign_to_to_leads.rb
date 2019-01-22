class AddAssignToToLeads < ActiveRecord::Migration
  def self.up
    add_column :leads, :assigned_to, :integer
  end

  def self.down
    remove_column :leads, :assigned_to
  end
end

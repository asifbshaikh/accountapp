class AddDeletedColumnsToLeads < ActiveRecord::Migration
  def self.up
    add_column :leads, :deleted, :boolean, :default => false
    add_column :leads, :deleted_by, :integer
    add_column :leads, :deleted_reason, :integer
    add_column :leads, :converted_comment, :integer
    add_column :leads, :converted_by, :integer
  end

  def self.down
    remove_column :leads, :converted_by
    remove_column :leads, :converted_comment
    remove_column :leads, :deleted_reason
    remove_column :leads, :deleted_by
    remove_column :leads, :deleted
  end
end

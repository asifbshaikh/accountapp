class AddNewColumnsToLeads < ActiveRecord::Migration
 def self.up
    add_column :leads, :stage, :integer
    add_column :leads, :trial_status, :integer
    add_column :leads, :paid_status, :integer
    add_column :leads, :segment, :text
    add_column :leads, :source, :text
   end

  def self.down
    remove_column :leads, :stage
    remove_column :leads, :trial_status
    remove_column :leads, :paid_status
    remove_column :leads, :segment
    remove_column :leads, :source
   end
end

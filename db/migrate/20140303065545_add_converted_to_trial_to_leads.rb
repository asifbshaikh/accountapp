class AddConvertedToTrialToLeads < ActiveRecord::Migration
 def self.up
    add_column :leads, :converted_to_trial, :boolean, :default => false
  end

  def self.down
    remove_column :leads, :converted_to_trial
  end
end

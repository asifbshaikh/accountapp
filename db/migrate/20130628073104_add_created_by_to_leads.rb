class AddCreatedByToLeads < ActiveRecord::Migration
  def self.up
    add_column :leads, :created_by, :Integer
  end

  def self.down
    remove_column :leads, :created_by
  end
end

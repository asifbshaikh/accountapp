class AddFieldToLeads < ActiveRecord::Migration
  def self.up
    add_column :leads, :city, :string
    add_column :leads, :organisation_name, :string
    add_column :leads, :notes, :text
  end

  def self.down
    remove_column :leads, :notes
    remove_column :leads, :organisation_name
    remove_column :leads, :city
  end
end

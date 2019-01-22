class AddStatusToCustomFields < ActiveRecord::Migration
  def self.up
    add_column :custom_fields, :status, :boolean, :default => 0
  end

  def self.down
    remove_column :custom_fields, :status
  end
end

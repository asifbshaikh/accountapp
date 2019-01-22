class AddResolutionDescriptionToSupports < ActiveRecord::Migration
  def self.up
    add_column :supports, :resolution_description, :text
  end

  def self.down
    remove_column :supports, :resolution_description
  end
end

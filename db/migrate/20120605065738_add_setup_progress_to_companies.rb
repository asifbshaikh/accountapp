class AddSetupProgressToCompanies < ActiveRecord::Migration
  def self.up
    add_column :companies, :setup_progress, :integer
  end

  def self.down
    remove_column :companies, :setup_progress
  end
end

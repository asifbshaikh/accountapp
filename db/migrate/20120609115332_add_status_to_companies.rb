class AddStatusToCompanies < ActiveRecord::Migration
  def self.up
    add_column :companies, :status, :integer
  end

  def self.down
    remove_column :companies, :status
  end
end

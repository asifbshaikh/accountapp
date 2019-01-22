class AddWaterMarkToCompanies < ActiveRecord::Migration
  def self.up
    add_column :companies, :watermark, :string, :default => "Generated from www.profitbooks.net" ,:limit => 150
  end

  def self.down
    remove_column :companies, :watermark
  end
end

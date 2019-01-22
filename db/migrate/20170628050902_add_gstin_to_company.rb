class AddGstinToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :GSTIN, :string, :limit => 15
  end
end

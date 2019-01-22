class AddTypeColumnToLeads < ActiveRecord::Migration
  def change
    add_column :leads, :type, :integer
  end
end

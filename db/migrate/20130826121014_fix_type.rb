class FixType < ActiveRecord::Migration
  def up
  rename_column :leads, :type, :lead_type
  end

  def down
  end
end

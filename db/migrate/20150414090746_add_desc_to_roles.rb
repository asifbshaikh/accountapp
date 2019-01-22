class AddDescToRoles < ActiveRecord::Migration

  def change
    add_column :roles, :desc, :text
  end
end

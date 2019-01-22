class AddPrefixAndMiddleNameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :prefix, :string
    add_column :users, :middle_name, :string
  end
end

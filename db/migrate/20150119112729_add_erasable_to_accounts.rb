class AddErasableToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :erasable, :boolean, :default=>true
  end
end

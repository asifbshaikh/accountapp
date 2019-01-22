class ChangeAccountIdToNullForProducts < ActiveRecord::Migration
  def self.up
    change_column_null :products, :account_id, true
  end

  def self.down
    change_column_null :products, :account_id, false
  end
end

class AddActionToWorkstream < ActiveRecord::Migration
  def self.up
    add_column :workstreams, :action_code, :string
  end

  def self.down
    remove_column :workstreams, :action_code
  end
end

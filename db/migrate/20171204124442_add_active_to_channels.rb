class AddActiveToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :active, :boolean, default: false
  end
end

class CreateCurrentAssets < ActiveRecord::Migration
  def self.up
    create_table :current_assets do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :current_assets
  end
end

class CreateOtherCurrentAssets < ActiveRecord::Migration
  def self.up
    create_table :other_current_assets do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :other_current_assets
  end
end

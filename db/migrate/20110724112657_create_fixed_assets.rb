class CreateFixedAssets < ActiveRecord::Migration
  def self.up
    create_table :fixed_assets do |t|
      t.boolean :depreciable
      t.decimal :depreciation_rate, :precision => 8, :scale => 2, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :fixed_assets
  end
end

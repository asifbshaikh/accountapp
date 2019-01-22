class CreateHelps < ActiveRecord::Migration
  def self.up
    create_table :helps do |t|
      t.string :screen_name
      t.integer :screen_id
      t.string :help

      t.timestamps
    end
  end

  def self.down
    drop_table :helps
  end
end

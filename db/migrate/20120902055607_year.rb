class Year < ActiveRecord::Migration
  def self.up
    create_table :years do |t|
      t.string  :name, :null => false
      t.date :start_date, :null => false
      t.date :end_date, :null => false
    end
  end

  def self.down
    drop_table :years
  end
end

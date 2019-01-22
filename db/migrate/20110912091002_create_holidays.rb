class CreateHolidays < ActiveRecord::Migration
  def self.up
    create_table :holidays do |t|
      t.date :holiday_date, :null => false
      t.string :holiday, :null => false
      t.text :description, :limit => 500
      t.integer :created_by, :null => false
      t.integer :company_id, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :holidays
  end
end

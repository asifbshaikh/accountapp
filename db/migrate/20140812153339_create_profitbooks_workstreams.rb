class CreateProfitbooksWorkstreams < ActiveRecord::Migration
  def change
    create_table :profitbooks_workstreams do |t|
      t.integer :feature_id, :null => false
      t.string :icon_code, :null => false, :limit => 150
      t.date :release_date, :null => false
      t.string :title, :null => false
      t.text :details
      t.string :link_URL, :null => true
      t.integer :created_by, :null => false, :limit => 2
      t.integer :status, :null => false, :limit =>1
    end
  end
end

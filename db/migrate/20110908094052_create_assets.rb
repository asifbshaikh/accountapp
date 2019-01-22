class CreateAssets < ActiveRecord::Migration
  def self.up
    create_table :assets do |t|
      t.integer :company_id, :null => false
      t.integer :user_id, :null => false
      t.string :asset_tag
      t.text :description, :limit => 500
      t.date :purchase_date
      

      t.timestamps
    end
  end

  def self.down
    drop_table :assets
  end
end

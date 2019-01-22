class CreateGsps < ActiveRecord::Migration
  def change
    create_table :gsps do |t|
      t.string :name, :null => false
      t.string :url, :null => false
      t.string :env, :null => false, :limit => 150
      t.string :version, :null => false, :limit => 25
      t.timestamps
    end
  end
end

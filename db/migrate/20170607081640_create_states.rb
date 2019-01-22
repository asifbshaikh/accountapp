class CreateStates < ActiveRecord::Migration
  def change
    create_table :states do |t|
      t.integer :country_id, :null => false, :size => 4
      t.string :code, :null => false, :size => 4
      t.string :name, :null => false
      t.string :state_type, :null => false, :size => 50
    end
  end
end

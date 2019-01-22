class AddStateCodeToAddress < ActiveRecord::Migration
  def change
  	add_column :addresses, :state_code ,:string, :null=>true
  end
end

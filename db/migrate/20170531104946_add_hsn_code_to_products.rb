class AddHsnCodeToProducts < ActiveRecord::Migration
  def change
  	add_column :products, :hsn_code, :string
  end
end

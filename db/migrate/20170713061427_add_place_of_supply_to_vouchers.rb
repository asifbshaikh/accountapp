class AddPlaceOfSupplyToVouchers < ActiveRecord::Migration
  def change
  	add_column :estimates, :place_of_supply, :string, :limit => 3
  end
end

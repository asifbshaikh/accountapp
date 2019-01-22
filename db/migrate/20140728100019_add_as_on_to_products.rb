class AddAsOnToProducts < ActiveRecord::Migration
  def change
    add_column :products, :as_on, :date
  end
end

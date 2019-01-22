class AddCurrencyIdToVendors < ActiveRecord::Migration
  def change
    add_column :vendors, :currency_id, :integer
  end
end

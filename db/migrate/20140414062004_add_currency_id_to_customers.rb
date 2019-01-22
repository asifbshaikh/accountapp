class AddCurrencyIdToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :currency_id, :integer
  end
end

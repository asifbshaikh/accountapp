class AddStartDateToCustomerImports < ActiveRecord::Migration
  def change
    add_column :customer_imports, :start_date, :string, :limit => 15
  end
end

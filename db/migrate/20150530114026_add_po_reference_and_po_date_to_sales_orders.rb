class AddPoReferenceAndPoDateToSalesOrders < ActiveRecord::Migration
  def change
    add_column :sales_orders, :po_reference, :string
    add_column :sales_orders, :po_date, :date
  end
end

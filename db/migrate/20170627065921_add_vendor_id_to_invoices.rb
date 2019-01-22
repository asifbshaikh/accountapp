class AddVendorIdToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :vendor_id, :integer
  end
end

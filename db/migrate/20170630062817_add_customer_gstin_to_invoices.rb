class AddCustomerGstinToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :cash_customer_gstin, :string, :limit =>15
  end
end

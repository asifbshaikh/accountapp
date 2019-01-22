class AddGstExportFieldsinToInvoices < ActiveRecord::Migration
  def change
  	add_column :invoices, :sbpcode, :string, :limit =>6
  	add_column :invoices, :sbnum ,:string, :limit =>7
  	add_column :invoices, :sbdate,:date
  end
end

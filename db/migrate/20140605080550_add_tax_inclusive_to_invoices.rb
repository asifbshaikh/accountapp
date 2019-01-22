class AddTaxInclusiveToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :tax_inclusive, :boolean, :default => false
  end
end

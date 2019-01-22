class AddTaxAccountIdToInvoiceLineItems < ActiveRecord::Migration
  def self.up
    add_column :invoice_line_items, :tax_account_id, :integer
  end

  def self.down
    remove_column :invoice_line_items, :tax_account_id
  end
end

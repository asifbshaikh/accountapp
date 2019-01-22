class ChangeAccountIdToNullForInvoiceLineItems < ActiveRecord::Migration
  def self.up
    change_column_null :invoice_line_items, :account_id, true
  end

  def self.down
    change_column_null :invoice_line_items, :account_id, false
  end
end

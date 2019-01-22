class AddOpenedAndInvoiceReturnIdAndReadOnlyToCreditNotes < ActiveRecord::Migration
  def change
    add_column :credit_notes, :opened, :boolean, :default=>true
    add_column :credit_notes, :invoice_return_id, :integer
    add_column :credit_notes, :read_only, :boolean, :default=>false
  end
end

class AddTitleToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :voucher_title_id, :integer
  end
end

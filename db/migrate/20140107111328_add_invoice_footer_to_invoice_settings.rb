class AddInvoiceFooterToInvoiceSettings < ActiveRecord::Migration
  def change
    add_column :invoice_settings, :invoice_footer, :text
  end
end

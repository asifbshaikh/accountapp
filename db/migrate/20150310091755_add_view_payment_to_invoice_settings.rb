class AddViewPaymentToInvoiceSettings < ActiveRecord::Migration
  def change
    add_column :invoice_settings, :view_payment, :boolean, :default=>true
  end
end

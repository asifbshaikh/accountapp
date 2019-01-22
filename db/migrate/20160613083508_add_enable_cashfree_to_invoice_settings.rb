class AddEnableCashfreeToInvoiceSettings < ActiveRecord::Migration
  def change
  	  add_column :invoice_settings, :enable_cashfree, :boolean, :default=>false
  end
end

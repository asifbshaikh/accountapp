class AddEnableGatewayToInvoiceSettings < ActiveRecord::Migration
  def change
    add_column :invoice_settings, :enable_gateway, :boolean, :default=>false
  end
end

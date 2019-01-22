class AddCustomLabelColumnsToInvoiceSettings < ActiveRecord::Migration
  def self.up
    add_column :invoice_settings, :item_label, :string
    add_column :invoice_settings, :desc_label, :string
    add_column :invoice_settings, :qty_label, :string
    add_column :invoice_settings, :rate_label, :string
    add_column :invoice_settings, :discount_label, :string
    add_column :invoice_settings, :amount_label, :string
  end

  def self.down
    remove_column :invoice_settings, :item_label
    remove_column :invoice_settings, :desc_label
    remove_column :invoice_settings, :qty_label
    remove_column :invoice_settings, :rate_label
    remove_column :invoice_settings, :discount_label
    remove_column :invoice_settings, :amount_label
  end

end

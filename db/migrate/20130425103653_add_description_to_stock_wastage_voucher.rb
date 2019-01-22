class AddDescriptionToStockWastageVoucher < ActiveRecord::Migration
  def self.up
    add_column :stock_wastage_vouchers, :description, :text
  end

  def self.down
    remove_column :stock_wastage_vouchers, :description
  end
end

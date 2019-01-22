class CreateStockWastageVouchers < ActiveRecord::Migration
  def self.up
    create_table :stock_wastage_vouchers do |t|
      t.integer :company_id, :null => false
      t.integer :warehouse_id, :null => false
      t.string :voucher_number
      t.datetime :voucher_date
      t.integer :branch_id
      t.integer :created_by, :null => false
      t.boolean :deleted, :default => false
      t.integer :deleted_by
      t.string :deleted_reason

      t.timestamps
    end
  end

  def self.down
    drop_table :stock_wastage_vouchers
  end
end

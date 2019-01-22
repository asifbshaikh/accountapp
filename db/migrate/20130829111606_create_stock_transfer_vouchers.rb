class CreateStockTransferVouchers < ActiveRecord::Migration
  def change
    create_table :stock_transfer_vouchers do |t|
      t.integer :company_id, :null=> false
      t.integer :created_by, :null => false
      t.integer :warehouse_id, :null => false
      t.string :voucher_number, :null => false
      t.string :details
      t.date :transfer_date
      t.date :voucher_date
      t.integer :branch_id

      t.timestamps
    end
  end
end

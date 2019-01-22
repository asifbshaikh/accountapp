class CreateStockIssueVouchers < ActiveRecord::Migration
  def self.up
    create_table :stock_issue_vouchers do |t|
      t.integer :company_id, :null => false
      t.integer :warehouse_id
      t.string :voucher_number, :null => false
      t.date :voucher_date, :null => false
      t.integer :issued_to, :null => false
      t.integer :created_by, :null => false
      t.string :details

      t.timestamps
    end
  end

  def self.down
    drop_table :stock_issue_vouchers
  end
end

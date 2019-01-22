class ChangeColumnToStockIssueVouchers < ActiveRecord::Migration
  def self.up
    change_column_null :stock_issue_vouchers, :issued_to,  true
  end

  def self.down
    change_column_null :stock_issue_vouchers, :issued_to, false
  end
end

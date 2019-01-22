class CreateStockIssueVoucherSequences < ActiveRecord::Migration
  def change
    create_table :stock_issue_voucher_sequences do |t|
      t.integer :company_id, :null=>false
      t.integer :stock_issue_voucher_sequence, :default=>0

      t.timestamps
    end
  end
end

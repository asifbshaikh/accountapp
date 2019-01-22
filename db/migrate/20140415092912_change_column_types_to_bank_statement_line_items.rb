class ChangeColumnTypesToBankStatementLineItems < ActiveRecord::Migration
  def up
	change_column :bank_statement_line_items, :amount, :decimal, :precision => 18, :scale => 2
	change_column :bank_statement_line_items, :account_balance, :decimal, :precision => 18, :scale => 2
  end

  def down
  end
end

class AddAccountBalanceToBankStatementLineItems < ActiveRecord::Migration
  def change
	add_column :bank_statement_line_items, :account_balance, :decimal
  end
end

class AddLedgerIdToBankStatementLineItems < ActiveRecord::Migration
  def change
	add_column :bank_statement_line_items, :ledger_id, :integer
  end
end

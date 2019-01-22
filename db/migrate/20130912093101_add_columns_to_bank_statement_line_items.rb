class AddColumnsToBankStatementLineItems < ActiveRecord::Migration
  def self.up
  	add_column :bank_statement_line_items, :account_id, :integer
  	add_column :bank_statement_line_items, :credit_debit_indicator, :boolean
  	add_column :bank_statement_line_items, :company_id, :integer
  end
end

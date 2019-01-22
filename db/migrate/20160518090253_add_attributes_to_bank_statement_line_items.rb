class AddAttributesToBankStatementLineItems < ActiveRecord::Migration
  def change
  	add_column :bank_statement_line_items, :value_date, :date
  	add_column :bank_statement_line_items, :cheque_reference, :string
  end
end

class AddColumnsToBankStatements < ActiveRecord::Migration
  def self.up
  	add_column :bank_statements, :status, :integer
  	add_column :bank_statements, :account_id, :integer
  	add_column :bank_statements, :start_date, :datetime
  	add_column :bank_statements, :end_date, :datetime
  end
end

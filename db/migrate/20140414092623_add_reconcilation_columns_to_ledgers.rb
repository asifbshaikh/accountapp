class AddReconcilationColumnsToLedgers < ActiveRecord::Migration
  def change
	add_column :ledgers, :reconcilation_status, :boolean, :default=> false
	add_column :ledgers, :reconcilation_date, :date
  end
end

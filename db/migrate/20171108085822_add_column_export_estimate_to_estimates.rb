class AddColumnExportEstimateToEstimates < ActiveRecord::Migration
  def change
  	add_column :estimates, :export_estimate, :boolean, :default => false
  end
end

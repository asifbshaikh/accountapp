class AddCalcTypeToPayheads < ActiveRecord::Migration
  def change
    add_column :payheads, :calculation_type, :integer, :limit => 2, :null => true
  end
end

class DefaultValueReverseChargeInExpenses < ActiveRecord::Migration
  def up
  	change_column :expenses, :reverse_charge, :boolean, :default => false
  end

  def down
  	change_column :expenses, :reverse_charge, :boolean, :default => null
  end
end

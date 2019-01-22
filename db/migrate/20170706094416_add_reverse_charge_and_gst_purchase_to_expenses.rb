class AddReverseChargeAndGstPurchaseToExpenses < ActiveRecord::Migration
  def change
  	add_column :expenses, :gst_expense, :boolean, :default => false
  	add_column :expenses, :reverse_charge, :boolean, :default => false
  end
end

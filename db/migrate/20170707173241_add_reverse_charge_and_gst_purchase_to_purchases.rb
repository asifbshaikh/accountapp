class AddReverseChargeAndGstPurchaseToPurchases < ActiveRecord::Migration
  def change
  
  	add_column :purchases, :reverse_charge, :boolean, :default => false
  end
end

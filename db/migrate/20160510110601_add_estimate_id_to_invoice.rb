class AddEstimateIdToInvoice < ActiveRecord::Migration
  def change
     	add_column :invoices,:estimate_id,:integer
   end
end

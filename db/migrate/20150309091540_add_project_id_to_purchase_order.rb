class AddProjectIdToPurchaseOrder < ActiveRecord::Migration
  def change
    add_column :purchase_orders, :project_id, :integer
  end
end

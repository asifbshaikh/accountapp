class AddStatusIdToExpenses < ActiveRecord::Migration
  def change
    add_column :expenses, :status_id, :integer, :default=>1
  end
end

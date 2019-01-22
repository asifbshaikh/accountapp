class AddPaidToLeaveTypes < ActiveRecord::Migration
  def change
    add_column :leave_types, :paid, :boolean, :default=>true
  end
end

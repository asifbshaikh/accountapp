class AddDueDateToExpenses < ActiveRecord::Migration
  def change
    add_column :expenses, :due_date, :date
  end
end

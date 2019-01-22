class AddCreditExpenseToExpenses < ActiveRecord::Migration
  def change
    add_column :expenses, :credit_expense, :boolean, :default=>false
  end
end

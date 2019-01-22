class AddStartDateAndEndDateToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :start_date, :date
    add_column :accounts, :end_date, :date
  end
end
